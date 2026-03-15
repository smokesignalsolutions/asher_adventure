import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
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
