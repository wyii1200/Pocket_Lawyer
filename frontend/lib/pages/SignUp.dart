import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _selectedLang = 'en';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('app_language') ?? 'en';
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleSubmit() async {
    bool isEn = _selectedLang == 'en';

    if (!_formKey.currentState!.validate()) return;

    if (!_agreed) {
      _showError(
          isEn ? "Please agree to the Terms." : "Sila setuju dengan Terma.");
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showError(isEn ? "Passwords do not match" : "Kata laluan tidak sepadan");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Store User Profile
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
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = e.message ?? 'Signup failed';
      if (e.code == 'weak-password')
        message = isEn ? 'Password too weak' : 'Kata laluan terlalu lemah';
      if (e.code == 'email-already-in-use')
        message = isEn ? 'Email already in use' : 'E-mel sudah digunakan';
      _showError(message);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(isEn ? "An error occurred." : "Ralat telah berlaku.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';
    if (_success) return _buildSuccessView(isEn);

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEn ? 'Sign Up' : 'Daftar Akaun',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif')),
              const SizedBox(height: 6),
              Text(
                  isEn
                      ? 'Join us to make legal help accessible.'
                      : 'Sertai kami untuk bantuan undang-undang mudah.',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              _buildField(
                isEn ? 'Full Name' : 'Nama Penuh',
                isEn ? 'Enter your full name' : 'Masukkan nama penuh anda',
                _nameController,
                icon: LucideIcons.user,
                validator: (val) =>
                    val!.isEmpty ? (isEn ? "Required" : "Wajib") : null,
              ),
              _buildField(
                isEn ? 'Email Address' : 'Alamat E-mel',
                'you@example.com',
                _emailController,
                keyboardType: TextInputType.emailAddress,
                icon: LucideIcons.mail,
                validator: (val) => !_isValidEmail(val!)
                    ? (isEn ? "Invalid email" : "E-mel tidak sah")
                    : null,
              ),
              _buildField(
                isEn ? 'Phone Number' : 'Nombor Telefon',
                '+60 12-345 6789',
                _phoneController,
                keyboardType: TextInputType.phone,
                icon: LucideIcons.phone,
                validator: (val) =>
                    val!.isEmpty ? (isEn ? "Required" : "Wajib") : null,
              ),
              _buildPasswordField(
                isEn ? 'Password' : 'Kata Laluan',
                _passwordController,
                _showPassword,
                () => setState(() => _showPassword = !_showPassword),
                validator: (val) => val!.length < 6
                    ? (isEn ? "Min 6 characters" : "Min 6 aksara")
                    : null,
              ),
              _buildPasswordField(
                isEn ? 'Confirm Password' : 'Sahkan Kata Laluan',
                _confirmController,
                _showConfirm,
                () => setState(() => _showConfirm = !_showConfirm),
                validator: (val) => val!.isEmpty
                    ? (isEn
                        ? "Confirm your password"
                        : "Sahkan kata laluan anda")
                    : null,
              ),
              _buildTermsCheckbox(isEn),
              const SizedBox(height: 24),
              _buildSubmitButton(isEn),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType,
      IconData? icon,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: _inputDecoration(hint).copyWith(
              prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggle,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: !isVisible,
            validator: validator,
            decoration: _inputDecoration('••••••••').copyWith(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
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

  Widget _buildSuccessView(bool isEn) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.checkCircle2, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(isEn ? 'Account Created' : 'Akaun Dicipta',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif')),
            const SizedBox(height: 8),
            Text(
                isEn
                    ? 'Welcome to Pocket Lawyer!'
                    : 'Selamat Datang ke Pocket Lawyer!',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEn) {
    return ElevatedButton(
      onPressed: (_agreed && !_isLoading) ? _handleSubmit : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: const Color(0xFF162235),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Text(isEn ? 'Create Account' : 'Daftar Akaun',
              style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTermsCheckbox(bool isEn) {
    return Row(
      children: [
        Checkbox(
          value: _agreed,
          activeColor: const Color(0xFF162235),
          onChanged: (val) => setState(() => _agreed = val ?? false),
        ),
        Expanded(
          child: Text(
            isEn
                ? 'I agree to the Terms of Service and Privacy Policy'
                : 'Saya setuju dengan Terma Perkhidmatan dan Dasar Privasi',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        )
      ],
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
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}
