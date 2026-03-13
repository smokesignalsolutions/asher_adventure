import 'ability.dart';
import 'enums.dart';
import 'equipment.dart';

class CharacterStats {
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int magic;

  const CharacterStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.magic,
  });

  Map<String, dynamic> toJson() => {
    'hp': hp,
    'attack': attack,
    'defense': defense,
    'speed': speed,
    'magic': magic,
  };

  factory CharacterStats.fromJson(Map<String, dynamic> json) => CharacterStats(
    hp: json['hp'],
    attack: json['attack'],
    defense: json['defense'],
    speed: json['speed'],
    magic: json['magic'],
  );
}

class Character {
  final String id;
  final String name;
  final CharacterClass characterClass;
  int level;
  int xp;
  int currentHp;
  int maxHp;
  int attack;
  int defense;
  int speed;
  int magic;
  Map<EquipmentSlot, Equipment?> equipment;
  List<Ability> abilities;

  Character({
    required this.id,
    required this.name,
    required this.characterClass,
    this.level = 1,
    this.xp = 0,
    required this.currentHp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.magic,
    Map<EquipmentSlot, Equipment?>? equipment,
    List<Ability>? abilities,
  }) : equipment = equipment ?? {
         for (var slot in EquipmentSlot.values) slot: null,
       },
       abilities = abilities ?? [];

  bool get isAlive => currentHp > 0;

  int get totalAttack =>
      attack +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.attackBonus);

  int get totalDefense =>
      defense +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.defenseBonus);

  int get totalSpeed =>
      speed +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.speedBonus);

  int get totalMagic =>
      magic +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.magicBonus);

  int get totalMaxHp =>
      maxHp +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.hpBonus);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'characterClass': characterClass.index,
    'level': level,
    'xp': xp,
    'currentHp': currentHp,
    'maxHp': maxHp,
    'attack': attack,
    'defense': defense,
    'speed': speed,
    'magic': magic,
    'equipment': {
      for (var entry in equipment.entries)
        entry.key.name: entry.value?.toJson(),
    },
    'abilities': abilities.map((a) => a.toJson()).toList(),
  };

  factory Character.fromJson(Map<String, dynamic> json) {
    final equipMap = <EquipmentSlot, Equipment?>{};
    final equipJson = json['equipment'] as Map<String, dynamic>;
    for (var slot in EquipmentSlot.values) {
      final val = equipJson[slot.name];
      equipMap[slot] = val != null ? Equipment.fromJson(val) : null;
    }

    return Character(
      id: json['id'],
      name: json['name'],
      characterClass: CharacterClass.values[json['characterClass']],
      level: json['level'],
      xp: json['xp'],
      currentHp: json['currentHp'],
      maxHp: json['maxHp'],
      attack: json['attack'],
      defense: json['defense'],
      speed: json['speed'],
      magic: json['magic'],
      equipment: equipMap,
      abilities: (json['abilities'] as List)
          .map((a) => Ability.fromJson(a))
          .toList(),
    );
  }
}
