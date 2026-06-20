import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:padly/features/users/domain/entities/padly_user.dart';

class RecentPlayersCache {
  static const _key = 'recent_players';
  static const _maxItems = 20;

  Future<List<PadlyUser>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final players = <PadlyUser>[];
    for (final e in raw) {
      try {
        players.add(PadlyUser.fromJson(json.decode(e) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupt entries.
      }
    }
    return players;
  }

  Future<void> save(List<PadlyUser> players) async {
    final prefs = await SharedPreferences.getInstance();
    final data = players
        .take(_maxItems)
        .map((p) => json.encode(p.toJson()))
        .toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
