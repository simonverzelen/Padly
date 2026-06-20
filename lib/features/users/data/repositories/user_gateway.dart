import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:padly/features/users/domain/entities/padly_user.dart';

class UserGateway {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    await _firestore.collection('users').doc(user!.uid).delete();
    await user.delete();
  }

  Future<void> updateUser(types.User user) async {
    if (user.id != _auth.currentUser!.uid) return;
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> updateUserWithJson(Map<String, dynamic> data) async {
    User user = FirebaseAuth.instance.currentUser!;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      print("User updated: ${user.uid}");
    } catch (e) {
      print("error in saving to firestore");
      print(e.toString());
    }
  }

  Future<void> saveUserToken(String? token) async {
    User user = FirebaseAuth.instance.currentUser!;
    if (token == null) {
      print("No token to save for user: ${user.uid}");
      return;
    }
    Map<String, dynamic> data = {
      'fcmTokens': FieldValue.arrayUnion([token]),
    };

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      print("Document Added to ${user.uid}");
    } catch (e) {
      print("error in saving to firestore");
      print(e.toString());
    }
  }

  Future<void> removeFcmToken(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (token == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  Future<PadlyUser?> fetchUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final PadlyUser user = PadlyUser.fromJson({'id': userDoc.id, ...data});
      return user;
    }
    return null;
  }

  Future<List<PadlyUser>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .where('searchKeywords', arrayContains: normalizedQuery)
        .limit(50)
        .get();

    final results = snapshot.docs
        //.where((doc) => doc.id != currentUserId)
        .map(
          (doc) => PadlyUser.fromJson({
            'id': doc.id,
            ...doc.data(),
          }),
        )
        .toSet()
        .toList();

    print(results);

    return results;
  }
}
