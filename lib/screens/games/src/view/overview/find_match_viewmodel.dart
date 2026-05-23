import 'package:flutter/material.dart';
import 'package:padly/screens/games/games.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

class FindMatchViewmodel with ChangeNotifier {
  List<Game> _games = [];
  List<Game> get games => _games;

  PadlyUser? _currentUser;
  PadlyUser? get currentUser => _currentUser;

  bool isLoading = false;
  String? errorMessage;

  String _selectedSport = 'Padel';
  String get selectedSport => _selectedSport;
  void setSelectedSport(String sport) {
    _selectedSport = sport;
    notifyListeners();
  }

  FindMatchViewmodel() {
    init();
  }

  final GamesServices _gamesServices = GamesServices();

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _games = await _gamesServices.fetchGames();
      _currentUser = await UserService().getUser();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    errorMessage = null;
    try {
      _games = await _gamesServices.fetchGames();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
