import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static Future<void> saveHistory({
    required String type,
    required String summary,
    Map<String, dynamic>? metadata,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'type': type,
      'summary': summary,
      'metadata': metadata ?? {},
      'createdAt': Timestamp.now(),
    });
  }
}
