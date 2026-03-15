import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import '../models/enums.dart';
import '../services/save_service.dart';

class PlayerProfileNotifier extends StateNotifier<PlayerProfile?> {
  PlayerProfileNotifier() : super(null);

  Future<void> initialize() async {
    final saved = await SaveService.loadProfile();
    state = saved ?? PlayerProfile();
    await _save();
  }

  Future<void> addLegacyPoints(int points) async {
    if (state == null) return;
    state!.legacyPoints += points;
    state!.totalLegacyPointsEarned += points;
    state = PlayerProfile.fromJson(state!.toJson()); // refresh
    await _save();
  }

  Future<void> recordRunEnd({
    required int mapsCompleted,
    required bool isVictory,
  }) async {
    if (state == null) return;
    state!.totalRuns++;
    if (isVictory) state!.totalVictories++;
    if (mapsCompleted > state!.furthestMap) {
      state!.furthestMap = mapsCompleted;
    }
    state = PlayerProfile.fromJson(state!.toJson()); // refresh
    await _save();
  }

  Future<bool> purchaseClassUnlock(CharacterClass cls, int cost) async {
    if (state == null || state!.legacyPoints < cost) return false;
    if (state!.unlockedClasses.contains(cls)) return false;
    state!.legacyPoints -= cost;
    state!.unlockedClasses.add(cls);
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
    return true;
  }

  Future<bool> purchasePassiveBonus(String bonusId, int cost, int maxRanks) async {
    if (state == null || state!.legacyPoints < cost) return false;
    final currentRank = state!.passiveBonuses[bonusId] ?? 0;
    if (currentRank >= maxRanks) return false;
    state!.legacyPoints -= cost;
    state!.passiveBonuses[bonusId] = currentRank + 1;
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
    return true;
  }

  Future<bool> purchasePerk(String perkId, int cost) async {
    if (state == null || state!.legacyPoints < cost) return false;
    if (state!.unlockedPerks.contains(perkId)) return false;
    state!.legacyPoints -= cost;
    state!.unlockedPerks.add(perkId);
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
    return true;
  }

  Future<void> recordEnemyKills(Map<String, int> killCounts) async {
    if (state == null) return;
    for (final entry in killCounts.entries) {
      state!.bestiaryKills[entry.key] = (state!.bestiaryKills[entry.key] ?? 0) + entry.value;
    }
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
  }

  Future<void> recordLorePageFound(String pageId) async {
    if (state == null) return;
    if (state!.loreFound.contains(pageId)) return;
    state!.loreFound.add(pageId);
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
  }

  Future<void> unlockDifficulty(DifficultyLevel level) async {
    if (state == null) return;
    if (state!.unlockedDifficulties.contains(level)) return;
    state!.unlockedDifficulties.add(level);
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
  }

  Future<void> recordClassStoryProgress(String className, int chapter) async {
    if (state == null) return;
    final current = state!.classStoryProgress[className] ?? 0;
    if (chapter <= current) return;
    state!.classStoryProgress[className] = chapter;
    state = PlayerProfile.fromJson(state!.toJson());
    await _save();
  }

  Future<void> _save() async {
    if (state != null) {
      await SaveService.saveProfile(state!);
    }
  }
}

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile?>((ref) {
  return PlayerProfileNotifier();
});
