import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase_firebase_auth_bridge.dart';
import '../domain/create_game.dart';
import '../domain/game.dart';

class GamesGateway {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient supabase;
  final SupabaseFirebaseAuthBridge authBridge;

  GamesGateway({required this.supabase, required this.authBridge});

  Future<List<Game>> fethcGames() async {
    try {
      final dataDoc = await _firestore.collection('games').get();
      final data = dataDoc.docs.map((doc) => doc.data()).toList();
      return List<Game>.from(
        data.map((gameData) => Game.fromJson(gameData)).toList(),
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<Game>?> fetchSupabaseGames({
    String sport = 'Padel',
    double lat = 50.83,
    double lng = 3.26,
  }) async {
    try {
      final response = await supabase.rpc('get_games_filtered', params: {
        'search_lon': lng,
        'search_lat': lat,
        'search_radius_km': 100,
        'min_ranking': null,
        'max_ranking': null,
        'start_time': null,
        'end_time': null,
        'sort_by': 'distance',
        'sort_direction': 'asc',
        'sport_name': sport,
      });
      final data = response as List<dynamic>;
      return List<Game>.from(
        data.map((gameData) => Game.fromJson(gameData)).toList(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createGame(GameCreate game) async {
    try {
      await authBridge.applyAuthHeader();
      final insertedRow = await supabase
          .from('games')
          .insert({...game.toInsertJson()})
          .select()
          .single();
      return insertedRow;
    } catch (e) {
      throw Exception('Game aanmaken mislukt: $e');
    }
  }

  Future<void> requestToJoin(String gameId, Map<String, dynamic> userJson) async {
    await authBridge.applyAuthHeader();
    await supabase.rpc('request_to_join', params: {
      'game_id': gameId,
      'user_json': userJson,
    });
  }

  Future<void> cancelJoinRequest(String gameId, String userId) async {
    await authBridge.applyAuthHeader();
    await supabase.rpc('cancel_join_request', params: {
      'game_id': gameId,
      'user_id': userId,
    });
  }

  Future<void> updateJoinRequests(
    String gameId,
    List<Map<String, dynamic>> newRequests,
  ) async {
    await authBridge.applyAuthHeader();
    await supabase
        .from('games')
        .update({'join_requests': newRequests})
        .eq('id', gameId);
  }

  Future<void> acceptRequest(
    String gameId,
    List<Map<String, dynamic>> newCurrentPlayers,
    List<Map<String, dynamic>> newJoinRequests,
  ) async {
    await authBridge.applyAuthHeader();
    await supabase.from('games').update({
      'current_players': newCurrentPlayers,
      'join_requests': newJoinRequests,
    }).eq('id', gameId);
  }

  Future<void> removePlayer(
    String gameId,
    List<Map<String, dynamic>> newCurrentPlayers,
  ) async {
    await authBridge.applyAuthHeader();
    await supabase
        .from('games')
        .update({'current_players': newCurrentPlayers})
        .eq('id', gameId);
  }

  Future<void> removePlayerSelf(String gameId, String userId) async {
    await authBridge.applyAuthHeader();
    await supabase.rpc('remove_player_self', params: {
      'p_game_id': gameId,
      'p_user_id': userId,
    });
  }

  Future<void> updateGame(String gameId, GameCreate game) async {
    await authBridge.applyAuthHeader();
    await supabase
        .from('games')
        .update(game.toInsertJson())
        .eq('id', gameId);
  }

  Future<void> deleteGame(String gameId) async {
    await authBridge.applyAuthHeader();
    await supabase.from('games').delete().eq('id', gameId);
  }

  Future<Game?> fetchGame(String gameId) async {
    await authBridge.applyAuthHeader();
    final row = await supabase.from('games').select().eq('id', gameId).single();
    return Game.fromJson(row);
  }
}
