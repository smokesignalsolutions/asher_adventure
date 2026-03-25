# Status Effects & Custom Map Enemies Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a unified status effect system, 60 custom map-themed enemies, and special attacks for all existing enemies.

**Architecture:** New `StatusEffect` model with enum types applied to both Characters and Enemies. Ability model gains `appliesStatusEffects` field. Combat service processes effects at turn start/end. Custom enemies defined as scaling templates tied to map definitions.

**Tech Stack:** Flutter/Dart, Riverpod state management, existing combat service pattern

**Spec:** `docs/superpowers/specs/2026-03-25-status-effects-custom-enemies-design.md`

---

### Task 1: Create StatusEffect Model

**Files:**
- Create: `lib/models/status_effect.dart`
- Modify: `lib/models/enums.dart` (no changes needed — enum goes in new file)

- [ ] **Step 1: Create `lib/models/status_effect.dart`**

```dart
import 'dart:math';

enum StatusEffectType {
  weakened,    // Deal reduced damage
  exposed,     // Reduced defense
  vulnerable,  // Takes bonus damage from all sources
  slowed,      // Reduced speed
  stunned,     // Lose next turn
  blinded,     // % chance attacks miss
  poisoned,    // Damage each turn
  burning,     // Damage each turn (higher, shorter)
  bleeding,    // Damage each turn
  silenced,    // Only basic attack available
  frozen,      // Stunned + next hit deals bonus damage
  cursed,      // Healing received halved
}

class AppliedEffect {
  final StatusEffectType type;
  final int duration;   // turns (-1 = permanent for this combat)
  final int magnitude;  // % for debuffs, flat damage for DoTs
  final int chance;     // 0-100% chance to apply on hit

  const AppliedEffect({
    required this.type,
    required this.duration,
    this.magnitude = 0,
    this.chance = 100,
  });

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'duration': duration,
    'magnitude': magnitude,
    'chance': chance,
  };

  factory AppliedEffect.fromJson(Map<String, dynamic> json) => AppliedEffect(
    type: StatusEffectType.values[json['type']],
    duration: json['duration'],
    magnitude: json['magnitude'] ?? 0,
    chance: json['chance'] ?? 100,
  );
}

class StatusEffect {
  final StatusEffectType type;
  int duration;
  final int magnitude;
  final String sourceId;

  StatusEffect({
    required this.type,
    required this.duration,
    this.magnitude = 0,
    this.sourceId = '',
  });

  bool get isExpired => duration == 0;
  bool get isPermanent => duration == -1;

  /// Whether this is a damage-over-time effect
  bool get isDot =>
      type == StatusEffectType.poisoned ||
      type == StatusEffectType.burning ||
      type == StatusEffectType.bleeding;

  /// Whether this is a control effect (refresh on reapply)
  bool get isControl =>
      type == StatusEffectType.stunned ||
      type == StatusEffectType.frozen ||
      type == StatusEffectType.silenced ||
      type == StatusEffectType.blinded ||
      type == StatusEffectType.cursed;

  /// Whether this is a stat debuff (keep strongest)
  bool get isStatDebuff =>
      type == StatusEffectType.weakened ||
      type == StatusEffectType.exposed ||
      type == StatusEffectType.slowed;

  /// Display name for UI
  String get displayName {
    switch (type) {
      case StatusEffectType.weakened: return 'Weakened';
      case StatusEffectType.exposed: return 'Exposed';
      case StatusEffectType.vulnerable: return 'Vulnerable';
      case StatusEffectType.slowed: return 'Slowed';
      case StatusEffectType.stunned: return 'Stunned';
      case StatusEffectType.blinded: return 'Blinded';
      case StatusEffectType.poisoned: return 'Poisoned';
      case StatusEffectType.burning: return 'Burning';
      case StatusEffectType.bleeding: return 'Bleeding';
      case StatusEffectType.silenced: return 'Silenced';
      case StatusEffectType.frozen: return 'Frozen';
      case StatusEffectType.cursed: return 'Cursed';
    }
  }
}

/// Default magnitudes when not specified
class StatusDefaults {
  static const int weakenedPercent = 25;
  static const int exposedPercent = 30;
  static const int vulnerablePercent = 15;
  static const int slowedPercent = 30;
  static const int blindedMissPercent = 40;
  static const int frozenBonusPercent = 30;
  static const int vulnerableCap = 30;

  /// DoT damage scales with tier: tier * 3 + 2
  static int dotDamage(int tier) => tier * 3 + 2;
}

/// Mixin for status effect management, shared by Character and Enemy
mixin StatusEffectMixin {
  List<StatusEffect> get statusEffects;

  /// Add a status effect following stacking rules:
  /// - DoTs: stack independently (multiple instances)
  /// - Control: refresh duration (latest wins)
  /// - Stat debuffs: keep as separate instances, strongest applies at resolution
  /// - Vulnerable: stack magnitude (capped at 30%)
  void addStatusEffect(StatusEffect effect) {
    if (effect.type == StatusEffectType.vulnerable) {
      // Vulnerable stacks magnitude, capped
      final existing = statusEffects.where((e) => e.type == StatusEffectType.vulnerable).toList();
      if (existing.isNotEmpty) {
        final totalMag = existing.fold(0, (sum, e) => sum + e.magnitude) + effect.magnitude;
        // Remove old, add combined
        statusEffects.removeWhere((e) => e.type == StatusEffectType.vulnerable);
        statusEffects.add(StatusEffect(
          type: StatusEffectType.vulnerable,
          duration: effect.isPermanent ? -1 : max(effect.duration, existing.first.duration),
          magnitude: min(totalMag, StatusDefaults.vulnerableCap),
          sourceId: effect.sourceId,
        ));
        return;
      }
    } else if (effect.isDot) {
      // DoTs stack independently — just add
      statusEffects.add(effect);
      return;
    } else if (effect.isControl) {
      // Control effects: refresh duration
      final existing = statusEffects.where((e) => e.type == effect.type).toList();
      if (existing.isNotEmpty) {
        existing.first.duration = effect.duration;
        return;
      }
    } else if (effect.isStatDebuff) {
      // Stat debuffs: keep as separate instances (strongest applies at resolution)
      statusEffects.add(effect);
      return;
    }

    statusEffects.add(effect);
  }

  /// Tick DoTs: apply damage, decrement durations, return total damage
  int tickDoTs() {
    int totalDamage = 0;
    final dots = statusEffects.where((e) => e.isDot).toList();
    for (final dot in dots) {
      totalDamage += dot.magnitude;
      if (!dot.isPermanent) dot.duration--;
    }
    statusEffects.removeWhere((e) => e.isDot && e.isExpired);
    return totalDamage;
  }

  /// Remove all expired non-DoT effects
  void removeExpiredEffects() {
    statusEffects.removeWhere((e) => !e.isDot && e.isExpired);
  }

  /// Decrement durations of all non-DoT effects (called at end of turn)
  void decrementEffectDurations() {
    for (final e in statusEffects) {
      if (!e.isDot && !e.isPermanent) {
        e.duration--;
      }
    }
  }

  void clearStatusEffects() {
    statusEffects.clear();
  }

  bool get isStunned => statusEffects.any((e) =>
      e.type == StatusEffectType.stunned || e.type == StatusEffectType.frozen);

  bool get isSilenced => statusEffects.any((e) => e.type == StatusEffectType.silenced);

  bool get isCursed => statusEffects.any((e) => e.type == StatusEffectType.cursed);

  /// Returns miss chance % if blinded, 0 otherwise
  int get blindedMissChance {
    final blinded = statusEffects.where((e) => e.type == StatusEffectType.blinded);
    if (blinded.isEmpty) return 0;
    return blinded.first.magnitude > 0 ? blinded.first.magnitude : StatusDefaults.blindedMissPercent;
  }

  /// Returns vulnerable bonus magnitude (0 if not vulnerable)
  int get vulnerableMagnitude {
    final vuln = statusEffects.where((e) => e.type == StatusEffectType.vulnerable);
    if (vuln.isEmpty) return 0;
    return vuln.first.magnitude > 0 ? vuln.first.magnitude : StatusDefaults.vulnerablePercent;
  }

  /// Returns frozen bonus damage % (0 if not frozen)
  int get frozenBonusDamage {
    final frozen = statusEffects.where((e) => e.type == StatusEffectType.frozen);
    if (frozen.isEmpty) return 0;
    return frozen.first.magnitude > 0 ? frozen.first.magnitude : StatusDefaults.frozenBonusPercent;
  }

  /// Remove frozen when shattered by a hit
  void shatterFrozen() {
    statusEffects.removeWhere((e) => e.type == StatusEffectType.frozen);
  }

  /// Get strongest magnitude for a stat debuff type
  int getStrongestDebuff(StatusEffectType type) {
    final matches = statusEffects.where((e) => e.type == type);
    if (matches.isEmpty) return 0;
    return matches.map((e) => e.magnitude > 0 ? e.magnitude : _defaultMagnitude(type)).reduce(max);
  }

  int _defaultMagnitude(StatusEffectType type) {
    switch (type) {
      case StatusEffectType.weakened: return StatusDefaults.weakenedPercent;
      case StatusEffectType.exposed: return StatusDefaults.exposedPercent;
      case StatusEffectType.slowed: return StatusDefaults.slowedPercent;
      default: return 0;
    }
  }

  /// UI labels for active effects
  List<(String label, StatusEffectType type)> get activeStatusLabels {
    final seen = <StatusEffectType>{};
    final labels = <(String, StatusEffectType)>[];
    for (final e in statusEffects) {
      if (!seen.contains(e.type)) {
        seen.add(e.type);
        labels.add((e.displayName, e.type));
      }
    }
    return labels;
  }
}
```

