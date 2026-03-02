import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/club.dart';

class RecentClubsCache {
  static const _key = 'recent_clubs';
  static const _maxItems = 50;

  Future<List<ClubPlace>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((e) => ClubPlace.fromJson(json.decode(e))).toList();
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
