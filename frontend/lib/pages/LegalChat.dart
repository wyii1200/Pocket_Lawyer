import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/history_service.dart';



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
  final ScrollController _scrollController = ScrollController(); // Added for auto-scroll
  
  final List<Message> _messages = [
    Message(
      role: 'ai',
      content: 'Hello! I\'m your legal assistant. How can I help you today? Please note that I provide general legal information, not professional legal advice.',
    ),
  ];
  
  bool _isTyping = false;

  final List<String> _quickQuestions = [
    "What are my rights as a tenant?",
    "How to report a workplace dispute?",
    "Can a contract be terminated early?"
  ];

  // Logic to scroll to the bottom of the list
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
          .call({'message': text});

      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content: result.data['reply'] ?? 'I am sorry, I could not process that.',
          legalRef: result.data['legalRef'] ?? 'General Malaysian Law principles',
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
          content: 'Error connecting to legal assistant. Please check your connection.',
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Legal Chatbot',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () => setState(() => _messages.removeRange(1, _messages.length)),
            tooltip: 'Clear Chat',
          )
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F2C),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach controller
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          if (_messages.length == 1) _buildQuickQuestions(),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
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
          color: isUser ? const Color(0xFF1A1F2C) : Colors.white,
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
                "Reference: ${msg.legalRef}",
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

  Widget _buildQuickQuestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Questions:',
            style: TextStyle(
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
            children: _quickQuestions.map((question) {
              return InkWell(
                onTap: () => _sendMessage(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1F2C),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              decoration: InputDecoration(
                hintText: 'Ask a legal question...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(8),
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