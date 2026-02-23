import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_functions/cloud_functions.dart';

import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/history_service.dart'; // adjust import path as needed


class DocumentAnalysisPage extends StatefulWidget {
  const DocumentAnalysisPage({super.key});

  @override
  State<DocumentAnalysisPage> createState() => _DocumentAnalysisPageState();
}

class _DocumentAnalysisPageState extends State<DocumentAnalysisPage> {
  String _currentState = 'upload';
  Map<String, dynamic>? _analysisData;
  int? _expandedIndex;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('app_language') ?? 'en';
    });
  }

  Future<String> uploadBytesToStorage(Uint8List bytes, String extension) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child("documents/$fileName.$extension");
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: extension == 'pdf' ? 'application/pdf' : 'image/jpeg',
      ),
    );
    return ref.fullPath;
  }

  Future<void> _sendBytesToBackend(Uint8List bytes, String extension) async {
    setState(() => _currentState = 'loading');

    try {
      final filePath = await uploadBytesToStorage(bytes, extension);

      final docRef = await FirebaseFirestore.instance.collection("documents").add({
        "filePath": filePath,
        "status": "processing",
        "createdAt": FieldValue.serverTimestamp(),
      });

      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('analyzeContract')
          .call({"documentId": docRef.id});

      final data = Map<String, dynamic>.from(result.data);

      setState(() {
        _analysisData = data;
        _currentState = 'result';
      });


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
        SnackBar(
          content: Text("Analysis failed: $e"),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _pickPDFAndAnalyze() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      await _sendBytesToBackend(result.files.single.bytes!, 'pdf');
    }
  }

  Future<void> _scanCameraAndAnalyze() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      await _sendBytesToBackend(result.files.single.bytes!, 'jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEn ? 'Analyze Document' : 'Analisis Dokumen'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          key: ValueKey(_currentState),
          padding: const EdgeInsets.all(24),
          child: _buildContent(isEn),
        ),
      ),
    );
  }

  Widget _buildContent(bool isEn) {
    switch (_currentState) {
      case 'loading':
        return _buildLoadingState(isEn);
      case 'result':
        return _buildResultState(isEn);
      default:
        return _buildUploadState(isEn);
    }
  }

  // --- 1. UPLOAD STATE ---
  Widget _buildUploadState(bool isEn) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFEDF2F7),
          child: Icon(LucideIcons.upload, size: 40, color: Color(0xFF1A1F2C)),
        ),
        const SizedBox(height: 20),
        Text(
          isEn
              ? 'Upload your legal document'
              : 'Muat naik dokumen undang-undang anda',
          style: const TextStyle(fontSize: 16),
        ),
        const Text(
          'GUIDED BY CONTRACTS ACT 1950',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickPDFAndAnalyze,
                icon: const Icon(LucideIcons.file),
                label: Text(isEn ? 'Upload PDF' : 'Muat Naik PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162235),
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
                onPressed: _scanCameraAndAnalyze,
                icon: const Icon(LucideIcons.camera),
                label: Text(isEn ? 'Camera Scan' : 'Imbasan Kamera'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. LOADING STATE ---
  Widget _buildLoadingState(bool isEn) {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CircularProgressIndicator(color: Color(0xFF1A1F2C)),
        const SizedBox(height: 20),
        Text(
          isEn ? 'Analyzing your document...' : 'Menganalisis dokumen anda...',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // --- 3. RESULT STATE ---
  Widget _buildResultState(bool isEn) {
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
                  Text(isEn ? 'Risk Level' : 'Tahap Risiko',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(risk,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: riskColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isEn ? 'Risky Clauses Found' : 'Klausa Berisiko Ditemui',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_analysisData?['clauses'] != null)
          ...(_analysisData!['clauses'] as List).asMap().entries.map((entry) {
            return _buildClauseCard(
              entry.key,
              entry.value['title'] ?? 'Unknown Clause',
              entry.value['risk'] ?? 'Potential Risk detected',
              entry.value['legalRef'] ?? 'No reference available',
              isEn,
            );
          }).toList()
        else
          Text(isEn
              ? "No significant risks found."
              : "Tiada risiko ketara ditemui."),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _currentState = 'upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162235),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
          ),
          child: Text(isEn ? 'Analyze Another Document' : 'Analisis Dokumen Lain'),
        ),
      ],
    );
  }

  Widget _buildClauseCard(
      int index, String title, String risk, String legalRef, bool isEn) {
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
                Text(
                  isEn
                      ? 'Relevant Legal Reference:'
                      : 'Rujukan Undang-undang Berkaitan:',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
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