- [ ] **Step 2: Verify file compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/models/status_effect.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/models/status_effect.dart
git commit -m "feat: add StatusEffect model with enum, stacking rules, and mixin"
```

---

### Task 2: Add `appliesStatusEffects` to Ability Model

**Files:**
- Modify: `lib/models/ability.dart`

- [ ] **Step 1: Add import and field to Ability**

At top of `lib/models/ability.dart`, add import:
```dart
import 'status_effect.dart';
```

Add field after `rogueDualStrike` (line 34):
```dart
  final List<AppliedEffect> appliesStatusEffects;
```

Add to constructor (after `this.rogueDualStrike = false,` line 64):
```dart
    this.appliesStatusEffects = const [],
```

- [ ] **Step 2: Update `copyWith` to include new field**

In `copyWith` method (line 68), add parameter and copy:
```dart
  Ability copyWith({bool? isAvailable, int? unlockedAtLevel, List<AppliedEffect>? appliesStatusEffects}) {
```
And in the returned Ability, add:
```dart
      appliesStatusEffects: appliesStatusEffects ?? this.appliesStatusEffects,
```

- [ ] **Step 3: Update `toJson` and `fromJson`**

In `toJson` (after line 129 `'rogueDualStrike': rogueDualStrike,`):
```dart
    if (appliesStatusEffects.isNotEmpty)
      'appliesStatusEffects': appliesStatusEffects.map((e) => e.toJson()).toList(),
```

In `fromJson` (after line 159 `rogueDualStrike: json['rogueDualStrike'] ?? false,`):
```dart
    appliesStatusEffects: (json['appliesStatusEffects'] as List?)
        ?.map((e) => AppliedEffect.fromJson(e))
        .toList() ?? const [],
```

- [ ] **Step 4: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/models/ability.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/models/ability.dart
git commit -m "feat: add appliesStatusEffects field to Ability model"
```

---

### Task 3: Add StatusEffects to Enemy Model

**Files:**
- Modify: `lib/models/enemy.dart`

- [ ] **Step 1: Add import, mixin, and migrate fields**

Replace the entire `lib/models/enemy.dart` with the migrated version. Key changes:
- Add `import 'status_effect.dart';`
- Add `with StatusEffectMixin` to class
- Remove: `isVulnerable`, `tempAttackMultiplier`, `tempAttackDebuffTurns`, `isStunned`
- Rename: `attackMultiplier` → `enrageMultiplier`, `defenseMultiplier` → `baseDefenseMultiplier`
- Add: `List<StatusEffect> statusEffects = []`
- Update `effectiveAttack` to layer: `attack * enrageMultiplier` then weakened reduction
- Update `effectiveDefense` to layer: `defense * baseDefenseMultiplier` then exposed reduction

```dart
import 'ability.dart';
import 'status_effect.dart';

class Enemy with StatusEffectMixin {
  final String id;
  final String name;
  final String type;
  int currentHp;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;
  final int magic;
  final int xpReward;
  final int goldReward;
  final List<Ability> abilities;
  double enrageMultiplier; // boss enrage + shadow summon reduction
  double baseDefenseMultiplier; // for future use
  @override
  List<StatusEffect> statusEffects;

  Enemy({
    required this.id,
    required this.name,
    required this.type,
    required this.currentHp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.magic,
    required this.xpReward,
    required this.goldReward,
    required this.abilities,
    this.enrageMultiplier = 1.0,
    this.baseDefenseMultiplier = 1.0,
    List<StatusEffect>? statusEffects,
  }) : statusEffects = statusEffects ?? [];

  bool get isAlive => currentHp > 0;

  int get effectiveAttack {
    var base = (attack * enrageMultiplier).round();
    final weakenedPercent = getStrongestDebuff(StatusEffectType.weakened);
    if (weakenedPercent > 0) {
      base = (base * (1 - weakenedPercent / 100)).round();
    }
    return base;
  }

  int get effectiveDefense {
    var base = (defense * baseDefenseMultiplier).round();
    final exposedPercent = getStrongestDebuff(StatusEffectType.exposed);
    if (exposedPercent > 0) {
      base = (base * (1 - exposedPercent / 100)).round();
    }
    return base;
  }

  int get effectiveSpeed {
    final slowedPercent = getStrongestDebuff(StatusEffectType.slowed);
    if (slowedPercent > 0) {
      return (speed * (1 - slowedPercent / 100)).round();
    }
    return speed;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'currentHp': currentHp,
    'maxHp': maxHp,
    'attack': attack,
    'defense': defense,
    'speed': speed,
    'magic': magic,
    'xpReward': xpReward,
    'goldReward': goldReward,
    'abilities': abilities.map((a) => a.toJson()).toList(),
  };

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    currentHp: json['currentHp'],
    maxHp: json['maxHp'],
    attack: json['attack'],
    defense: json['defense'],
    speed: json['speed'],
    magic: json['magic'],
    xpReward: json['xpReward'],
    goldReward: json['goldReward'],
    abilities: (json['abilities'] as List)
        .map((a) => Ability.fromJson(a))
        .toList(),
  );
}
```

- [ ] **Step 2: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/models/enemy.dart`
Expected: Errors from other files still referencing old fields (expected at this stage)

- [ ] **Step 3: Commit**

```bash
git add lib/models/enemy.dart
git commit -m "feat: migrate Enemy to StatusEffectMixin, rename multiplier fields"
```

---

### Task 4: Add StatusEffects to Character Model

**Files:**
- Modify: `lib/models/character.dart`

- [ ] **Step 1: Add import and mixin**

Add import at top:
```dart
import 'status_effect.dart';
```

Change class declaration to:
```dart
class Character with StatusEffectMixin {
```

Add field after `skeletonCount` (line 60):
```dart
  @override
  List<StatusEffect> statusEffects;
```

Add to constructor (after `this.skeletonCount = 0,` line 85):
```dart
    List<StatusEffect>? statusEffects,
```

And in the initializer list, add:
```dart
       statusEffects = statusEffects ?? [];
```

- [ ] **Step 2: Update stat getters to factor in status effects**

Update `totalAttack` getter (line 94) — after computing `base` with combatAttackMultiplier, apply weakened:
```dart
  int get totalAttack {
    var base = ((attack +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.attackBonus)) *
      combatAttackMultiplier).round();
    // Barbarian: gains up to +50% base attack as HP drops
    if (characterClass == CharacterClass.barbarian && currentHp < totalMaxHp) {
      final missingRatio = 1 - (currentHp / totalMaxHp);
      base += (attack * missingRatio * 0.5).round();
    }
    // Status effect: weakened reduces damage dealt
    final weakenedPercent = getStrongestDebuff(StatusEffectType.weakened);
    if (weakenedPercent > 0) {
      base = (base * (1 - weakenedPercent / 100)).round();
    }
    return base;
  }
```

Update `totalDefense` getter (line 106):
```dart
  int get totalDefense {
    var base = ((defense + combatDefenseBonus +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.defenseBonus)) *
      combatDefenseMultiplier).round();
    final exposedPercent = getStrongestDebuff(StatusEffectType.exposed);
    if (exposedPercent > 0) {
      base = (base * (1 - exposedPercent / 100)).round();
    }
    return base;
  }
