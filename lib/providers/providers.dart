import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/games/data/repositories/games_gateway.dart';
import '../features/games/data/repositories/sports_repository.dart';
import '../features/games/data/caches/user_preferences_cache.dart';
import '../features/games/domain/entities/game.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';
import 'package:padly/features/users/domain/services/user_service.dart';
import '../core/services/supabase_firebase_auth_bridge.dart';

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

// ── Game detail ────────────────────────────────────────────────────────────

final gameDetailProvider =
    FutureProvider.autoDispose.family<Game?, String>((ref, gameId) async {
  final gateway = ref.watch(gamesGatewayProvider);
  return gateway.fetchGame(gameId);
});

// ── My upcoming games ──────────────────────────────────────────────────────

final myGamesProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final gateway = ref.watch(gamesGatewayProvider);
  final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];
  return gateway.fetchMyGames(uid);
});

// ── Games stream (real-time via Supabase Realtime + RPC re-fetch) ──────────

/// Family parameter is the sport name.
/// Provider auto-disposes (and cleans up the Realtime channel) when not watched.
final gamesStreamProvider =
    StreamProvider.autoDispose.family<List<Game>, String>((ref, sport) {
  final gateway = ref.watch(gamesGatewayProvider);
  final supabase = ref.watch(supabaseClientProvider);

  final controller = StreamController<List<Game>>();

  Future<void> fetchAndEmit(LocationState location) async {
    final games = await gateway.fetchSupabaseGames(
      sport: sport,
      lat: location.effectiveLat,
      lng: location.effectiveLng,
    );
    if (!controller.isClosed) controller.add(games ?? []);
  }

  // Read current location without watching — avoids stream restart on location change.
  final initialLocation =
      ref.read(locationProvider).asData?.value ?? const LocationState();
  fetchAndEmit(initialLocation);

  // When real device location arrives, re-fetch into the same stream.
  ref.listen<AsyncValue<LocationState>>(locationProvider, (previous, next) {
    final loc = next.asData?.value;
    if (loc != null && loc.lat != null) {
      fetchAndEmit(loc);
    }
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
          final loc =
              ref.read(locationProvider).asData?.value ?? const LocationState();
          final games = await gateway.fetchSupabaseGames(
            sport: sport,
            lat: loc.effectiveLat,
            lng: loc.effectiveLng,
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
