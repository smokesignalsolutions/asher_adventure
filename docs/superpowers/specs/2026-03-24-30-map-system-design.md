# 30-Map System

**Date:** 2026-03-24
**Status:** Draft

## Overview

Replace the fixed 8-map progression with a pool of 30 themed maps. Each run randomly selects 8 unique maps — slots 1-4 from the natural/overworld pool, slots 5-8 from dungeon/magical pools. Maps apply class-specific stat modifiers to combat. Map backgrounds use new art from `assets/maps/`.

**Important distinction:** `currentMapNumber` (1-8) remains the **difficulty tier index** used for enemy scaling, boss selection, equipment tiers, shop pricing, and lore tier calculations. The **map definition ID** (1-30) determines the theme, background, and class modifiers. These are separate concepts.

## Map Definition Data

### New file: `lib/data/map_data.dart`

```dart
class StatModifier {
  final double atkPercent;
  final double magPercent;
  final double defPercent;
  final double spdPercent;
  const StatModifier({this.atkPercent = 0, this.magPercent = 0, this.defPercent = 0, this.spdPercent = 0});
}

class MapDefinition {
  final int id;
  final String name;
  final String category; // 'natural', 'dungeon', 'magical'
  final String imagePath;
  final String eventTheme; // ties into event_data.dart theme system
  final Map<CharacterClass, StatModifier> classModifiers;
  const MapDefinition({required this.id, required this.name, required this.category,
    required this.imagePath, required this.eventTheme, required this.classModifiers});
  // Future: specialMonsters, hazard
}

/// Lookup helper used by UI and background functions.
MapDefinition getMapDefinition(int id) => mapDefinitions.firstWhere((m) => m.id == id);
```

All 30 maps from the reference document, with their full class modifier data. The `eventTheme` field maps each map to the event theme system for story unlocks.

### Map-to-Event Theme Mapping

| Map | Event Theme |
|---|---|
| Forest, Deep Jungle, Mushroom Forest, Enchanted Grove | forest |
| Desert, Tundra, Mountain Pass, Badlands, Plains | wild |
| Swamp, Sunken Marsh, Coastal Cliffs | wild |
| Cursed Wasteland, Shadow Realm, Catacombs, Haunted Graveyard | dark |
| Cave System, Goblin Warren, Abandoned Mine, Underground Lake | martial |
| Ancient Ruins, Crystal Caverns, Arcane Tower | arcane |
| Volcano, Volcanic Demon Fortress | arcane |
| Frozen Citadel, Gladiator Arena | martial |
| Pirate Cove | dark |
| Floating Sky Islands, The Void | dark |
| Ancient Shrine (Plains), Phoenix Nest-style maps | holy |

**Note on `holy` theme:** Several maps have no natural `holy` affinity. To ensure holy-themed events (Ancient Shrine, Lost Traveler, etc.) remain reachable, add a secondary event theme field to `MapDefinition`:

```dart
final String? secondaryEventTheme; // optional, 20% chance to use instead of primary
```

Maps assigned `holy` as secondary: Plains(8), Enchanted Grove(17), Frozen Citadel(30), Mountain Pass(6). This ensures Cleric/Paladin/Templar get story unlocks on some maps.

### Category Pools

- **Natural/Overworld** (13 maps): Forest(1), Desert(2), Swamp(3), Tundra(4), Volcano(5), Mountain Pass(6), Coastal Cliffs(7), Plains(8), Deep Jungle(9), Cursed Wasteland(10), Badlands(21), Mushroom Forest(22), Sunken Marsh(23)
- **Dungeon/Underground** (8 maps): Cave System(11), Ancient Ruins(12), Catacombs(13), Underground Lake(14), Goblin Warren(15), Crystal Caverns(24), Haunted Graveyard(25), Abandoned Mine(26)
- **Magical/Special** (9 maps): Shadow Realm(16), Enchanted Grove(17), Volcanic Demon Fortress(18), Floating Sky Islands(19), The Void(20), Pirate Cove(27), Arcane Tower(28), Gladiator Arena(29), Frozen Citadel(30)

## Map Selection Per Run

At run start, select 8 unique maps:

1. Shuffle the Natural/Overworld pool (13 maps), take 4
2. Combine Dungeon + Magical pools (17 maps), shuffle, take 4
3. The 8 selected map IDs stored in order as `List<int> mapPool` on `GameState`

No repeats within a single run. Each run feels different.

## Stat Modifiers

From the reference document, each map has bonuses and penalties for specific classes. Example:

**Forest:**
- Druid: +20% MAG, +10% DEF
- Ranger: +20% ATK, +10% SPD
- Rogue: +15% ATK, +15% SPD
- Wizard: -15% MAG
- Sorcerer: -15% MAG
- Artificer: -10% ATK, -10% SPD

### Application — Combat Multiplier Pattern

Follow the existing pattern of combat multiplier fields on `Character`. Currently `combatAttackMultiplier` and `combatDefenseMultiplier` exist and are reset to 1.0 in `CombatService.initCombat()`.

**Add two new fields to `Character`:**
- `combatSpeedMultiplier` (double, default 1.0)
- `combatMagicMultiplier` (double, default 1.0)

**In `CombatService.initCombat()`:**
1. Reset all 4 combat multiplier fields to 1.0 (existing behavior for ATK/DEF, new for SPD/MAG)
2. Look up the current map definition
3. For each party member, check if their class has a modifier on this map
4. Apply: `combatAttackMultiplier += atkPercent / 100`, same for DEF/SPD/MAG

