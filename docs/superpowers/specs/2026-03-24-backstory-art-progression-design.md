# Character Backstory & Art Progression

**Date:** 2026-03-24
**Status:** Draft

## Overview

Add an 8-chapter backstory system for each of the 16 character classes, viewable in the Guide screen. Story progress drives a 3-tier art progression system (basic → mid → high) that applies globally wherever character sprites appear. Remove the Stories tab from the Codex.

## Art & Sprite System

### New Asset Paths

All art moves from `assets/sprites/` to `assets/new_art/`. The old `assets/sprites/` directory entries should be removed from `pubspec.yaml` once migration is complete.

- **Player classes:** `assets/new_art/{class}_{low|mid|high}_128x128.png`
- **Enemies:** `assets/new_art/{type}_low_128x128.png` (mid/high reserved for future use)
- **Bosses:** `assets/new_art/{name}_256x256.png` (no `boss_` prefix — differs from old convention)
- **Army units:** `assets/new_art/{army_fighter|army_cleric|army_wizard}_low_128x128.png`

### Enemy Type → Asset Name Mapping

Some enemy types in `codex_data.dart` don't match the asset filenames directly. The sprite functions need a mapping:

| Enemy Type | Asset Name |
|---|---|
| `orc` | `orc_grunt` |
| `spider` | `giant_spider` |
| `archdemon` | `arch_demon` |

All other types match their asset names directly.

### Known Missing Assets

- `elder_dragon_mid_128x128.png` — missing from `assets/new_art/`. Needs to be created or the low variant used as fallback.

### Art Tier Thresholds

Art tier is derived from `classStoryProgress` (number of chapters unlocked, 0-8):

| Chapters Unlocked | Tier | Asset Suffix |
|---|---|---|
| 0-3 | Basic | `_low_128x128.png` |
| 4-7 | Mid | `_mid_128x128.png` |
| 8 | High | `_high_128x128.png` |

### Sprite Function Changes

`classSpritePath(CharacterClass cls, int storyProgress)` — takes story progress count, returns the correct tier path from `assets/new_art/`. Classes with no story progress default to 0 (basic tier).

`artTierForProgress(int progress)` — helper that returns `'low'`, `'mid'`, or `'high'`. Used by both `classSpritePath` and the Guide screen UI (for border coloring/greyscale logic), avoiding duplicated threshold logic.

`enemySpritePath(String enemyType)` — updated to point at `assets/new_art/` with `_low_128x128.png`, applying the type-to-asset name mapping above.

`enemySpritePathByName(String enemyName)` — updated for bosses to use `assets/new_art/{name}_256x256.png` (removing old `boss_` prefix).

### Call Site Updates

Every screen that calls `classSpritePath()` needs access to the player profile to pass story progress. Affected screens:

- `combat_screen.dart`
- `help_screen.dart`
- `recruit_screen.dart`

## Story Data

### Structure

Expand from 3 to 8 chapters per class (128 total chapters). Each class follows this 8-part arc:

1. Origin — who they were before
2. The call to action — why they fight
3. Early adventure — first challenge
4. A setback or loss
5. A key ally or discovery
6. Growing mastery
7. The darkest moment
8. Final revelation — who they've become

### Data Model

`ClassStoryChapter` model stays the same. Stories move to a new `lib/data/class_stories.dart` file (128 entries would make `codex_data.dart` too large).

Existing chapters will be repositioned or rewritten to fit the 8-part arc. The old chapter 3 (final confrontation) becomes the basis for chapter 8.

### Progress Tracking

`PlayerProfile.classStoryProgress` stays as `Map<String, int>` — class name to highest chapter unlocked (now 0-8 instead of 0-3).

### Unlock Mechanism

Chapters unlock via event (`!`) nodes during gameplay. Details to be designed separately.

## Guide Screen Redesign

### Current State

- `HelpScreen` is a `StatelessWidget` with 2 tabs (Classes, Map Nodes)
- Classes tab has `ExpansionTile` cards showing sprite, name, stats, and ability list

### Changes

- Convert `HelpScreen` to a `ConsumerWidget` to access player profile
- Redesign expanded accordion layout:

**Header row:**
- Left: class name, starter badge, base stats
- Right: 3 art tier images displayed horizontally (Basic → Mid → High)
  - Current tier: full color, blue border
  - Locked tiers: greyscale + darkened (`grayscale(100%) brightness(0.4)`), grey border
  - Hint text below locked tiers ("4/8 chapters", "8/8 chapters")
  - Connected by arrow indicators

**Expanded body (two columns, side by side):**
- Left column: abilities list (same content as current, constrained to left half)
- Right column: vertical story timeline
  - Numbered circle nodes connected by a vertical line
  - Line colored up to last unlocked chapter, grey after
  - Unlocked chapters: colored circle, blue left border, title in bold, full story text
  - Locked chapters: grey circle, grey border, "Chapter X: Not unlocked"

### Target Screens

Tablet, PC (web browser), and phone in landscape. No narrow-screen stacking needed.

## Codex Screen Changes

- Remove Stories tab
- Reduce from 3 tabs to 2 (Bestiary, Lore)
- `classStories` data and `ClassStoryChapter` model remain — they're used by the Guide screen now
- Clean up any story-specific imports/code from codex screen

## Files Modified

| File | Change |
|---|---|
| `lib/data/sprite_data.dart` | Update all sprite functions for new_art paths + art tiers + `artTierForProgress` helper |
| `lib/data/class_stories.dart` | **New file** — 8 chapters per class (128 total), moved out of codex_data |
| `lib/data/codex_data.dart` | Remove classStories list and ClassStoryChapter class (moved to class_stories.dart) |
| `lib/ui/screens/help/help_screen.dart` | Full redesign: ConsumerWidget, art tiers in header, side-by-side abilities + timeline |
| `lib/ui/screens/codex/codex_screen.dart` | Remove Stories tab, reduce to 2 tabs |
| `lib/ui/screens/combat/combat_screen.dart` | Update classSpritePath calls to pass story progress |
| `lib/ui/screens/recruit/recruit_screen.dart` | Update classSpritePath calls to pass story progress |
| `pubspec.yaml` | Add `assets/new_art/` declaration, remove old `assets/sprites/` entries |

## Not In Scope

- Enemy art tier progression (mid/high art reserved for future)
- Event node unlock mechanism (to be designed separately)
- Achievement system
