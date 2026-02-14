import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/Dashboard.dart';
import '../pages/HistoryPage.dart';
import '../pages/ProfilePage.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  int _currentIndex = 0;
  String _selectedLang = 'en';

  final List<Widget> _pages = [
    const DashboardPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

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

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding:
            EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _loadLanguage();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF162235),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.home),
              label: isEn ? 'Home' : 'Utama',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.clock),
              label: isEn ? 'History' : 'Sejarah',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.user),
              label: isEn ? 'Profile' : 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
