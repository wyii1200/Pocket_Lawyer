import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'Pocket Lawyer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1A1F2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'YOUR LEGAL COMPANION',
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
                      icon:
                          const Icon(Icons.language, color: Color(0xFF1A1F2C)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "How can we help you?",
                style: TextStyle(
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
                title: 'Analyze Document',
                description: 'Understand risks in your contracts.',
                route: '/analyze',
                accentColor: Colors.blue,
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.messageSquare,
                title: 'Legal Chat',
                description: 'Ask questions about your rights.',
                route: '/chat',
                accentColor: Colors.purple,
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.fileText,
                title: 'Generate Letter',
                description: 'Create formal complaint drafts.',
                route: '/letter',
                accentColor: Colors.orange,
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.bookOpen,
                title: 'Know Your Rights',
                description: 'Learn about local laws easily.',
                route: '/rights',
                accentColor: Colors.teal,
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'FOR EDUCATIONAL PURPOSES ONLY',
                  style: TextStyle(
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
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 26,
                  ),
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
