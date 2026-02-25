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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF162235)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Legal Resources' : 'Sumber Undang-Undang',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Disclaimer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF162235).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isEn ? 'EDUCATIONAL PURPOSES ONLY' : 'TUJUAN PENDIDIKAN SAHAJA',
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF162235),
                    letterSpacing: 1.2,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  hintText: isEn
                      ? "Search laws or topics..."
                      : "Cari undang-undang...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(LucideIcons.search,
                      size: 18, color: Color(0xFF162235)),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF162235), width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rights List
            if (filteredRights.isEmpty)
              _buildEmptyState(isEn)
            else
              ...filteredRights.asMap().entries.map((entry) {
                return _buildRightsCard(entry.key, entry.value, isEn);
              }),

            const SizedBox(height: 32),

            // Bottom Disclaimer
            Text(
              isEn
                  ? 'Pocket Lawyer is an AI assistant and does not provide legal advice. Always consult a qualified lawyer for legal matters.'
                  : 'Pocket Lawyer adalah pembantu AI dan tidak memberikan nasihat undang-undang. Sentiasa rujuk peguam bertauliah untuk urusan undang-undang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  height: 1.5,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRightsCard(int index, Map<String, dynamic> item, bool isEn) {
    bool isExpanded = _expandedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isExpanded
                ? const Color(0xFF162235).withOpacity(0.2)
                : Colors.transparent),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: GlobalKey(),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) async {
            setState(() => _expandedIndex = expanded ? index : null);
            if (expanded) {
              await HistoryService.saveHistory(
                type: "Know Your Rights",
                summary: item['title'],
                metadata: {
                  "act": item['act'],
                  "summary": item['summary'],
                  "details": item['details'],
                },
              );
            }
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF162235).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(item['icon'], size: 22, color: const Color(0xFF162235)),
          ),
          title: Text(item['title'],
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item['act'].toString().toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey[700])),
                ),
                const SizedBox(height: 8),
                Text(item['summary'],
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.4,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.bookOpen,
                          size: 14, color: Color(0xFF162235)),
                      const SizedBox(width: 8),
                      Text(isEn ? 'IN-DEPTH VIEW' : 'PENERANGAN LANJUT',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              color: Color(0xFF162235))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item['details'],
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.6,
                          fontFamily: 'Poppins')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isEn) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            isEn
                ? "No matching legal topics found."
                : "Tiada topik undang-undang ditemui.",
            style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
