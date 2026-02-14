import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit $field",
                  style: const TextStyle(fontFamily: 'Poppins')),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter your $field",
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
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
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Save"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFEDF2F7),
                    child: Icon(LucideIcons.user,
                        size: 48, color: Color(0xFF162235)),
                  ),
                  const SizedBox(height: 16),
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    icon: LucideIcons.user,
                    label: 'Full Name',
                    value: fullName,
                    dbField: 'fullName',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: LucideIcons.phone,
                    label: 'Phone Number',
                    value: phone,
                    dbField: 'phone',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: LucideIcons.mapPin,
                    label: 'Address',
                    value: address,
                    dbField: 'address',
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: const Text('Log Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ],
              ),
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
                    value.isEmpty ? "Tap to add" : value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.edit2, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
