import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesCache {
  static const _sportKey = 'selected_sport';
  static const _languageKey = 'preferred_language';

  Future<String> getSelectedSport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sportKey) ?? 'Padel';
  }

  Future<void> saveSelectedSport(String sport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sportKey, sport);
  }

  Future<String> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'Nederlands';
  }

  Future<void> savePreferredLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sportKey);
    await prefs.remove(_languageKey);
  }
}
