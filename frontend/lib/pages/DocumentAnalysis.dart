import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

String _analysisResult = ""; // Variable to store the JS response



class DocumentAnalysisPage extends StatefulWidget {
  const DocumentAnalysisPage({super.key});

  @override
  State<DocumentAnalysisPage> createState() => _DocumentAnalysisPageState();
}

class _DocumentAnalysisPageState extends State<DocumentAnalysisPage> {
  
  Future<String> uploadFileToStorage(File file) async {
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child("documents/$fileName.pdf");

    await ref.putFile(file);

    return ref.fullPath;
  }

  Future<void> _sendFileToBackend(File file) async {
    setState(() => _currentState = 'loading');

    try {
      final filePath = await uploadFileToStorage(file);

      final docRef =
          await FirebaseFirestore.instance.collection("documents").add({
        "filePath": filePath,
        "status": "processing",
        "createdAt": FieldValue.serverTimestamp(),
      });

      final documentId = docRef.id;

      final result = await FirebaseFunctions.instance
          .httpsCallable('analyzeContract')
          .call({
        "documentId": documentId,
      });

      setState(() {
        _analysisResult = result.data['analysis'].toString();
        _currentState = 'result';
      });

    } catch (e) {
      setState(() => _currentState = 'upload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

      Future<void> _pickPDFAndAnalyze() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        await _sendFileToBackend(file);
      }
    }

  Future<void> _scanCameraAndAnalyze() async {
      final picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        File file = File(image.path);
        await _sendFileToBackend(file);
      }
    }


  // Inside _DocumentAnalysisPageState
  Future<void> _runRealAnalysis() async {


    setState(() => _currentState = 'loading');
    try {
      // Calling the JS export "analyzeContract"
      final result = await FirebaseFunctions.instance
          .httpsCallable('analyzeContract') 
          .call({'documentId': 'your_actual_doc_id'});

      setState(() {
        _analysisResult = result.data['analysis'] ?? "No data";
        _currentState = 'result';
      });
    } catch (e) {
      setState(() => _currentState = 'upload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backend Error: $e")),
      );
    }
  }

  String _currentState = 'upload'; // upload, loading, result
  int? _expandedIndex;

  void _startAnalysis() {
    setState(() => _currentState = 'loading');
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _currentState = 'result');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analyze Document',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF1A1F2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentState == 'upload') return _buildUploadState();
    if (_currentState == 'loading') return _buildLoadingState();
    return _buildResultState();
  }

  // --- 1. UPLOAD STATE ---
  Widget _buildUploadState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFEDF2F7),
          child: Icon(LucideIcons.upload,
              size: 40, color: Color(0xFF1A1F2C), semanticLabel: 'Upload Icon'),
        ),
        const SizedBox(height: 20),
        Text(
          'Upload your legal document',
          style: TextStyle(
              fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 4),
        Text(
          'GUIDED BY CONTRACTS ACT 1950',
          style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickPDFAndAnalyze, // 🔥 CHANGED FROM _startAnalysis
                icon: const Icon(LucideIcons.file),
                label: const Text('Upload PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F2C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _scanCameraAndAnalyze, // 🔥 CHANGED FROM _startAnalysis
                icon: const Icon(LucideIcons.camera),
                label: const Text('Camera Scan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1F2C),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. LOADING STATE ---
  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CircularProgressIndicator(color: Color(0xFF1A1F2C)),
        const SizedBox(height: 20),
        Text(
          'Analyzing your document...',
          style: TextStyle(color: Colors.grey[600], fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  // --- 3. RESULT STATE ---
  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk Level Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.alertTriangle,
                  color: Colors.orange, size: 24, semanticLabel: 'Risk Level'),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Analyze the risk level based on _analysisResult
                 /* _analysisResult.isEmpty
                      ? "No analysis result."
                      : _analysisResult,
                  style: const TextStyle(fontFamily: 'Poppins'),*/
                  Text(
                    'Risk Level',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Poppins'),
                  ),
                  Text(
                    'MEDIUM',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Clauses List
        const Text(
          'Risky Clauses Found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        _buildClauseCard(
          0,
          'Termination Clause',
          'Allows immediate termination without notice.',
          'Section 56 of Contracts Act 1950.',
        ),
        _buildClauseCard(
          1,
          'Indemnity Clause',
          'One-sided financial risk burden.',
          'Section 24 of Contracts Act 1950.',
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _currentState = 'upload'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF1A1F2C),
          ),
          child: const Text('Back to Upload',
              style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }

  Widget _buildClauseCard(
      int index, String title, String risk, String legalRef) {
    bool isExpanded = _expandedIndex == index;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: GlobalKey(),
        initiallyExpanded: isExpanded,
        leading: const Icon(LucideIcons.alertCircle, color: Colors.orange),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        subtitle: Text(risk,
            style: const TextStyle(
                fontSize: 12, color: Colors.orange, fontFamily: 'Poppins')),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Relevant Legal Reference:',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontFamily: 'Poppins'),
                ),
                Text(legalRef,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                const Text(
                  'Consult a lawyer before signing this document.',
                  style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
        ],
        onExpansionChanged: (val) {
          setState(() {
            _expandedIndex = val ? index : null;
          });
        },
      ),
    );
  }
}