```

Update `totalSpeed` getter (line 111):
```dart
  int get totalSpeed {
    var base = ((speed +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.speedBonus)) *
      combatSpeedMultiplier).round();
    final slowedPercent = getStrongestDebuff(StatusEffectType.slowed);
    if (slowedPercent > 0) {
      base = (base * (1 - slowedPercent / 100)).round();
    }
    return base;
  }
```

- [ ] **Step 3: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/models/character.dart`
Expected: No errors (or only errors from downstream files)

- [ ] **Step 4: Commit**

```bash
git add lib/models/character.dart
git commit -m "feat: add StatusEffectMixin to Character with debuff-aware stat getters"
```

---

### Task 5: Update Combat Service — Status Effect Processing

**Files:**
- Modify: `lib/services/combat_service.dart`

- [ ] **Step 1: Add import**

Add at top:
```dart
import '../models/status_effect.dart';
```

- [ ] **Step 2: Update `initCombat` to clear status effects**

In `initCombat` (line 21), after `char.skeletonCount = 0;` (line 32), add:
```dart
      char.clearStatusEffects();
```

Also add a loop after the party reset to clear enemy status effects (defensive, per spec):
```dart
    for (final enemy in enemies) {
      enemy.clearStatusEffects();
    }
```

- [ ] **Step 3: Update `calculateDamage` — replace `targetVulnerable` bool with `vulnerableMagnitude` int**

Change signature (line 132):
```dart
  static (int damage, bool isCrit) calculateDamage(
    int attackStat,
    int abilityDamage,
    int targetDefense, {
    int vulnerableMagnitude = 0,
    int frozenBonusDamage = 0,
    bool chaotic = false,
    double damageMultiplier = 1.0,
    int attackerSpeed = 0,
  }) {
```

Replace the vulnerability bonus block (lines 146-149):
```dart
    if (vulnerableMagnitude > 0) {
      final rollMax = max(1, vulnerableMagnitude - 4);
      final bonus = 1.0 + (5 + _random.nextInt(rollMax)) / 100;
      result = (result * bonus).round();
    }
    if (frozenBonusDamage > 0) {
      result = (result * (1 + frozenBonusDamage / 100)).round();
    }
```

