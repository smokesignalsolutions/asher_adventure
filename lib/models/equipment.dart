import 'enums.dart';

class Equipment {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final Rarity rarity;
  final int attackBonus;
  final int defenseBonus;
  final int hpBonus;
  final int speedBonus;
  final int magicBonus;
  final int value; // gold value
  final SpecialEffect? specialEffect;

  const Equipment({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.hpBonus = 0,
    this.speedBonus = 0,
    this.magicBonus = 0,
    required this.value,
    this.specialEffect,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slot': slot.index,
    'rarity': rarity.index,
    'attackBonus': attackBonus,
    'defenseBonus': defenseBonus,
    'hpBonus': hpBonus,
    'speedBonus': speedBonus,
    'magicBonus': magicBonus,
    'value': value,
    'specialEffect': specialEffect?.index,
  };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    id: json['id'],
    name: json['name'],
    slot: EquipmentSlot.values[json['slot']],
    rarity: Rarity.values[json['rarity']],
    attackBonus: json['attackBonus'] ?? 0,
    defenseBonus: json['defenseBonus'] ?? 0,
    hpBonus: json['hpBonus'] ?? 0,
    speedBonus: json['speedBonus'] ?? 0,
    magicBonus: json['magicBonus'] ?? 0,
    value: json['value'],
    specialEffect: json['specialEffect'] != null
        ? SpecialEffect.values[json['specialEffect']]
        : null,
  );
}
