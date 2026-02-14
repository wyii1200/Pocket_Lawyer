import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  
  String _searchQuery = "";
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "All",
    "Document Analysis",
    "Letter Generation"
  ];


  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F2C),
        elevation: 1,
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search your legal history...",
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. CATEGORY CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _categories.map((category) {
                bool isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool value) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF1A1F2C).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF1A1F2C)
                          : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF1A1F2C)
                            : Colors.transparent),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. FILTERED LIST
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No records found."));
                }

                // Apply both Search and Category filters
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final type = doc['type'].toString();
                  final summary = doc['summary'].toString().toLowerCase();

                  bool matchesSearch =
                      type.toLowerCase().contains(_searchQuery) ||
                          summary.contains(_searchQuery);
                  bool matchesCategory =
                      _selectedCategory == "All" || type == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No matches found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final item = filteredDocs[index];
                    return _buildDismissibleItem(item, uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleItem(DocumentSnapshot item, String uid) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('history')
            .doc(item.id)
            .delete();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Entry deleted")));
      },
      child: _buildHistoryItem(
        type: item['type'],
        summary: item['summary'],
        date: item['createdAt'] ?? Timestamp.now(),
      ),
    );
  }

  Widget _buildHistoryItem(
      {required String type,
      required String summary,
      required Timestamp date}) {
    DateTime dt = date.toDate();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            type == "Document Analysis"
                ? LucideIcons.fileSearch
                : LucideIcons.fileText,
            size: 20,
            color: const Color(0xFF1A1F2C),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text("${dt.day}/${dt.month}/${dt.year}",
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
