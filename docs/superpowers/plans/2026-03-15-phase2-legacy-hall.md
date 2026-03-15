# Phase 2: Legacy Hall — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the Legacy Hall meta-shop where players spend Legacy Points on class unlocks, passive stat bonuses, and starting perks. Add perk selection to party select and apply passive bonuses + perks at run start.

**Architecture:** Static data definitions for bonuses and perks. PlayerProfile extended with `passiveBonuses` and `unlockedPerks` maps. GameState extended with `activePerk`. Legacy Hall is a new 3-tab screen. `startNewGame()` reads profile to apply bonuses and perk effects.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, GoRouter

---

## Task 1: Define passive bonus and starting perk data

**Files:**
- Create: `lib/data/legacy_data.dart`

Static data for all purchasable items. No tests needed (pure data).

- [ ] **Step 1: Create legacy_data.dart**

```dart
// lib/data/legacy_data.dart

class PassiveBonusDefinition {
  final String id;
  final String name;
  final String description;
  final int costPerRank;
  final int maxRanks;

  const PassiveBonusDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.costPerRank,
    required this.maxRanks,
  });
}

class StartingPerkDefinition {
  final String id;
  final String name;
  final String description;
  final int cost;

  const StartingPerkDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });
}

const List<PassiveBonusDefinition> passiveBonuses = [
  PassiveBonusDefinition(id: 'hp', name: '+5 Max HP', description: 'All characters start with +5 max HP per rank', costPerRank: 25, maxRanks: 10),
  PassiveBonusDefinition(id: 'attack', name: '+1 Attack', description: 'All characters start with +1 attack per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'defense', name: '+1 Defense', description: 'All characters start with +1 defense per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'speed', name: '+1 Speed', description: 'All characters start with +1 speed per rank', costPerRank: 40, maxRanks: 3),
  PassiveBonusDefinition(id: 'magic', name: '+1 Magic', description: 'All characters start with +1 magic per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'shop_discount', name: '+5% Shop Discount', description: 'Reduces purchase prices by 5% per rank', costPerRank: 20, maxRanks: 4),
  PassiveBonusDefinition(id: 'ability_refresh', name: '+10% Ability Refresh', description: 'Abilities have +10% refresh chance per rank (additive)', costPerRank: 50, maxRanks: 3),
  PassiveBonusDefinition(id: 'health_potion', name: '+1 Starting Potion', description: 'Start each run with +1 health potion per rank', costPerRank: 15, maxRanks: 3),
  PassiveBonusDefinition(id: 'army_delay', name: 'Army Delay', description: 'Army starts 1 column further back per rank', costPerRank: 75, maxRanks: 2),
];

const List<StartingPerkDefinition> startingPerks = [
  StartingPerkDefinition(id: 'scavenger', name: 'Scavenger', description: 'Start with a random common weapon', cost: 25),
  StartingPerkDefinition(id: 'merchant_purse', name: "Merchant's Purse", description: 'Start with 50 gold', cost: 20),
  StartingPerkDefinition(id: 'scout_eye', name: "Scout's Eye", description: 'All adjacent nodes start scouted on map 1', cost: 40),
  StartingPerkDefinition(id: 'veteran', name: 'Veteran', description: 'Start at level 2', cost: 60),
  StartingPerkDefinition(id: 'lucky', name: 'Lucky', description: '+10% treasure quality', cost: 45),
  StartingPerkDefinition(id: 'army_intel', name: 'Army Intel', description: 'Army moves 20% slower on map 1', cost: 35),
];
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/legacy_data.dart
git commit -m "feat: add passive bonus and starting perk data definitions"
```

---

## Task 2: Extend PlayerProfile with bonus/perk fields

**Files:**
- Modify: `lib/models/player_profile.dart`
- Modify: `test/models/player_profile_test.dart`

- [ ] **Step 1: Add fields to PlayerProfile**

Add two new fields:
```dart
Map<String, int> passiveBonuses; // bonus ID -> rank purchased
List<String> unlockedPerks; // perk IDs purchased
```

