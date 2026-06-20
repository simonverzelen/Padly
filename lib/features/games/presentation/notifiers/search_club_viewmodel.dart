import 'dart:async';

import 'package:async/async.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:padly/features/games/data/datasources/google_maps_repo.dart';
import 'package:padly/features/games/data/caches/recent_clubs_cache.dart';
import 'package:padly/features/games/domain/entities/club.dart';

class SearchClubState {
  final List<AutocompleteResult> results;
  final List<ClubPlace> recentClubs;
  final List<ClubPlace> filteredRecentClubs;
  final String query;
  final String? errorMessage;
  final bool isSearchingRemote;

  const SearchClubState({
    this.results = const [],
    this.recentClubs = const [],
    this.filteredRecentClubs = const [],
    this.query = '',
    this.errorMessage,
    this.isSearchingRemote = false,
  });

  bool get isSearching => query.isNotEmpty || isSearchingRemote;

  SearchClubState copyWith({
    List<AutocompleteResult>? results,
    List<ClubPlace>? recentClubs,
    List<ClubPlace>? filteredRecentClubs,
    String? query,
    Object? errorMessage = _sentinel,
    bool? isSearchingRemote,
  }) {
    return SearchClubState(
      results: results ?? this.results,
      recentClubs: recentClubs ?? this.recentClubs,
      filteredRecentClubs: filteredRecentClubs ?? this.filteredRecentClubs,
      query: query ?? this.query,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isSearchingRemote: isSearchingRemote ?? this.isSearchingRemote,
    );
  }
}

const Object _sentinel = Object();

class SearchClubNotifier extends AutoDisposeNotifier<SearchClubState> {
  Timer? _debounce;
  CancelableOperation<List<AutocompleteResult>>? _searchOperation;
  final GooglePlacesRepository _repo = GooglePlacesRepository();
  final RecentClubsCache _cache = RecentClubsCache();

  @override
  SearchClubState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _searchOperation?.cancel();
      _repo.endSession();
    });
    Future.microtask(_loadRecentClubs);
    return const SearchClubState();
  }

  Future<void> _loadRecentClubs() async {
    try {
      final stored = await _cache.load();
      state = state.copyWith(recentClubs: List<ClubPlace>.from(stored));
    } catch (e) {
      await _cache.clear();
      state = state.copyWith(recentClubs: []);
    }
  }

  void onSearchChanged(String value) {
    state = state.copyWith(
      query: value,
      errorMessage: null,
      results: [],
    );

    _debounce?.cancel();
    _searchOperation?.cancel();

    if (value.isEmpty) {
      _repo.endSession();
      return;
    }

    _searchRecentFuzzy(value);

    if (state.filteredRecentClubs.isNotEmpty) {
      return;
    }

    _repo.startSession();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(isSearchingRemote: true);

      _searchOperation = CancelableOperation.fromFuture(
        _repo.autocomplete(value),
      );

      _searchOperation!.value.then((r) {
        state = state.copyWith(results: r, isSearchingRemote: false);
      }).catchError((e) {
        state = state.copyWith(
            errorMessage: e.toString(), isSearchingRemote: false);
      });
    });
  }

  Future<ClubPlace?> selectClub(String placeId) async {
    _debounce?.cancel();
    _searchOperation?.cancel();

    final place = await _repo.getPlaceDetails(placeId);
    _repo.endSession();

    if (place != null) {
      await _addToCache(place);
    }

    return place;
  }

  Future<void> setToFirstRecent(ClubPlace club) async {
    await _addToCache(club);
  }

  Future<void> _addToCache(ClubPlace club) async {
    final updated = List<ClubPlace>.from(state.recentClubs);
    updated.removeWhere((c) => c.placeId == club.placeId);
    updated.insert(0, club);

    if (updated.length > 5) {
      updated.removeLast();
    }

    await _cache.save(updated);
    state = state.copyWith(recentClubs: updated);
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  void _searchRecentFuzzy(String query) {
    final q = _normalize(query);

    final scored = <({ClubPlace club, int score})>[];

    for (final club in state.recentClubs) {
      final nameScore = ratio(q, _normalize(club.name));
      final addressScore = ratio(q, _normalize(club.address));

      final score = nameScore > addressScore ? nameScore : addressScore;

      if (score >= 65) {
        scored.add((club: club, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    state = state.copyWith(
        filteredRecentClubs: scored.map((e) => e.club).toList());
  }
}

final searchClubNotifierProvider =
    AutoDisposeNotifierProvider<SearchClubNotifier, SearchClubState>(
        SearchClubNotifier.new);
