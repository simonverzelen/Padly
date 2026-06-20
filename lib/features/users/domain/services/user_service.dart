import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:padly/core/services/supabase_firebase_auth_bridge.dart';
import 'package:padly/features/users/data/repositories/user_gateway.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';

class UserService {
  final UserGateway _userGateway = UserGateway();
  final SupabaseFirebaseAuthBridge _supabaseAuthBridge =
      SupabaseFirebaseAuthBridge(Supabase.instance.client);

  Future<void> updateUser(types.User user) async {
    await _userGateway.updateUser(user);
  }

  Future<void> updateUserWithJson(Map<String, dynamic> data) async {
    await _userGateway.updateUserWithJson(data);
    await _supabaseAuthBridge.updateUserSupabase(data);
  }

  Future<void> saveUserToken(String? token) async {
    await _userGateway.saveUserToken(token);
  }

  Future<void> removeUserToken(String? token) async {
    await _userGateway.removeFcmToken(token);
  }

  Future<PadlyUser?> getUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return await _userGateway.fetchUserData(user.uid);
  }

  Future<List<PadlyUser>> searchPlayers(String query) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    return _userGateway.searchUsers(
      query: query,
      currentUserId: currentUser.uid,
    );
  }

  //upload to firestore
  Future<String> uploadImageToFirebase(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser!;
    final String fileExt = imageFile.path.split('.').last;
    final String fileName = 'profile${user.uid}.$fileExt';
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> saveSportsAndLevels({
    required List<String> selectedSports,
    required Map<String, String> sportLevels,
  }) async {
    await _userGateway.updateUserWithJson({
      'selectedSports': selectedSports,
      'sportLevels': sportLevels,
    });
    await _supabaseAuthBridge.updateSportsAndLevels(
      selectedSports: selectedSports,
      sportLevels: sportLevels,
    );
  }

  Future<void> saveImageUrlToFirestore(String downloadUrl) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'imageUrl': downloadUrl,
    });
  }
}
