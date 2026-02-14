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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
              ),
              _buildPage(
                icon: LucideIcons.messageSquare,
                title: isEn ? "Legal Assistant" : "Pembantu Undang-undang",
                description: isEn
                    ? "Chat with our AI-powered companion to understand your rights regarding tenancy, employment, and more."
                    : "Sembang dengan pembantu AI kami untuk memahami hak anda mengenai sewaan, pekerjaan, dan banyak lagi.",
              ),
              _buildPage(
                icon: LucideIcons.fileText,
                title: isEn ? "Generate Letters" : "Jana Surat",
                description: isEn
                    ? "Draft formal demand letters or complaint notices professionally with just a few simple details."
                    : "Draf surat tuntutan rasmi atau notis aduan secara profesional dengan hanya beberapa butiran mudah.",
              ),
            ],
          ),

          // SKIP BUTTON
          Container(
            alignment: const Alignment(0.85, -0.85),
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                isEn ? "Skip" : "Langkau",
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // BOTTOM CONTROLS
          Container(
            alignment: const Alignment(0, 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF162235),
                    dotColor: Color(0xFFE2E8F0),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_isLastPage) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162235),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isLastPage
                        ? (isEn ? "Get Started" : "Mula Sekarang")
                        : (isEn ? "Next" : "Seterusnya"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F4F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: const Color(0xFF162235)),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: Color(0xFF1A1F2C),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