- [ ] **Step 4: Update all `calculateDamage` call sites in combat_service.dart**

Replace `targetVulnerable: enemyTarget.isVulnerable` with `vulnerableMagnitude: enemyTarget.vulnerableMagnitude` in:
- `executeAllyTurn` (around line 342): also add `frozenBonusDamage: enemyTarget.frozenBonusDamage`. After the damage loop, if frozen bonus was applied, call `enemyTarget.shatterFrozen()` and log `'${enemyTarget.name} takes bonus damage from being frozen!'`
- `executeChaoticBounce` (around line 198): add `vulnerableMagnitude: target.vulnerableMagnitude, frozenBonusDamage: target.frozenBonusDamage`. Call `target.shatterFrozen()` after if frozen.
- `executePierce` (around line 223): same pattern
- `executeRogueDualStrike` (around line 264): same pattern

For enemy-on-ally attacks in `executeEnemyTurn`, add vulnerability and frozen checks:
- Single-target attack (around line 822): add `vulnerableMagnitude: target.vulnerableMagnitude, frozenBonusDamage: target.frozenBonusDamage`. After damage, if target was frozen, call `target.shatterFrozen()` and log.
- AOE attack (around line 745): add `vulnerableMagnitude: ally.vulnerableMagnitude, frozenBonusDamage: ally.frozenBonusDamage`. Same shatter pattern per ally.

- [ ] **Step 5: Update `executeAllyTurn` — migrate debuff application to status effects**

Replace the debuff block (lines 405-439) with status effect application:
```dart
      // Apply status effects from ability
      if (enemyTarget.isAlive) {
        for (final applied in ability.appliesStatusEffects) {
          if (_random.nextInt(100) < applied.chance) {
            final duration = enemyTarget.type == 'boss'
                ? max(1, applied.duration - 1)
                : applied.duration;
            enemyTarget.addStatusEffect(StatusEffect(
              type: applied.type,
              duration: duration,
              magnitude: applied.magnitude,
              sourceId: attacker.id,
            ));
            logs.add('${enemyTarget.name} is ${StatusEffect(type: applied.type, duration: duration, magnitude: applied.magnitude).displayName.toLowerCase()}!');
          }
        }
      }

      // Legacy debuff fields (will be removed once class_data.dart is migrated in Task 8.5)
      // Boss resistance applies here too: duration -1 for bosses (min 1)
      final isBoss = enemyTarget.type == 'boss';
      if (ability.appliesVulnerability && enemyTarget.vulnerableMagnitude == 0) {
        enemyTarget.addStatusEffect(StatusEffect(
          type: StatusEffectType.vulnerable,
          duration: -1,
          magnitude: StatusDefaults.vulnerablePercent,
          sourceId: attacker.id,
        ));
        logs.add('${enemyTarget.name} is vulnerable!');
      }
      if (ability.enemyAttackDebuffPercent > 0) {
        enemyTarget.addStatusEffect(StatusEffect(
          type: StatusEffectType.weakened,
          duration: -1,
          magnitude: ability.enemyAttackDebuffPercent,
          sourceId: attacker.id,
        ));
        logs.add('${enemyTarget.name} attack reduced by ${ability.enemyAttackDebuffPercent}%!');
      }
      if (ability.enemyDefenseDebuffPercent > 0) {
        enemyTarget.addStatusEffect(StatusEffect(
          type: StatusEffectType.exposed,
          duration: -1,
          magnitude: ability.enemyDefenseDebuffPercent,
          sourceId: attacker.id,
        ));
        logs.add('${enemyTarget.name} defense reduced by ${ability.enemyDefenseDebuffPercent}%!');
      }
      if (ability.stunChance > 0 && enemyTarget.isAlive && !enemyTarget.isStunned) {
        if (_random.nextInt(100) < ability.stunChance) {
          final stunDur = isBoss ? 1 : 1; // stun is already 1 turn, boss min is 1
          enemyTarget.addStatusEffect(StatusEffect(
            type: StatusEffectType.stunned,
            duration: stunDur,
            sourceId: attacker.id,
          ));
          logs.add('${enemyTarget.name} is stunned!');
        }
      }
      if (ability.tempEnemyAttackDebuffPercent > 0) {
        final dur = isBoss ? max(1, ability.debuffDuration - 1) : ability.debuffDuration;
        enemyTarget.addStatusEffect(StatusEffect(
          type: StatusEffectType.weakened,
          duration: dur,
          magnitude: ability.tempEnemyAttackDebuffPercent,
          sourceId: attacker.id,
        ));
        logs.add('${enemyTarget.name} attack reduced by ${ability.tempEnemyAttackDebuffPercent}% for $dur turns!');
      }
```

- [ ] **Step 6: Update `executeEnemyTurn` — full status effect processing**

Replace the stun check and temp debuff tick (lines 695-709) with:
```dart
    // Collect DoT types BEFORE ticking (some may be removed after tick)
    final dotTypes = enemy.statusEffects.where((e) => e.isDot).map((e) => e.type).toSet();
    final dotDamage = enemy.tickDoTs();
    final logs = <String>[];
    if (dotDamage > 0) {
      enemy.currentHp = max(0, enemy.currentHp - dotDamage);
      for (final dt in dotTypes) {
        final name = StatusEffect(type: dt, duration: 0).displayName;
        logs.add('$name deals damage to ${enemy.name}!');
      }
      if (!enemy.isAlive) {
        logs.add('${enemy.name} is defeated!');
        return logs.join(' ');
      }
    }

    // Check stun/frozen
    if (enemy.isStunned) {
      final wasFrozen = enemy.statusEffects.any((e) => e.type == StatusEffectType.frozen);
      // Decrement stun/frozen duration
      for (final e in enemy.statusEffects.where((e) =>
          e.type == StatusEffectType.stunned || e.type == StatusEffectType.frozen)) {
        if (!e.isPermanent) e.duration--;
      }
      enemy.removeExpiredEffects();
      logs.add('${enemy.name} is ${wasFrozen ? 'frozen' : 'stunned'} and loses their turn!');
      return logs.join(' ');
    }
```

After the enemy action resolves (near end of method), before `return`, add:
```dart
    // End of turn: decrement effect durations, remove expired
    enemy.decrementEffectDurations();
    enemy.removeExpiredEffects();
```

