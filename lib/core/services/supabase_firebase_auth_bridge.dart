import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFirebaseAuthBridge {
  final SupabaseClient supabase;
  SupabaseFirebaseAuthBridge(this.supabase);

  String? _cachedToken;
  DateTime? _tokenExpiry;
  Future<String>? _inflightFetch;

  Future<String> _fetchFreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Gebruiker niet ingelogd');

    final firebaseToken = await user.getIdToken(true);
    final res = await supabase.functions.invoke(
      'firebase-to-supabase',
      headers: {'x-firebase-token': 'Bearer $firebaseToken'},
    );
    if (res.status != 200) {
      throw Exception('Edge function failed (${res.status}): ${res.data}');
    }
    final token = (res.data as Map<String, dynamic>)['token'] as String;
    _cachedToken = token;
    // JWTs are 1 h; refresh 5 min early to avoid expiry during a long request.
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    return token;
  }

  /// Returns a valid Supabase JWT, fetching a new one only when necessary.
  /// Concurrent callers share the same in-flight request.
  Future<String> getValidToken() {
    final now = DateTime.now();
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!)) {
      return Future.value(_cachedToken!);
    }
    _inflightFetch ??=
        _fetchFreshToken().whenComplete(() => _inflightFetch = null);
    return _inflightFetch!;
  }

  /// Sets the Authorization header on the shared REST client.
  /// All callers in GamesGateway must await this before any mutating call.
  Future<void> applyAuthHeader() async {
    final token = await getValidToken();
    supabase.rest.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuth() {
    _cachedToken = null;
    _tokenExpiry = null;
    _inflightFetch = null;
    supabase.rest.headers.remove('Authorization');
  }

  // ── Profile sync methods (unchanged) ────────────────────────────────────

  Future<void> updateUserSupabase(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not logged in');
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

  /// Legacy alias — existing callers in AuthService still compile.
  Future<void> signInToSupabaseWithFirebase() => applyAuthHeader();

  void signOut() => clearAuth();
}
