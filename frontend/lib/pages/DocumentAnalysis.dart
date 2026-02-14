import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/history_service.dart';


class DocumentAnalysisPage extends StatefulWidget {
  const DocumentAnalysisPage({super.key});

  @override
  State<DocumentAnalysisPage> createState() => _DocumentAnalysisPageState();
}

class _DocumentAnalysisPageState extends State<DocumentAnalysisPage> {
  String _currentState = 'upload';
  Map<String, dynamic>? _analysisData;
  int? _expandedIndex;

  Future<String> uploadFileToStorage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // Use .pdf for files or .jpg for camera scans
    final extension = file.path.endsWith('.pdf') ? 'pdf' : 'jpg';
    final ref =
        FirebaseStorage.instance.ref().child("documents/$fileName.$extension");

    await ref.putFile(file);
    return ref.fullPath;
  }

  /*Future<void> _sendFileToBackend(File file) async {
    setState(() => _currentState = 'loading');

    try {
      final filePath = await uploadFileToStorage(file);

      // Save metadata to Firestore
      final docRef =
          await FirebaseFirestore.instance.collection("documents").add({
        "filePath": filePath,
        "status": "processing",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Call Firebase Function
      final result = await FirebaseFunctions.instance
          .httpsCallable('analyzeContract')
          .call({"documentId": docRef.id});

      setState(() {
        // Assume backend returns a Map with 'riskLevel', 'clauses', and 'summary'
        _analysisData = Map<String, dynamic>.from(result.data);
        _currentState = 'result';
      });

      //save history to firestore
      await HistoryService.saveHistory(
        type: "Document Analysis",
        summary:
            "${_analysisData?['documentName'] ?? 'Document'} — ${_analysisData?['riskLevel'] ?? 'Unknown Risk'}",
        metadata: {
          "riskLevel": _analysisData?['riskLevel'],
          "summary": _analysisData?['summary'],
          "clauses": _analysisData?['clauses'],
          "filePath": filePath,
        },
      );


    } catch (e) {
      setState(() => _currentState = 'upload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analysis failed: $e")),
      );
    }
  }*/

    Future<void> _sendFileToBackend(File file) async {
    setState(() => _currentState = 'loading');
    try {
      final filePath = await uploadFileToStorage(file);

      // Save metadata to Firestore
      final docRef = await FirebaseFirestore.instance.collection("documents").add({
        "filePath": filePath,
        "status": "processing",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Call Firebase Function
      final result = await FirebaseFunctions.instance
          .httpsCallable('analyzeContract')
          .call({"documentId": docRef.id});

      final data = Map<String, dynamic>.from(result.data);

      setState(() {
        _analysisData = data;
        _currentState = 'result';
      });

      // Save history to Firestore
      await HistoryService.saveHistory(
        type: "Document Analysis",
        summary: "Document ${docRef.id} — ${data['riskLevel'] ?? 'Unknown Risk'}",
        metadata: {
          "riskLevel": data['riskLevel'],
          "summary": data['summary'],
          "clauses": data['clauses'],
          "filePath": filePath,
        },
      );
    } catch (e) {
      setState(() => _currentState = 'upload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analysis failed: $e")),
      );
    }
  }


  Future<void> _pickPDFAndAnalyze() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      await _sendFileToBackend(File(result.files.single.path!));
    }
  }

  Future<void> _scanCameraAndAnalyze() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _sendFileToBackend(File(image.path));
    }
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
        title: const Text('Analyze Document'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          key: ValueKey(_currentState),
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case 'loading':
        return _buildLoadingState();
      case 'result':
        return _buildResultState();
      default:
        return _buildUploadState();
    }
  }

  // --- 1. UPLOAD STATE ---
  Widget _buildUploadState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFEDF2F7),
          child: Icon(LucideIcons.upload, size: 40, color: Color(0xFF1A1F2C)),
        ),
        const SizedBox(height: 20),
        const Text('Upload your legal document',
            style: TextStyle(fontSize: 16)),
        const Text('GUIDED BY CONTRACTS ACT 1950',
            style: TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickPDFAndAnalyze,
                icon: const Icon(LucideIcons.file),
                label: const Text('Upload PDF'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _scanCameraAndAnalyze,
                icon: const Icon(LucideIcons.camera),
                label: const Text('Camera Scan'),
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
        const Text('Analyzing your document...',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // --- 3. RESULT STATE ---
  Widget _buildResultState() {
    final String risk =
        _analysisData?['riskLevel']?.toString().toUpperCase() ?? 'UNKNOWN';
    final Color riskColor = risk == 'HIGH'
        ? Colors.red
        : (risk == 'MEDIUM' ? Colors.orange : Colors.green);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: riskColor, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Risk Level',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(risk,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: riskColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Risky Clauses Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_analysisData?['clauses'] != null)
          ...(_analysisData!['clauses'] as List).asMap().entries.map((entry) {
            return _buildClauseCard(
              entry.key,
              entry.value['title'] ?? 'Unknown Clause',
              entry.value['risk'] ?? 'Potential Risk detected',
              entry.value['legalRef'] ?? 'No reference available',
            );
          }).toList()
        else
          const Text("No significant risks found."),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _currentState = 'upload'),
          child: const Text('Analyze Another Document'),
        ),
      ],
    );
  }

  Widget _buildClauseCard(
      int index, String title, String risk, String legalRef) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _expandedIndex == index,
        leading: const Icon(LucideIcons.alertCircle, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(risk,
            style: const TextStyle(fontSize: 12, color: Colors.orange)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Relevant Legal Reference:',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(legalRef,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        onExpansionChanged: (val) =>
            setState(() => _expandedIndex = val ? index : null),
      ),
    );
  }
}
