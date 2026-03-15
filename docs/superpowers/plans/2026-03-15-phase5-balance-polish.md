# Phase 5: Balance & Polish — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Balance the game for roguelike difficulty: default 60% rest heal, boss enrage timers, difficulty gating (Hard/Nightmare unlock), shield mechanic for Healer's Blessing perk, and enemy stat retuning for level-1 starts.

**Architecture:** Minimal new models. Boss enrage handled in combat service via round checks. Difficulty gating via PlayerProfile field. Shield as a new Character field absorbed before HP in combat.

**Tech Stack:** Flutter, Riverpod, SharedPreferences

---

## Task 1: Default rest to 60% heal

**Files:**
- Modify: `lib/ui/screens/rest/rest_screen.dart`

The rest screen currently reads `getMutatorEffect(gameState.activeMutator, 'rest_heal')` which returns 1.0 (full) when no mutator is active. Change default to 0.6:

```dart
final mutatorHeal = getMutatorEffect(gameState.activeMutator, 'rest_heal');
// Default rest heals 60%. Mutator can override (e.g. merchant_holiday = 0.3)
final healFraction = mutatorHeal < 1.0 ? mutatorHeal : 0.6;
```

This means: if the mutator doesn't override rest (returns 1.0), use 0.6. If mutator sets a specific value (e.g. 0.3), use that.

- [ ] **Step 1: Change default heal fraction**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 2: Boss enrage timer

**Files:**
- Modify: `lib/services/combat_service.dart`
- Modify: `lib/ui/screens/combat/combat_screen.dart`

After round 15 in a boss fight, the boss gets +10% attack per round. In the combat screen's `_advanceTurn()` method, after incrementing roundNumber, check if it's a boss fight and round > 15. If so, boost each alive enemy's attack.

In combat_screen.dart, in `_advanceTurn()` after round increment:
```dart
// Boss enrage: after round 15, enemies get +10% attack per round
if (_isBossFight && _combat!.roundNumber > 15) {
  for (final enemy in _combat!.enemies.where((e) => e.isAlive)) {
    enemy.attack = (enemy.attack * 1.10).round();
  }
  _combat!.combatLog.add('The boss grows stronger! (Enrage!)');
}
```

Need to track `_isBossFight` — set it in `_initCombat()` based on currentNode.type == NodeType.boss.

- [ ] **Step 1: Add _isBossFight flag**
- [ ] **Step 2: Add enrage logic after round 15**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 3: Difficulty gating

**Files:**
- Modify: `lib/models/player_profile.dart`
- Modify: `lib/providers/player_profile_provider.dart`
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`
- Modify: `lib/ui/screens/game_over/game_over_screen.dart`
- Modify: `lib/ui/screens/victory/victory_screen.dart`

### Add unlockedDifficulties to PlayerProfile

New field: `Set<DifficultyLevel> unlockedDifficulties` defaulting to `{DifficultyLevel.easy, DifficultyLevel.normal}`.

Add to constructor, toJson (as list of indices), fromJson.

### Unlock on victory

In victory_screen.dart, after recording run end:
- If difficulty was Normal or higher → unlock Hard
- If difficulty was Hard or higher → unlock Nightmare

Add a method to PlayerProfileNotifier:
```dart
Future<void> unlockDifficulty(DifficultyLevel level) async
```

### Gate in party select

Update the difficulty picker to show all 4 levels but disable locked ones. Read unlocked difficulties from profile.

- [ ] **Step 1: Add unlockedDifficulties to PlayerProfile**
- [ ] **Step 2: Add unlockDifficulty method to provider**
- [ ] **Step 3: Unlock difficulties on victory**
- [ ] **Step 4: Gate difficulty selection in party select**
- [ ] **Step 5: Run flutter analyze, commit**

---

## Task 4: Shield mechanic for Healer's Blessing

**Files:**
- Modify: `lib/models/character.dart`
- Modify: `lib/services/combat_service.dart`
- Modify: `lib/providers/game_state_provider.dart`

### Add shieldHp to Character

New field: `int shieldHp = 0`. Add to constructor, toJson, fromJson.

### Apply shield in startNewGame

When activePerk == 'healer_blessing' (check the actual perk ID — it might be different), set shieldHp on each character:
```dart
if (activePerk == 'healer_blessing') {
  for (final char in party) {
    char.shieldHp = (char.totalMaxHp * 0.20).round();
  }
}
```

Wait — check the perk ID. Read legacy_data.dart. The Healer's Blessing perk was removed and replaced with Merchant's Purse in the actual implementation. Let me check... Actually looking at the plan, the perk IDs are: scavenger, merchant_purse, scout_eye, veteran, lucky, army_intel. There's no healer_blessing perk defined. Let me add it back.

Actually, re-reading the spec — the original perk was renamed. Let me just add the shield mechanic and apply it if a perk with that ID exists. Or better: add a "healer_blessing" perk to the legacy data and implement the shield.

### Absorb damage from shield first

In CombatService.executeEnemyTurn(), when dealing damage to an ally, absorb from shieldHp first:
```dart
if (target.shieldHp > 0) {
  final shieldAbsorb = min(damage, target.shieldHp);
  target.shieldHp -= shieldAbsorb;
  damage -= shieldAbsorb;
}
target.currentHp -= damage;
```

- [ ] **Step 1: Add shieldHp to Character**
- [ ] **Step 2: Add healer_blessing perk to legacy_data.dart if missing**
- [ ] **Step 3: Apply shield in startNewGame**
- [ ] **Step 4: Absorb damage from shield in combat**
- [ ] **Step 5: Run flutter analyze, commit**

---

## Task 5: Enemy retuning for level-1 starts

**Files:**
- Modify: `lib/data/enemy_data.dart`

The current enemy stats were designed for accumulating party power. With roguelike resets (party starts at level 1 each run), early maps need to be easier and the difficulty curve needs to be steeper.

Retune guidelines:
- Map 1: Very easy (HP ~15-20, ATK ~3-4). Players learning.
- Map 2: Easy-moderate (HP ~22-28, ATK ~5-6).
- Map 3-4: Moderate (HP ~35-50, ATK ~8-12).
- Map 5-6: Hard (HP ~60-90, ATK ~14-18).
- Map 7-8: Very hard (HP ~100-160, ATK ~20-28).
- Bosses: ~2-3x regular enemy stats for their map.

Reduce Map 1-2 enemy stats slightly, keep 3-4 roughly the same, and keep 5-8 as challenging targets.

- [ ] **Step 1: Adjust enemy stats**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 6: Final verification

- [ ] **Step 1: Run all tests**
- [ ] **Step 2: Run flutter analyze**
- [ ] **Step 3: Final commit if needed**
