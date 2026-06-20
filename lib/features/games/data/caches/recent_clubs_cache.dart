import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:padly/features/games/domain/entities/club.dart';

class RecentClubsCache {
  static const _key = 'recent_clubs';
  static const _maxItems = 50;

  Future<List<ClubPlace>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final clubs = <ClubPlace>[];
    for (final e in raw) {
      try {
        clubs.add(ClubPlace.fromJson(json.decode(e) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupt cache entries rather than crashing the whole load.
      }
    }
    return clubs;
  }

  Future<void> save(List<ClubPlace> clubs) async {
    final prefs = await SharedPreferences.getInstance();

    final data =
        clubs.take(_maxItems).map((c) => json.encode(c.toJson())).toList();

    await prefs.setStringList(_key, data);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
