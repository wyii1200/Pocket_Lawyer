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
      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
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

      await HistoryService.saveHistory(
        type: "Legal Chat",
        summary: text.length > 40 ? "${text.substring(0, 40)}..." : text,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF162235)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Legal Assistant' : 'Pembantu Undang-undang',
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.eraser, size: 20),
            onPressed: () =>
                setState(() => _messages.removeRange(1, _messages.length)),
            tooltip: isEn ? 'Clear Chat' : 'Padam Sembang',
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF162235) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1E293B),
                fontSize: 14,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            if (msg.legalRef != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.scale,
                        size: 14,
                        color:
                            isUser ? Colors.white70 : const Color(0xFF162235)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${_selectedLang == 'en' ? 'Reference' : 'Rujukan'}: ${msg.legalRef}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isUser ? Colors.white70 : Colors.blueGrey[700],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Try asking:' : 'Cuba tanya:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: questions.map((question) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(question),
                    onPressed: () => _sendMessage(question),
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF162235),
                        fontFamily: 'Poppins'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: List.generate(
                  3,
                  (index) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                            color: Color(0xFF162235), shape: BoxShape.circle),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isEn) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: isEn ? 'Type a question...' : 'Taip soalan...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: const Color(0xFF162235),
                  borderRadius: BorderRadius.circular(16)),
              child:
                  const Icon(LucideIcons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
