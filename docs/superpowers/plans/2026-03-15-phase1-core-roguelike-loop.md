# Phase 1: Core Roguelike Loop — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the game into a roguelike where each run starts fresh (level 1, no gear, no gold), Legacy Points are earned on death/victory based on progress, and the LP breakdown is displayed before returning to the title screen.

**Architecture:** New `PlayerProfile` model persists across runs in SharedPreferences under its own key. New `PlayerProfileProvider` (Riverpod StateNotifier) manages profile state. Run tracking fields are added to `GameState` for LP calculation. The run-end lifecycle calculates LP, updates the profile, displays the breakdown, then deletes the run save. Save slots are simplified to a single ephemeral run save.

**Tech Stack:** Flutter, Riverpod (flutter_riverpod), SharedPreferences (shared_preferences), GoRouter (go_router)

---

## Chunk 1: PlayerProfile Model & Persistence

### Task 1: Create PlayerProfile model

**Files:**
- Create: `lib/models/player_profile.dart`
- Test: `test/models/player_profile_test.dart`

- [ ] **Step 1: Write the failing test for PlayerProfile serialization**

```dart
// test/models/player_profile_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/models/player_profile.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  group('PlayerProfile', () {
    test('creates with default values', () {
      final profile = PlayerProfile();
      expect(profile.legacyPoints, 0);
      expect(profile.totalLegacyPointsEarned, 0);
      expect(profile.totalRuns, 0);
      expect(profile.totalVictories, 0);
      expect(profile.furthestMap, 0);
      expect(profile.unlockedClasses, containsAll([
        CharacterClass.fighter,
        CharacterClass.rogue,
        CharacterClass.cleric,
        CharacterClass.wizard,
      ]));
      expect(profile.unlockedClasses.length, 4);
    });

    test('serializes to JSON and back', () {
      final profile = PlayerProfile(
        legacyPoints: 150,
        totalLegacyPointsEarned: 300,
        totalRuns: 5,
        totalVictories: 1,
        furthestMap: 6,
        unlockedClasses: [
          CharacterClass.fighter,
          CharacterClass.rogue,
          CharacterClass.cleric,
          CharacterClass.wizard,
          CharacterClass.paladin,
        ],
      );

      final json = profile.toJson();
      final restored = PlayerProfile.fromJson(json);

      expect(restored.legacyPoints, 150);
      expect(restored.totalLegacyPointsEarned, 300);
      expect(restored.totalRuns, 5);
      expect(restored.totalVictories, 1);
      expect(restored.furthestMap, 6);
      expect(restored.unlockedClasses.length, 5);
      expect(restored.unlockedClasses, contains(CharacterClass.paladin));
    });

    test('fromJson handles missing keys with defaults', () {
      final json = <String, dynamic>{};
      final profile = PlayerProfile.fromJson(json);
      expect(profile.legacyPoints, 0);
      expect(profile.unlockedClasses.length, 4);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/player_profile_test.dart`
Expected: FAIL — `player_profile.dart` does not exist

- [ ] **Step 3: Write PlayerProfile model**

```dart
// lib/models/player_profile.dart
import 'enums.dart';

class PlayerProfile {
  int legacyPoints;
  int totalLegacyPointsEarned;
  int totalRuns;
  int totalVictories;
  int furthestMap;
  List<CharacterClass> unlockedClasses;

  static const List<CharacterClass> starterClasses = [
    CharacterClass.fighter,
    CharacterClass.rogue,
    CharacterClass.cleric,
    CharacterClass.wizard,
  ];

  PlayerProfile({
    this.legacyPoints = 0,
    this.totalLegacyPointsEarned = 0,
    this.totalRuns = 0,
    this.totalVictories = 0,
    this.furthestMap = 0,
    List<CharacterClass>? unlockedClasses,
  }) : unlockedClasses = unlockedClasses ?? List.from(starterClasses);

  Map<String, dynamic> toJson() => {
    'legacyPoints': legacyPoints,
    'totalLegacyPointsEarned': totalLegacyPointsEarned,
    'totalRuns': totalRuns,
    'totalVictories': totalVictories,
    'furthestMap': furthestMap,
    'unlockedClasses': unlockedClasses.map((c) => c.index).toList(),
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    legacyPoints: json['legacyPoints'] ?? 0,
    totalLegacyPointsEarned: json['totalLegacyPointsEarned'] ?? 0,
    totalRuns: json['totalRuns'] ?? 0,
    totalVictories: json['totalVictories'] ?? 0,
    furthestMap: json['furthestMap'] ?? 0,
    unlockedClasses: json['unlockedClasses'] != null
        ? (json['unlockedClasses'] as List)
            .map((i) => CharacterClass.values[i])
            .toList()
        : null,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/player_profile_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/player_profile.dart test/models/player_profile_test.dart
git commit -m "feat: add PlayerProfile model with serialization"
```

