import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateLetterPage extends StatefulWidget {
  const GenerateLetterPage({super.key});

  @override
  State<GenerateLetterPage> createState() => _GenerateLetterPageState();
}

class _GenerateLetterPageState extends State<GenerateLetterPage> {
  String _generatedLetterText = "";
  bool _isLoading = false;
  bool _showPreview = false;
  String _selectedLang = 'en';

  final _yourNameController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _issueController = TextEditingController();
  final String _date = DateFormat('MMMM dd, yyyy').format(DateTime.now());
  String _letterType = 'complaint';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  // --- ORIGIN FUNCTIONS (UNTOUCHED) ---
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('app_language') ?? 'en';
    });
  }

  Future<void> _handleGenerate() async {
    bool isEn = _selectedLang == 'en';
    if (_yourNameController.text.isEmpty || _issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEn
                ? "Please fill in your name and the issue description."
                : "Sila isi nama anda dan keterangan isu.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('generateLetter')
          .call({
        'templateId': _letterType,
        'userData': {
          'userName': _yourNameController.text,
          'recipientName': _recipientNameController.text.isEmpty
              ? (isEn ? "Sir/Madam" : "Tuan/Puan")
              : _recipientNameController.text,
          'issue': _issueController.text,
          'date': _date,
        }
      });

      setState(() {
        _generatedLetterText =
            result.data['letterText'] ?? "Failed to generate text.";
        _showPreview = true;
        _isLoading = false;
      });

      await HistoryService.saveHistory(
          type: "Letter Generation",
          summary:
              "${_letterType.toUpperCase()} Letter — ${_issueController.text}",
          metadata: {
            'letterType': _letterType,
            'recipientName': _recipientNameController.text,
            'date': _date,
            'lang': _selectedLang,
          });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Text(
            _generatedLetterText,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${_letterType}_letter.pdf',
    );
  }

  Future<void> _shareLetter() async {
    if (_generatedLetterText.isNotEmpty) {
      await Share.share(_generatedLetterText,
          subject: "Legal Letter - Pocket Lawyer");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
              _showPreview ? LucideIcons.chevronLeft : LucideIcons.arrowLeft,
              color: const Color(0xFF162235)),
          onPressed: () {
            if (_showPreview) {
              setState(() => _showPreview = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _showPreview
              ? (isEn ? 'Preview Draft' : 'Pratonton Draf')
              : (isEn ? 'Generate Letter' : 'Jana Surat'),
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(isEn),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                key: ValueKey(_showPreview),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: _showPreview ? _buildPreview(isEn) : _buildForm(isEn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isEn) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepDot(true, isEn ? "Details" : "Butiran"),
          _stepLine(!_showPreview),
          _stepDot(_showPreview, isEn ? "Preview" : "Pratonton"),
        ],
      ),
    );
  }

  Widget _stepDot(bool active, String label) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF162235) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? const Color(0xFF162235) : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(bool inactive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      color: inactive ? Colors.grey[200] : const Color(0xFF162235),
    );
  }

  Widget _buildForm(bool isEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(isEn ? "Personal Info" : "Maklumat Peribadi"),
              _buildInputField(
                  controller: _yourNameController,
                  hint: isEn ? "Your Full Name" : "Nama Penuh Anda",
                  icon: LucideIcons.user),
              const SizedBox(height: 20),
              _buildLabel(isEn ? "Recipient Info" : "Maklumat Penerima"),
              _buildInputField(
                  controller: _recipientNameController,
                  hint: isEn ? "e.g. Landlord Name" : "cth. Nama Tuan Rumah",
                  icon: LucideIcons.building),
              const SizedBox(height: 20),
              _buildLabel(isEn ? "Select Purpose" : "Pilih Tujuan"),
              DropdownButtonFormField(
                value: _letterType,
                icon: const Icon(LucideIcons.chevronDown, size: 18),
                items: [
                  DropdownMenuItem(
                      value: 'complaint',
                      child: Text(isEn ? 'Formal Complaint' : 'Aduan Rasmi')),
                  DropdownMenuItem(
                      value: 'demand',
                      child:
                          Text(isEn ? 'Letter of Demand' : 'Surat Tuntutan')),
                  DropdownMenuItem(
                      value: 'notice',
                      child:
                          Text(isEn ? 'Legal Notice' : 'Notis Undang-undang')),
                ],
                onChanged: (val) => setState(() => _letterType = val as String),
                decoration: _inputDecoration(null, LucideIcons.fileSignature),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildLabel(isEn ? "Describe the Issue" : "Keterangan Isu"),
        TextField(
          controller: _issueController,
          maxLines: 6,
          decoration: _inputDecoration(
              isEn
                  ? "Provide specific facts and dates..."
                  : "Berikan fakta dan tarikh spesifik...",
              LucideIcons.textCursorInput),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162235),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isEn ? 'Generate Draft' : 'Jana Draf',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 10),
                    const Icon(LucideIcons.sparkles, size: 18),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPreview(bool isEn) {
    return Column(
      children: [
        // Physical Paper Effect
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            children: [
              Container(
                  height: 8, color: const Color(0xFF162235)), // Letterhead bar
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _generatedLetterText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      height: 1.6,
                      fontSize: 13,
                      color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(
            onPressed: _downloadPdf,
            icon: LucideIcons.fileDown,
            label: isEn ? "Export as PDF" : "Eksport ke PDF",
            primary: true),
        const SizedBox(height: 12),
        _buildActionButton(
            onPressed: _shareLetter,
            icon: LucideIcons.share2,
            label: isEn ? "Share via..." : "Kongsi melalui...",
            primary: false),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5)),
      );

  Widget _buildInputField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon}) {
    return TextField(
        controller: controller, decoration: _inputDecoration(hint, icon));
  }

  Widget _buildActionButton(
      {required VoidCallback onPressed,
      required IconData icon,
      required String label,
      required bool primary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? const Color(0xFF162235) : Colors.white,
        foregroundColor: primary ? Colors.white : const Color(0xFF162235),
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        side: primary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins'),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF162235)),
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF162235), width: 1.5)),
      );
}
