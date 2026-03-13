import 'ability.dart';

class Enemy {
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
  });

  bool get isAlive => currentHp > 0;

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
