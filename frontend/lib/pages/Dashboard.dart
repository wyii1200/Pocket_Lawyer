import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedLang = 'en';
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    final savedLang = prefs.getString('app_language') ?? 'en';

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc['fullName']?.split(' ')[0] ?? "User";
        });
      }
    }

    if (mounted) {
      setState(() {
        _selectedLang = savedLang;
      });
    }
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() => _selectedLang = lang);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: const Text('English'),
              trailing: _selectedLang == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                _changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: const Text('Bahasa Melayu'),
              trailing: _selectedLang == 'ms'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                _changeLanguage('ms');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Hello, $_userName' : 'Helo, $_userName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1A1F2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn
                            ? 'YOUR LEGAL COMPANION'
                            : 'TEMAN UNDANG-UNDANG ANDA',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.languages,
                          color: Color(0xFF1A1F2C), size: 20),
                      onPressed: _showLanguagePicker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                isEn
                    ? "How can we help you?"
                    : "Bagaimana kami boleh membantu?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1A1F2C),
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureButton(
                context,
                icon: LucideIcons.fileSearch,
                title: isEn ? 'Analyze Document' : 'Analisis Dokumen',
                description: isEn
                    ? 'Understand risks in your contracts.'
                    : 'Fahami risiko dalam kontrak anda.',
                route: '/analyze',
                accentColor: const Color(0xFF162235),
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.messageSquare,
                title: isEn ? 'Legal Chat' : 'Sembang Undang-Undang',
                description: isEn
                    ? 'Ask questions about your rights.'
                    : 'Tanya soalan tentang hak anda.',
                route: '/chat',
                accentColor: Colors.purple,
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.fileText,
                title: isEn ? 'Generate Letter' : 'Jana Surat',
                description: isEn
                    ? 'Create formal complaint drafts.'
                    : 'Buat draf aduan rasmi.',
                route: '/letter',
                accentColor: Colors.orange,
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.bookOpen,
                title: isEn ? 'Know Your Rights' : 'Kenali Hak Anda',
                description: isEn
                    ? 'Learn about local laws easily.'
                    : 'Pelajari undang-undang tempatan.',
                route: '/rights',
                accentColor: Colors.teal,
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  isEn
                      ? 'FOR EDUCATIONAL PURPOSES ONLY'
                      : 'UNTUK TUJUAN PENDIDIKAN SAHAJA',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          splashColor: accentColor.withOpacity(0.05),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1A1F2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
