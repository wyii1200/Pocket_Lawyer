import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _selectedLang = 'en';
  final TextEditingController _searchController = TextEditingController();

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
    bool isEn = _selectedLang == 'en';
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final List<String> categories = [
      isEn ? "All" : "Semua",
      "Document Analysis",
      "Letter Generation",
      "Know Your Rights"
    ];

    String displayCategory =
        (_selectedCategory == "Semua" || _selectedCategory == "All")
            ? "All"
            : _selectedCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEn ? 'Activity History' : 'Sejarah Aktiviti',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF162235),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: isEn ? "Search your history..." : "Cari sejarah...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(LucideIcons.search,
                    size: 18, color: Color(0xFF162235)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.xCircle,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF162235), width: 1),
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                bool isSelected = _selectedCategory == category;
                return Padding(
                  padding:
                      const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: const Color(0xFF162235),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('history')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF162235)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isEn, LucideIcons.history,
                      isEn ? "No records yet" : "Tiada rekod lagi");
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final type = doc['type'].toString();
                  final summary = doc['summary'].toString().toLowerCase();

                  bool matchesSearch =
                      type.toLowerCase().contains(_searchQuery) ||
                          summary.contains(_searchQuery);
                  bool matchesCategory =
                      displayCategory == "All" || type == displayCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState(isEn, LucideIcons.searchX,
                      isEn ? "No matches found" : "Tiada padanan");
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final item = filteredDocs[index];
                    return _buildDismissibleItem(item, uid, isEn);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isEn, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDismissibleItem(DocumentSnapshot item, String uid, bool isEn) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
      ),
      onDismissed: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('history')
            .doc(item.id)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEn ? "Entry deleted" : "Entri dipadam"),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: _buildHistoryCard(
        type: item['type'],
        summary: item['summary'],
        date: item['createdAt'] ?? Timestamp.now(),
        isEn: isEn,
      ),
    );
  }

  Widget _buildHistoryCard(
      {required String type,
      required String summary,
      required Timestamp date,
      required bool isEn}) {
    DateTime dt = date.toDate();
    String formattedDate = "${dt.day}/${dt.month}/${dt.year}";

    Color accentColor = type == "Document Analysis"
        ? const Color(0xFF162235)
        : type == "Letter Generation"
            ? const Color(0xFFE67E22)
            : const Color(0xFF0D9488);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type == "Document Analysis"
                    ? LucideIcons.fileSearch
                    : type == "Letter Generation"
                        ? LucideIcons.fileText
                        : LucideIcons.bookOpen,
                size: 22,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTypeLabel(type, isEn),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: accentColor,
                            fontFamily: 'Poppins'),
                      ),
                      Text(formattedDate,
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type, bool isEn) {
    if (type == "Document Analysis") return isEn ? "Analysis" : "Analisis";
    if (type == "Letter Generation") return isEn ? "Letter" : "Surat";
    if (type == "Know Your Rights") return isEn ? "Rights Guide" : "Panduan Hak";
    return type;
  }
}
