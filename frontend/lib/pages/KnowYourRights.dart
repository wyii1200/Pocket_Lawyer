import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class KnowYourRightsPage extends StatefulWidget {
  const KnowYourRightsPage({super.key});

  @override
  State<KnowYourRightsPage> createState() => _KnowYourRightsPageState();
}

class _KnowYourRightsPageState extends State<KnowYourRightsPage> {
  int? _expandedIndex;
  String _searchQuery = "";
  String _selectedLang = 'en';

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

  List<Map<String, dynamic>> _getRights(bool isEn) {
    return [
      {
        'icon': LucideIcons.briefcase,
        'title': isEn ? 'Employment Rights' : 'Hak Pekerja',
        'act': 'Employment Act 1955',
        'summary': isEn
            ? 'Protects employees regarding minimum wages and leave entitlements.'
            : 'Melindungi pekerja berkaitan gaji minimum dan kelayakan cuti.',
        'details': isEn
            ? 'The Employment Act 1955 applies to employees earning up to RM4,000 per month. It covers rights such as maximum 48 working hours per week and 98 days maternity leave.'
            : 'Akta Kerja 1955 terpakai kepada pekerja yang bergaji sehingga RM4,000 sebulan. Ia merangkumi hak seperti maksimum 48 jam kerja seminggu dan 98 hari cuti bersalin.',
      },
      {
        'icon': LucideIcons.home,
        'title': isEn ? 'Tenant Rights' : 'Hak Penyewa',
        'act': 'National Land Code 1965',
        'summary': isEn
            ? 'Protects tenants regarding tenancy agreements and occupancy.'
            : 'Melindungi penyewa berkaitan perjanjian sewa dan hak kediaman.',
        'details': isEn
            ? 'In Malaysia, tenant rights are protected through valid agreements. Landlords must provide adequate notice before termination and maintain habitable premises.'
            : 'Di Malaysia, hak penyewa dilindungi melalui perjanjian yang sah. Tuan rumah mesti memberi notis yang mencukupi sebelum penamatan dan menyelenggara premis.',
      },
      {
        'icon': LucideIcons.shoppingCart,
        'title': isEn ? 'Consumer Rights' : 'Hak Pengguna',
        'act': 'Consumer Protection Act 1999',
        'summary': isEn
            ? 'Protects consumers against unfair trade and defective goods.'
            : 'Melindungi pengguna daripada perdagangan tidak adil dan barangan rosak.',
        'details': isEn
            ? 'The Consumer Protection Act 1999 grants rights to safe goods and accurate information. The Tribunal for Consumer Claims handles claims up to RM50,000.'
            : 'Akta Perlindungan Pengguna 1999 memberi hak kepada barangan selamat dan maklumat tepat. Tribunal Tuntutan Pengguna mengendalikan tuntutan sehingga RM50,000.',
      },
      {
        'icon': LucideIcons.fileText,
        'title': isEn ? 'Contract Basics' : 'Asas Kontrak',
        'act': 'Contracts Act 1950',
        'summary': isEn
            ? 'Governs the formation and enforcement of contracts in Malaysia.'
            : 'Mengawal pembentukan dan penguatkuasaan kontrak di Malaysia.',
        'details': isEn
            ? 'The Contracts Act 1950 establishes that valid contracts require offer, acceptance, and consideration. Section 24 states unlawful agreements are void.'
            : 'Akta Kontrak 1950 menetapkan bahawa kontrak yang sah memerlukan tawaran, penerimaan, dan balasan. Seksyen 24 menyatakan perjanjian tidak sah adalah terbatal.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';
    final rightsList = _getRights(isEn);

    final filteredRights = rightsList.where((right) {
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
        title: Text(isEn ? 'Know Your Rights' : 'Kenali Hak Anda'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF162235),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              isEn
                  ? 'FOR EDUCATIONAL PURPOSES ONLY'
                  : 'UNTUK TUJUAN PENDIDIKAN SAHAJA',
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: isEn
                    ? "Search laws or topics..."
                    : "Cari undang-undang atau topik...",
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            if (filteredRights.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(isEn
                    ? "No matching legal topics found."
                    : "Tiada topik undang-undang ditemui."),
              )
            else
              ...filteredRights.asMap().entries.map((entry) {
                return _buildRightsCard(entry.key, entry.value, isEn);
              }),
            const SizedBox(height: 32),
            Text(
              isEn
                  ? 'Pocket Lawyer is an AI assistant and does not provide legal advice. Always consult a qualified lawyer for legal matters.'
                  : 'Pocket Lawyer adalah pembantu AI dan tidak memberikan nasihat undang-undang. Sentiasa rujuk peguam bertauliah untuk urusan undang-undang.',
              textAlign: TextAlign.center,
              style: const TextStyle(
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

  Widget _buildRightsCard(int index, Map<String, dynamic> item, bool isEn) {
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
          key: GlobalKey(),
          initiallyExpanded: _expandedIndex == index,
          onExpansionChanged: (expanded) {
            setState(() => _expandedIndex = expanded ? index : null);
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(item['icon'],
                size: 20, color: const Color(0xFF162235)), // 🔥 Brand Navy
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
                      color: Color(0xFF162235))),
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
                  Text(isEn ? 'LEARN MORE' : 'KETAHUI LEBIH LANJUT',
                      style: const TextStyle(
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
