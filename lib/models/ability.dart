import 'enums.dart';

class Ability {
  final String name;
  final String description;
  final int damage; // negative for healing
  final int refreshChance; // 0-100 percent chance to refresh each round
  final AbilityTarget targetType;
  final int unlockedAtLevel;
  final bool isBasicAttack;
  final bool lifeDrain; // heals attacker for 50% of damage dealt
  final bool appliesVulnerability; // enemy takes 5-15% more damage from all attacks
  final int healPercentMaxHp; // heals for % of target's max HP (bypasses magic formula)
  final int attackBuffPercent; // buff target's attack by this %
  final int defenseBuffPercent; // buff target's defense by this %
  final int enemyAttackDebuffPercent; // reduce enemy attack by this %
  final int enemyDefenseDebuffPercent; // reduce enemy defense by this %
  final bool darkPact; // sacrifice 15-25% HP, deal 1.5x to all enemies
  final int grantCasterDefensePercent; // grant % of caster's defense to target
  final bool healScalesWithDefense; // use defense instead of magic for heal calc
  final int tempEnemyAttackDebuffPercent; // temporary attack debuff on enemy
  final int debuffDuration; // turns the temp debuff lasts
  final bool chaotic; // wider variance (-25% to +25%) + 50% chance to bounce
  final int stunChance; // 0-100% chance to stun enemy (skip next turn)
  final int hitCount; // number of times this ability hits (each hit rolls separately)
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
    this.appliesVulnerability = false,
    this.healPercentMaxHp = 0,
    this.attackBuffPercent = 0,
    this.defenseBuffPercent = 0,
    this.enemyAttackDebuffPercent = 0,
    this.enemyDefenseDebuffPercent = 0,
    this.darkPact = false,
    this.grantCasterDefensePercent = 0,
    this.healScalesWithDefense = false,
    this.tempEnemyAttackDebuffPercent = 0,
    this.debuffDuration = 0,
    this.chaotic = false,
    this.stunChance = 0,
    this.hitCount = 1,
    this.isAvailable = true,
  });

  Ability copyWith({bool? isAvailable}) {
    return Ability(
      name: name,
      description: description,
      damage: damage,
      refreshChance: refreshChance,
      targetType: targetType,
      unlockedAtLevel: unlockedAtLevel,
      isBasicAttack: isBasicAttack,
      lifeDrain: lifeDrain,
      appliesVulnerability: appliesVulnerability,
      healPercentMaxHp: healPercentMaxHp,
      attackBuffPercent: attackBuffPercent,
      defenseBuffPercent: defenseBuffPercent,
      enemyAttackDebuffPercent: enemyAttackDebuffPercent,
      enemyDefenseDebuffPercent: enemyDefenseDebuffPercent,
      darkPact: darkPact,
      grantCasterDefensePercent: grantCasterDefensePercent,
      healScalesWithDefense: healScalesWithDefense,
      tempEnemyAttackDebuffPercent: tempEnemyAttackDebuffPercent,
      debuffDuration: debuffDuration,
      chaotic: chaotic,
      stunChance: stunChance,
      hitCount: hitCount,
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
    'appliesVulnerability': appliesVulnerability,
    'healPercentMaxHp': healPercentMaxHp,
    'attackBuffPercent': attackBuffPercent,
    'defenseBuffPercent': defenseBuffPercent,
    'enemyAttackDebuffPercent': enemyAttackDebuffPercent,
    'enemyDefenseDebuffPercent': enemyDefenseDebuffPercent,
    'darkPact': darkPact,
    'grantCasterDefensePercent': grantCasterDefensePercent,
    'healScalesWithDefense': healScalesWithDefense,
    'tempEnemyAttackDebuffPercent': tempEnemyAttackDebuffPercent,
    'debuffDuration': debuffDuration,
    'chaotic': chaotic,
    'stunChance': stunChance,
    'hitCount': hitCount,
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
    appliesVulnerability: json['appliesVulnerability'] ?? false,
    healPercentMaxHp: json['healPercentMaxHp'] ?? 0,
    attackBuffPercent: json['attackBuffPercent'] ?? 0,
    defenseBuffPercent: json['defenseBuffPercent'] ?? 0,
    enemyAttackDebuffPercent: json['enemyAttackDebuffPercent'] ?? 0,
    enemyDefenseDebuffPercent: json['enemyDefenseDebuffPercent'] ?? 0,
    darkPact: json['darkPact'] ?? false,
    grantCasterDefensePercent: json['grantCasterDefensePercent'] ?? 0,
    healScalesWithDefense: json['healScalesWithDefense'] ?? false,
    tempEnemyAttackDebuffPercent: json['tempEnemyAttackDebuffPercent'] ?? 0,
    debuffDuration: json['debuffDuration'] ?? 0,
    chaotic: json['chaotic'] ?? false,
    stunChance: json['stunChance'] ?? 0,
    hitCount: json['hitCount'] ?? 1,
    isAvailable: json['isAvailable'] ?? true,
  );
}
