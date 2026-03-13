import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class SaveService {
  static const _gameStateKey = 'game_state';
  static const _achievementsKey = 'achievements';
  static const _settingsKey = 'settings';

  static Future<void> autoSave(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_gameStateKey, json);
  }

  static Future<GameState?> loadSave() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_gameStateKey);
    if (json == null) return null;
    return GameState.fromJson(jsonDecode(json));
  }

  static Future<void> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }

  static Future<void> saveAchievements(Map<String, bool> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_achievementsKey, jsonEncode(achievements));
  }

  static Future<Map<String, bool>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_achievementsKey);
    if (json == null) return {};
    return Map<String, bool>.from(jsonDecode(json));
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await loadSettings();
    settings[key] = value;
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    if (json == null) return {};
    return Map<String, dynamic>.from(jsonDecode(json));
  }
}
