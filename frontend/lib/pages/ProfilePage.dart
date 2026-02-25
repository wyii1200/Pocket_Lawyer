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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // --- UI DIALOG ---
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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(isEn ? "Update $field" : "Kemaskini $field",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              content: TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  hintText: isEn ? "Enter your $field" : "Masukkan $field anda",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Batal",
                      style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162235),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    bool isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEn ? 'Account Profile' : 'Profil Akaun',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF162235),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF162235)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // --- 1. PROFILE HEADER ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF162235).withOpacity(0.1),
                          width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFF162235),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : "U",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1A1F2C))),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF162235).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(email,
                        style: const TextStyle(
                            color: Color(0xFF162235),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),

                  const SizedBox(height: 40),

                  // --- 2. INFORMATION SECTION ---
                  _buildSectionTitle(
                      isEn ? "PERSONAL DETAILS" : "MAKLUMAT PERIBADI"),
                  _buildInfoCard(
                    icon: LucideIcons.user,
                    label: isEn ? 'Display Name' : 'Nama Paparan',
                    value: fullName,
                    dbField: 'fullName',
                    isEn: isEn,
                  ),
                  _buildInfoCard(
                    icon: LucideIcons.phone,
                    label: isEn ? 'Phone Number' : 'Nombor Telefon',
                    value: phone,
                    dbField: 'phone',
                    isEn: isEn,
                  ),
                  _buildInfoCard(
                    icon: LucideIcons.mapPin,
                    label: isEn ? 'Residential Address' : 'Alamat Kediaman',
                    value: address,
                    dbField: 'address',
                    isEn: isEn,
                  ),

                  const SizedBox(height: 32),

                  // --- 3. PREFERENCES SECTION ---
                  _buildSectionTitle(
                      isEn ? "APP PREFERENCES" : "TETAPAN APLIKASI"),
                  _buildLanguageToggle(isEn),

                  const SizedBox(height: 48),

                  // --- 4. LOGOUT ---
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: Text(isEn ? 'Sign Out' : 'Log Keluar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side:
                          const BorderSide(color: Colors.redAccent, width: 1.5),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Pocket Lawyer v1.0.0",
                    style: TextStyle(
                        color: Colors.blueGrey[200],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildLanguageToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.languages,
                size: 20, color: Color(0xFF162235)),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(isEn ? "Application Language" : "Bahasa Aplikasi",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
              value: _selectedLang,
              underline: const SizedBox(),
              icon: const Icon(LucideIcons.chevronDown, size: 14),
              items: const [
                DropdownMenuItem(
                    value: 'en',
                    child: Text("EN",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(
                    value: 'ms',
                    child: Text("MS",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
              ],
              onChanged: (val) {
                if (val != null) _changeLanguage(val);
              },
            ),
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
    required bool isEn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditDialog(label, value, dbField),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 20, color: const Color(0xFF162235)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        value.isEmpty
                            ? (isEn ? "Not set" : "Belum ditetapkan")
                            : value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.pencil, size: 14, color: Colors.blueGrey[100]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
