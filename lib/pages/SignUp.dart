import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _agreed = false;
  bool _success = false;

  void _handleSubmit() {
    setState(() => _success = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.checkCircle2, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('Account Created',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif')),
              SizedBox(height: 8),
              Text('Welcome to Pocket Lawyer!',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.languages, size: 20),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1F2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sign Up',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif')),
            const SizedBox(height: 6),
            const Text('Join us to make legal help accessible.',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 32),

            // Full Name, Email, Phone
            _buildField('Full Name', 'Enter your full name'),
            _buildField('Email', 'you@example.com',
                keyboardType: TextInputType.emailAddress),
            _buildField('Phone Number', '+60 12-345 6789',
                keyboardType: TextInputType.phone),

            // Password fields
            _buildPasswordField('Password', _showPassword, () {
              setState(() => _showPassword = !_showPassword);
            }),
            _buildPasswordField('Confirm Password', _showConfirm, () {
              setState(() => _showConfirm = !_showConfirm);
            }),

            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: const Color(0xFF1A1F2C),
                  onChanged: (val) => setState(() => _agreed = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _agreed ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF1A1F2C),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Account',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            keyboardType: keyboardType,
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
      String label, bool isVisible, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            obscureText: !isVisible,
            decoration: _inputDecoration('••••••••').copyWith(
              suffixIcon: IconButton(
                icon: Icon(isVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20),
                onPressed: toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
