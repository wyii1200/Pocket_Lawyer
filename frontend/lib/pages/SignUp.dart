import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  void _handleSubmit() async {
    if (!_agreed) return;

    // 1. Basic validation
    if (_passwordController.text != _confirmController.text) {
      _showError("Passwords do not match");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Create Auth User
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 3. Store User Profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _success = true;
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = e.message ?? 'Signup failed';
      if (e.code == 'weak-password')
        message = 'The password provided is too weak.';
      if (e.code == 'email-already-in-use')
        message = 'An account already exists for that email.';
      _showError(message);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("An unexpected error occurred.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccessView();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF162235),
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
            _buildField('Full Name', 'Enter your full name', _nameController),
            _buildField('Email Address', 'you@example.com', _emailController,
                keyboardType: TextInputType.emailAddress),
            _buildField('Phone Number', '+60 12-345 6789', _phoneController,
                keyboardType: TextInputType.phone),
            _buildPasswordField('Password', _passwordController, _showPassword,
                () => setState(() => _showPassword = !_showPassword)),
            _buildPasswordField(
                'Confirm Password',
                _confirmController,
                _showConfirm,
                () => setState(() => _showConfirm = !_showConfirm)),
            _buildTermsCheckbox(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_agreed && !_isLoading) ? _handleSubmit : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: const Color(0xFF162235),
        disabledBackgroundColor: Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text('Create Account',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreed,
          activeColor: const Color(0xFF162235),
          onChanged: (val) => setState(() => _agreed = val ?? false),
        ),
        const Expanded(
          child: Text('I agree to the Terms of Service and Privacy Policy',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        )
      ],
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
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
            controller: controller,
            keyboardType: keyboardType,
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggle) {
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
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF162235))),
    );
  }
}
