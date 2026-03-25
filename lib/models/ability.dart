import 'enums.dart';
import 'status_effect.dart';

class Ability {
  final String name;
  final String description;
  final int damage; // negative for healing
  final int refreshChance; // 0-100 percent chance to refresh each round
  final AbilityTarget targetType;
  final int unlockedAtLevel;
  final bool isBasicAttack;
  final bool lifeDrain; // heals attacker for 50% of damage dealt
  final int
  healPercentMaxHp; // heals for % of target's max HP (bypasses magic formula)
  final int attackBuffPercent; // buff target's attack by this %
  final int defenseBuffPercent; // buff target's defense by this %
  final bool darkPact; // sacrifice 15-25% HP, deal 1.5x to all enemies
  final int grantCasterDefensePercent; // grant % of caster's defense to target
  final bool
  healScalesWithDefense; // use defense instead of magic for heal calc
  final bool chaotic; // wider variance (-25% to +25%) + 50% chance to bounce
  final int
  hitCount; // number of times this ability hits (each hit rolls separately)
  final int minTargets; // random multi-target: min targets (0 = not used)
  final int maxTargets; // random multi-target: max targets
  final String summonId; // persistent summon identifier (summoner class)
  final bool isPhysicalAttack; // for spellsword alternating bonus
  final bool rogueDualStrike; // rogue: 15% chance to execute ability twice
  final List<AppliedEffect> appliesStatusEffects;
  bool isAvailable;

  Ability({
    required this.name,
    required this.description,
    required this.damage,
    required this.refreshChance,
    required this.targetType,
    required this.unlockedAtLevel,
    this.isBasicAttack = false,
    this.lifeDrain = false,
    this.healPercentMaxHp = 0,
    this.attackBuffPercent = 0,
    this.defenseBuffPercent = 0,
    this.darkPact = false,
    this.grantCasterDefensePercent = 0,
    this.healScalesWithDefense = false,
    this.chaotic = false,
    this.hitCount = 1,
    this.minTargets = 0,
    this.maxTargets = 0,
    this.summonId = '',
    this.isPhysicalAttack = false,
    this.rogueDualStrike = false,
    this.appliesStatusEffects = const [],
    this.isAvailable = true,
  });

  Ability copyWith({bool? isAvailable, int? unlockedAtLevel, List<AppliedEffect>? appliesStatusEffects}) {
    return Ability(
      name: name,
      description: description,
      damage: damage,
      refreshChance: refreshChance,
      targetType: targetType,
      unlockedAtLevel: unlockedAtLevel ?? this.unlockedAtLevel,
      isBasicAttack: isBasicAttack,
      lifeDrain: lifeDrain,
      healPercentMaxHp: healPercentMaxHp,
      attackBuffPercent: attackBuffPercent,
      defenseBuffPercent: defenseBuffPercent,
      darkPact: darkPact,
      grantCasterDefensePercent: grantCasterDefensePercent,
      healScalesWithDefense: healScalesWithDefense,
      chaotic: chaotic,
      hitCount: hitCount,
      minTargets: minTargets,
      maxTargets: maxTargets,
      summonId: summonId,
      isPhysicalAttack: isPhysicalAttack,
      rogueDualStrike: rogueDualStrike,
      appliesStatusEffects: appliesStatusEffects ?? this.appliesStatusEffects,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'damage': damage,
    'refreshChance': refreshChance,
    'targetType': targetType.index,
    'unlockedAtLevel': unlockedAtLevel,
    'isBasicAttack': isBasicAttack,
    'isAvailable': isAvailable,
    'lifeDrain': lifeDrain,
    'healPercentMaxHp': healPercentMaxHp,
    'attackBuffPercent': attackBuffPercent,
    'defenseBuffPercent': defenseBuffPercent,
    'darkPact': darkPact,
    'grantCasterDefensePercent': grantCasterDefensePercent,
    'healScalesWithDefense': healScalesWithDefense,
    'chaotic': chaotic,
    'hitCount': hitCount,
    'minTargets': minTargets,
    'maxTargets': maxTargets,
    'summonId': summonId,
    'isPhysicalAttack': isPhysicalAttack,
    'rogueDualStrike': rogueDualStrike,
    if (appliesStatusEffects.isNotEmpty)
      'appliesStatusEffects': appliesStatusEffects.map((e) => e.toJson()).toList(),
  };

  factory Ability.fromJson(Map<String, dynamic> json) => Ability(
    name: json['name'],
    description: json['description'],
    damage: json['damage'],
    refreshChance: json['refreshChance'],
    targetType: AbilityTarget.values[json['targetType']],
    unlockedAtLevel: json['unlockedAtLevel'],
    isBasicAttack: json['isBasicAttack'] ?? false,
    lifeDrain: json['lifeDrain'] ?? false,
    healPercentMaxHp: json['healPercentMaxHp'] ?? 0,
    attackBuffPercent: json['attackBuffPercent'] ?? 0,
    defenseBuffPercent: json['defenseBuffPercent'] ?? 0,
    darkPact: json['darkPact'] ?? false,
    grantCasterDefensePercent: json['grantCasterDefensePercent'] ?? 0,
    healScalesWithDefense: json['healScalesWithDefense'] ?? false,
    chaotic: json['chaotic'] ?? false,
    hitCount: json['hitCount'] ?? 1,
    minTargets: json['minTargets'] ?? 0,
    maxTargets: json['maxTargets'] ?? 0,
    summonId: json['summonId'] ?? '',
    isPhysicalAttack: json['isPhysicalAttack'] ?? false,
    rogueDualStrike: json['rogueDualStrike'] ?? false,
    appliesStatusEffects: (json['appliesStatusEffects'] as List?)
        ?.map((e) => AppliedEffect.fromJson(e))
        .toList() ?? const [],
    isAvailable: json['isAvailable'] ?? true,
  );
}
