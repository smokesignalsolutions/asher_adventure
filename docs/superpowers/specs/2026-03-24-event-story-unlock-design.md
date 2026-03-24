# Event Story Unlock System

**Date:** 2026-03-24
**Status:** Draft

## Overview

Wire up event (`!`) nodes to unlock backstory chapters. Events have themes that map to class affinities. Players choose "explore" to trigger a story unlock for an eligible party member. Art tier upgrades (chapters 4 and 8) get a celebratory animation.

## Event Data Structure

### New file: `lib/data/event_data.dart`

Move the 36 hardcoded events out of `event_screen.dart` into a data file. Each event gets a `theme` tag.

```dart
class GameEvent {
  final String title;
  final String description;
  final String theme; // 'forest', 'dark', 'holy', 'arcane', 'martial', 'wild'
  final List<EventChoice> choices;
  const GameEvent({required this.title, required this.description, required this.theme, required this.choices});
}

class EventChoice {
  final String text;
  final String result;
  final int goldChange;
  final int hpChange;
  const EventChoice({required this.text, required this.result, this.goldChange = 0, this.hpChange = 0});
}
```

All events and choices use `const` constructors to match the existing pattern.

### Theme-to-Class Affinities

```dart
const Map<String, List<CharacterClass>> themeClassAffinities = {
  'forest': [ranger, druid],
  'dark': [warlock, necromancer, rogue],
  'holy': [cleric, paladin, templar],
  'arcane': [wizard, sorcerer, summoner, artificer],
  'martial': [fighter, barbarian, monk, spellsword],
  'wild': [barbarian, druid, ranger, monk],
};
```

Each event is tagged with one theme. Multiple themes can share classes (e.g., barbarian appears in both `martial` and `wild`).

### Map-to-Theme Weights

Each map number has weighted theme probabilities for event selection. **Placeholder weights** — will be updated when new map system arrives.

```dart
const Map<int, Map<String, int>> mapThemeWeights = {
  1: {'forest': 40, 'martial': 30, 'wild': 20, 'holy': 10},
  2: {'forest': 30, 'arcane': 25, 'martial': 25, 'wild': 20},
  3: {'martial': 30, 'arcane': 25, 'wild': 25, 'holy': 20},
  4: {'arcane': 30, 'dark': 25, 'martial': 25, 'holy': 20},
  5: {'dark': 30, 'wild': 25, 'arcane': 25, 'martial': 20},
  6: {'dark': 30, 'martial': 25, 'holy': 25, 'arcane': 20},
  7: {'dark': 35, 'arcane': 25, 'holy': 25, 'martial': 15},
  8: {'dark': 40, 'holy': 25, 'arcane': 20, 'martial': 15},
};
```

Event selection happens at screen entry time (same as current behavior), not during map generation. The event screen reads the current map number from `gameStateProvider`, picks a theme using the map's weights, then picks a random event with that theme.

## Choice Structure — Explore Follow-Up

After the player resolves a normal event choice (existing behavior), a **follow-up prompt** appears:

> *"You notice something interesting nearby..."*
> - **Explore** — triggers story unlock check
> - **Move on** — skip, return to map

This approach avoids restructuring the existing 36 events. The explore option is appended as a second step.

The follow-up always appears (for narrative flavor), but the outcome varies:
- If eligible classes exist → "explore" unlocks a story chapter
- If no eligible class (all maxed or no affinity match) → "explore" shows flavor text ("You search but find nothing of note.")

### Lore Drops

The existing `_checkForLoreDrop()` (20% chance) still fires after the initial event choice, **before** the explore follow-up appears. Lore and story unlocks are independent systems.

## Story Unlock Logic

When player picks "explore":

1. Get the event's `theme` → look up `themeClassAffinities[theme]`
2. Filter to classes **currently in the party** (alive or dead — story progress is per-class, not per-character-state)
3. For each matching class, get current progress: `profile.classStoryProgress[cls.name] ?? 0`
4. Filter to classes where progress < 7 (maps 1-7) or progress < 8 (map 8+)
5. If no eligible class: show flavor text (*"You search but find nothing of note."*) — no penalty
6. If eligible classes found: pick one randomly
7. Call `recordClassStoryProgress(className, currentProgress + 1)` — this takes an **absolute chapter number**, not an increment
8. Look up the story content: find the `ClassStoryChapter` from `classStories` where `characterClass == cls && chapter == currentProgress + 1`
9. Show story dialog with the chapter content (see below)

### Coexistence with Run-End Chapter Awards

The game over screen already awards chapter 1 (2+ maps) or chapter 2 (5+ maps) for alive party members. The victory screen awards chapter 3. Events can unlock these same chapters earlier during a run — the run-end awards become no-ops since `recordClassStoryProgress` only updates if the new chapter is higher than current progress. This is fine; events simply give players a way to discover stories earlier through exploration.

### Chapter 8 Gate

Chapter 8 can **only** unlock on map 8 or higher. On maps 1-7, the max unlockable chapter is 7. This means:
- On maps 1-7: filter to classes with progress < 7
- On map 8+: filter to classes with progress < 8

## Story Dialog

After unlocking a chapter, show a dialog with:

- Class name and chapter number as header
- Chapter title in bold
- Full story text
- Dismiss button

### Art Tier Upgrade Animation (Chapters 4 and 8)

When the unlocked chapter is **4** or **8**, the story dialog is followed by an art upgrade animation:

1. Display the **old tier** art centered on screen (low for chapter 4, mid for chapter 8)
2. Golden glow/pulse effect around the art
3. Brief flash of light
4. `AnimatedSwitcher` crossfade to the **new tier** art (mid for chapter 4, high for chapter 8)
5. "Art Upgraded!" label with class name
6. Dismiss → return to map

The animation uses `AnimatedSwitcher` with scale + fade transition and a gold `Container` overlay that animates opacity for the glow effect. Simple but satisfying.

## Files

| File | Change |
|---|---|
| `lib/data/event_data.dart` | **New** — GameEvent, EventChoice classes, theme affinities, map theme weights, event definitions (moved from event_screen) |
| `lib/ui/screens/event/event_screen.dart` | Refactor to use event_data, add explore follow-up prompt, story dialog, art upgrade animation |
| `lib/providers/player_profile_provider.dart` | No changes — `recordClassStoryProgress()` already exists |
| `lib/data/class_stories.dart` | No changes — story content already exists (128 chapters) |

## Not In Scope

- Full map theme weight tuning (placeholder weights — updated when new map system arrives)
- New event content (existing 36 events get theme tags, new themed events added later)
- Explore reward balancing (gold/HP for explore vs move-on — tune later)
