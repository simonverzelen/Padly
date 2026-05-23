import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/sport.dart';

class SportsRepository {
  SportsRepository._();
  static final SportsRepository instance = SportsRepository._();

  static const List<Sport> _fallback = [
    Sport(name: 'Padel'),
    Sport(name: 'Tennis'),
    Sport(name: 'Squash'),
    Sport(name: 'Badminton'),
    Sport(name: 'Pickleball'),
    Sport(name: 'Ping Pong'),
    Sport(name: 'PadBol'),
    Sport(name: 'Petanque'),
  ];

  List<Sport>? _sportsCache;

  Future<List<Sport>> _fetchSports() async {
    if (_sportsCache != null) return _sportsCache!;

    try {
      final response = await Supabase.instance.client
          .from('sports')
          .select('id, name, levels')
          .order('name');

      _sportsCache = (response as List<dynamic>).map<Sport>((row) {
        final rawLevels = row['levels'] as List<dynamic>?;
        final levels =
            rawLevels?.map<String>((l) => l as String).toList() ?? <String>[];
        return Sport(
          id: row['id'] as String?,
          name: row['name'] as String,
          levels: levels,
        );
      }).toList();

      return _sportsCache!;
    } catch (_) {
      return _fallback;
    }
  }

  /// Returns sport names only. Backwards-compatible with all existing callers.
  Future<List<String>> getSports() async {
    final sports = await _fetchSports();
    return sports.map((s) => s.name).toList();
  }

  /// Returns the skill levels for the given sport name.
  /// Returns an empty list when the sport is not found.
  Future<List<String>> getLevelsForSport(String name) async {
    final sports = await _fetchSports();
    final match = sports.where((s) => s.name == name).firstOrNull;
    return match?.levels ?? <String>[];
  }

  /// Returns the UUID of the sport with the given name, or null if not found.
  Future<String?> getSportId(String name) async {
    final sports = await _fetchSports();
    return sports.where((s) => s.name == name).firstOrNull?.id;
  }
}
