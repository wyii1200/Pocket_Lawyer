import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  bool _isLoading = false;
  String _selectedLang = 'en';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _selectedLang = lang;
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            Text(
              _selectedLang == 'en' ? 'Select Language' : 'Pilih Bahasa',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            _buildLangTile('English', 'en'),
            _buildLangTile('Bahasa Melayu', 'ms'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(String label, String code) {
    bool isSelected = _selectedLang == code;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: isSelected ? const Color(0xFF162235).withOpacity(0.05) : null,
      leading: Icon(LucideIcons.globe,
          color: isSelected ? const Color(0xFF162235) : Colors.grey),
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF162235))
          : null,
      onTap: () {
        _changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar(_selectedLang == 'en'
          ? 'Please fill in all fields'
          : 'Sila isi semua ruangan');
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar(_selectedLang == 'en'
          ? 'Enter a valid email'
          : 'Masukkan e-mel yang sah');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      String message =
          _selectedLang == 'en' ? 'An error occurred' : 'Ralat berlaku';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = _selectedLang == 'en'
            ? 'Invalid email or password'
            : 'E-mel atau kata laluan tidak sah';
      }
      _showSnackBar(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildHeaderIcon(
                      LucideIcons.languages, _showLanguagePicker),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 32),
                      const Text(
                        'Pocket Lawyer',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Serif',
                          color: Color(0xFF162235),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEn
                            ? 'Making Law Simple for Everyone'
                            : 'Memudahkan Undang-Undang untuk Semua',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),
                _buildLabel(isEn ? 'Email Address' : 'Alamat E-mel'),
                _buildTextField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  icon: LucideIcons.mail,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _buildLabel(isEn ? 'Password' : 'Kata Laluan'),
                _buildTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: LucideIcons.lock,
                  obscure: !_showPassword,
                  suffix: IconButton(
                    icon: Icon(
                        _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20,
                        color: Colors.grey[400]),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(
                      isEn ? 'Forgot Password?' : 'Lupa Kata Laluan?',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildLoginButton(isEn),
                const SizedBox(height: 20),
                _buildSignUpButton(isEn),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: IconButton(
          icon: Icon(icon, color: const Color(0xFF162235), size: 22),
          onPressed: onPressed),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162235), Color(0xFF2C3E50)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF162235).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: const Icon(LucideIcons.scale, color: Colors.white, size: 44),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style:
          const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF162235)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF162235), width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isEn) {
    return Hero(
      tag: 'auth_btn',
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162235),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Text(isEn ? 'Sign In' : 'Log Masuk',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _buildSignUpButton(bool isEn) {
    return OutlinedButton(
      onPressed: () => Navigator.pushNamed(context, '/signup'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        isEn ? 'Create an Account' : 'Daftar Akaun',
        style: const TextStyle(
            color: Color(0xFF162235),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins'),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5)),
    );
  }
}
