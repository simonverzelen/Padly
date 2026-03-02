import 'package:flutter/material.dart';

import '../../../../user_info/src/domain/padly_user.dart';
import '../../../../user_info/src/domain/user_service.dart';

class AddPlayersViewModel extends ChangeNotifier {
  AddPlayersViewModel({
    required this.maxPlayers,
    required List<PadlyUser> initialPlayers,
    required this.userService,
  }) : selectedPlayers = [...initialPlayers];

  final int maxPlayers;
  final UserService userService;

  final List<PadlyUser> selectedPlayers;
  final List<PadlyUser> recentPlayers = [];

  List<PadlyUser> searchResults = [];
  String searchQuery = '';
  bool isLoading = false;

  // --------------------
  // Derived state
  // --------------------

  bool get isSearching => searchQuery.isNotEmpty;

  bool isSelected(PadlyUser user) =>
      selectedPlayers.any((p) => p.id == user.id);

  bool get canAddMore => selectedPlayers.length < maxPlayers;

  // --------------------
  // Actions
  // --------------------

  void setSearch(String value) async {
    searchQuery = value.trim();

    if (searchQuery.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    searchResults = await userService.searchPlayers(searchQuery);

    isLoading = false;
    notifyListeners();
  }

  void togglePlayer(PadlyUser user) {
    final index = selectedPlayers.indexWhere((p) => p.id == user.id);

    if (index >= 0) {
      selectedPlayers.removeAt(index);
    } else {
      if (!canAddMore) return;
      selectedPlayers.add(user);
      _addToRecent(user);
    }

    notifyListeners();
  }

  void _addToRecent(PadlyUser user) {
    recentPlayers.removeWhere((p) => p.id == user.id);
    recentPlayers.insert(0, user);

    if (recentPlayers.length > 6) {
      recentPlayers.removeLast();
    }
  }
}
