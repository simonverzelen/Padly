import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFirebaseAuthBridge {
  final SupabaseClient supabase;

  SupabaseFirebaseAuthBridge(this.supabase);

  String? _jwt;
  String? get jwt => _jwt;

  Future<void> signInToSupabaseWithFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firebaseIdToken = await user.getIdToken(true);

    final res = await supabase.functions.invoke(
      'firebase-to-supabase',
      headers: {
        'x-firebase-token': 'Bearer $firebaseIdToken',
      },
    );

    if (res.status != 200) {
      throw Exception('Edge function failed (${res.status}): ${res.data}');
    }

    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String?;

    if (token == null || token.isEmpty) {
      throw Exception('No token returned by edge function');
    }

    _jwt = token;
    supabase.rest.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> updateUserSupabase(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("Not logged in");

    final firstName = data['firstName'];
    final lastName = data['lastName'];

    final response = await supabase.from('profiles').upsert({
      'firebase_uid': currentUser.uid,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': '$firstName $lastName',
      'location': null,
      'last_seen': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'firebase_uid');
  }

  void signOut() {
    _jwt = null;
    supabase.rest.headers.remove('Authorization');
  }
}