Also add **status effect application for enemy abilities hitting allies**. After damage is applied to a single-target ally (after line 847), add:
```dart
    // Apply status effects from enemy ability to target
    for (final applied in ability.appliesStatusEffects) {
      if (_random.nextInt(100) < applied.chance) {
        target.addStatusEffect(StatusEffect(
          type: applied.type,
          duration: applied.duration,
          magnitude: applied.magnitude,
          sourceId: enemy.id,
        ));
        logs.add('${target.name} is ${StatusEffect(type: applied.type, duration: applied.duration, magnitude: applied.magnitude).displayName.toLowerCase()}!');
      }
    }
```

Do the same for AOE hits (after damage applied to each ally in the AOE loop, around line 769):
```dart
    // Apply status effects from enemy AOE ability
    for (final applied in ability.appliesStatusEffects) {
      if (_random.nextInt(100) < applied.chance) {
        ally.addStatusEffect(StatusEffect(
          type: applied.type,
          duration: applied.duration,
          magnitude: applied.magnitude,
          sourceId: enemy.id,
        ));
        logs.add('${ally.name} is ${StatusEffect(type: applied.type, duration: applied.duration, magnitude: applied.magnitude).displayName.toLowerCase()}!');
      }
    }
```

- [ ] **Step 7: Add ally turn-start status processing**

Add a new static method to CombatService for processing ally status effects at the start of their turn. This will be called from the game_state_provider before the player chooses their action:

```dart
  /// Process ally status effects at start of turn.
  /// Returns (canAct, logs, dotDamage).
  static (bool canAct, List<String> logs) processAllyTurnStart(Character ally) {
    final logs = <String>[];

    // Collect DoT types BEFORE ticking
    final dotTypes = ally.statusEffects.where((e) => e.isDot).map((e) => e.type).toSet();
    final dotDamage = ally.tickDoTs();
    if (dotDamage > 0) {
      // Absorb with shield first
      var remaining = dotDamage;
      if (ally.shieldHp > 0) {
        final shieldAbsorb = min(remaining, ally.shieldHp);
        ally.shieldHp -= shieldAbsorb;
        remaining -= shieldAbsorb;
      }
      ally.currentHp = max(0, ally.currentHp - remaining);
      for (final dt in dotTypes) {
        final name = StatusEffect(type: dt, duration: 0).displayName;
        logs.add('$name deals damage to ${ally.name}!');
      }
      if (!ally.isAlive) {
        logs.add('${ally.name} falls!');
        return (false, logs);
      }
    }

    // Check stun/frozen
    if (ally.isStunned) {
      final wasFrozen = ally.statusEffects.any((e) => e.type == StatusEffectType.frozen);
      for (final e in ally.statusEffects.where((e) =>
          e.type == StatusEffectType.stunned || e.type == StatusEffectType.frozen)) {
        if (!e.isPermanent) e.duration--;
      }
      ally.removeExpiredEffects();
      logs.add('${ally.name} is ${wasFrozen ? 'frozen' : 'stunned'} and can\'t act!');
      return (false, logs);
    }

    return (true, logs);
  }

  /// Process ally end-of-turn: decrement durations, remove expired
  static void processAllyTurnEnd(Character ally) {
    ally.decrementEffectDurations();
    ally.removeExpiredEffects();
  }

  /// Get available abilities for a combatant, considering silenced status
  static List<Ability> getAvailableAbilities(List<Ability> abilities, bool isSilenced) {
    var available = abilities.where((a) => a.isAvailable).toList();
    if (isSilenced) {
      available = available.where((a) => a.isBasicAttack).toList();
    }
    return available;
  }

  /// Roll blinded miss check. Returns true if the attack misses.
  static bool rollBlindedMiss(int missChance) {
    return _random.nextInt(100) < missChance;
  }
```

- [ ] **Step 8: Update `processHeal` for cursed**

In the heal section of `executeAllyTurn` (around line 464), after calculating `healAmount`, add curse check:
```dart
        // Cursed: healing halved
        var finalHeal = healAmount;
        if (charTarget.isCursed) {
          finalHeal = (healAmount / 2).round();
          logs.add('Curse halves the healing!');
        }
```
Then use `finalHeal` instead of `healAmount` when applying the heal.

- [ ] **Step 9: Update shadow summon to use enrageMultiplier**

In `processSummonEffects`, shadow case (line 643), change:
```dart
              e.attackMultiplier = max(0.5, e.attackMultiplier - 0.10);
```
to:
```dart
              e.enrageMultiplier = max(0.5, e.enrageMultiplier - 0.10);
```

- [ ] **Step 10: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/services/combat_service.dart`
Expected: May have some errors from downstream call sites — note them for next tasks

- [ ] **Step 11: Commit**

```bash
git add lib/services/combat_service.dart
git commit -m "feat: integrate status effect processing into combat service"
```

---

### Task 6: Update Game State Provider & Help Dialogs

**Files:**
- Modify: `lib/providers/game_state_provider.dart`
- Modify: `lib/ui/widgets/help_dialogs.dart`

- [ ] **Step 1: Fix `_enemyFromTemplate` to copy full abilities**

In `game_state_provider.dart` (lines 211-221), replace the ability mapping to pass abilities directly instead of cherry-picking fields:

```dart
    abilities: template.abilities
        .map((a) => a.copyWith())
        .toList(),
```

Do the same in `generateBoss` (lines 258-267).

Also fix `generateArmyEnemies` (around lines 362-371) — it has the same cherry-picking pattern. Change to `a.copyWith()` there too.

- [ ] **Step 2: Update boss enrage to use `enrageMultiplier`**

In `game_state_provider.dart` (around line 438-444), change:
```dart
        enemy.attackMultiplier = (enemy.attackMultiplier * 1.10);
```
to:
```dart
        enemy.enrageMultiplier = (enemy.enrageMultiplier * 1.10);
```

- [ ] **Step 3: Add ally turn-start processing**

Find where ally turns begin in game_state_provider (the method that handles the current turn advancing). Before the player gets to pick their ability, call:
```dart
    final (canAct, statusLogs) = CombatService.processAllyTurnStart(currentAlly);
    _combat!.combatLog.addAll(statusLogs);
    if (!canAct) {
      // Skip to next turn
      // (advance turn order)
    }
```

Also call `CombatService.processAllyTurnEnd(ally)` after the ally's action resolves.

- [ ] **Step 4: Add silenced ability filtering**

Where available abilities are presented to the player for selection, filter using:
```dart
    final available = CombatService.getAvailableAbilities(ally.abilities, ally.isSilenced);
