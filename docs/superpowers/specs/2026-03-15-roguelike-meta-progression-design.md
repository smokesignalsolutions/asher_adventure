# Roguelike Meta-Progression Design

## Overview

Transform Asher's Adventure from a linear progression game into a true roguelike with meta-progression. Each run starts fresh (level 1, no gear, no gold), but players permanently unlock classes, passive bonuses, starting perks, loot pool items, and codex knowledge across runs. Two progression tracks work together: **Legacy Points** (concrete upgrades) and the **Codex** (discovery-driven rewards).

Difficulty is accessible — Normal mode is winnable fairly often — but harder difficulties and challenges provide a steep ceiling for experienced players.

## Run Reset & Legacy Points

### What Resets Each Run
- Party levels → level 1
- All equipment → removed
- Gold → 0
- Health potions → 0
- Map progress → map 1
- Gold also resets between maps (spend it or lose it)

### What Persists Forever
Stored in a `PlayerProfile` separate from run saves, never deleted:
- Legacy Points balance
- Codex entries (bestiary, lore, class stories)
- Purchased upgrades (passive bonuses, starting perks, class unlocks)
- Unlocked mutators and difficulties
- Meta-stats (total runs, total kills, furthest map reached, total victories)

### Legacy Point Formula (on death or victory)
- Base: 10 points per map completed
- Bonus: +5 per boss killed
- Bonus: +2 per unique enemy type killed that run
- Bonus: +25 for a full victory (beating map 8)
- Difficulty multiplier: Easy x0.5, Normal x1.0, Hard x1.5, Nightmare x2.0

Example: Normal run, dies on map 4, killed 2 bosses, encountered 8 enemy types = (40 + 10 + 16) x 1.0 = 66 points.

### Run-End Lifecycle (Critical Sequence)
1. Party wipes (or final boss defeated) → trigger run-end
2. Calculate legacy points from run tracking data (before save is touched)
3. Update PlayerProfile: add LP, update bestiary kills, check codex unlocks, update meta-stats
4. Save PlayerProfile to SharedPreferences
5. Display LP breakdown screen (Game Over or Victory screen)
6. Player dismisses → delete run save → return to title screen

### Run Tracking Fields (in GameState, reset each run)
- `mapsCompletedThisRun: int` — incremented when boss is defeated and map advances
- `bossesKilledThisRun: int` — incremented on boss kill
- `uniqueEnemyTypesKilledThisRun: Set<String>` — enemy template IDs added on kill
- These fields exist only for LP calculation and are discarded with the run save

## Legacy Hall (Meta-Shop)

Accessible from the title screen. Three tabs:

### Class Unlocks
- Start with 4 classes: Fighter, Rogue, Cleric, Wizard
- Other 12 unlock at increasing costs: 50, 75, 100, 150, 200, 250, 300, 350, 400, 500, 600, 750
- Player chooses which class to unlock next (not a fixed order)

### Passive Bonuses (stackable ranks)
Applied at character creation time in `startNewGame()`, baked into base stats. The profile is read once and the bonuses are added to each character's base stats before the run begins.

| Bonus | Cost/Rank | Max Ranks |
|-------|-----------|-----------|
| +5 max HP (all characters) | 25 | 10 |
| +1 attack | 30 | 5 |
| +1 defense | 30 | 5 |
| +1 speed | 40 | 3 |
| +1 magic | 30 | 5 |
| +5% shop discount | 20 | 4 |
| +10% ability refresh rate (additive, e.g. 35% becomes 45%) | 50 | 3 |
| Start with 1 health potion | 15 | 3 |
| Army starts 1 column further back | 75 | 2 |

### Starting Perks (pick ONE per run)
Purchased once, then chosen at the start of each run:
| Perk | Cost | Effect |
|------|------|--------|
| Scavenger | 25 | Start with a random common weapon |
| Healer's Blessing | 30 | Start with a bonus shield equal to 20% max HP (absorbs damage first, does not exceed max HP cap) |
| Merchant's Purse | 20 | Start with 50 gold |
| Scout's Eye | 40 | All adjacent nodes start scouted |
| Veteran | 60 | Start at level 2 |
| Lucky | 45 | +10% treasure quality |
| Army Intel | 35 | Army moves 20% slower for map 1 |

