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

  Future<List<Game>> fetchGames() async {
    try {
      final games = await _gamesGateway.fethSupabaseGames();
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
}