---

### Task 2: Add PlayerProfile persistence to SaveService

**Files:**
- Modify: `lib/services/save_service.dart`
- Test: `test/services/save_service_test.dart`

- [ ] **Step 1: Write the failing test for profile save/load**

```dart
// test/services/save_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/services/save_service.dart';
import 'package:asher_adventure/models/player_profile.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  group('SaveService - PlayerProfile', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveProfile and loadProfile round-trip', () async {
      final profile = PlayerProfile(
        legacyPoints: 100,
        totalRuns: 3,
        furthestMap: 5,
      );

      await SaveService.saveProfile(profile);
      final loaded = await SaveService.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.legacyPoints, 100);
      expect(loaded.totalRuns, 3);
      expect(loaded.furthestMap, 5);
    });

    test('loadProfile returns null when no profile saved', () async {
      final loaded = await SaveService.loadProfile();
      expect(loaded, isNull);
    });

    test('save and load run uses single key (no slots)', () async {
      // Verify the new single-save methods work
      await SaveService.autoSaveRun(
        _makeMockGameStateJson(),
      );
      final json = await SaveService.loadRunSaveJson();
      expect(json, isNotNull);

      await SaveService.deleteRunSave();
      final deleted = await SaveService.loadRunSaveJson();
      expect(deleted, isNull);
    });
  });
}

// Helper to create a minimal JSON string for testing
Map<String, dynamic> _makeMockGameStateJson() => {
  'party': [],
  'gold': 0,
  'healthPotions': 0,
  'currentMapNumber': 1,
  'currentMap': {
    'mapNumber': 1,
    'nodes': [],
    'armyColumn': -2.0,
    'currentNodeId': '',
  },
  'difficulty': 1,
};
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/save_service_test.dart`
Expected: FAIL — `saveProfile`, `loadProfile`, `autoSaveRun`, etc. do not exist

- [ ] **Step 3: Add profile and single-run-save methods to SaveService**

Add to `lib/services/save_service.dart` — new constants and methods:

```dart
// Add these constants after existing ones (line 9):
static const _profileKey = 'player_profile';
static const _runSaveKey = 'active_run';

// Add these methods after existing methods:

static Future<void> saveProfile(PlayerProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  final json = jsonEncode(profile.toJson());
  await prefs.setString(_profileKey, json);
}

static Future<PlayerProfile?> loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_profileKey);
  if (json == null) return null;
  return PlayerProfile.fromJson(jsonDecode(json));
}

/// Save run state (single active run, no slots).
static Future<void> autoSaveRun(Map<String, dynamic> stateJson) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_runSaveKey, jsonEncode(stateJson));
}

/// Load active run JSON (null if no run in progress).
static Future<String?> loadRunSaveJson() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_runSaveKey);
}

/// Delete the active run save.
static Future<void> deleteRunSave() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_runSaveKey);
}
```

Also add import at top of file:
```dart
import '../models/player_profile.dart';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/save_service_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/save_service.dart test/services/save_service_test.dart
git commit -m "feat: add PlayerProfile persistence and single-run save to SaveService"
```

---

### Task 3: Create PlayerProfileProvider

**Files:**
- Create: `lib/providers/player_profile_provider.dart`
- Test: `test/providers/player_profile_provider_test.dart`

- [ ] **Step 1: Write the failing test for the provider**

```dart
// test/providers/player_profile_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/providers/player_profile_provider.dart';
import 'package:asher_adventure/models/player_profile.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlayerProfileNotifier', () {
    test('initialize creates default profile when none exists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();

      final profile = container.read(playerProfileProvider);
      expect(profile, isNotNull);
      expect(profile!.legacyPoints, 0);
      expect(profile.unlockedClasses.length, 4);
    });

    test('addLegacyPoints increases balance and total', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(50);

      final profile = container.read(playerProfileProvider);
      expect(profile!.legacyPoints, 50);
      expect(profile.totalLegacyPointsEarned, 50);
    });

    test('recordRunEnd updates stats', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(
        mapsCompleted: 4,
        isVictory: false,
      );

      final profile = container.read(playerProfileProvider);
      expect(profile!.totalRuns, 1);
      expect(profile.totalVictories, 0);
      expect(profile.furthestMap, 4);
    });

    test('recordRunEnd tracks victories', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(
        mapsCompleted: 8,
        isVictory: true,
      );

      final profile = container.read(playerProfileProvider);
      expect(profile!.totalRuns, 1);
      expect(profile.totalVictories, 1);
      expect(profile.furthestMap, 8);
    });

    test('furthestMap only updates if new map is further', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(mapsCompleted: 5, isVictory: false);
      await notifier.recordRunEnd(mapsCompleted: 3, isVictory: false);

      final profile = container.read(playerProfileProvider);
      expect(profile!.furthestMap, 5);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/player_profile_provider_test.dart`
