# Phase 4: Run Variety — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make each run feel different through run mutators (random modifier per run), expanded meaningful events with real tradeoffs, and build-defining legendary equipment with special effects.

**Architecture:** Mutator data + selection at run start stored in GameState. Mutator effects applied at their natural hook points (combat damage, shop prices, army speed, etc.). SpecialEffect enum added to Equipment model. Legendary items added to treasure/boss drop pools. Event system expanded with more choices and consequences.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, GoRouter

---

## Task 1: Define mutator data and add to GameState

**Files:**
- Create: `lib/data/mutator_data.dart`
- Modify: `lib/models/game_state.dart`

Define mutator data:
```dart
class MutatorDefinition {
  final String id;
  final String name;
  final String description;
  final Map<String, double> effects; // effect key -> multiplier

  const MutatorDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.effects,
  });
}

const List<MutatorDefinition> runMutators = [
  MutatorDefinition(
    id: 'blood_moon',
    name: 'Blood Moon',
    description: 'Enemies deal +15% damage, but drop +25% more gold',
    effects: {'enemy_damage': 1.15, 'gold_drop': 1.25},
  ),
  MutatorDefinition(
    id: 'merchant_holiday',
    name: "Merchant's Holiday",
    description: 'Shops have double inventory, but rest nodes only heal 30%',
    effects: {'shop_stock': 2.0, 'rest_heal': 0.3},
  ),
  MutatorDefinition(
    id: 'fog_of_war',
    name: 'Fog of War',
    description: 'Scouting is disabled, but treasure gives double loot',
    effects: {'scouting_disabled': 1.0, 'treasure_gold': 2.0},
  ),
  MutatorDefinition(
    id: 'veteran_army',
    name: 'Veteran Army',
    description: 'Army moves 25% faster, but army fights give double legacy points',
    effects: {'army_speed': 1.25, 'army_lp': 2.0},
  ),
  MutatorDefinition(
    id: 'blessed_run',
    name: 'Blessed Run',
    description: 'Healing is +30% effective, but shops cost +20%',
    effects: {'healing': 1.3, 'shop_cost': 1.2},
  ),
];
```

Add `String? activeMutator` to GameState (alongside activePerk). Add to constructor, toJson, fromJson, and carry through _refreshState and advanceToNextMap in the provider.

- [ ] **Step 1: Create mutator_data.dart**
- [ ] **Step 2: Add activeMutator to GameState**
- [ ] **Step 3: Carry through in provider (_refreshState, advanceToNextMap)**
- [ ] **Step 4: Run flutter analyze, commit**

---

## Task 2: Select mutator at run start and display it