With constructor defaults:
```dart
Map<String, int>? passiveBonuses,
List<String>? unlockedPerks,
```
Initialize: `passiveBonuses = passiveBonuses ?? {}` and `unlockedPerks = unlockedPerks ?? []`

Add to toJson/fromJson.

- [ ] **Step 2: Add tests for new fields**

Add to existing test file:
```dart
test('passiveBonuses and unlockedPerks serialize', () {
  final profile = PlayerProfile(
    passiveBonuses: {'hp': 3, 'attack': 1},
    unlockedPerks: ['scavenger', 'veteran'],
  );
  final json = profile.toJson();
  final restored = PlayerProfile.fromJson(json);
  expect(restored.passiveBonuses['hp'], 3);
  expect(restored.passiveBonuses['attack'], 1);
  expect(restored.unlockedPerks, contains('scavenger'));
  expect(restored.unlockedPerks, contains('veteran'));
});
```

- [ ] **Step 3: Run tests, commit**

```bash
flutter test test/models/player_profile_test.dart
git commit -m "feat: add passiveBonuses and unlockedPerks to PlayerProfile"
```

---

## Task 3: Add purchase methods to PlayerProfileProvider

**Files:**
- Modify: `lib/providers/player_profile_provider.dart`
- Modify: `test/providers/player_profile_provider_test.dart`

- [ ] **Step 1: Add purchase methods**

```dart
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
```

- [ ] **Step 2: Add tests**

```dart
test('purchaseClassUnlock deducts LP and adds class', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(playerProfileProvider.notifier);
  await notifier.initialize();
  await notifier.addLegacyPoints(100);

  final success = await notifier.purchaseClassUnlock(CharacterClass.paladin, 50);
  final profile = container.read(playerProfileProvider);

  expect(success, true);
  expect(profile!.legacyPoints, 50);
  expect(profile.unlockedClasses, contains(CharacterClass.paladin));
});

test('purchaseClassUnlock fails if insufficient LP', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(playerProfileProvider.notifier);
  await notifier.initialize();

  final success = await notifier.purchaseClassUnlock(CharacterClass.paladin, 50);
  expect(success, false);
});

test('purchasePassiveBonus increments rank', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(playerProfileProvider.notifier);
  await notifier.initialize();
  await notifier.addLegacyPoints(100);

  await notifier.purchasePassiveBonus('hp', 25, 10);
  await notifier.purchasePassiveBonus('hp', 25, 10);
  final profile = container.read(playerProfileProvider);

  expect(profile!.passiveBonuses['hp'], 2);
  expect(profile.legacyPoints, 50);
});

test('purchasePassiveBonus fails at max rank', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(playerProfileProvider.notifier);
  await notifier.initialize();
  await notifier.addLegacyPoints(500);

  for (int i = 0; i < 10; i++) {
    await notifier.purchasePassiveBonus('hp', 25, 10);
  }
  final success = await notifier.purchasePassiveBonus('hp', 25, 10);
  expect(success, false);
});

test('purchasePerk unlocks perk', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final notifier = container.read(playerProfileProvider.notifier);
  await notifier.initialize();
  await notifier.addLegacyPoints(100);

  final success = await notifier.purchasePerk('scavenger', 25);
  final profile = container.read(playerProfileProvider);

  expect(success, true);
  expect(profile!.unlockedPerks, contains('scavenger'));
  expect(profile.legacyPoints, 75);
});
```

- [ ] **Step 3: Run tests, commit**

```bash
flutter test test/providers/player_profile_provider_test.dart
git commit -m "feat: add purchase methods for classes, bonuses, and perks"
```

---

## Task 4: Add activePerk to GameState

**Files:**
- Modify: `lib/models/game_state.dart`

- [ ] **Step 1: Add activePerk field**

Add `String? activePerk;` field to GameState. Add to constructor, toJson, fromJson. Also carry forward in `_refreshState()` in game_state_provider.dart and in `advanceToNextMap()`.