```

- [ ] **Step 5: Add blinded miss check**

Before executing an ally's offensive ability, check:
```dart
    if (ally.blindedMissChance > 0 && CombatService.rollBlindedMiss(ally.blindedMissChance)) {
      _combat!.combatLog.add('${ally.name}\'s attack misses!');
      // Skip damage, still use the ability
    }
```

- [ ] **Step 6: Update `help_dialogs.dart`**

In `showEnemyHelp` (lines 33-41), replace the old status effect display:
```dart
      final statusLabels = enemy.activeStatusLabels;
      final statusEffects = statusLabels.map((e) => e.$1).toList();
      if (enemy.enrageMultiplier != 1.0) {
        statusEffects.add('ATK x${enemy.enrageMultiplier.toStringAsFixed(2)}');
      }
      if (enemy.baseDefenseMultiplier != 1.0) {
        statusEffects.add('DEF x${enemy.baseDefenseMultiplier.toStringAsFixed(2)}');
      }
```

- [ ] **Step 7: Verify full project compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/`
Expected: No errors (or only warnings)

- [ ] **Step 8: Commit**

```bash
git add lib/providers/game_state_provider.dart lib/ui/widgets/help_dialogs.dart
git commit -m "feat: update game state provider and help dialogs for status effects"
```

---

### Task 7: Add Status Effect UI to Combat Screen

**Files:**
- Modify: `lib/ui/screens/combat/combat_screen.dart`

- [ ] **Step 1: Add status line to `_buildAllyWidget`**

After the HP text (around line 1446), add a status effect display:
```dart
              // Status effects
              if (ally.statusEffects.isNotEmpty)
                Text(
                  ally.activeStatusLabels.map((e) => e.$1).join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: _statusColor(ally.activeStatusLabels.first.$2),
                    shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
```

- [ ] **Step 2: Add status line to `_buildEnemyWidget`**

After the HP text (around line 1525), add the same pattern:
```dart
              // Status effects
              if (enemy.statusEffects.isNotEmpty)
                Text(
                  enemy.activeStatusLabels.map((e) => e.$1).join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: _statusColor(enemy.activeStatusLabels.first.$2),
                    shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
```

- [ ] **Step 2.5: Add status color helper method to combat screen**

Add a helper method to the combat screen state class:
```dart
  Color _statusColor(StatusEffectType type) {
    switch (type) {
      case StatusEffectType.poisoned:
      case StatusEffectType.burning:
      case StatusEffectType.bleeding:
        return Colors.red.shade300;
      case StatusEffectType.weakened:
      case StatusEffectType.exposed:
      case StatusEffectType.slowed:
      case StatusEffectType.vulnerable:
        return Colors.yellow.shade200;
      case StatusEffectType.stunned:
      case StatusEffectType.blinded:
      case StatusEffectType.silenced:
      case StatusEffectType.frozen:
      case StatusEffectType.cursed:
        return Colors.cyan.shade200;
    }
  }
```

- [ ] **Step 3: Update boss enrage reference**

Find `enemy.attackMultiplier` in combat_screen.dart (around line 441) and change to `enemy.enrageMultiplier`.

- [ ] **Step 4: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/ui/screens/combat/`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/combat/combat_screen.dart
git commit -m "feat: add status effect display under HP bars in combat"
```

---

### Task 8: Add Special Abilities to All Existing Enemies

**Files:**
- Modify: `lib/data/enemy_data.dart`

- [ ] **Step 1: Add import**

Add at top of `enemy_data.dart`:
```dart
import '../models/status_effect.dart';
```

- [ ] **Step 2: Add special abilities to Tier 1-4 enemies**

Add second ability to each enemy. Example for Goblin:
```dart
    EnemyTemplate(name: 'Goblin', type: 'goblin', hp: 30, attack: 6, defense: 2, speed: 7, magic: 0, xpReward: 20, goldReward: 8,
      abilities: [
        Ability(name: 'Scratch', description: 'A clumsy scratch.', damage: 6, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Dirty Throw', description: 'Throws dirt in your eyes.', damage: 3, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1,
          appliesStatusEffects: [AppliedEffect(type: StatusEffectType.blinded, duration: 1, magnitude: 40, chance: 100)]),
      ]),
```

Full list per spec Section 5:

**Tier 1:**
- Goblin: Dirty Throw → blinded 1 turn (50% refresh, dmg: 3)
- Wolf: Trip → stunned 1 turn (45% refresh, dmg: 4)
- Bandit: Low Blow → weakened 2 turns (50% refresh, dmg: 4)

**Tier 2:**
- Skeleton: Bone Rattle → silenced 2 turns (45% refresh, dmg: 5)
- Orc Grunt: War Stomp → slowed 2 turns (50% refresh, dmg: 7)
- Giant Spider: Web Shot → weakened 2 turns (50% refresh, dmg: 6)

**Tier 3:**
- Dark Mage: Hex Bolt → cursed 2 turns (45% refresh, dmg: 10)
- Ogre: Ground Pound → stunned 1 turn (50% refresh, dmg: 11)
- Harpy: Shriek → silenced 2 turns (50% refresh, dmg: 9)

**Tier 4:**
- Troll: Savage Tear → bleeding 3 turns (50% refresh, dmg: 16, bleed magnitude: 14)
- Wraith: Soul Chill → slowed 2 turns + weakened 1 turn (45% refresh, dmg: 16)
- Minotaur: Gore Charge → stunned 1 turn + bleeding 1 turn (50% refresh, dmg: 18, bleed magnitude: 14)

**Tier 5:**
- Wyvern: Poison Barb → poisoned 3 turns (50% refresh, dmg: 20, poison magnitude: 17)
- Lich Acolyte: Withering Curse → cursed 2 turns + weakened 1 turn (45% refresh, dmg: 22)
- Golem: Crushing Slam → stunned 1 turn + exposed 1 turn (50% refresh, dmg: 16)

**Tier 6:**
- Vampire: Mesmerize → stunned 1 turn + cursed 1 turn (45% refresh, dmg: 18)
- Chimera: Venomous Bite → poisoned 2 turns + burning 1 turn (50% refresh, dmg: 22, poison mag: 20, burn mag: 20)
- Death Knight: Cursed Blade → bleeding 3 turns + cursed 1 turn (45% refresh, dmg: 20, bleed mag: 20)

