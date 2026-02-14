import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';



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
  
  // Inside _LegalChatPageState
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message to UI
    setState(() {
      _messages.add(Message(role: 'user', content: text));
      _inputController.clear();
      _isTyping = true;
    });

    try {
      // 2. Call your JS Backend via Firebase Emulator
      // Ensure your main.dart has: FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);
      final result = await FirebaseFunctions.instance
          .httpsCallable('legalChat')
          .call({
            'message': text,
          });


      // 3. Add AI Response to UI
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content: result.data['reply'] ?? 'I am sorry, I could not process that.',
          legalRef: 'Referenced from Malaysian Laws', // You can also pass this from JS
        ));
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content: 'Error connecting to legal assistant: $e',
        ));
      });
    }
  }
  
  final TextEditingController _inputController = TextEditingController();
  final List<Message> _messages = [
    Message(
      role: 'ai',
      content:
          'Hello! I\'m your legal assistant. How can I help you today? Please note that I provide general legal information, not professional legal advice.',
    ),
  ];
  bool _isTyping = false;

  final List<String> _quickQuestions = [
    "What are my rights as a tenant?",
    "How to report a workplace dispute?",
    "Can a contract be terminated early?"
  ];

  //demo only
  /*void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(role: 'user', content: text));
      _inputController.clear();
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isTyping = false;
        _messages.add(Message(
          role: 'ai',
          content:
              'Thank you for your question. Based on general Malaysian legal principles, this area of law involves several considerations.',
          legalRef: 'Contracts Act 1950 (Malaysia)',
        ));
      });
    });
  }*/

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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F2C),
        elevation: 1,
      ),
      body: Column(
        children: [
          // 1. MESSAGES AREA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // 2. SUGGESTED QUESTIONS
          if (_messages.length == 1) _buildQuickQuestions(),

          // 3. TYPING INDICATOR
          if (_isTyping) _buildTypingIndicator(),

          // 4. INPUT AREA
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
              const SizedBox(height: 6),
              Text(
                "Reference: ${msg.legalRef}",
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.blueGrey,
                    fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                fillColor: const Color(0xFFF1F4F9),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1A1F2C),
            child: IconButton(
              icon: const Icon(LucideIcons.send, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(_inputController.text),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _quickQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return OutlinedButton(
            onPressed: () => _sendMessage(_quickQuestions[index]),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Text(
              _quickQuestions[index],
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('AI is typing',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(width: 4),
            SizedBox(
              width: 24,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFF1A1F2C),
                backgroundColor: Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
