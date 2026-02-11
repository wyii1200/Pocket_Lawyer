import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class GenerateLetterPage extends StatefulWidget {
  const GenerateLetterPage({super.key});

  @override
  State<GenerateLetterPage> createState() => _GenerateLetterPageState();
}

class _GenerateLetterPageState extends State<GenerateLetterPage> {
  bool _showPreview = false;
  final _yourNameController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _issueController = TextEditingController();
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _letterType = 'complaint';

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
        child: _showPreview ? _buildPreview() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Your Name"),
        TextField(
            controller: _yourNameController, decoration: _inputDecoration()),
        const SizedBox(height: 16),
        _buildLabel("Recipient Name"),
        TextField(
            controller: _recipientNameController,
            decoration: _inputDecoration()),
        const SizedBox(height: 16),
        _buildLabel("Letter Type"),
        DropdownButtonFormField(
          value: _letterType,
          items: const [
            DropdownMenuItem(value: 'complaint', child: Text('Complaint')),
            DropdownMenuItem(value: 'demand', child: Text('Demand')),
            DropdownMenuItem(value: 'notice', child: Text('Notice')),
          ],
          onChanged: (val) => setState(() => _letterType = val as String),
          decoration: _inputDecoration(),
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
        ),
        const SizedBox(height: 16),
        _buildLabel("Issue Description"),
        TextField(
          controller: _issueController,
          maxLines: 4,
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _showPreview = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1F2C),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Generate Letter',
              style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(_date,
                      style: const TextStyle(fontFamily: 'Poppins'))),
              const SizedBox(height: 16),
              Text(
                  _recipientNameController.text.isEmpty
                      ? 'Recipient Name'
                      : _recipientNameController.text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              const Text('Dear Sir/Madam,',
                  style: TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Text('RE: FORMAL ${_letterType.toUpperCase()} LETTER',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const SizedBox(height: 16),
              Text(
                  'I, ${_yourNameController.text.isEmpty ? "Your Name" : _yourNameController.text}, am writing to formally bring to your attention the following matter.',
                  style: const TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Text(
                  _issueController.text.isEmpty
                      ? 'Issue description will appear here.'
                      : _issueController.text,
                  style: const TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 16),
              const Text(
                  'I kindly request that this matter be addressed within 14 working days. Failure to respond may result in further action as permitted by law.',
                  style: TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 24),
              const Text('Yours faithfully,',
                  style: TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Text(_yourNameController.text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
                child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download,
                  semanticLabel: 'Download PDF'),
              label: const Text("Download PDF",
                  style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1F2C),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: OutlinedButton.icon(
              onPressed: () {},
              icon:
                  const Icon(LucideIcons.share2, semanticLabel: 'Share Letter'),
              label:
                  const Text("Share", style: TextStyle(fontFamily: 'Poppins')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            )),
          ],
        )
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins')),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}
