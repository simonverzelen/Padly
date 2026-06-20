import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:padly/features/users/domain/entities/padly_user.dart';
import 'package:padly/features/users/domain/services/user_service.dart';
import 'package:padly/features/games/data/caches/recent_players_cache.dart';

class AddPlayersState {
  final int maxPlayers;
  final String? lockedPlayerId;
  final List<PadlyUser> selectedPlayers;
  final Set<String?> initialIds;
  final List<PadlyUser> cachedRecent;
  final List<PadlyUser> searchResults;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? feedbackMessage;

  const AddPlayersState({
    this.maxPlayers = 4,
    this.lockedPlayerId,
    this.selectedPlayers = const [],
    this.initialIds = const {},
    this.cachedRecent = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.feedbackMessage,
  });

  bool get isSearching => searchQuery.isNotEmpty;

  AddPlayersState copyWith({
    int? maxPlayers,
    Object? lockedPlayerId = _sentinel,
    List<PadlyUser>? selectedPlayers,
    Set<String?>? initialIds,
    List<PadlyUser>? cachedRecent,
    List<PadlyUser>? searchResults,
    String? searchQuery,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? feedbackMessage = _sentinel,
  }) {
    return AddPlayersState(
      maxPlayers: maxPlayers ?? this.maxPlayers,
      lockedPlayerId: identical(lockedPlayerId, _sentinel)
          ? this.lockedPlayerId
          : lockedPlayerId as String?,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      initialIds: initialIds ?? this.initialIds,
      cachedRecent: cachedRecent ?? this.cachedRecent,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      feedbackMessage: identical(feedbackMessage, _sentinel)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const Object _sentinel = Object();

class AddPlayersNotifier extends AutoDisposeNotifier<AddPlayersState> {
  final RecentPlayersCache _cache = RecentPlayersCache();
  final UserService _userService = UserService();

  @override
  AddPlayersState build() => const AddPlayersState();

  void init({
    required int maxPlayers,
    required List<PadlyUser> initialPlayers,
    String? lockedPlayerId,
  }) {
    state = AddPlayersState(
      maxPlayers: maxPlayers,
      lockedPlayerId: lockedPlayerId,
      selectedPlayers: List<PadlyUser>.from(initialPlayers),
      initialIds: initialPlayers.map((p) => p.id).toSet(),
    );
    _loadRecentPlayers();
  }

  bool get hasChanges {
    final currentIds = state.selectedPlayers.map((p) => p.id).toSet();
    return !currentIds.containsAll(state.initialIds) ||
        !state.initialIds.containsAll(currentIds);
  }

  List<PadlyUser> get recentPlayers => state.cachedRecent
      .where((p) => !isSelected(p) && p.id != state.lockedPlayerId)
      .toList();

  bool get canAddMore =>
      state.selectedPlayers.length < state.maxPlayers;

  bool isSelected(PadlyUser user) =>
      state.selectedPlayers.any((p) => p.id == user.id);

  Future<void> _loadRecentPlayers() async {
    try {
      final recent = await _cache.load();
      state = state.copyWith(cachedRecent: recent);
    } catch (_) {
      await _cache.clear();
      state = state.copyWith(cachedRecent: []);
    }
  }

  Future<void> setSearch(String value) async {
    final trimmed = value.trim();
    state = state.copyWith(
      searchQuery: trimmed,
      errorMessage: null,
    );

    if (trimmed.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final results = await _userService.searchPlayers(trimmed);
      state = state.copyWith(searchResults: results);
    } catch (e) {
      state = state.copyWith(
          errorMessage: e.toString(), searchResults: []);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePlayer(PadlyUser user) {
    if (state.lockedPlayerId != null && user.id == state.lockedPlayerId) {
      return;
    }

    final index =
        state.selectedPlayers.indexWhere((p) => p.id == user.id);

    if (index >= 0) {
      final updated = List<PadlyUser>.from(state.selectedPlayers)
        ..removeAt(index);
      state = state.copyWith(selectedPlayers: updated);
    } else {
      if (!canAddMore) {
        state = state.copyWith(
            feedbackMessage:
                'Maximum aantal spelers bereikt (${state.maxPlayers})');
        return;
      }
      final updated = List<PadlyUser>.from(state.selectedPlayers)
        ..add(user);
      state = state.copyWith(selectedPlayers: updated);
      _persistToRecent(user);
    }
  }

  void addGuestPlayer() {
    if (!canAddMore) {
      state = state.copyWith(
          feedbackMessage:
              'Maximum aantal spelers bereikt (${state.maxPlayers})');
      return;
    }
    final guest = PadlyUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      firstName: 'Gast',
    );
    final updated = List<PadlyUser>.from(state.selectedPlayers)..add(guest);
    state = state.copyWith(
      selectedPlayers: updated,
      searchQuery: '',
      searchResults: [],
    );
  }

  void clearFeedbackMessage() {
    state = state.copyWith(feedbackMessage: null);
  }

  void _persistToRecent(PadlyUser user) {
    if (user.id == null || user.id!.startsWith('guest_')) return;

    final updated = List<PadlyUser>.from(state.cachedRecent);
    updated.removeWhere((p) => p.id == user.id);
    updated.insert(0, user);

    state = state.copyWith(cachedRecent: updated);
    _cache.save(updated);
  }
}

final addPlayersNotifierProvider =
    AutoDisposeNotifierProvider<AddPlayersNotifier, AddPlayersState>(
        AddPlayersNotifier.new);