## The Codex

Accessible from the title screen. Three sections:

### Bestiary
- One entry per enemy type (including bosses and army units)
- Progressive reveal:
  - Encounter → silhouette + name
  - Kill 5 → stats shown
  - Kill 15 → full description + mechanical reward
- Rewards per completed entry:
  - +3% damage vs that enemy type
  - Hint about their abilities (e.g. "Goblin Shaman will always heal when below 50% HP")
- Completing ALL entries for a map-tier (e.g. all enemies from the 3 themes in the map 1-2 pool) → +5% damage on maps of that tier

### Lore Pages
- Found at event nodes and treasure nodes (~20% chance)
- 3-5 pages per map-tier (not per theme), so 12-20 total across 4 tiers
- Each page is a short paragraph of world-building
- Collecting all pages for a map → unlocks 1-2 new unique items in that map's equipment pool
- Collecting ALL lore → unlocks a secret 9th "true ending" boss fight (stretch goal)

### Class Stories
- One story per class (16 total), told in 3 chapters
- Chapter 1: complete map 2 with that class alive in party (dead members don't count)
- Chapter 2: complete map 5 with that class alive in party
- Chapter 3: complete map 8 with that class alive in party
- Rewards:
  - Chapter 1: unlock a new ability for that class
  - Chapter 2: +5% to that class's primary stat growth
  - Chapter 3: unlock that class's "ultimate" ability (60-80 damage range, 10-15% refresh chance)

## Run Variety

### Map Themes
Each map gets a random theme from a pool. Themes determine enemy types, flavor text, and events:
- Map 1-2 pool: Goblin Woods, Bandit Road, Cursed Graveyard
- Map 3-4 pool: Frozen Pass, Burning Desert, Haunted Swamp
- Map 5-6 pool: Dragon Mountain, Shadow Keep, Sunken Ruins
- Map 7-8 pool: Demon Fortress, Void Realm, The Dark Throne

Each theme has its own enemy set (3 regular enemy types + 1 boss), and 3-5 unique events. This means 12 themes x 3 enemies = 36 regular enemies, 12 bosses, and 3 army unit types = ~51 total bestiary entries.

Existing enemy data in `enemiesByMap` will be reorganized by theme ID instead of map number. New enemy templates will be authored as themes are built out.

### Run Mutators
Each run gets 1 random mutator (shown at start):
- "Blood Moon" — enemies +15% attack, +25% gold drops
- "Merchant's Holiday" — shops have double inventory, rest nodes removed
- "Fog of War" — scouting disabled, treasure gives double loot
- "Veteran Army" — army 25% faster, army fights give double legacy points
- "Blessed Run" — healing +30% effective, shops cost +20%
- More unlockable via legacy points (stretch goal — unlock mechanism TBD)

### Meaningful Events
Choice-driven with real tradeoffs:
- "A dying soldier offers his cursed blade: +8 attack, -15 max HP permanently. Take it?"
- "A fork in the road — shortcut (skip a column, army advances 2 extra) or long way?"
- "A merchant offers to identify a mystery potion — could be full heal or poison"
- ~15-20 unique events per map theme pool

### Build-Defining Drops
Rare legendary items that change playstyle. These require adding a `specialEffect: String?` field to the `Equipment` model to define passive behaviors. Drop source: treasure nodes and boss kills (10% chance to drop a legendary instead of normal loot).
- "Vampiric Blade" — all attacks heal 25% damage dealt, can't use healing abilities
- "Staff of Chains" — AOE spells hit twice, single-target spells deal -30%
- "Shield of Thorns" — reflect 15% damage taken, -20% attack

## Difficulty & Balance

### Enemy Scaling
Tuned for a party that starts at level 1 each run:
- Map 1: easy, teaches mechanics, almost always clearable
- Map 2-3: moderate, careless play kills you
- Map 4-5: hard, requires good team comp and smart ability usage
- Map 6-7: very hard, need good equipment and solid build choices
- Map 8: brutal, boss is a real wall, most runs end here or on the way

### Difficulty Modes
- **Easy:** Slow army, enemies deal less damage. 0.5x legacy points. For learning.
- **Normal:** Intended experience. 1x legacy points.
- **Hard:** Unlocked after first victory. More enemy HP, faster army. 1.5x legacy points.
- **Nightmare:** Unlocked after Hard victory. Everything cranked up. 2x legacy points.

### Anti-Snowball Mechanics
- Gold resets between maps (spend or lose)
- Rest nodes heal 60% instead of full (dead party members are revived at 30% HP)
- Health potions heal 30%
- Boss enrage timers: after 15 rounds, boss gets +10% attack per round
- Starting gold is 0 (changed from current default of 50)

### Pro-Player Rewards
- Faster clears = army is less of a threat
- Smart pathing (shop before boss, or risk it?)
- Party comp matters when every class starts at level 1

## Data Architecture

### New Model: PlayerProfile
Stored in SharedPreferences under its own key, never deleted:
```
PlayerProfile
  legacyPoints: int
  totalLegacyPointsEarned: int
  totalRuns: int
  totalVictories: int
  furthestMap: int
  unlockedClasses: List<CharacterClass>
  passiveBonuses: Map<String, int>  // bonus ID → rank
  unlockedPerks: List<String>
  bestiary: Map<String, BestiaryEntry>
  lorePages: Map<String, List<bool>>  // map ID → pages found
  classStories: Map<CharacterClass, int>  // class → highest chapter
  unlockedMutators: List<String>
  unlockedDifficulties: List<DifficultyLevel>
```

### New Models
- `BestiaryEntry` — enemyId, killCount, isComplete, rewardUnlocked
- `LorePage` — mapNumber, pageIndex, title, content, found
- `RunMutator` — id, name, description, effects
- `MapTheme` — id, name, enemyPool, boss, eventPool, lorePages
- `StartingPerk` — id, name, description, effect
- `PassiveBonus` — id, name, description, costPerRank, maxRanks, effect

### Modified GameState
- Remove `totalEnemiesDefeated`, `totalGoldEarned` (moved to profile)
- Add `activePerk: String?` (chosen at run start)
- Add `activeMutator: String` (randomly assigned)
- Add `currentTheme: String` (per map)
- Add `mapsCompletedThisRun: int`
- Add `bossesKilledThisRun: int`
- Add `uniqueEnemyTypesKilledThisRun: Set<String>`
- Gold resets per map
- Starting gold changed from 50 to 0 (unless Merchant's Purse perk is active)

### New Provider: PlayerProfileProvider
- `StateNotifierProvider<PlayerProfileNotifier, PlayerProfile>`
- Loaded on app startup from SharedPreferences
- Updated at run-end (LP award, codex updates)
- Updated from Legacy Hall (purchases)
- Read during `startNewGame()` to apply passive bonuses and check class unlocks
- Separate from `gameStateProvider` — profile persists, run state is ephemeral

### Save Slot Changes
The current 3-slot system is simplified: only 1 active run save (since runs reset on death). The slot system is removed. PlayerProfile is the persistent store; the run save is a single ephemeral key.

### Migration Notes
- Flip 12 classes from `unlockedByDefault: true` to `false` in class_data.dart
- Existing saves: on first launch with new version, create a PlayerProfile with all 16 classes unlocked (grandfathering existing players)
- New installs: PlayerProfile starts with 4 starter classes

### New Screens
- **Legacy Hall** — shop for spending legacy points (3 tabs: classes, passives, perks)
- **Codex** — viewer for bestiary + lore + class stories

### Modified Screens
- **Title Screen** — add Legacy Hall and Codex buttons
- **Party Select** — gate classes behind unlocks, add perk selection
- **Game Over** — show legacy points earned breakdown before returning to title
- **Victory** — same legacy point breakdown plus victory bonus

### No New Dependencies
Built on existing architecture: Riverpod providers, SharedPreferences, GoRouter.
