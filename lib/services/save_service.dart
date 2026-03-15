import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class SaveService {
  static const _slotPrefix = 'game_state_slot_';
  static const _achievementsKey = 'achievements';
  static const _settingsKey = 'settings';
  static const slotCount = 3;

  static String _slotKey(int slot) => '$_slotPrefix$slot';

  static Future<void> autoSave(GameState state, int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_slotKey(slot), json);
  }

  static Future<GameState?> loadSave(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_slotKey(slot));
    if (json == null) return null;
    return GameState.fromJson(jsonDecode(json));
  }

  static Future<void> deleteSave(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_slotKey(slot));
  }

  /// Load summaries for all slots (null if empty).
  static Future<List<GameState?>> loadAllSlots() async {
    final slots = <GameState?>[];
    for (int i = 0; i < slotCount; i++) {
      slots.add(await loadSave(i));
    }
    return slots;
  }

  /// Migrate old single-key save to slot 0 if it exists.
  static Future<void> migrateOldSave() async {
    final prefs = await SharedPreferences.getInstance();
    const oldKey = 'game_state';
    final oldJson = prefs.getString(oldKey);
    if (oldJson != null) {
      // Move to slot 0 if slot 0 is empty
      final slot0 = prefs.getString(_slotKey(0));
      if (slot0 == null) {
        await prefs.setString(_slotKey(0), oldJson);
      }
      await prefs.remove(oldKey);
    }
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
