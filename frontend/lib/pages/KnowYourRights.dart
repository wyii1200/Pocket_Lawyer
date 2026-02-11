import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class KnowYourRightsPage extends StatefulWidget {
  const KnowYourRightsPage({super.key});

  @override
  State<KnowYourRightsPage> createState() => _KnowYourRightsPageState();
}

class _KnowYourRightsPageState extends State<KnowYourRightsPage> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _rights = [
    {
      'icon': LucideIcons.briefcase,
      'title': 'Employment Rights',
      'act': 'Employment Act 1955',
      'summary':
          'Protects employees regarding minimum wages, working hours, and leave entitlements.',
      'details':
          'The Employment Act 1955 applies to employees earning up to RM4,000 per month. It covers rights such as maximum 48 working hours per week and 98 days maternity leave.',
    },
    {
      'icon': LucideIcons.home,
      'title': 'Tenant Rights',
      'act': 'National Land Code 1965',
      'summary':
          'Protects tenants regarding tenancy agreements and occupancy rights.',
      'details':
          'In Malaysia, tenant rights are protected through valid agreements. Landlords must provide adequate notice before termination and maintain habitable premises.',
    },
    {
      'icon': LucideIcons.shoppingCart,
      'title': 'Consumer Rights',
      'act': 'Consumer Protection Act 1999',
      'summary':
          'Protects consumers against unfair trade practices and defective goods.',
      'details':
          'The Consumer Protection Act 1999 grants rights to safe goods and accurate information. The Tribunal for Consumer Claims handles claims up to RM50,000.',
    },
    {
      'icon': LucideIcons.fileText,
      'title': 'Contract Basics',
      'act': 'Contracts Act 1950',
      'summary':
          'Governs the formation and enforcement of contracts in Malaysia.',
      'details':
          'The Contracts Act 1950 establishes that valid contracts require offer, acceptance, and consideration. Section 24 states unlawful agreements are void.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Know Your Rights',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF1A1F2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Center(
              child: Text(
                'FOR EDUCATIONAL PURPOSES ONLY',
                style: TextStyle(
                    fontSize: 10, color: Colors.grey, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 24),
            ..._rights.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return _buildRightsCard(idx, item);
            }),
            const SizedBox(height: 24),
            const Text(
              'Pocket Lawyer is an AI assistant and does not provide legal advice. Always consult a qualified lawyer for legal matters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightsCard(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: GlobalKey(),
          initiallyExpanded: _expandedIndex == index,
          onExpansionChanged: (expanded) {
            setState(() => _expandedIndex = expanded ? index : null);
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item['icon'], size: 20, color: const Color(0xFF1A1F2C)),
          ),
          title: Text(item['title'],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins')),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item['act'].toString().toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Text(item['summary'],
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[700], height: 1.4)),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LEARN MORE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(item['details'],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5568), height: 1.6)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
