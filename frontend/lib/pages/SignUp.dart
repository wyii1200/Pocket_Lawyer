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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF162235),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';
    if (_success) return _buildSuccessView(isEn);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF162235)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Create Account' : 'Daftar Akaun',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Serif',
                      color: Color(0xFF162235),
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  isEn
                      ? 'Join us to make legal help accessible.'
                      : 'Sertai kami untuk bantuan undang-undang mudah.',
                  style: TextStyle(
                      color: Colors.blueGrey[400],
                      fontSize: 15,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 48),
                _buildField(
                  label: isEn ? 'Full Name' : 'Nama Penuh',
                  hint: isEn
                      ? 'Enter your full name'
                      : 'Masukkan nama penuh anda',
                  controller: _nameController,
                  icon: LucideIcons.user,
                  validator: (val) =>
                      val!.isEmpty ? (isEn ? "Required" : "Wajib") : null,
                ),
                _buildField(
                  label: isEn ? 'Email Address' : 'Alamat E-mel',
                  hint: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  icon: LucideIcons.mail,
                  validator: (val) => !_isValidEmail(val!)
                      ? (isEn ? "Invalid email" : "E-mel tidak sah")
                      : null,
                ),
                _buildField(
                  label: isEn ? 'Phone Number' : 'Nombor Telefon',
                  hint: '+60 12-345 6789',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  icon: LucideIcons.phone,
                  validator: (val) =>
                      val!.isEmpty ? (isEn ? "Required" : "Wajib") : null,
                ),
                _buildPasswordField(
                  label: isEn ? 'Password' : 'Kata Laluan',
                  controller: _passwordController,
                  isVisible: _showPassword,
                  toggle: () => setState(() => _showPassword = !_showPassword),
                  validator: (val) => val!.length < 6
                      ? (isEn ? "Min 6 characters" : "Min 6 aksara")
                      : null,
                ),
                _buildPasswordField(
                  label: isEn ? 'Confirm Password' : 'Sahkan Kata Laluan',
                  controller: _confirmController,
                  isVisible: _showConfirm,
                  toggle: () => setState(() => _showConfirm = !_showConfirm),
                  validator: (val) => val!.isEmpty
                      ? (isEn
                          ? "Confirm your password"
                          : "Sahkan kata laluan anda")
                      : null,
                ),
                const SizedBox(height: 12),
                _buildTermsCheckbox(isEn),
                const SizedBox(height: 40),
                _buildSubmitButton(isEn),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14),
            decoration: _inputDecoration(hint, icon),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: !isVisible,
            validator: validator,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14),
            decoration: _inputDecoration('••••••••', LucideIcons.lock).copyWith(
              suffixIcon: IconButton(
                icon: Icon(isVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20, color: Colors.blueGrey[300]),
                onPressed: toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
              letterSpacing: 0.5)),
    );
  }

  Widget _buildSuccessView(bool isEn) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.green[50], shape: BoxShape.circle),
              child: const Icon(LucideIcons.userCheck,
                  size: 64, color: Colors.green),
            ),
            const SizedBox(height: 32),
            Text(isEn ? 'Account Created' : 'Akaun Dicipta',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Serif',
                    color: Color(0xFF162235))),
            const SizedBox(height: 12),
            Text(
                isEn
                    ? 'Welcome to Pocket Lawyer!'
                    : 'Selamat Datang ke Pocket Lawyer!',
                style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 16,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEn) {
    return Hero(
      tag: 'auth_btn',
      child: ElevatedButton(
        onPressed: (_agreed && !_isLoading) ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          backgroundColor: const Color(0xFF162235),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blueGrey[50],
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Text(isEn ? 'Create Account' : 'Daftar Akaun',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isEn) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreed,
            activeColor: const Color(0xFF162235),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _agreed = val ?? false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isEn
                ? 'I agree to the Terms and Privacy Policy'
                : 'Saya setuju dengan Terma dan Dasar Privasi',
            style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey[500],
                fontFamily: 'Poppins'),
          ),
        )
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey[200], fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF162235)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF162235), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    );
  }
}
