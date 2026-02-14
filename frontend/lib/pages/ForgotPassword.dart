import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    bool isEn = _selectedLang == 'en';

    if (email.isEmpty) {
      _showMessage(isEn
          ? "Please enter your email address."
          : "Sila masukkan alamat e-mel anda.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(isEn
          ? "Please enter a valid email."
          : "Sila masukkan e-mel yang sah.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(
          e.message ?? (isEn ? "An error occurred." : "Ralat telah berlaku."));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessDialog() {
    bool isEn = _selectedLang == 'en';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isEn ? "Email Sent" : "E-mel Dihantar",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(isEn
            ? "A password reset link has been sent to your email. Please check your inbox (and spam folder)."
            : "Pautan set semula kata laluan telah dihantar ke e-mel anda. Sila semak peti masuk anda (dan folder spam)."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(isEn ? "Back to Login" : "Kembali ke Log Masuk"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              isEn ? 'Reset Password' : 'Set Semula Kata Laluan',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif'),
            ),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'Enter your email associated with your account and we will send a reset link.'
                  : 'Masukkan e-mel yang dikaitkan dengan akaun anda dan kami akan menghantar pautan set semula.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            Text(isEn ? "Email Address" : "Alamat E-mel",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "you@example.com",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF162235)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162235),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(isEn ? "Send Reset Link" : "Hantar Pautan",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