**Computed stats** (`totalAttack`, `totalDefense`, etc.) already incorporate the ATK/DEF multipliers. Add equivalent multiplier usage to `totalSpeed` and `totalMagic` getters.

This is safer than store-and-restore — multipliers reset automatically at each combat start, so crashes or abnormal exits can't leave stats corrupted.

The combat screen should show a small indicator when a character has active modifiers (green up arrow for bonuses, red down arrow for penalties).

## Map Backgrounds

### Replace `map_backgrounds.dart`

Both `mapBackground()` and `combatBackground()` change signature to accept a map definition ID:

```dart
String mapBackground(int mapDefinitionId) {
  return getMapDefinition(mapDefinitionId).imagePath;
}

String combatBackground(int mapDefinitionId) {
  return getMapDefinition(mapDefinitionId).imagePath; // Same for now
}
```

Callers update: `mapBackground(gameState.currentMapDefinitionId)` instead of `mapBackground(gameState.currentMapNumber)`.

Custom combat backgrounds per map are a future enhancement.

### Asset Declaration

Add `assets/maps/` to `pubspec.yaml`.

## Game State Changes

### `GameState` model

Add field: `List<int> mapPool` — the 8 selected map definition IDs for this run, in order.

`mapPool[0]` is the map definition used for map 1, `mapPool[1]` for map 2, etc.

Helper: `int get currentMapDefinitionId => mapPool[currentMapNumber - 1]`

### Serialization

`mapPool` serializes to/from JSON as a simple `List<int>`.

**Backward compatibility:** If `mapPool` is missing from saved JSON (pre-update saves), generate a default `[1, 2, 3, 4, 5, 6, 7, 8]` to provide legacy linear progression. This maps to the first 8 map definitions (Forest through Plains), which approximates the old behavior.

### Provider Changes

- `startNewRun()`: generate the 8-map pool before creating the game state, pass it to the GameState constructor
- `advanceToNextMap()`: must forward `mapPool` when constructing the new GameState (it creates a new instance manually)
- `_refreshState()`: must copy `mapPool` when creating the refreshed GameState (it also creates a new instance manually)

**Note:** Both `advanceToNextMap()` and `_refreshState()` manually copy every GameState field into a new constructor call. The new `mapPool` field MUST be added to both, or it will be silently lost.

## Event Theme Integration

Update `event_data.dart`:
- `selectEventForMap` changes signature to accept an event theme string: `selectEventForMap(String theme, [Random? rng])`
- Remove `mapThemeWeights` map (no longer needed — theme comes from map definition)
- Filter events by the given theme, pick randomly

The event screen reads the current map definition's `eventTheme` (with 20% chance to use `secondaryEventTheme` if present) and passes it to `selectEventForMap`.

**Call sites to update:**
- `event_screen.dart` `initState()`: currently calls `selectEventForMap(mapNumber)`, changes to use theme string from map definition

**Unchanged references:** Lore tier calculation in `_checkForLoreDrop()` still uses `currentMapNumber` (1-8) for tier, NOT the map definition ID. Enemy generation, boss selection, shop pricing, treasure tiers all continue using `currentMapNumber` as the difficulty index.

## UI Changes

### Map Screen

Show the map name via a lookup: `getMapDefinition(gameState.currentMapDefinitionId).name`. Display as "Map 3 — Catacombs" in the app bar.

### Combat Screen

Small modifier indicators next to characters that have active bonuses/penalties. A green/red arrow icon with the stat name is sufficient for now.

## Files Modified

| File | Change |
|---|---|
| `lib/data/map_data.dart` | **New** — 30 MapDefinitions with class modifiers, event themes, `getMapDefinition()` helper |
| `lib/data/map_backgrounds.dart` | Rewrite to use MapDefinition from map_data, change function signatures |
| `lib/data/event_data.dart` | Change `selectEventForMap` to accept theme string; remove `mapThemeWeights` |
| `lib/models/game_state.dart` | Add `mapPool` field, `currentMapDefinitionId` helper, backward-compatible fromJson |
| `lib/models/character.dart` | Add `combatSpeedMultiplier` and `combatMagicMultiplier` fields |
| `lib/providers/game_state_provider.dart` | Generate map pool at run start; forward `mapPool` in `advanceToNextMap()` and `_refreshState()` |
| `lib/services/combat_service.dart` | Reset all 4 multipliers in `initCombat()`, apply map modifiers |
| `lib/ui/screens/map/map_screen.dart` | Show map name, update `mapBackground` call |
| `lib/ui/screens/combat/combat_screen.dart` | Update `combatBackground` call, show modifier indicators |
| `lib/ui/screens/event/event_screen.dart` | Use map definition's eventTheme for event selection |
| `pubspec.yaml` | Add `assets/maps/` |

## Unchanged References (using `currentMapNumber` 1-8 as difficulty tier)

These continue to work as-is and are NOT modified:
- `enemiesByMap[mapNum]` — enemy scaling
- `bossByMap[mapNum]` — boss selection
- `armySoldiers(mapNum)` — army encounters
- `_generateStock(mapNum)` — shop equipment tiers
- Lore tier calculation `((currentMapNumber - 1) ~/ 2) + 1`
- `GameConstants.totalMaps = 8` — maps per run, not total definitions

## Not In Scope (Future TODO)

- Special monsters (2 unique monsters per map with custom mechanics)
- Environmental hazards (1 per map with per-round effects)
- Custom combat backgrounds per map (separate art per map for combat scenes)
- Map-specific loot tables
