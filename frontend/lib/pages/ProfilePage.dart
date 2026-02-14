import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//change to implement retrieving user data from firestore

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showEditDialog(String field, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter new $field",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateField(field, controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        fullName = doc['fullName'];
        email = doc['email'];
        phone = doc['phone'];
        address = doc['address'];
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _updateField(String field, String newValue) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({field: newValue});

    await _loadUserData(); // refresh UI
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1F2C),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFEDF2F7),
                child: Icon(LucideIcons.user, size: 44),
              ),
              const SizedBox(height: 16),

              Text(fullName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),

              const SizedBox(height: 32),


              //store user data in variables and display here
              _buildInfoCard(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  value: email,
                  fieldName: 'email',
                ),

              const SizedBox(height: 16),

              _buildInfoCard(
                  icon: LucideIcons.phone,
                  label: 'Phone Number',
                  value: phone,
                  fieldName: 'phone',
                ),

                _buildInfoCard(
                  icon: LucideIcons.mapPin,
                  label: 'Address',
                  value: address,
                  fieldName: 'address',
                ),

              const SizedBox(height: 32),

              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(LucideIcons.logOut),
                label: const Text('Log Out'),
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
      required String fieldName,
    }) {
      return InkWell(
      onTap: () => _showEditDialog(fieldName, value),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Tap to add" : value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 

 /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.languages),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF1A1F2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // 1. AVATAR & NAME
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFEDF2F7),
              child: Icon(LucideIcons.user, size: 44, color: Color(0xFF1A1F2C)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ahmad bin Ismail',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif'),
            ),
            const SizedBox(height: 4),
            const Text(
              'ahmad@example.com',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // 2. INFORMATION CARDS
            _buildInfoCard(
              icon: LucideIcons.mail,
              label: 'Email',
              value: 'ahmad@example.com',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: LucideIcons.phone,
              label: 'Phone Number',
              value: '+60 12-345 6789',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: LucideIcons.mapPin,
              label: 'Address',
              value: 'Kuala Lumpur, Malaysia',
            ),

            const SizedBox(height: 32),

            // 3. LOGOUT BUTTON
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(LucideIcons.logOut, size: 18),
              label: const Text('Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF1A1F2C)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/


