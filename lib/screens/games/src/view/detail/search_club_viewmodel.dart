import 'dart:async';

import 'package:async/async.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:flutter/material.dart';

import '../../data/google_maps_repo.dart';
import '../../data/recent_clubs_cache.dart';
import '../../domain/club.dart';

class SearchClubViewModel extends ChangeNotifier {
  SearchClubViewModel(
    this._repo,
    this._cache,
  ) {
    _loadRecentClubs();
  }

  final GooglePlacesRepository _repo;
  final RecentClubsCache _cache;

  Timer? _debounce;
  CancelableOperation<List<AutocompleteResult>>? _searchOperation;

  List<AutocompleteResult> results = [];
  final List<ClubPlace> _recentClubs = [];

  List<ClubPlace> _filteredRecent = [];
  List<ClubPlace> get filteredRecentClubs => _filteredRecent;

  String _query = '';
  String? _error;
  String? get errorMessage => _error;

  List<ClubPlace> get recentClubs => List.unmodifiable(_recentClubs);
  bool _isSearching = false;
  bool get isSearching => _query.isNotEmpty || _isSearching;

  Future<void> _loadRecentClubs() async {
    try {
      final stored = await _cache.load();
      _recentClubs
        ..clear()
        ..addAll(stored);
      notifyListeners();
    } catch (e) {
      // Corrupt cache — clear the bad entry and start fresh.
      await _cache.clear();
      _recentClubs.clear();
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    _query = value;
    _error = null;
    results = [];
    notifyListeners();

    _debounce?.cancel();
    _searchOperation?.cancel();

    if (value.isEmpty) {
      _repo.endSession();
      return;
    }

    _searchRecentFuzzy(_query);

    if (_filteredRecent.isNotEmpty) {
      notifyListeners();
      return;
    }

    _repo.startSession();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _isSearching = true;
      notifyListeners();

      _searchOperation = CancelableOperation.fromFuture(
        _repo.autocomplete(value),
      );

      _searchOperation!.value.then((r) {
        results = r;
        _isSearching = false;
        notifyListeners();
      }).catchError((e) {
        _error = e.toString();
        _isSearching = false;
        notifyListeners();
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
    _recentClubs.removeWhere((c) => c.placeId == club.placeId);
    _recentClubs.insert(0, club);

    if (_recentClubs.length > 5) {
      _recentClubs.removeLast();
    }

    await _cache.save(_recentClubs);
    notifyListeners();
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  void _searchRecentFuzzy(String query) {
    final q = _normalize(query);

    final scored = <({ClubPlace club, int score})>[];

    for (final club in _recentClubs) {
      final nameScore = ratio(q, _normalize(club.name));
      final addressScore = ratio(q, _normalize(club.address));

      final score = nameScore > addressScore ? nameScore : addressScore;

      if (score >= 65) {
        scored.add((club: club, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    _filteredRecent = scored.map((e) => e.club).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchOperation?.cancel();
    _repo.endSession();
    super.dispose();
  }
}
