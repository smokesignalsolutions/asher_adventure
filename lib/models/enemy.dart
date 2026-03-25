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
