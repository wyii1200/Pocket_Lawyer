import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class GenerateLetterPage extends StatefulWidget {
  const GenerateLetterPage({super.key});

  @override
  State<GenerateLetterPage> createState() => _GenerateLetterPageState();
}

class _GenerateLetterPageState extends State<GenerateLetterPage> {
  String _generatedLetterText = "";
  bool _isLoading = false;
  bool _showPreview = false;

  final _yourNameController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _issueController = TextEditingController();
  final String _date = DateFormat('MMMM dd, yyyy').format(DateTime.now());
  String _letterType = 'complaint';

  Future<void> _handleGenerate() async {
    // Basic Form Validation
    if (_yourNameController.text.isEmpty || _issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please fill in your name and the issue description.")),
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
              ? "Sir/Madam"
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Generation failed: $e")),
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
          _showPreview ? 'Letter Preview' : 'Generate Letter',
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
          child: _showPreview ? _buildPreview() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Your Name"),
        TextField(
            controller: _yourNameController,
            decoration: _inputDecoration("e.g. John Doe")),
        const SizedBox(height: 16),
        _buildLabel("Recipient Name"),
        TextField(
            controller: _recipientNameController,
            decoration: _inputDecoration("e.g. HR Manager / Landlord")),
        const SizedBox(height: 16),
        _buildLabel("Letter Type"),
        DropdownButtonFormField(
          value: _letterType,
          items: const [
            DropdownMenuItem(value: 'complaint', child: Text('Complaint')),
            DropdownMenuItem(value: 'demand', child: Text('Letter of Demand')),
            DropdownMenuItem(value: 'notice', child: Text('Notice')),
          ],
          onChanged: (val) => setState(() => _letterType = val as String),
          decoration: _inputDecoration(null),
        ),
        const SizedBox(height: 16),
        _buildLabel("Issue Description"),
        TextField(
          controller: _issueController,
          maxLines: 5,
          decoration:
              _inputDecoration("Describe the facts of your situation..."),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1F2C),
            minimumSize: const Size.fromHeight(56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Generate Letter',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPreview() {
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
                label: const Text("Export PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F2C),
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
                label: const Text("Share"),
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
