import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase_firebase_auth_bridge.dart';
import '../data/games_gateway.dart';
import 'create_game.dart';
import 'game.dart';

class GamesServices {
  final GamesGateway _gamesGateway = GamesGateway(
    supabase: Supabase.instance.client,
    authBridge: SupabaseFirebaseAuthBridge(Supabase.instance.client),
  );

  Future<List<Game>> fetchGames({String sport = 'Padel'}) async {
    try {
      final games = await _gamesGateway.fetchSupabaseGames(sport: sport);
      return games ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGame(GameCreate game) async {
    try {
      return await _gamesGateway.createGame(game);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestToJoin(
    String gameId,
    Map<String, dynamic> userJson,
  ) async {
    try {
      await _gamesGateway.requestToJoin(gameId, userJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelJoinRequest(String gameId, String userId) async {
    try {
      await _gamesGateway.cancelJoinRequest(gameId, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateJoinRequests(
    String gameId,
    List<Map<String, dynamic>> newRequests,
  ) async {
    try {
      await _gamesGateway.updateJoinRequests(gameId, newRequests);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(
    String gameId,
    List<Map<String, dynamic>> newCurrentPlayers,
    List<Map<String, dynamic>> newJoinRequests,
  ) async {
    try {
      await _gamesGateway.acceptRequest(gameId, newCurrentPlayers, newJoinRequests);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePlayer(
    String gameId,
    List<Map<String, dynamic>> newCurrentPlayers,
  ) async {
    try {
      await _gamesGateway.removePlayer(gameId, newCurrentPlayers);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePlayerSelf(String gameId, String userId) async {
    try {
      await _gamesGateway.removePlayerSelf(gameId, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGame(String gameId, GameCreate game) async {
    try {
      await _gamesGateway.updateGame(gameId, game);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      await _gamesGateway.deleteGame(gameId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Game?> fetchGame(String gameId) async {
    try {
      return await _gamesGateway.fetchGame(gameId);
    } catch (e) {
      return null;
    }
  }
}