**Tier 7:**
- Elder Dragon: Immolate → burning 3 turns + exposed 1 turn (45% refresh, dmg: 26, burn mag: 23)
- Archdemon: Abyssal Chains → slowed 2 turns + weakened 2 turns (45% refresh, dmg: 24)
- Titan: Earthshatter → stunned 1 turn + slowed 2 turns (45% refresh, dmg: 22)

**Tier 8:**
- Shadow Lord: Void Grip → silenced 2 turns + weakened 2 turns (40% refresh, dmg: 28)
- Ancient Wyrm: Cataclysmic Roar → exposed 2 turns + slowed 2 turns (40% refresh, dmg: 30)
- Void Walker: Phase Strike → blinded 2 turns + cursed 2 turns (40% refresh, dmg: 30)

Special ability damage should be ~50-60% of the basic attack damage to balance the status effect value.

- [ ] **Step 3: Add status effects to boss AOE abilities**

Per spec, add `appliesStatusEffects` to existing boss abilities:
- Goblin King's Call Minions: `[AppliedEffect(type: StatusEffectType.slowed, duration: 1, chance: 100)]`
- Bone Lord's Bone Crush: `[AppliedEffect(type: StatusEffectType.exposed, duration: 2, chance: 100)]`
- Shadow Witch's Curse All: `[AppliedEffect(type: StatusEffectType.cursed, duration: 2, chance: 100)]`
- Mountain Giant's Earthquake: `[AppliedEffect(type: StatusEffectType.slowed, duration: 2, chance: 100)]`
- Lich King's Mass Wither: `[AppliedEffect(type: StatusEffectType.cursed, duration: 3, chance: 100)]`
- Demon Prince's Rain of Fire: `[AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: 20, chance: 100)]`
- Dragon Emperor's Inferno: `[AppliedEffect(type: StatusEffectType.burning, duration: 3, magnitude: 23, chance: 100)]`
- The Dark One's Apocalypse: `[AppliedEffect(type: StatusEffectType.cursed, duration: 2, chance: 100), AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: 26, chance: 100)]`

- [ ] **Step 4: Add status effects to army soldier abilities**

- Army Fighter's Shield Bash: `[AppliedEffect(type: StatusEffectType.stunned, duration: 1, chance: 100)]`
- Army Cleric: add 3rd ability Holy Smite: `Ability(name: 'Holy Smite', description: 'Divine judgment.', damage: 4 + s * 3, refreshChance: 40, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.silenced, duration: 2, chance: 100)])`
- Army Wizard's Arcane Blast: `[AppliedEffect(type: StatusEffectType.burning, duration: 1, magnitude: dotDamage, chance: 100)]` where dotDamage scales with tier

- [ ] **Step 5: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/data/enemy_data.dart`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/data/enemy_data.dart
git commit -m "feat: add special status-effect abilities to all existing enemies and bosses"
```

---

### Task 8.5: Migrate Player Abilities in class_data.dart

**Files:**
- Modify: `lib/data/class_data.dart`
- Modify: `lib/services/combat_service.dart` (remove legacy bridge code)
- Modify: `lib/models/ability.dart` (remove old debuff fields)

- [ ] **Step 1: Migrate all player abilities that use old debuff fields**

In `lib/data/class_data.dart`, replace each old debuff field usage with `appliesStatusEffects`:

- Line 153 (`appliesVulnerability: true`) → add `appliesStatusEffects: [AppliedEffect(type: StatusEffectType.vulnerable, duration: -1, magnitude: 15)]`, remove `appliesVulnerability: true`
- Lines 485-486 (`enemyAttackDebuffPercent: 20, enemyDefenseDebuffPercent: 20`) → add `appliesStatusEffects: [AppliedEffect(type: StatusEffectType.weakened, duration: -1, magnitude: 20), AppliedEffect(type: StatusEffectType.exposed, duration: -1, magnitude: 20)]`, remove old fields
- Line 689 (`enemyAttackDebuffPercent: 10`) → add `appliesStatusEffects: [AppliedEffect(type: StatusEffectType.weakened, duration: -1, magnitude: 10)]`, remove old field
- Lines 707-708 (`tempEnemyAttackDebuffPercent: 50, debuffDuration: 2`) → add `appliesStatusEffects: [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 50)]`, remove old fields
- Lines 757, 766, 784, 794 (`stunChance: N`) → add `appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1, chance: N)]`, remove old field

Add import at top of class_data.dart:
```dart
import '../models/status_effect.dart';
```

- [ ] **Step 2: Remove legacy bridge code from combat_service.dart**

In `executeAllyTurn`, remove the entire "Legacy debuff fields" block (the bridge code that checks `ability.appliesVulnerability`, `ability.enemyAttackDebuffPercent`, etc.). The new `appliesStatusEffects` path handles everything now.

- [ ] **Step 3: Remove old debuff fields from Ability model**

In `lib/models/ability.dart`, remove:
- `appliesVulnerability` field, constructor param, copyWith, toJson, fromJson
- `enemyAttackDebuffPercent` field, constructor param, copyWith, toJson, fromJson
- `enemyDefenseDebuffPercent` field, constructor param, copyWith, toJson, fromJson
- `tempEnemyAttackDebuffPercent` field, constructor param, copyWith, toJson, fromJson
- `debuffDuration` field, constructor param, copyWith, toJson, fromJson
- `stunChance` field, constructor param, copyWith, toJson, fromJson

Keep all other fields (buff fields, lifeDrain, etc.).

- [ ] **Step 4: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/data/class_data.dart lib/services/combat_service.dart lib/models/ability.dart
git commit -m "feat: migrate player abilities to appliesStatusEffects, remove legacy debuff fields"
```

---

### Task 9: Add 60 Custom Map Enemies

**Files:**
- Modify: `lib/data/enemy_data.dart` (add custom enemy templates)
- Modify: `lib/data/map_data.dart` (add customEnemies field to MapDefinition)
- Modify: `lib/providers/game_state_provider.dart` (mix custom enemies into encounters)

- [ ] **Step 1: Add custom enemy template structure to `enemy_data.dart`**

Add a new map of custom enemies keyed by map definition ID. Each entry has 2 enemy "template factories" that take a tier and return an EnemyTemplate with 120% scaled stats:

```dart
/// Custom map enemies: 2 per map definition, scaled to 120% of tier stats.
/// Key = map definition ID, Value = list of 2 factory functions (tier -> EnemyTemplate).
typedef CustomEnemyFactory = EnemyTemplate Function(int tier);

