import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/history_service.dart';
import 'package:image_picker/image_picker.dart';

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
    final ref =
        FirebaseStorage.instance.ref().child("documents/$fileName.$extension");
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: extension == 'pdf' ? 'application/pdf' : 'image/jpeg',
      ),
    );
    return ref.fullPath;
  }

    Future<void> _sendBytesToBackend(Uint8List bytes, String extension, String fileName) async {
      setState(() => _currentState = 'loading');

      try {
        final filePath = await uploadBytesToStorage(bytes, extension);

        final docRef = await FirebaseFirestore.instance.collection("documents").add({
          "filePath": filePath,
          "fileName": fileName, // SAVE FILE NAME
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
          summary: "$fileName — ${data['riskLevel'] ?? 'Unknown Risk'}", // USE FILE NAME
          metadata: {
            "riskLevel": data['riskLevel'],
            "summary": data['summary'],
            "clauses": data['clauses'],
            "filePath": filePath,
            "fileName": fileName,
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
        final fileName = result.files.single.name; // GET FILE NAME HERE
        await _sendBytesToBackend(result.files.single.bytes!, 'pdf', fileName);
      }
    }

    Future<void> _scanCameraAndAnalyze() async {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final fileName = image.name.isNotEmpty ? image.name : 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _sendBytesToBackend(bytes, 'jpg', fileName);
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
        title: Text(
          isEn ? 'Analyze Document' : 'Analisis Dokumen',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF162235),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: SingleChildScrollView(
          key: ValueKey(_currentState),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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

  Widget _buildUploadState(bool isEn) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF162235).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.uploadCloud,
                    size: 48, color: Color(0xFF162235)),
              ),
              const SizedBox(height: 24),
              Text(
                isEn
                    ? 'Drop your document here'
                    : 'Letakkan dokumen anda di sini',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1A1F2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? 'Support PDF or Images of contracts'
                    : 'Sokong PDF atau Imej kontrak',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildActionButton(
                onPressed: _pickPDFAndAnalyze,
                icon: LucideIcons.fileText,
                label: isEn ? 'Select PDF' : 'Pilih PDF',
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                onPressed: _scanCameraAndAnalyze,
                icon: LucideIcons.camera,
                label: isEn ? 'Take Photo' : 'Ambil Foto',
                isPrimary: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.shieldCheck, size: 14, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'GUIDED BY CONTRACTS ACT 1950',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isEn) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          const SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Color(0xFF162235),
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isEn
                ? 'AI is scanning clauses...'
                : 'AI sedang mengimbas klausa...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFF1A1F2C),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isEn
                  ? 'Identifying potential risks based on Malaysian law.'
                  : 'Mengenal pasti risiko berpotensi berdasarkan undang-undang Malaysia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(bool isEn) {
    final String risk =
        _analysisData?['riskLevel']?.toString().toUpperCase() ?? 'UNKNOWN';

    // Risk styling map
    final riskConfig = {
          'HIGH': {
            'color': Colors.red[900]!,
            'bg': Colors.red[50]!,
            'icon': LucideIcons.alertTriangle
          },
          'MEDIUM': {
            'color': Colors.orange[900]!,
            'bg': Colors.orange[50]!,
            'icon': LucideIcons.info
          },
          'LOW': {
            'color': Colors.green[900]!,
            'bg': Colors.green[50]!,
            'icon': LucideIcons.checkCircle
          },
        }[risk] ??
        {
          'color': Colors.blueGrey[900]!,
          'bg': Colors.blueGrey[50]!,
          'icon': LucideIcons.helpCircle
        };

    final List clauses = _analysisData?['clauses'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Risk Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: riskConfig['bg'] as Color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: (riskConfig['color'] as Color).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(riskConfig['icon'] as IconData,
                  color: riskConfig['color'] as Color, size: 32),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'ANALYSIS COMPLETE' : 'ANALISIS SELESAI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (riskConfig['color'] as Color).withOpacity(0.7),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      isEn ? '$risk RISK LEVEL' : 'TAHAP RISIKO $risk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: riskConfig['color'] as Color,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _buildSummaryCard(clauses.length, isEn),

        const SizedBox(height: 32),
        Text(
          isEn ? 'Key Findings' : 'Penemuan Utama',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 16),

        if (clauses.isNotEmpty)
          ...clauses.asMap().entries.map((entry) {
            return _buildClauseCard(
              entry.key,
              entry.value['title'] ?? 'Unknown Clause',
              entry.value['risk'] ?? 'Potential Risk detected',
              entry.value['legalRef'] ?? 'No reference available',
              isEn,
              riskConfig['color'] as Color,
            );
          }).toList()
        else
          _buildEmptyFindings(isEn),

        const SizedBox(height: 24),
        _buildNextSteps(isEn),
        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: () => setState(() => _currentState = 'upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162235),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            isEn ? 'Analyze New Document' : 'Analisis Dokumen Baru',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required VoidCallback onPressed,
      required IconData icon,
      required String label,
      required bool isPrimary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF162235) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF162235),
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins'),
      ),
    );
  }

  Widget _buildSummaryCard(int count, bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.listChecks,
                  size: 20, color: Color(0xFF162235)),
              const SizedBox(width: 12),
              Text(
                isEn ? 'Executive Summary' : 'Ringkasan Eksekutif',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isEn
                ? 'Our AI identified $count specific points of interest. Generally, this document ${count > 2 ? "requires significant changes" : "is mostly standard but check the details below"}.'
                : 'AI kami mengenal pasti $count perkara yang perlu diberi perhatian. Secara amnya, dokumen ini ${count > 2 ? "memerlukan perubahan besar" : "adalah standard tetapi sila semak butiran di bawah"}.',
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF475569), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildClauseCard(int index, String title, String risk, String legalRef,
      bool isEn, Color accent) {
    bool isExpanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isExpanded ? accent.withOpacity(0.3) : const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) =>
              setState(() => _expandedIndex = val ? index : null),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: accent.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(LucideIcons.alertCircle, color: accent, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          subtitle: Text(risk,
              style: TextStyle(fontSize: 13, color: accent.withOpacity(0.8))),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'LEGAL CONTEXT' : 'KONTEKS UNDANG-UNDANG',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey[400],
                        letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    legalRef,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps(bool isEn) {
    final steps = isEn
        ? [
            'Consult a licensed lawyer before signing',
            'Request amendments to highlighted clauses',
            'Negotiate for mutual indemnification'
          ]
        : [
            'Rujuk peguam berlesen sebelum menandatangani',
            'Minta pindaan pada klausa yang ditandakan',
            'Rundingkan indemniti bersama'
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Recommended Actions' : 'Tindakan Disyorkan',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 16),
        ...steps.map((step) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(step,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyFindings(bool isEn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(LucideIcons.checkCircle2, size: 48, color: Colors.green[200]),
            const SizedBox(height: 16),
            Text(isEn
                ? "No significant risks found."
                : "Tiada risiko ketara ditemui."),
          ],
        ),
      ),
    );
  }
}
