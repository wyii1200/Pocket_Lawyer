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

  // --- ORIGIN FUNCTIONS (UNTOUCHED) ---
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

  // --- ENHANCED UI MODAL ---
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Allow for custom shape
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildLanguageOption('English', 'en'),
            const SizedBox(height: 8),
            _buildLanguageOption('Bahasa Melayu', 'ms'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String code) {
    bool isSelected = _selectedLang == code;
    return Material(
      color: isSelected
          ? const Color(0xFF162235).withOpacity(0.05)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(LucideIcons.globe,
            color: isSelected ? const Color(0xFF162235) : Colors.grey),
        title: Text(label,
            style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Poppins')),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF162235))
            : null,
        onTap: () {
          _changeLanguage(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC), // Slightly lighter/cleaner background
      body: Stack(
        // Using Stack for a subtle background accent
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: const Color(0xFF162235).withOpacity(0.03),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn
                                  ? 'Hello, $_userName 👋'
                                  : 'Helo, $_userName 👋',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: Color(0xFF1A1F2C),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF162235).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isEn
                                    ? 'YOUR LEGAL COMPANION'
                                    : 'TEMAN UNDANG-UNDANG ANDA',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF162235),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildIconButton(
                          LucideIcons.languages, _showLanguagePicker),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- WELCOME TEXT ---
                  Text(
                    isEn
                        ? "How can we help you?"
                        : "Bagaimana kami boleh membantu?",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- FEATURES GRID/LIST ---
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
                    accentColor: Colors.indigo,
                  ),
                  _buildFeatureButton(
                    context,
                    icon: LucideIcons.fileText,
                    title: isEn ? 'Generate Letter' : 'Jana Surat',
                    description: isEn
                        ? 'Create formal complaint drafts.'
                        : 'Buat draf aduan rasmi.',
                    route: '/letter',
                    accentColor: const Color(0xFFE67E22),
                  ),
                  _buildFeatureButton(
                    context,
                    icon: LucideIcons.bookOpen,
                    title: isEn ? 'Know Your Rights' : 'Kenali Hak Anda',
                    description: isEn
                        ? 'Learn about local laws easily.'
                        : 'Pelajari undang-undang tempatan.',
                    route: '/rights',
                    accentColor: const Color(0xFF0D9488),
                  ),

                  const SizedBox(height: 40),

                  // --- DISCLAIMER ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEn
                            ? 'FOR EDUCATIONAL PURPOSES ONLY'
                            : 'UNTUK TUJUAN PENDIDIKAN SAHAJA',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1A1F2C), size: 22),
        onPressed: onPressed,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.2),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontFamily: 'Poppins',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
