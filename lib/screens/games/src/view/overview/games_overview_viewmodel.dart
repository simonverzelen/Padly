import 'package:flutter/material.dart';
import 'package:padly/screens/games/games.dart';

class GamesOverviewViewmodel with ChangeNotifier {
  List<Game> _games = [];
  List<Game> get games => _games;

  GamesOverviewViewmodel() {
    init();
  }

  final GamesServices _gamesServices = GamesServices();

  Future<void> init() async {
    _games = await _gamesServices.fetchGames();
    notifyListeners();
  }

  Future<void> refresh() async {
    _games = await _gamesServices.fetchGames();
    notifyListeners();
  }
}