final Map<int, List<CustomEnemyFactory>> customEnemiesByMap = {
  // Forest (map 1)
  1: [
    (tier) => _customEnemy('Thornbear', 'thornbear', tier, [
      AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: StatusDefaults.dotDamage(tier)),
    ], 'Thorn Maul', 'Bramble-covered claws rend flesh.'),
    (tier) => _customEnemy('Woodland Stalker', 'woodland_stalker', tier, [
      AppliedEffect(type: StatusEffectType.slowed, duration: 2),
    ], 'Snare Shot', 'A well-aimed snare.'),
  ],
  // ... (all 30 maps)
};
```

Add a helper function that generates scaled stats from tier:
```dart
EnemyTemplate _customEnemy(String name, String type, int tier,
    List<AppliedEffect> specialEffects, String specialName, String specialDesc,
    {AbilityTarget specialTarget = AbilityTarget.singleEnemy, int specialRefresh = 50}) {
  // Average stats for the tier, scaled to 120%
  final templates = enemiesByMap[tier] ?? enemiesByMap[1]!;
  final avgHp = (templates.fold(0, (sum, t) => sum + t.hp) / templates.length * 1.2).round();
  final avgAtk = (templates.fold(0, (sum, t) => sum + t.attack) / templates.length * 1.2).round();
  final avgDef = (templates.fold(0, (sum, t) => sum + t.defense) / templates.length * 1.2).round();
  final avgSpd = (templates.fold(0, (sum, t) => sum + t.speed) / templates.length * 1.2).round();
  final avgMag = (templates.fold(0, (sum, t) => sum + t.magic) / templates.length * 1.2).round();
  final avgXp = (templates.fold(0, (sum, t) => sum + t.xpReward) / templates.length * 1.15).round();
  final avgGold = (templates.fold(0, (sum, t) => sum + t.goldReward) / templates.length * 1.15).round();
  final specialDmg = (avgAtk * 0.55).round(); // Special attack does ~55% of ATK as damage

  return EnemyTemplate(
    name: name, type: type,
    hp: avgHp, attack: avgAtk, defense: avgDef, speed: avgSpd, magic: avgMag,
    xpReward: avgXp, goldReward: avgGold,
    abilities: [
      Ability(name: 'Attack', description: 'A basic attack.', damage: avgAtk,
        refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: specialName, description: specialDesc, damage: specialDmg,
        refreshChance: specialRefresh, targetType: specialTarget, unlockedAtLevel: 1,
        appliesStatusEffects: specialEffects),
    ],
  );
}
```

Then define all 60 enemies (2 per map) in the `customEnemiesByMap` map, following the full roster from the spec Section 4. Each entry calls the `_customEnemy` helper with appropriate status effects.

- [ ] **Step 2: Add `customEnemies` field to `MapDefinition`**

In `lib/data/map_data.dart`, add to `MapDefinition`:
```dart
  final List<CustomEnemyFactory>? customEnemies;
```

No need to populate it on each map definition — we look it up from `customEnemiesByMap` using the map's ID at encounter time.

Actually, simpler approach: just look up `customEnemiesByMap[mapDefinitionId]` directly in the encounter generator. No MapDefinition change needed.

- [ ] **Step 3: Mix custom enemies into encounter generation**

In `game_state_provider.dart`, update `generateEnemies()`:

```dart
  List<Enemy> generateEnemies() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final mapDefId = state!.currentMapDefinitionId;
    final templates = enemiesByMap[mapNum] ?? enemiesByMap[1]!;
    final customFactories = customEnemiesByMap[mapDefId];

    final partySize = state!.party.where((c) => c.isAlive).length;
    final baseMax = partySize <= 1 ? 1 : partySize <= 2 ? 2 : 3;
    final extra = 1 + _random.nextInt(3);
    final count = (1 + _random.nextInt(baseMax)) + extra;

    return List.generate(count, (_) {
      // 25% chance to spawn a custom map enemy if available
      if (customFactories != null && _random.nextInt(100) < 25) {
        final factory = customFactories[_random.nextInt(customFactories.length)];
        return _enemyFromTemplate(factory(mapNum));
      }
      final template = templates[_random.nextInt(templates.length)];
      return _enemyFromTemplate(template);
    });
  }
```

- [ ] **Step 4: Verify compiles**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/data/enemy_data.dart lib/data/map_data.dart lib/providers/game_state_provider.dart
git commit -m "feat: add 60 custom map-themed enemies with status effect abilities"
```

---

### Task 10: Full Integration & Verify

**Files:**
- All modified files

- [ ] **Step 1: Run full analysis**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/`
Expected: 0 errors. Fix any remaining compile errors from missed references to old field names.

- [ ] **Step 2: Search for any remaining old field references**

Search for: `isVulnerable`, `attackMultiplier` (not `enrageMultiplier`), `defenseMultiplier` (not `baseDefenseMultiplier`), `tempAttackMultiplier`, `tempAttackDebuffTurns`, `enemy.isStunned` (the direct field, not the getter).

Fix any remaining references.

- [ ] **Step 3: Run analysis again**

Run: `cd /Users/matthewhelling/smoke/asher_adventure && flutter analyze lib/`
Expected: 0 errors

- [ ] **Step 4: Commit any fixups**

```bash
git add -A
git commit -m "fix: resolve remaining old field references after status effect migration"
```

---

### Task 11: Manual Testing Checklist

- [ ] **Step 1: Start a new game and enter combat**
  - Verify enemies display correctly with no status effects
  - Verify ally HP bars show normally

- [ ] **Step 2: Fight enemies with special abilities**
  - Verify status effects appear under HP bars when applied
  - Verify combat log shows status effect messages
  - Verify DoTs tick damage each turn
  - Verify stun causes turn skip
  - Verify silenced limits abilities to basic attack only

- [ ] **Step 3: Test custom map enemies**
  - Verify custom enemies appear in encounters (may take a few fights)
  - Verify their stats are slightly higher than regulars
  - Verify their special abilities apply status effects

- [ ] **Step 4: Test boss fights**
  - Verify boss AOE abilities apply status effects to party
  - Verify boss resistance (reduced durations)
  - Verify enrage still works after round 15

- [ ] **Step 5: Test player debuff abilities**
  - Verify Monk stun still works
  - Verify Druid entangle still works
  - Verify Rogue vulnerability still works
  - Verify Warlock hex still works
