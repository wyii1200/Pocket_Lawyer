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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF162235),
      ),
    );
  }

  void _showSuccessDialog() {
    bool isEn = _selectedLang == 'en';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle,
                    color: Colors.green, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                isEn ? "Email Sent" : "E-mel Dihantar",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              Text(
                isEn
                    ? "A password reset link has been sent to your email. Please check your inbox."
                    : "Pautan set semula kata laluan telah dihantar ke e-mel anda. Sila semak peti masuk anda.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162235),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEn ? "Back to Login" : "Kembali ke Log Masuk",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
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
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF162235)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF162235).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.keyRound,
                    color: Color(0xFF162235), size: 30),
              ),
              const SizedBox(height: 30),
              Text(
                isEn ? 'Reset Password' : 'Set Semula Kata Laluan',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                    color: Color(0xFF162235)),
              ),
              const SizedBox(height: 12),
              Text(
                isEn
                    ? 'Enter your email associated with your account and we will send a reset link.'
                    : 'Masukkan e-mel yang dikaitkan dengan akaun anda dan kami akan menghantar pautan set semula.',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    height: 1.5,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 40),
              Text(
                isEn ? "Email Address" : "Alamat E-mel",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF162235),
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  hintText: "you@example.com",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(LucideIcons.mail, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF162235), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Hero(
                tag: 'auth_btn',
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162235),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Text(isEn ? "Send Reset Link" : "Hantar Pautan",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isEn ? "Return to Login" : "Kembali ke Log Masuk",
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
