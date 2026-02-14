import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
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
      final result = await FirebaseFunctions.instance
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
          'lang': _selectedLang,
        }
      });

      setState(() {
        _generatedLetterText =
            result.data['letterText'] ?? "Failed to generate text.";
        _showPreview = true;
        _isLoading = false;
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
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
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
              ? (isEn ? 'Letter Preview' : 'Pratonton Surat')
              : (isEn ? 'Generate Letter' : 'Jana Surat'),
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          key: ValueKey(_showPreview),
          padding: const EdgeInsets.all(24),
          child: _showPreview ? _buildPreview(isEn) : _buildForm(isEn),
        ),
      ),
    );
  }

  Widget _buildForm(bool isEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(isEn ? "Your Name" : "Nama Anda"),
        TextField(
            controller: _yourNameController,
            decoration:
                _inputDecoration(isEn ? "e.g. John Doe" : "cth. Ali Bin Abu")),
        const SizedBox(height: 16),
        _buildLabel(isEn ? "Recipient Name" : "Nama Penerima"),
        TextField(
            controller: _recipientNameController,
            decoration:
                _inputDecoration(isEn ? "e.g. Landlord" : "cth. Tuan Rumah")),
        const SizedBox(height: 16),
        _buildLabel(isEn ? "Letter Type" : "Jenis Surat"),
        DropdownButtonFormField(
          value: _letterType,
          items: [
            DropdownMenuItem(
                value: 'complaint', child: Text(isEn ? 'Complaint' : 'Aduan')),
            DropdownMenuItem(
                value: 'demand',
                child: Text(isEn ? 'Letter of Demand' : 'Surat Tuntutan')),
            DropdownMenuItem(
                value: 'notice', child: Text(isEn ? 'Notice' : 'Notis')),
          ],
          onChanged: (val) => setState(() => _letterType = val as String),
          decoration: _inputDecoration(null),
        ),
        const SizedBox(height: 16),
        _buildLabel(isEn ? "Issue Description" : "Keterangan Isu"),
        TextField(
          controller: _issueController,
          maxLines: 5,
          decoration: _inputDecoration(isEn
              ? "Describe the facts..."
              : "Terangkan fakta situasi anda..."),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162235),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(isEn ? 'Generate Letter' : 'Jana Surat',
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPreview(bool isEn) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            _generatedLetterText,
            style: const TextStyle(
                fontFamily: 'Poppins', height: 1.5, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(LucideIcons.download, size: 18),
                label: Text(isEn ? "Export PDF" : "Eksport PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162235),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareLetter,
                icon: const Icon(LucideIcons.share2, size: 18),
                label: Text(isEn ? "Share" : "Kongsi"),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins')),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      );
}
