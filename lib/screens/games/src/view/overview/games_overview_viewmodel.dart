import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padly/screens/games/games.dart';

class GamesOverviewViewmodel with ChangeNotifier {
  List<Game> _games = [];
  List<Game> get games => _games;

  List<Game> get myGames {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    return _games
        .where((g) => g.currentPlayers?.any((p) => p.id == uid) == true)
        .toList();
  }

  bool isLoading = false;
  String? errorMessage;

  GamesOverviewViewmodel() {
    init();
  }

  final GamesServices _gamesServices = GamesServices();

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _games = await _gamesServices.fetchGames();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _games = await _gamesServices.fetchGames();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
