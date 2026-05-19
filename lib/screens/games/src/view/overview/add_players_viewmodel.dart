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
  String? errorMessage;

  /// Set by [togglePlayer] when [canAddMore] is false.
  /// The view should read this and show a SnackBar, then clear it.
  String? feedbackMessage;

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
      _addToRecent(user);
    }

    notifyListeners();
  }

  /// Called by the view after it has displayed [feedbackMessage].
  void clearFeedbackMessage() {
    feedbackMessage = null;
  }

  void _addToRecent(PadlyUser user) {
    recentPlayers.removeWhere((p) => p.id == user.id);
    recentPlayers.insert(0, user);

    if (recentPlayers.length > 6) {
      recentPlayers.removeLast();
    }
  }
}
