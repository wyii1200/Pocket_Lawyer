import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool _isLastPage = false;
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

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: const Color(0xFF162235).withOpacity(0.03),
            ),
          ),
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _isLastPage = index == 2);
            },
            children: [
              _buildPage(
                icon: LucideIcons.fileSearch,
                title: isEn ? "Analyze Documents" : "Analisis Dokumen",
                description: isEn
                    ? "Upload contracts or legal papers to identify potential risks and relevant legal references instantly."
                    : "Muat naik kontrak atau dokumen undang-undang untuk mengenal pasti risiko dan rujukan undang-undang dengan segera.",
                accent: const Color(0xFF162235),
              ),
              _buildPage(
                icon: LucideIcons.messageSquare,
                title: isEn ? "Legal Assistant" : "Pembantu Undang-undang",
                description: isEn
                    ? "Chat with our AI-powered companion to understand your rights regarding tenancy, employment, and more."
                    : "Sembang dengan pembantu AI kami untuk memahami hak anda mengenai sewaan, pekerjaan, dan banyak lagi.",
                accent: Colors.indigo,
              ),
              _buildPage(
                icon: LucideIcons.fileText,
                title: isEn ? "Generate Letters" : "Jana Surat",
                description: isEn
                    ? "Draft formal demand letters or complaint notices professionally with just a few simple details."
                    : "Draf surat tuntutan rasmi atau notis aduan secara profesional dengan hanya beberapa butiran mudah.",
                accent: const Color(0xFFE67E22),
              ),
            ],
          ),
          SafeArea(
            child: Container(
              alignment: const Alignment(0.9, -0.95),
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                child: Text(
                  isEn ? "SKIP" : "LANGKAU",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2),
                ),
              ),
            ),
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF162235),
                    dotColor: Color(0xFFE2E8F0),
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 4,
                    spacing: 8,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_isLastPage) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162235),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(64),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isLastPage
                          ? (isEn ? "GET STARTED" : "MULA SEKARANG")
                          : (isEn ? "NEXT" : "SETERUSNYA"),
                      key: ValueKey(_isLastPage),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 1.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.02)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 70, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              fontFamily: 'Serif',
              color: Color(0xFF162235),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.6,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
