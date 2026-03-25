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

  bool get isDot =>
      type == StatusEffectType.poisoned ||
      type == StatusEffectType.burning ||
      type == StatusEffectType.bleeding;

  bool get isControl =>
      type == StatusEffectType.stunned ||
      type == StatusEffectType.frozen ||
      type == StatusEffectType.silenced ||
      type == StatusEffectType.blinded ||
      type == StatusEffectType.cursed;

  bool get isStatDebuff =>
      type == StatusEffectType.weakened ||
      type == StatusEffectType.exposed ||
      type == StatusEffectType.slowed;

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

class StatusDefaults {
  static const int weakenedPercent = 25;
  static const int exposedPercent = 30;
  static const int vulnerablePercent = 15;
  static const int slowedPercent = 30;
  static const int blindedMissPercent = 40;
  static const int frozenBonusPercent = 30;
  static const int vulnerableCap = 30;

  static int dotDamage(int tier) => tier * 3 + 2;
}

mixin StatusEffectMixin {
  List<StatusEffect> get statusEffects;

  void addStatusEffect(StatusEffect effect) {
    if (effect.type == StatusEffectType.vulnerable) {
      final existing = statusEffects.where((e) => e.type == StatusEffectType.vulnerable).toList();
      if (existing.isNotEmpty) {
        final totalMag = existing.fold(0, (sum, e) => sum + e.magnitude) + effect.magnitude;
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
      statusEffects.add(effect);
      return;
    } else if (effect.isControl) {
      final existing = statusEffects.where((e) => e.type == effect.type).toList();
      if (existing.isNotEmpty) {
        existing.first.duration = effect.duration;
        return;
      }
    } else if (effect.isStatDebuff) {
      statusEffects.add(effect);
      return;
    }

    statusEffects.add(effect);
  }

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

  void removeExpiredEffects() {
    statusEffects.removeWhere((e) => !e.isDot && e.isExpired);
  }

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

  int get blindedMissChance {
    final blinded = statusEffects.where((e) => e.type == StatusEffectType.blinded);
    if (blinded.isEmpty) return 0;
    return blinded.first.magnitude > 0 ? blinded.first.magnitude : StatusDefaults.blindedMissPercent;
  }

  int get vulnerableMagnitude {
    final vuln = statusEffects.where((e) => e.type == StatusEffectType.vulnerable);
    if (vuln.isEmpty) return 0;
    return vuln.first.magnitude > 0 ? vuln.first.magnitude : StatusDefaults.vulnerablePercent;
  }

  int get frozenBonusDamage {
    final frozen = statusEffects.where((e) => e.type == StatusEffectType.frozen);
    if (frozen.isEmpty) return 0;
    return frozen.first.magnitude > 0 ? frozen.first.magnitude : StatusDefaults.frozenBonusPercent;
  }

  void shatterFrozen() {
    statusEffects.removeWhere((e) => e.type == StatusEffectType.frozen);
  }

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
