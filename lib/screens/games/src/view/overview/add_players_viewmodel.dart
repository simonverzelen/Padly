import 'package:flutter/material.dart';

import '../../../../user_info/src/domain/padly_user.dart';
import '../../../../user_info/src/domain/user_service.dart';
import '../../data/recent_players_cache.dart';

class AddPlayersViewModel extends ChangeNotifier {
  AddPlayersViewModel({
    required this.maxPlayers,
    required List<PadlyUser> initialPlayers,
    required this.userService,
    this.lockedPlayerId,
    RecentPlayersCache? cache,
  })  : selectedPlayers = [...initialPlayers],
        _initialIds = initialPlayers.map((p) => p.id).toSet(),
        _cache = cache ?? RecentPlayersCache() {
    _loadRecentPlayers();
  }

  final int maxPlayers;
  final UserService userService;
  final String? lockedPlayerId;
  final RecentPlayersCache _cache;
  final Set<String?> _initialIds;

  final List<PadlyUser> selectedPlayers;
  List<PadlyUser> _cachedRecent = [];

  bool get hasChanges {
    final currentIds = selectedPlayers.map((p) => p.id).toSet();
    return !currentIds.containsAll(_initialIds) ||
        !_initialIds.containsAll(currentIds);
  }

  List<PadlyUser> get recentPlayers => _cachedRecent
      .where((p) => !isSelected(p) && p.id != lockedPlayerId)
      .toList();

  List<PadlyUser> searchResults = [];
  String searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  String? feedbackMessage;

  bool get isSearching => searchQuery.isNotEmpty;

  bool isSelected(PadlyUser user) =>
      selectedPlayers.any((p) => p.id == user.id);

  bool get canAddMore => selectedPlayers.length < maxPlayers;

  Future<void> _loadRecentPlayers() async {
    try {
      _cachedRecent = await _cache.load();
    } catch (_) {
      await _cache.clear();
      _cachedRecent = [];
    }
    notifyListeners();
  }

  Future<void> setSearch(String value) async {
    searchQuery = value.trim();
    errorMessage = null;

    if (searchQuery.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      searchResults = await userService.searchPlayers(searchQuery);
    } catch (e) {
      errorMessage = e.toString();
      searchResults = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void togglePlayer(PadlyUser user) {
    if (lockedPlayerId != null && user.id == lockedPlayerId) return;

    final index = selectedPlayers.indexWhere((p) => p.id == user.id);

    if (index >= 0) {
      selectedPlayers.removeAt(index);
    } else {
      if (!canAddMore) {
        feedbackMessage = 'Maximum aantal spelers bereikt ($maxPlayers)';
        notifyListeners();
        return;
      }
      selectedPlayers.add(user);
      _persistToRecent(user);
    }

    notifyListeners();
  }

  void addGuestPlayer() {
    if (!canAddMore) {
      feedbackMessage = 'Maximum aantal spelers bereikt ($maxPlayers)';
      notifyListeners();
      return;
    }
    final guest = PadlyUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      firstName: 'Gast',
    );
    selectedPlayers.add(guest);
    searchQuery = '';
    searchResults = [];
    notifyListeners();
  }

  void clearFeedbackMessage() {
    feedbackMessage = null;
  }

  void _persistToRecent(PadlyUser user) {
    // Don't cache guests or users without an id.
    if (user.id == null || (user.id!.startsWith('guest_'))) return;

    _cachedRecent.removeWhere((p) => p.id == user.id);
    _cachedRecent.insert(0, user);

    _cache.save(_cachedRecent);
  }
}