**Files:**
- Modify: `lib/providers/game_state_provider.dart`
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`

In `startNewGame()`, randomly pick a mutator and store it. After navigating to the map, show a dialog announcing the mutator.

Update `startNewGame()` signature to accept `String? activeMutator`:
```dart
Future<void> startNewGame(
  List<CharacterClass> selectedClasses,
  DifficultyLevel difficulty, {
  PlayerProfile? profile,
  String? activePerk,
  String? activeMutator,
}) async {
```

In party select's `_startGame()`, pick a random mutator:
```dart
final mutator = runMutators[Random().nextInt(runMutators.length)];
```

Pass it to startNewGame. After navigating to `/map`, show the mutator announcement (or show it on the map screen).

Better approach: Show the mutator on the map screen when first loaded. Add a flag or check if it's map 1 to trigger a dialog.

- [ ] **Step 1: Add activeMutator to startNewGame**
- [ ] **Step 2: Pick random mutator in party select**
- [ ] **Step 3: Show mutator announcement on map screen (first load)**
- [ ] **Step 4: Run flutter analyze, commit**

---

## Task 3: Apply mutator effects throughout the game

**Files:**
- Modify: `lib/services/combat_service.dart` (damage/healing multipliers)
- Modify: `lib/ui/screens/shop/shop_screen.dart` (price multipliers)
- Modify: `lib/ui/screens/treasure/treasure_screen.dart` (gold multipliers)
- Modify: `lib/ui/screens/rest/rest_screen.dart` (healing multiplier)
- Modify: `lib/providers/game_state_provider.dart` (army speed, scouting)

Each mutator effect is applied at its natural hook point. The screen/service reads the activeMutator from GameState and looks up the effect value.

Helper function (can be in mutator_data.dart):
```dart
double getMutatorEffect(String? mutatorId, String effectKey) {
  if (mutatorId == null) return 1.0;
  final mutator = runMutators.firstWhere(
    (m) => m.id == mutatorId,
    orElse: () => MutatorDefinition(id: '', name: '', description: '', effects: {}),
  );
  return mutator.effects[effectKey] ?? 1.0;
}
```

Effects to apply:
- `enemy_damage`: In CombatService.calculateDamage, multiply enemy damage result. Need to pass mutator context or make it a parameter.
- `gold_drop`: In completeCombat, multiply goldGained.
- `shop_cost`: In ShopScreen, multiply item.value for purchase price.
- `rest_heal`: In RestScreen, multiply heal amount (currently heals to full — change to heal by percentage).
- `treasure_gold`: In TreasureScreen, multiply gold found.
- `healing`: In CombatService.calculateHealing, multiply result.
- `army_speed`: In _getArmySpeed, divide by mutator value (faster army = lower speed threshold).
- `scouting_disabled`: In moveToNode, skip scouting call.

- [ ] **Step 1: Add getMutatorEffect helper**
- [ ] **Step 2: Apply combat effects (enemy_damage, healing)**
- [ ] **Step 3: Apply economy effects (gold_drop, shop_cost, treasure_gold)**
- [ ] **Step 4: Apply army and rest effects**
- [ ] **Step 5: Apply scouting disabled**
- [ ] **Step 6: Run flutter analyze, commit**

---

## Task 4: Add SpecialEffect to Equipment model

**Files:**
- Modify: `lib/models/enums.dart`
- Modify: `lib/models/equipment.dart`

Add enum and field:
```dart
// In enums.dart
enum SpecialEffect { vampiric, chainCast, thorns }

// In equipment.dart
SpecialEffect? specialEffect;
```

Add to constructor, toJson (as index or null), fromJson.

- [ ] **Step 1: Add enum and field**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 5: Create legendary items and drop logic

**Files:**
- Create: `lib/data/legendary_data.dart`
- Modify: `lib/ui/screens/treasure/treasure_screen.dart`

Define 3-5 legendary items with special effects:
```dart
const List<Equipment> legendaryItems = [
  Equipment(name: 'Vampiric Blade', slot: weapon, rarity: legendary, attackBonus: 12, specialEffect: vampiric, value: 200),
  Equipment(name: 'Staff of Chains', slot: weapon, rarity: legendary, magicBonus: 15, attackBonus: 5, specialEffect: chainCast, value: 200),
  Equipment(name: 'Shield of Thorns', slot: offhand, rarity: legendary, defenseBonus: 10, specialEffect: thorns, value: 200),
];
```

At treasure nodes and after boss kills, 10% chance to get a legendary instead of normal loot.

- [ ] **Step 1: Create legendary_data.dart**
- [ ] **Step 2: Add 10% legendary drop chance to treasure**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 6: Apply special effects in combat

**Files:**
- Modify: `lib/services/combat_service.dart`

In `executeAllyTurn()`:
- **vampiric**: After dealing damage, heal attacker for 25% of damage dealt. Check if equipped weapon has `SpecialEffect.vampiric`.
- **chainCast**: If ability targets allEnemies, apply damage twice. Check weapon for `SpecialEffect.chainCast`.
- **thorns**: After taking damage (in executeEnemyTurn), if defender has `SpecialEffect.thorns` equipped, deal 15% of damage back to attacker.

Pass the character's equipment to combat calculations to check for effects.

- [ ] **Step 1: Add vampiric effect**
- [ ] **Step 2: Add thorns effect**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 7: Expand event system with more meaningful choices

**Files:**
- Modify: `lib/ui/screens/event/event_screen.dart`

Add 6-8 new events with more impactful choices:
- Permanent stat changes (attack/defense)
- Equipment offers (cursed items with tradeoffs)
- Party-wide effects
- Army manipulation (speed up/slow down)

- [ ] **Step 1: Add new events to the event list**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 8: Final verification

- [ ] **Step 1: Run all tests**
- [ ] **Step 2: Run flutter analyze**
- [ ] **Step 3: Final commit if needed**
