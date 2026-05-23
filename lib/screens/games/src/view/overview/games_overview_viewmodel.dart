import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padly/screens/games/games.dart';
import 'package:padly/screens/games/src/data/sports_repository.dart';
import 'package:padly/screens/games/src/data/user_preferences_cache.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';
import 'package:padly/services/supabase_firebase_auth_bridge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamesOverviewViewmodel with ChangeNotifier {
  final _prefsCache = UserPreferencesCache();
  final _bridge = SupabaseFirebaseAuthBridge(Supabase.instance.client);

  List<Game> _games = [];
  List<Game> get games => _games;

  List<Game> get myGames {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    return _games
        .where((g) => g.currentPlayers?.any((p) => p.id == uid) == true)
        .toList();
  }

  PadlyUser? _currentUser;
  PadlyUser? get currentUser => _currentUser;

  List<String> availableSports = [];

  String _selectedSport = 'Padel';
  String get selectedSport => _selectedSport;

  Future<void> setSelectedSport(String sport) async {
    _selectedSport = sport;
    notifyListeners();
    await _prefsCache.saveSelectedSport(sport);
    _bridge.updateUserPreferences(sport: sport);
    await refresh();
  }

  bool isLoading = false;
  String? errorMessage;

  GamesOverviewViewmodel() {
    init();
  }

  final GamesServices _gamesServices = GamesServices();

  Future<void> init() async {
    _selectedSport = await _prefsCache.getSelectedSport();
    availableSports = await SportsRepository.instance.getSports();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _games = await _gamesServices.fetchGames(sport: _selectedSport);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }

    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await UserService().getUser();
    _currentUser = user;
    notifyListeners();
  }

  Future<void> refresh() async {
    errorMessage = null;
    try {
      _games = await _gamesServices.fetchGames(sport: _selectedSport);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
