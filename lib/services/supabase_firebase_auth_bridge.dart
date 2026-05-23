import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFirebaseAuthBridge {
  final SupabaseClient supabase;

  SupabaseFirebaseAuthBridge(this.supabase);

  String? _jwt;
  String? get jwt => _jwt;

  Future<void> signInToSupabaseWithFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Gebruiker niet ingelogd');

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
    // RISK: mutating the shared REST client header is not thread-safe and will
    // affect all concurrent requests. A full per-request auth header approach
    // should be implemented in a future refactor.
    supabase.rest.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> updateUserSupabase(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("Not logged in");

    final firstName = data['firstName'];
    final lastName = data['lastName'];

    await supabase.from('profiles').upsert({
      'firebase_uid': currentUser.uid,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': '$firstName $lastName',
      'location': null,
      'last_seen': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'firebase_uid');
  }

  Future<bool> profileExistsInSupabase(String firebaseUid) async {
    final response = await supabase
        .from('profiles')
        .select('firebase_uid')
        .eq('firebase_uid', firebaseUid)
        .maybeSingle();
    return response != null;
  }

  Future<void> syncProfileFromFirestore(
      Map<String, dynamic> firestoreData, String firebaseUid) async {
    final firstName = firestoreData['firstName'] as String?;
    final lastName = firestoreData['lastName'] as String?;
    final fullName = firestoreData['name'] as String? ??
        '${firstName ?? ''} ${lastName ?? ''}'.trim();

    await supabase.from('profiles').upsert({
      'firebase_uid': firebaseUid,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': firestoreData['email'] as String?,
      'avatar_url': firestoreData['imageUrl'] as String?,
      'last_seen': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'firebase_uid');
  }

  Future<void> updateUserPreferences({String? sport, String? language}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await supabase.from('profiles').update({
      if (sport != null) 'selected_sport': sport,
      if (language != null) 'preferred_language': language,
    }).eq('firebase_uid', uid);
  }

  Future<void> updateSportsAndLevels({
    required List<String> selectedSports,
    required Map<String, String> sportLevels,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await supabase.from('profiles').update({
      'selected_sports': selectedSports,
      'sport_levels': sportLevels,
    }).eq('firebase_uid', uid);
  }

  void signOut() {
    _jwt = null;
    supabase.rest.headers.remove('Authorization');
  }
}
