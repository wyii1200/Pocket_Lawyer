import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/history_service.dart';


class KnowYourRightsPage extends StatefulWidget {
  const KnowYourRightsPage({super.key});

  @override
  State<KnowYourRightsPage> createState() => _KnowYourRightsPageState();
}

class _KnowYourRightsPageState extends State<KnowYourRightsPage> {
  int? _expandedIndex;
  String _searchQuery = "";

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
    // Filter logic
    final filteredRights = _rights.where((right) {
      final title = right['title'].toLowerCase();
      final act = right['act'].toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          act.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () async {
            if (_expandedIndex != null) {
              final right = _rights[_expandedIndex!];

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(right['title']),
                    content: Text(right['summary']),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );

              await HistoryService.saveHistory(
                type: "Know Your Rights",
                summary: right['title'],
                metadata: {
                  "act": right['act'],
                  "summary": right['summary'],
                  "details": right['details'],
                },
              );
            } else {
              Navigator.pop(context); // fallback if nothing expanded
            }
          }


        ),
        title: const Text('Know Your Rights'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'FOR EDUCATIONAL PURPOSES ONLY',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // SEARCH BAR
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search laws or topics...",
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),

            // LIST OF RIGHTS
            if (filteredRights.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("No matching legal topics found."),
              )
            else
              ...filteredRights.asMap().entries.map((entry) {
                return _buildRightsCard(entry.key, entry.value);
              }),

            const SizedBox(height: 32),
            const Text(
              'Pocket Lawyer is an AI assistant and does not provide legal advice. Always consult a qualified lawyer for legal matters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  height: 1.5,
                  fontStyle: FontStyle.italic),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: GlobalKey(), // Ensures proper state reset on search
          initiallyExpanded: _expandedIndex == index,
          onExpansionChanged: (expanded) {
            setState(() => _expandedIndex = expanded ? index : null);
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(item['icon'], size: 20, color: const Color(0xFF1A1F2C)),
          ),
          title: Text(item['title'],
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(item['act'].toString().toUpperCase(),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey)),
              const SizedBox(height: 6),
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