- [ ] **Step 2: Run tests, commit**

```bash
flutter test test/models/game_state_test.dart
git commit -m "feat: add activePerk field to GameState"
```

---

## Task 5: Apply passive bonuses and perks in startNewGame

**Files:**
- Modify: `lib/providers/game_state_provider.dart`

Update `startNewGame()` to:
1. Accept an optional `PlayerProfile? profile` parameter and `String? activePerk` parameter
2. Apply passive stat bonuses from profile to each character's base stats after creation
3. Apply perk effects (starting gold, potions, level, army delay)
4. Store activePerk in GameState

```dart
Future<void> startNewGame(
  List<CharacterClass> selectedClasses,
  DifficultyLevel difficulty, {
  PlayerProfile? profile,
  String? activePerk,
}) async {
  // ... create party as before ...

  // Apply passive bonuses from profile
  if (profile != null) {
    final bonuses = profile.passiveBonuses;
    for (final char in party) {
      char.maxHp += (bonuses['hp'] ?? 0) * 5;
      char.currentHp = char.maxHp; // refresh after HP boost
      char.attack += bonuses['attack'] ?? 0;
      char.defense += bonuses['defense'] ?? 0;
      char.speed += bonuses['speed'] ?? 0;
      char.magic += bonuses['magic'] ?? 0;
    }
  }

  // Calculate starting resources from profile and perk
  int startingGold = 0;
  int startingPotions = 0;
  double armyStartColumn = -2.0;

  if (profile != null) {
    startingPotions += profile.passiveBonuses['health_potion'] ?? 0;
    armyStartColumn -= (profile.passiveBonuses['army_delay'] ?? 0).toDouble();
  }

  if (activePerk == 'merchant_purse') startingGold += 50;
  if (activePerk == 'veteran') {
    for (final char in party) {
      ProgressionService.addXp(char, ProgressionService.xpForLevel(2));
    }
  }

  final map = MapService.generateMap(1);
  map.armyColumn = armyStartColumn;

  state = GameState(
    party: party,
    gold: startingGold,
    healthPotions: startingPotions,
    currentMap: map,
    difficulty: difficulty,
    activePerk: activePerk,
  );

  ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
  await _autoSave();
}
```

- [ ] **Step 1: Make the changes**
- [ ] **Step 2: Update party_select_screen.dart to pass profile and perk**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 6: Create Legacy Hall screen

**Files:**
- Create: `lib/ui/screens/legacy_hall/legacy_hall_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/ui/screens/title/title_screen.dart`

3-tab screen (Classes, Passives, Perks) with purchase buttons. Each tab reads from PlayerProfile to show current state and remaining LP.

- [ ] **Step 1: Create Legacy Hall screen**

A ConsumerWidget with DefaultTabController(length: 3). Three tabs:
- Classes tab: grid of 12 lockable classes with unlock buttons showing cost
- Passives tab: list of 9 passive bonuses with rank progress and buy button
- Perks tab: list of 6 perks with unlock/locked state

Each purchase calls the provider method and the UI rebuilds via ref.watch.

- [ ] **Step 2: Add route**

Add to app_router.dart:
```dart
GoRoute(path: '/legacy-hall', builder: (context, state) => const LegacyHallScreen()),
```

- [ ] **Step 3: Add Legacy Hall button to title screen**

Add between Continue and Guide buttons.

- [ ] **Step 4: Run flutter analyze, commit**

---

## Task 7: Add perk selection to Party Select

**Files:**
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`

Add a perk picker section before the "Begin Adventure" button. Shows unlocked perks from profile. Player picks one (or none). The selected perk is passed to `startNewGame()`.

- [ ] **Step 1: Add perk selection UI**
- [ ] **Step 2: Pass profile and perk to startNewGame**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 8: Final integration and verification

- [ ] **Step 1: Run all tests**
- [ ] **Step 2: Run flutter analyze**
- [ ] **Step 3: Final commit if needed**
