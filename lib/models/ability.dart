import 'enums.dart';

class Ability {
  final String name;
  final String description;
  final int damage; // negative for healing
  final int refreshChance; // 0-100 percent chance to refresh each round
  final AbilityTarget targetType;
  final int unlockedAtLevel;
  final bool isBasicAttack;
  bool isAvailable;

  Ability({
    required this.name,
    required this.description,
    required this.damage,
    required this.refreshChance,
    required this.targetType,
    required this.unlockedAtLevel,
    this.isBasicAttack = false,
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
  };

  factory Ability.fromJson(Map<String, dynamic> json) => Ability(
    name: json['name'],
    description: json['description'],
    damage: json['damage'],
    refreshChance: json['refreshChance'],
    targetType: AbilityTarget.values[json['targetType']],
    unlockedAtLevel: json['unlockedAtLevel'],
    isBasicAttack: json['isBasicAttack'] ?? false,
    isAvailable: json['isAvailable'] ?? true,
  );
}
