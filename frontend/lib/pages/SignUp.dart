import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  void _handleSubmit() async {
    if (!_agreed) return;
    
    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _success = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email is already in use.';
      } else {
        message = e.message ?? 'Signup failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
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
        /*actions: [
          IconButton(
            icon: const Icon(LucideIcons.languages, size: 20),
            onPressed: () {},
          ),
        ],*/
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

            // Full Name
            _buildField('Full Name', 'Enter your full name', _nameController),

            // Email
            _buildField(
                'Email Address', 'you@example.com', _emailController,
                keyboardType: TextInputType.emailAddress),

            // Phone
            _buildField('Phone Number', '+60 12-345 6789', _phoneController,
                keyboardType: TextInputType.phone),

            // Password
            _buildPasswordField('Password', _passwordController, _showPassword,
                () => setState(() => _showPassword = !_showPassword)),

            // Confirm Password
            _buildPasswordField(
                'Confirm Password', _confirmController, _showConfirm,
                () => setState(() => _showConfirm = !_showConfirm)),


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

  Widget _buildField( String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
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
            controller: controller, // <- connect controller
            keyboardType: keyboardType,
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller,
      bool isVisible, VoidCallback toggle){
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
            controller: controller,
            obscureText: !isVisible,
            decoration: _inputDecoration('••••••••').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                    isVisible ? LucideIcons.eyeOff : LucideIcons.eye,
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
