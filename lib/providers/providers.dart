import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/games/src/data/games_gateway.dart';
import '../screens/games/src/data/sports_repository.dart';
import '../screens/games/src/data/user_preferences_cache.dart';
import '../screens/games/src/domain/game.dart';
import '../screens/user_info/src/domain/padly_user.dart';
import '../screens/user_info/src/domain/user_service.dart';
import '../services/supabase_firebase_auth_bridge.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authBridgeProvider = Provider<SupabaseFirebaseAuthBridge>((ref) {
  return SupabaseFirebaseAuthBridge(ref.watch(supabaseClientProvider));
});

final gamesGatewayProvider = Provider<GamesGateway>((ref) {
  return GamesGateway(
    supabase: ref.watch(supabaseClientProvider),
    authBridge: ref.watch(authBridgeProvider),
  );
});

// ── Auth ───────────────────────────────────────────────────────────────────

final firebaseAuthStateProvider = StreamProvider<fb_auth.User?>((ref) {
  return fb_auth.FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = FutureProvider<PadlyUser?>((ref) async {
  final firebaseUser = ref.watch(firebaseAuthStateProvider).asData?.value;
  if (firebaseUser == null) return null;
  try {
    return await UserService().getUser();
  } catch (_) {
    return null;
  }
});

// ── Location ───────────────────────────────────────────────────────────────

class LocationState {
  final double? lat;
  final double? lng;
  final bool isDenied;

  const LocationState({this.lat, this.lng, this.isDenied = false});

  /// Falls back to Kortrijk when no device location is available.
  double get effectiveLat => lat ?? 50.83;
  double get effectiveLng => lng ?? 3.26;
}

final locationProvider = FutureProvider<LocationState>((ref) async {
  final status = await ph.Permission.location.status;
  if (!status.isGranted) {
    final result = await ph.Permission.location.request();
    if (!result.isGranted) return const LocationState(isDenied: true);
  }
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LocationState(lat: position.latitude, lng: position.longitude);
  } catch (_) {
    return const LocationState();
  }
});

// ── Sports ─────────────────────────────────────────────────────────────────

final sportNamesProvider = FutureProvider<List<String>>((ref) async {
  return SportsRepository.instance.getSports();
});

// ── Selected sport (persisted in SharedPreferences) ────────────────────────

final selectedSportProvider =
    StateNotifierProvider<SelectedSportNotifier, String>((ref) {
  return SelectedSportNotifier();
});

class SelectedSportNotifier extends StateNotifier<String> {
  final _cache = UserPreferencesCache();

  SelectedSportNotifier() : super('Padel') {
    _load();
  }

  Future<void> _load() async {
    state = await _cache.getSelectedSport();
  }

  Future<void> setSport(String sport) async {
    state = sport;
    await _cache.saveSelectedSport(sport);
  }
}

// ── Games stream (real-time via Supabase Realtime + RPC re-fetch) ──────────

/// Family parameter is the sport name.
/// Provider auto-disposes (and cleans up the Realtime channel) when not watched.
final gamesStreamProvider =
    StreamProvider.autoDispose.family<List<Game>, String>((ref, sport) {
  final gateway = ref.watch(gamesGatewayProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final location =
      ref.watch(locationProvider).asData?.value ?? const LocationState();

  final controller = StreamController<List<Game>>();

  // Initial fetch
  gateway
      .fetchSupabaseGames(
        sport: sport,
        lat: location.effectiveLat,
        lng: location.effectiveLng,
      )
      .then((games) {
    if (!controller.isClosed) controller.add(games ?? []);
  });

  // Subscribe to Realtime changes on the games table.
  // On any INSERT/UPDATE/DELETE, re-fetch the full filtered list from the RPC
  // (direct row payloads don't include distance/ranking computed by the RPC).
  final channel = supabase
      .channel('games-realtime-$sport')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'games',
        callback: (payload) async {
          final games = await gateway.fetchSupabaseGames(
            sport: sport,
            lat: location.effectiveLat,
            lng: location.effectiveLng,
          );
          if (!controller.isClosed) controller.add(games ?? []);
        },
      )
      .subscribe();

  ref.onDispose(() {
    controller.close();
    supabase.removeChannel(channel);
  });

  return controller.stream;
});
