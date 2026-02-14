import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "";
  String email = "";
  String phone = "";
  String address = "";
  bool _isLoading = true;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLang = prefs.getString('app_language') ?? 'en';
      });
    }
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() => _selectedLang = lang);
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          fullName = doc['fullName'] ?? "";
          email = doc['email'] ?? "";
          phone = doc['phone'] ?? "";
          address = doc['address'] ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error loading user data: $e");
    }
  }

  void _showEditDialog(String field, String currentValue, String dbField) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    bool isSaving = false;
    bool isEn = _selectedLang == 'en';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(isEn ? "Edit $field" : "Sunting $field",
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isEn ? "Enter your $field" : "Masukkan $field anda",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162235),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          await _updateField(dbField, controller.text.trim());
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isEn ? "Save" : "Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateField(String field, String newValue) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({field: newValue});
      await _loadUserData();
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEn ? 'Profile' : 'Profil',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF162235),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF162235)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 1. HEADER SECTION
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFEDF2F7),
                    child: Icon(LucideIcons.user,
                        size: 48, color: const Color(0xFF162235)),
                  ),
                  const SizedBox(height: 16),
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 32),

                  // 2. PERSONAL INFO SECTION
                  _buildSectionTitle(
                      isEn ? "Personal Information" : "Maklumat Peribadi"),
                  _buildInfoCard(
                    icon: LucideIcons.user,
                    label: isEn ? 'Full Name' : 'Nama Penuh',
                    value: fullName,
                    dbField: 'fullName',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: LucideIcons.phone,
                    label: isEn ? 'Phone Number' : 'Nombor Telefon',
                    value: phone,
                    dbField: 'phone',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: LucideIcons.mapPin,
                    label: isEn ? 'Address' : 'Alamat',
                    value: address,
                    dbField: 'address',
                  ),

                  const SizedBox(height: 24),

                  // 3. SETTINGS SECTION (Language Picker)
                  _buildSectionTitle(isEn ? "Settings" : "Tetapan"),
                  _buildLanguageToggle(isEn),

                  const SizedBox(height: 40),

                  // 4. LOGOUT BUTTON
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: Text(isEn ? 'Log Out' : 'Log Keluar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEn
                        ? "Version 1.0.0 (KitaHack 2026)"
                        : "Versi 1.0.0 (KitaHack 2026)",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildLanguageToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.globe, size: 20, color: Color(0xFF162235)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(isEn ? "Language" : "Bahasa",
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          DropdownButton<String>(
            value: _selectedLang,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text("English")),
              DropdownMenuItem(value: 'ms', child: Text("B. Melayu")),
            ],
            onChanged: (val) {
              if (val != null) _changeLanguage(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required String dbField,
  }) {
    return InkWell(
      onTap: () => _showEditDialog(label, value, dbField),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF162235)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty
                        ? (_selectedLang == 'en'
                            ? "Tap to add"
                            : "Tambah maklumat")
                        : value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
