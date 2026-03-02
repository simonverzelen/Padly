import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase_firebase_auth_bridge.dart';
import '../domain/create_game.dart';
import '../domain/game.dart';

class GamesGateway {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final SupabaseClient supabase;
  final SupabaseFirebaseAuthBridge authBridge;

  GamesGateway({
    required this.supabase,
    required this.authBridge,
  });

  Future<List<Game>?> fethcGames() async {
    final dataDoc = await _firestore.collection('games').get();
    // return List<Game>.from(
    //   data.docs.map((doc) => Game.fromJson(doc.data())).toList(),
    // );

    final data = dataDoc.docs.map((doc) => doc.data()).toList();
    print(data);
    final List<Game> games = List<Game>.from(
      data.map((gameData) => Game.fromJson(gameData)).toList(),
    );
    return games;
  }

  Future<List<Game>?> fethSupabaseGames() async {
    try {
      final response = await supabase.rpc('get_games_filtered', params: {
        'search_lon': 3.26,
        'search_lat': 50.83,
        'search_radius_km': 100,
        'min_ranking': null,
        'max_ranking': null,
        'start_time': null,
        'end_time': null,
        'sort_by': 'price', //distance, ranking, price, start_time, endt_time,
        'sort_direction': 'asc',
      });

      final data = response as List<dynamic>;

      final List<Game> games = List<Game>.from(
        data.map((gameData) => Game.fromJson(gameData)).toList(),
      );
      return games;
    } catch (e) {
      print("Supabase error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> createGame(GameCreate game) async {
    await authBridge.signInToSupabaseWithFirebase();

    final insertedRow = await supabase
        .from('games')
        .insert({
          ...game.toInsertJson(),
        })
        .select()
        .single();
    return insertedRow;
  }
}
