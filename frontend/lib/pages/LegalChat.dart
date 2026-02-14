import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/history_service.dart';


import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String role;
  final String content;
  final String? legalRef;

  Message({required this.role, required this.content, this.legalRef});
}

class LegalChatPage extends StatefulWidget {
  const LegalChatPage({super.key});

  @override
  State<LegalChatPage> createState() => _LegalChatPageState();
}

class _LegalChatPageState extends State<LegalChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedLang = 'en';

  final List<Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadLanguageAndWelcome();
  }

  Future<void> _loadLanguageAndWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('app_language') ?? 'en';
      bool isEn = _selectedLang == 'en';
      _messages.add(Message(
        role: 'ai',
        content: isEn
            ? 'Hello! I\'m your legal assistant. How can I help you today? Please note that I provide general legal information, not professional legal advice.'
            : 'Helo! Saya pembantu undang-undang anda. Bagaimanakah saya boleh membantu anda hari ini? Sila ambil perhatian bahawa saya menyediakan maklumat undang-undang am, bukan nasihat undang-undang profesional.',
      ));
    });
  }

  List<String> _getQuickQuestions(bool isEn) {
    return isEn
        ? [
            "What are my rights as a tenant?",
            "How to report a workplace dispute?",
            "Can a contract be terminated early?"
          ]
        : [
            "Apakah hak saya sebagai penyewa?",
            "Cara melapor pertikaian tempat kerja?",
            "Bolehkah kontrak ditamatkan awal?"
          ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(role: 'user', content: text));
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('legalChat')
          .call({'message': text, 'lang': _selectedLang});

      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content: result.data['reply'] ??
              (_selectedLang == 'en'
                  ? 'I could not process that.'
                  : 'Saya tidak dapat memprosesnya.'),
          legalRef: result.data['legalRef'],
        ));
      });

      _scrollToBottom();

      //save history to firestore
      await HistoryService.saveHistory(
        type: "Legal Chat",
        summary: text.length > 40
            ? "${text.substring(0, 40)}..."
            : text,
        metadata: {
          "question": text,
          "reply": result.data['reply'],
          "legalRef": result.data['legalRef'],
        },
      );

    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content: _selectedLang == 'en'
              ? 'Error connecting. Check connection.'
              : 'Ralat sambungan. Semak talian internet.',
        ));
      });
      _scrollToBottom();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Legal Chatbot' : 'Sembang Undang-undang',
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () =>
                setState(() => _messages.removeRange(1, _messages.length)),
            tooltip: isEn ? 'Clear Chat' : 'Padam Sembang',
          )
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF162235),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(_messages[index]),
            ),
          ),
          if (_messages.length == 1) _buildQuickQuestions(isEn),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(isEn),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Message msg) {
    bool isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF162235) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            if (msg.legalRef != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 4),
              Text(
                "${_selectedLang == 'en' ? 'Reference' : 'Rujukan'}: ${msg.legalRef}",
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestions(bool isEn) {
    final questions = _getQuickQuestions(isEn);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Quick Questions:' : 'Soalan Pantas:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((question) {
              return InkWell(
                onTap: () => _sendMessage(question),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF162235),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Row(
        children: List.generate(
            3,
            (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                )),
      ),
    );
  }

  Widget _buildInputArea(bool isEn) {
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: isEn
                    ? 'Ask a legal question...'
                    : 'Tanya soalan undang-undang...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF162235)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF162235),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.send, size: 20),
              onPressed: () => _sendMessage(_inputController.text),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
