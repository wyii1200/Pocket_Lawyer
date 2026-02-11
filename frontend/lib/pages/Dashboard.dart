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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pocket Lawyer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'YOUR LEGAL COMPANION',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 40),

              // FEATURE CARDS
              _buildFeatureButton(
                context,
                icon: LucideIcons.fileSearch,
                title: 'Analyze Document',
                description: 'Understand risks in your contracts.',
                route: '/analyze',
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.messageSquare,
                title: 'Legal Chat',
                description: 'Ask questions about your rights.',
                route: '/chat',
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.fileText,
                title: 'Generate Letter',
                description: 'Create formal complaint drafts.',
                route: '/letter',
              ),
              _buildFeatureButton(
                context,
                icon: LucideIcons.bookOpen,
                title: 'Know Your Rights',
                description: 'Learn about local laws easily.',
                route: '/rights',
              ),

              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'FOR EDUCATIONAL PURPOSES ONLY',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey, fontFamily: 'Poppins'),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: const Color(0xFF1A1F2C),
                    size: 24,
                    semanticLabel: title),
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
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
