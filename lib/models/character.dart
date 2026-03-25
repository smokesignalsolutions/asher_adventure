import 'ability.dart';
import 'enums.dart';
import 'equipment.dart';
import 'status_effect.dart';

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

class Character with StatusEffectMixin {
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
  int shieldHp;
  double combatAttackMultiplier; // combat-only, resets each fight
  double combatDefenseMultiplier; // combat-only, resets each fight
  double combatSpeedMultiplier; // combat-only, resets each fight
  double combatMagicMultiplier; // combat-only, resets each fight
  int combatDefenseBonus; // flat defense bonus from abilities like Holy Guard
  List<String> activeSummons; // summoner: persistent summon IDs (combat-only)
  bool? lastAttackWasPhysical; // spellsword: track alternation (combat-only)
  bool isFrontLine; // front line characters are targeted more often
  int skeletonCount; // necromancer: active skeleton minions (combat-only)
  @override
  List<StatusEffect> statusEffects;

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
    this.shieldHp = 0,
    this.combatAttackMultiplier = 1.0,
    this.combatDefenseMultiplier = 1.0,
    this.combatSpeedMultiplier = 1.0,
    this.combatMagicMultiplier = 1.0,
    this.combatDefenseBonus = 0,
    List<String>? activeSummons,
    this.lastAttackWasPhysical,
    this.isFrontLine = true,
    this.skeletonCount = 0,
    List<StatusEffect>? statusEffects,
  }) : statusEffects = statusEffects ?? [],
       equipment = equipment ?? {
         for (var slot in EquipmentSlot.values) slot: null,
       },
       abilities = abilities ?? [],
       activeSummons = activeSummons ?? [];

  bool get isAlive => currentHp > 0;

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

  int get totalMagic =>
      ((magic +
      equipment.values.where((e) => e != null).fold(0, (sum, e) => sum + e!.magicBonus)) *
      combatMagicMultiplier).round();

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
    'shieldHp': shieldHp,
    'abilities': abilities.map((a) => a.toJson()).toList(),
    'isFrontLine': isFrontLine,
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
      shieldHp: json['shieldHp'] ?? 0,
      equipment: equipMap,
      abilities: (json['abilities'] as List)
          .map((a) => Ability.fromJson(a))
          .toList(),
      isFrontLine: json['isFrontLine'] ?? true,
    );
  }
}