Expected: FAIL — `player_profile_provider.dart` does not exist

- [ ] **Step 3: Write PlayerProfileProvider**

```dart
// lib/providers/player_profile_provider.dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/player_profile_provider_test.dart`
Expected: All 5 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/providers/player_profile_provider.dart test/providers/player_profile_provider_test.dart
git commit -m "feat: add PlayerProfileProvider with LP tracking and run stats"
```

---

## Chunk 2: Run Tracking & Legacy Point Calculation

### Task 4: Add run tracking fields to GameState

**Files:**
- Modify: `lib/models/game_state.dart`
- Test: `test/models/game_state_test.dart`

- [ ] **Step 1: Write the failing test for new tracking fields**

```dart
// test/models/game_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/models/game_state.dart';
import 'package:asher_adventure/models/enums.dart';
import 'package:asher_adventure/models/game_map.dart';
import 'package:asher_adventure/services/map_service.dart';

void main() {
  group('GameState run tracking', () {
    test('new GameState has zeroed run tracking fields', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
      );
      expect(state.mapsCompletedThisRun, 0);
      expect(state.bossesKilledThisRun, 0);
      expect(state.uniqueEnemyTypesKilledThisRun, isEmpty);
    });

    test('run tracking fields serialize and deserialize', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
        mapsCompletedThisRun: 3,
        bossesKilledThisRun: 2,
        uniqueEnemyTypesKilledThisRun: {'goblin_grunt', 'goblin_shaman'},
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.mapsCompletedThisRun, 3);
      expect(restored.bossesKilledThisRun, 2);
      expect(restored.uniqueEnemyTypesKilledThisRun, hasLength(2));
      expect(restored.uniqueEnemyTypesKilledThisRun, contains('goblin_grunt'));
    });

    test('default gold is 0', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
      );
      expect(state.gold, 0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/game_state_test.dart`
Expected: FAIL — `mapsCompletedThisRun` etc. don't exist, gold default is 50

- [ ] **Step 3: Add run tracking fields to GameState and change gold default**

Modify `lib/models/game_state.dart`:

1. Add fields to the class (after `armyMoveAccumulator`):
```dart
int mapsCompletedThisRun;
int bossesKilledThisRun;
Set<String> uniqueEnemyTypesKilledThisRun;
```

2. Add to constructor (with defaults):
```dart
this.mapsCompletedThisRun = 0,
this.bossesKilledThisRun = 0,
Set<String>? uniqueEnemyTypesKilledThisRun,
```
And in initializer list: `uniqueEnemyTypesKilledThisRun = uniqueEnemyTypesKilledThisRun ?? {}`.

3. Change gold default from `50` to `0`:
```dart
this.gold = 0,
```

4. Add to `toJson()`:
```dart
'mapsCompletedThisRun': mapsCompletedThisRun,
'bossesKilledThisRun': bossesKilledThisRun,
'uniqueEnemyTypesKilledThisRun': uniqueEnemyTypesKilledThisRun.toList(),
```

5. Add to `fromJson()`:
```dart
mapsCompletedThisRun: json['mapsCompletedThisRun'] ?? 0,
bossesKilledThisRun: json['bossesKilledThisRun'] ?? 0,
uniqueEnemyTypesKilledThisRun: json['uniqueEnemyTypesKilledThisRun'] != null
    ? Set<String>.from(json['uniqueEnemyTypesKilledThisRun'])
    : null,
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/game_state_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/game_state.dart test/models/game_state_test.dart
git commit -m "feat: add run tracking fields to GameState, change default gold to 0"
```

---

### Task 5: Create LegacyPointCalculator

**Files:**
- Create: `lib/services/legacy_point_calculator.dart`
- Test: `test/services/legacy_point_calculator_test.dart`

- [ ] **Step 1: Write the failing tests for LP calculation**

```dart
// test/services/legacy_point_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/services/legacy_point_calculator.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  group('LegacyPointCalculator', () {
    test('calculates base points from maps completed', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 0,
        uniqueEnemyTypesKilled: 0,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      // 3 maps * 10 = 30, normal multiplier 1.0
      expect(result.totalPoints, 30);
      expect(result.basePoints, 30);
    });

    test('adds boss kill bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 0,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      // (30 + 10) * 1.0 = 40
      expect(result.bossBonus, 10);
      expect(result.totalPoints, 40);
    });

    test('adds unique enemy type bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 0,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      // (30 + 16) * 1.0 = 46
      expect(result.enemyTypeBonus, 16);
      expect(result.totalPoints, 46);
    });

    test('adds victory bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 8,
        bossesKilled: 8,
        uniqueEnemyTypesKilled: 20,
        isVictory: true,
        difficulty: DifficultyLevel.normal,
      );
      // (80 + 40 + 40 + 25) * 1.0 = 185
      expect(result.victoryBonus, 25);
      expect(result.totalPoints, 185);
    });

    test('applies easy difficulty multiplier (0.5x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.easy,
      );
      // (40 + 10 + 16) * 0.5 = 33
      expect(result.difficultyMultiplier, 0.5);
      expect(result.totalPoints, 33);
    });

    test('applies hard difficulty multiplier (1.5x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.hard,
      );
      // (40 + 10 + 16) * 1.5 = 99
      expect(result.difficultyMultiplier, 1.5);
      expect(result.totalPoints, 99);
    });

    test('applies nightmare difficulty multiplier (2.0x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.nightmare,
      );
      // (40 + 10 + 16) * 2.0 = 132
      expect(result.difficultyMultiplier, 2.0);
      expect(result.totalPoints, 132);
    });

    test('spec example: Normal, die on map 4, 2 bosses, 8 types', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3, // died ON map 4, completed maps 1-3
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      // (30 + 10 + 16) * 1.0 = 56
      expect(result.totalPoints, 56);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/legacy_point_calculator_test.dart`
Expected: FAIL — file does not exist

- [ ] **Step 3: Write LegacyPointCalculator**

```dart
// lib/services/legacy_point_calculator.dart
import '../models/enums.dart';

class LegacyPointResult {
  final int basePoints;
  final int bossBonus;
  final int enemyTypeBonus;
  final int victoryBonus;
  final double difficultyMultiplier;
  final int totalPoints;

  const LegacyPointResult({
    required this.basePoints,
    required this.bossBonus,
    required this.enemyTypeBonus,
    required this.victoryBonus,
    required this.difficultyMultiplier,
    required this.totalPoints,
  });
}

class LegacyPointCalculator {
  static const int _pointsPerMap = 10;
  static const int _pointsPerBoss = 5;
  static const int _pointsPerEnemyType = 2;
  static const int _victoryBonus = 25;

  static double _multiplierForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0.5;
      case DifficultyLevel.normal:
        return 1.0;
      case DifficultyLevel.hard:
        return 1.5;
      case DifficultyLevel.nightmare:
        return 2.0;
    }
  }

  static LegacyPointResult calculate({
    required int mapsCompleted,
    required int bossesKilled,
    required int uniqueEnemyTypesKilled,
    required bool isVictory,
    required DifficultyLevel difficulty,
  }) {
    final basePoints = mapsCompleted * _pointsPerMap;
    final bossBonus = bossesKilled * _pointsPerBoss;
    final enemyTypeBonus = uniqueEnemyTypesKilled * _pointsPerEnemyType;
    final victoryBonus = isVictory ? _victoryBonus : 0;
    final multiplier = _multiplierForDifficulty(difficulty);

    final rawTotal = basePoints + bossBonus + enemyTypeBonus + victoryBonus;
    final totalPoints = (rawTotal * multiplier).round();

    return LegacyPointResult(
      basePoints: basePoints,
      bossBonus: bossBonus,
      enemyTypeBonus: enemyTypeBonus,
      victoryBonus: victoryBonus,
      difficultyMultiplier: multiplier,
      totalPoints: totalPoints,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/legacy_point_calculator_test.dart`
Expected: All 8 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/legacy_point_calculator.dart test/services/legacy_point_calculator_test.dart
git commit -m "feat: add LegacyPointCalculator with difficulty multipliers"
```

---

## Chunk 3: Wire Up Run Tracking in GameStateProvider

### Task 6: Update GameStateProvider to track run data and handle run-end

**Files:**
- Modify: `lib/providers/game_state_provider.dart`
- Modify: `lib/models/game_state.dart` (if `_refreshState` needs updating)

This task modifies the provider to:
1. Track enemy types killed during `completeCombat()`
2. Track boss kills and maps completed during `advanceToNextMap()`
3. Reset gold on map advance
4. Add a `endRun()` method that returns LP result before clearing state
5. Remove slot-based save logic (single run save)

- [ ] **Step 1: Update `_refreshState()` to include new tracking fields**

In `lib/providers/game_state_provider.dart`, update the `_refreshState()` method (currently at lines 85-95) to carry forward the new tracking fields:

```dart
GameState _refreshState() => GameState(
  party: state!.party,
  gold: state!.gold,
  healthPotions: state!.healthPotions,
  currentMapNumber: state!.currentMapNumber,
  currentMap: state!.currentMap,
  difficulty: state!.difficulty,
  totalEnemiesDefeated: state!.totalEnemiesDefeated,
  totalGoldEarned: state!.totalGoldEarned,
  armyMoveAccumulator: state!.armyMoveAccumulator,
  mapsCompletedThisRun: state!.mapsCompletedThisRun,
  bossesKilledThisRun: state!.bossesKilledThisRun,
  uniqueEnemyTypesKilledThisRun: state!.uniqueEnemyTypesKilledThisRun,
);
```

- [ ] **Step 2: Update `completeCombat()` to track enemy types**

Modify `completeCombat()` (currently at lines 207-220) to accept a list of killed enemy type IDs:

```dart
Future<void> completeCombat(
  int xpGained,
  int goldGained, {
  List<String> killedEnemyTypes = const [],
  bool bossKilled = false,
}) async {
  if (state == null) return;

  for (final char in state!.party) {
    ProgressionService.addXp(char, xpGained);
  }

  state!.gold += goldGained;
  state!.totalGoldEarned += goldGained;

  // Track enemy types killed this run
  state!.uniqueEnemyTypesKilledThisRun.addAll(killedEnemyTypes);
  if (bossKilled) {
    state!.bossesKilledThisRun++;
  }

  state = _refreshState();
  await _autoSave();
}
```

- [ ] **Step 3: Update `advanceToNextMap()` to reset gold and track maps completed**

Modify `advanceToNextMap()` (currently at lines 285-303):

```dart
Future<void> advanceToNextMap() async {
  if (state == null) return;
  final nextMap = state!.currentMapNumber + 1;
  if (nextMap > 8) return;

  state = GameState(
    party: state!.party,
    gold: 0, // Gold resets between maps
    healthPotions: state!.healthPotions,
    currentMapNumber: nextMap,
    currentMap: MapService.generateMap(nextMap),
    difficulty: state!.difficulty,
    totalEnemiesDefeated: state!.totalEnemiesDefeated,
    totalGoldEarned: state!.totalGoldEarned,
    mapsCompletedThisRun: state!.mapsCompletedThisRun + 1,
    bossesKilledThisRun: state!.bossesKilledThisRun,
    uniqueEnemyTypesKilledThisRun: state!.uniqueEnemyTypesKilledThisRun,
  );

  ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
  await _autoSave();
}
```

- [ ] **Step 4: Add `endRun()` method and simplify save logic**

Add new method and update `_autoSave` and `gameOver`:

```dart
/// Returns the final GameState snapshot for LP calculation, then clears state.
/// Callers should calculate LP from the returned state before it's gone.
GameState? endRun() {
  final snapshot = state;
  state = null;
  return snapshot;
}

Future<void> gameOver() async {
  await SaveService.deleteRunSave();
  state = null;
}
```

Update `_autoSave()` to use single-run save:
```dart
Future<void> _autoSave() async {
  if (state != null) {
    await SaveService.autoSaveRun(state!.toJson());
  }
}
```

Update `loadGame()` to use single-run load:
```dart
Future<void> loadGame() async {
  final json = await SaveService.loadRunSaveJson();
  if (json != null) {
    state = GameState.fromJson(jsonDecode(json));
  }
}
```

Remove `_activeSlot` and `activeSlot` getter. Remove the `slot` parameter from `loadGame()` and `startNewGame()`.

Update `startNewGame()` to remove `slot` parameter:
```dart
Future<void> startNewGame(
  List<CharacterClass> selectedClasses,
  DifficultyLevel difficulty,
) async {
```

Add import at top if not present:
```dart
import 'dart:convert';
```

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: May show warnings in screens that call `loadGame(slot)` or `startNewGame(..., slot: x)` — these will be fixed in Task 8. The provider itself should have no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/game_state_provider.dart
git commit -m "feat: add run tracking, LP-ready endRun, single-run saves, gold reset per map"
```

---

## Chunk 4: Update Screens for Run-End Flow

### Task 7: Update Game Over and Victory screens to show LP breakdown

**Files:**
- Modify: `lib/ui/screens/game_over/game_over_screen.dart`
- Modify: `lib/ui/screens/victory/victory_screen.dart`
- Create: `lib/ui/widgets/lp_breakdown.dart` (shared widget for both screens)

- [ ] **Step 1: Create LpBreakdown shared widget**

```dart
// lib/ui/widgets/lp_breakdown.dart
import 'package:flutter/material.dart';
import '../../services/legacy_point_calculator.dart';

class LpBreakdown extends StatelessWidget {
  final LegacyPointResult result;

  const LpBreakdown({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legacy Points Earned',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _row('Maps completed', '+${result.basePoints}'),
            if (result.bossBonus > 0) _row('Bosses slain', '+${result.bossBonus}'),
            if (result.enemyTypeBonus > 0)
              _row('Enemy types discovered', '+${result.enemyTypeBonus}'),
            if (result.victoryBonus > 0) _row('Victory!', '+${result.victoryBonus}'),
            if (result.difficultyMultiplier != 1.0)
              _row('Difficulty bonus', 'x${result.difficultyMultiplier}'),
            const Divider(),
            _row(
              'Total',
              '+${result.totalPoints} LP',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Rewrite Game Over screen**

Replace `lib/ui/screens/game_over/game_over_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/legacy_point_calculator.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/lp_breakdown.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  LegacyPointResult? _lpResult;

  @override
  void initState() {
    super.initState();
    _processRunEnd();
  }

  Future<void> _processRunEnd() async {
    final gameNotifier = ref.read(gameStateProvider.notifier);
    final profileNotifier = ref.read(playerProfileProvider.notifier);

    // Step 1: Snapshot state before clearing
    final snapshot = gameNotifier.endRun();
    if (snapshot == null) return;

    // Step 2: Calculate LP
    final result = LegacyPointCalculator.calculate(
      mapsCompleted: snapshot.mapsCompletedThisRun,
      bossesKilled: snapshot.bossesKilledThisRun,
      uniqueEnemyTypesKilled: snapshot.uniqueEnemyTypesKilledThisRun.length,
      isVictory: false,
      difficulty: snapshot.difficulty,
    );

    // Step 3: Update profile
    await profileNotifier.addLegacyPoints(result.totalPoints);
    await profileNotifier.recordRunEnd(
      mapsCompleted: snapshot.currentMapNumber,
      isVictory: false,
    );

    // Step 4: Delete run save
    await gameNotifier.gameOver();

    // Step 5: Display
    if (mounted) {
      setState(() => _lpResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.heart_broken, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                'Game Over',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your party has fallen...\nBut the knowledge you gained lives on.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_lpResult != null) ...[
                SizedBox(
                  width: 300,
                  child: LpBreakdown(result: _lpResult!),
                ),
                const SizedBox(height: 24),
              ] else
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: _lpResult != null ? () => context.go('/') : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Rewrite Victory screen**

Replace `lib/ui/screens/victory/victory_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/legacy_point_calculator.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/lp_breakdown.dart';

class VictoryScreen extends ConsumerStatefulWidget {
  const VictoryScreen({super.key});

  @override
  ConsumerState<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends ConsumerState<VictoryScreen> {
  LegacyPointResult? _lpResult;

  @override
  void initState() {
    super.initState();
    _processRunEnd();
  }

  Future<void> _processRunEnd() async {
    final gameNotifier = ref.read(gameStateProvider.notifier);
    final profileNotifier = ref.read(playerProfileProvider.notifier);

    final snapshot = gameNotifier.endRun();
    if (snapshot == null) return;

    final result = LegacyPointCalculator.calculate(
      mapsCompleted: snapshot.mapsCompletedThisRun + 1, // include final map
      bossesKilled: snapshot.bossesKilledThisRun,
      uniqueEnemyTypesKilled: snapshot.uniqueEnemyTypesKilledThisRun.length,
      isVictory: true,
      difficulty: snapshot.difficulty,
    );

    await profileNotifier.addLegacyPoints(result.totalPoints);
    await profileNotifier.recordRunEnd(
      mapsCompleted: 8,
      isVictory: true,
    );

    await gameNotifier.gameOver();

    if (mounted) {
      setState(() => _lpResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                'Victory!',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The Dark One has been vanquished!\n'
                'Peace returns to the land.\n\n'
                'Asher, your adventure is complete!',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_lpResult != null) ...[
                SizedBox(
                  width: 300,
                  child: LpBreakdown(result: _lpResult!),
                ),
                const SizedBox(height: 24),
              ] else
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: _lpResult != null ? () => context.go('/') : null,
                  icon: const Icon(Icons.home),
                  label: const Text('Return Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/ui/widgets/lp_breakdown.dart lib/ui/screens/game_over/game_over_screen.dart lib/ui/screens/victory/victory_screen.dart
git commit -m "feat: show LP breakdown on Game Over and Victory screens"
```

---

### Task 8: Update Title Screen and Party Select for single-save and profile

**Files:**
- Modify: `lib/ui/screens/title/title_screen.dart`
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`

- [ ] **Step 1: Simplify Title Screen (remove slots, add LP display, add profile init)**

Replace `lib/ui/screens/title/title_screen.dart`. Key changes:
- Remove `_slots` list and `_SlotPickerSheet`
- Load single run save (continue vs new game)
- Initialize PlayerProfile on load
- Show LP balance on title screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/save_service.dart';
import '../../widgets/audio_controls.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  bool _isLoading = true;
  bool _hasRunSave = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize player profile (creates default if first launch)
    await ref.read(playerProfileProvider.notifier).initialize();

    // Check for existing run save
    final runJson = await SaveService.loadRunSaveJson();
    setState(() {
      _hasRunSave = runJson != null;
      _isLoading = false;
    });
  }

  Future<void> _continueRun() async {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    await ref.read(gameStateProvider.notifier).loadGame();
    if (mounted) context.go('/map');
  }

  void _newGame() {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    if (_hasRunSave) {
      _confirmOverwrite();
    } else {
      context.go('/party-select');
    }
  }

  void _confirmOverwrite() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandon Run?'),
        content: const Text(
          'You have a run in progress. Starting a new game will erase it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/party-select');
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Asher's Adventure",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Grand Quest Awaits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    if (profile != null && profile.totalRuns > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${profile.legacyPoints} Legacy Points'
                        '  •  ${profile.totalRuns} runs'
                        '  •  ${profile.totalVictories} wins',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 220,
                      child: FilledButton.icon(
                        onPressed: _newGame,
                        icon: const Icon(Icons.add),
                        label: const Text('New Game'),
                      ),
                    ),
                    if (_hasRunSave) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 220,
                        child: FilledButton.tonalIcon(
                          onPressed: _continueRun,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Continue'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(audioProvider.notifier)
                              .playSfx(SfxType.menuSelect);
                          context.go('/help');
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Guide'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update Party Select to remove slot parameter**

In `lib/ui/screens/party_select/party_select_screen.dart`, find where `startNewGame` is called and remove the `slot:` parameter. The call should become:

```dart
ref.read(gameStateProvider.notifier).startNewGame(
  _selectedClasses,
  _selectedDifficulty,
);
```

Also update the class filtering to read from PlayerProfile instead of `classDefinitions[c].unlockedByDefault`:

**Delete** the old `_unlockedClasses` late field declaration (around line 24, currently: `late final List<CharacterClass> _unlockedClasses = ...`). Replace it with a getter method:

```dart
List<CharacterClass> get _unlockedClasses {
  final profile = ref.read(playerProfileProvider);
  if (profile == null) {
    return PlayerProfile.starterClasses;
  }
  return profile.unlockedClasses;
}
```

Add imports at the top of the file:
```dart
import '../../../providers/player_profile_provider.dart';
import '../../../models/player_profile.dart';
```

Also remove the `slot` parameter from the `startNewGame()` call if present (e.g. `slot: notifier.activeSlot` → remove it).

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 issues (or only pre-existing ones unrelated to our changes)

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/title/title_screen.dart lib/ui/screens/party_select/party_select_screen.dart
git commit -m "feat: simplify title screen to single-save, show LP stats, profile-based class unlocks"
```

---

### Task 9: Update combat screen for run tracking and run-end flow

**Files:**
- Modify: `lib/ui/screens/combat/combat_screen.dart`

Two critical changes in `_onCombatEnd()` (line 334):
1. Pass killed enemy types and boss flag to `completeCombat()`
2. **Remove the `gameOver()` call on defeat** — the Game Over screen now handles the run-end lifecycle. If we call `gameOver()` here, the state is null by the time Game Over tries to calculate LP.
3. Similarly, don't call `gameOver()` before victory navigation.

- [ ] **Step 1: Update the `_onCombatEnd()` method**

Replace `_onCombatEnd()` at line 334 of `lib/ui/screens/combat/combat_screen.dart`:

```dart
void _onCombatEnd() {
  if (_combat == null) return;
  if (_combat!.isVictory) {
    final totalXp =
        _combat!.enemies.fold(0, (sum, e) => sum + e.xpReward);
    final totalGold =
        _combat!.enemies.fold(0, (sum, e) => sum + e.goldReward);
    final notifier = ref.read(gameStateProvider.notifier);

    // Determine if this was a boss fight
    final gameState = ref.read(gameStateProvider);
    final isBoss = gameState != null &&
        gameState.currentMap.currentNode.type == NodeType.boss;

    // Track killed enemy types for LP calculation
    notifier.completeCombat(
      totalXp,
      totalGold,
      killedEnemyTypes: _combat!.enemies
          .where((e) => !e.isAlive)
          .map((e) => e.type)
          .toSet()
          .toList(),
      bossKilled: isBoss,
    );

    if (_isArmyFight) {
      notifier.defeatArmy();
    }

    // Re-read state after completeCombat updates it
    final updatedState = ref.read(gameStateProvider);
    if (isBoss) {
      if (updatedState != null && updatedState.currentMapNumber >= 8) {
        // Victory screen handles LP calculation and save cleanup
        context.go('/victory');
      } else {
        ref.read(gameStateProvider.notifier).advanceToNextMap();
        context.go('/map');
      }
    } else {
      context.go('/map');
    }
  } else {
    // DO NOT call gameOver() here — Game Over screen handles
    // the run-end lifecycle (LP calc → profile update → save delete)
    context.go('/game-over');
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 issues

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/combat/combat_screen.dart
git commit -m "feat: pass enemy type tracking, delegate run-end to Game Over/Victory screens"
```

---

### Task 10: Final integration — initialize profile in app startup

**Files:**
- Modify: `lib/app.dart` (or `lib/main.dart` — wherever the app bootstraps)

- [ ] **Step 1: Find the app entry point**

Read `lib/main.dart` and `lib/app.dart` to understand how the app bootstraps.

- [ ] **Step 2: Ensure PlayerProfile initializes before first screen renders**

The title screen already calls `initialize()` in its `initState`. This is sufficient for Phase 1 — the profile provider is initialized when the title screen loads.

No changes needed here if the title screen handles it. Verify by running the app.

- [ ] **Step 3: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 4: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 issues

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: Phase 1 complete — core roguelike loop with LP tracking"
```

---

## Summary of Changes

| File | Action | Purpose |
|------|--------|---------|
| `lib/models/player_profile.dart` | Create | Persistent profile model (LP, stats, unlocked classes) |
| `lib/models/game_state.dart` | Modify | Add run tracking fields, change gold default to 0 |
| `lib/services/save_service.dart` | Modify | Add profile persistence, single-run save methods |
| `lib/services/legacy_point_calculator.dart` | Create | LP calculation with difficulty multipliers |
| `lib/providers/player_profile_provider.dart` | Create | Riverpod provider for PlayerProfile |
| `lib/providers/game_state_provider.dart` | Modify | Run tracking, endRun(), single-save, gold reset |
| `lib/ui/widgets/lp_breakdown.dart` | Create | Shared LP display widget |
| `lib/ui/screens/game_over/game_over_screen.dart` | Modify | Show LP breakdown, process run-end lifecycle |
| `lib/ui/screens/victory/victory_screen.dart` | Modify | Show LP breakdown, process run-end lifecycle |
| `lib/ui/screens/title/title_screen.dart` | Modify | Single save, LP display, profile init |
| `lib/ui/screens/party_select/party_select_screen.dart` | Modify | Profile-based class unlocks, remove slot param |
| `lib/ui/screens/combat/combat_screen.dart` | Modify | Pass enemy type data to completeCombat |
| `test/models/player_profile_test.dart` | Create | Unit tests for PlayerProfile |
| `test/services/save_service_test.dart` | Create | Unit tests for profile persistence |
| `test/providers/player_profile_provider_test.dart` | Create | Unit tests for profile provider |
| `test/models/game_state_test.dart` | Create | Unit tests for run tracking fields |
| `test/services/legacy_point_calculator_test.dart` | Create | Unit tests for LP calculation |
