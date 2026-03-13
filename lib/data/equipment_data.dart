import '../models/enums.dart';
import '../models/equipment.dart';

// Shop items available per map tier
final Map<int, List<Equipment>> shopItemsByMap = {
  1: [
    const Equipment(id: 'iron_sword', name: 'Iron Sword', slot: EquipmentSlot.weapon, rarity: Rarity.common, attackBonus: 3, value: 30),
    const Equipment(id: 'wooden_shield', name: 'Wooden Shield', slot: EquipmentSlot.offhand, rarity: Rarity.common, defenseBonus: 2, value: 25),
    const Equipment(id: 'leather_armor', name: 'Leather Armor', slot: EquipmentSlot.armor, rarity: Rarity.common, defenseBonus: 3, hpBonus: 10, value: 40),
    const Equipment(id: 'cloth_cap', name: 'Cloth Cap', slot: EquipmentSlot.helm, rarity: Rarity.common, defenseBonus: 1, value: 15),
    const Equipment(id: 'copper_ring', name: 'Copper Ring', slot: EquipmentSlot.ring, rarity: Rarity.common, attackBonus: 1, magicBonus: 1, value: 20),
    const Equipment(id: 'simple_amulet', name: 'Simple Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.common, hpBonus: 15, value: 25),
  ],
  2: [
    const Equipment(id: 'steel_sword', name: 'Steel Sword', slot: EquipmentSlot.weapon, rarity: Rarity.uncommon, attackBonus: 5, value: 60),
    const Equipment(id: 'iron_shield', name: 'Iron Shield', slot: EquipmentSlot.offhand, rarity: Rarity.uncommon, defenseBonus: 4, value: 55),
    const Equipment(id: 'chainmail', name: 'Chainmail', slot: EquipmentSlot.armor, rarity: Rarity.uncommon, defenseBonus: 5, hpBonus: 15, value: 75),
    const Equipment(id: 'iron_helm', name: 'Iron Helm', slot: EquipmentSlot.helm, rarity: Rarity.uncommon, defenseBonus: 3, value: 40),
    const Equipment(id: 'silver_ring', name: 'Silver Ring', slot: EquipmentSlot.ring, rarity: Rarity.uncommon, attackBonus: 2, magicBonus: 2, value: 50),
    const Equipment(id: 'jade_amulet', name: 'Jade Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.uncommon, hpBonus: 25, magicBonus: 2, value: 55),
  ],
  3: [
    const Equipment(id: 'enchanted_blade', name: 'Enchanted Blade', slot: EquipmentSlot.weapon, rarity: Rarity.uncommon, attackBonus: 7, magicBonus: 2, value: 100),
    const Equipment(id: 'tower_shield', name: 'Tower Shield', slot: EquipmentSlot.offhand, rarity: Rarity.uncommon, defenseBonus: 6, hpBonus: 10, value: 90),
    const Equipment(id: 'plate_armor', name: 'Plate Armor', slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 8, hpBonus: 20, value: 130),
    const Equipment(id: 'steel_helm', name: 'Steel Helm', slot: EquipmentSlot.helm, rarity: Rarity.uncommon, defenseBonus: 4, hpBonus: 10, value: 70),
    const Equipment(id: 'gold_ring', name: 'Gold Ring', slot: EquipmentSlot.ring, rarity: Rarity.rare, attackBonus: 3, magicBonus: 3, speedBonus: 1, value: 90),
    const Equipment(id: 'emerald_amulet', name: 'Emerald Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.rare, hpBonus: 35, magicBonus: 3, value: 95),
  ],
  4: [
    const Equipment(id: 'runic_sword', name: 'Runic Sword', slot: EquipmentSlot.weapon, rarity: Rarity.rare, attackBonus: 10, magicBonus: 3, value: 160),
    const Equipment(id: 'runic_shield', name: 'Runic Shield', slot: EquipmentSlot.offhand, rarity: Rarity.rare, defenseBonus: 8, magicBonus: 2, value: 140),
    const Equipment(id: 'dragonscale_armor', name: 'Dragonscale Armor', slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 10, hpBonus: 30, value: 200),
    const Equipment(id: 'runic_helm', name: 'Runic Helm', slot: EquipmentSlot.helm, rarity: Rarity.rare, defenseBonus: 6, hpBonus: 15, magicBonus: 2, value: 120),
    const Equipment(id: 'ruby_ring', name: 'Ruby Ring', slot: EquipmentSlot.ring, rarity: Rarity.rare, attackBonus: 5, speedBonus: 2, value: 140),
    const Equipment(id: 'dragon_amulet', name: 'Dragon Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.rare, hpBonus: 50, attackBonus: 3, value: 150),
  ],
  5: [
    const Equipment(id: 'mythril_blade', name: 'Mythril Blade', slot: EquipmentSlot.weapon, rarity: Rarity.epic, attackBonus: 14, speedBonus: 2, value: 250),
    const Equipment(id: 'mythril_shield', name: 'Mythril Shield', slot: EquipmentSlot.offhand, rarity: Rarity.epic, defenseBonus: 11, hpBonus: 20, value: 220),
    const Equipment(id: 'mythril_armor', name: 'Mythril Armor', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 13, hpBonus: 40, value: 300),
    const Equipment(id: 'mythril_helm', name: 'Mythril Helm', slot: EquipmentSlot.helm, rarity: Rarity.epic, defenseBonus: 8, hpBonus: 20, magicBonus: 3, value: 180),
    const Equipment(id: 'diamond_ring', name: 'Diamond Ring', slot: EquipmentSlot.ring, rarity: Rarity.epic, attackBonus: 6, magicBonus: 6, speedBonus: 2, value: 220),
    const Equipment(id: 'phoenix_amulet', name: 'Phoenix Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.epic, hpBonus: 60, magicBonus: 5, value: 240),
  ],
  6: [
    const Equipment(id: 'shadow_blade', name: 'Shadow Blade', slot: EquipmentSlot.weapon, rarity: Rarity.epic, attackBonus: 18, speedBonus: 3, value: 350),
    const Equipment(id: 'aegis', name: 'Aegis', slot: EquipmentSlot.offhand, rarity: Rarity.epic, defenseBonus: 14, hpBonus: 30, magicBonus: 3, value: 320),
    const Equipment(id: 'celestial_armor', name: 'Celestial Armor', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 16, hpBonus: 50, magicBonus: 4, value: 400),
    const Equipment(id: 'crown_of_stars', name: 'Crown of Stars', slot: EquipmentSlot.helm, rarity: Rarity.epic, defenseBonus: 10, magicBonus: 6, value: 280),
    const Equipment(id: 'void_ring', name: 'Void Ring', slot: EquipmentSlot.ring, rarity: Rarity.epic, attackBonus: 8, magicBonus: 8, speedBonus: 3, value: 320),
    const Equipment(id: 'amulet_of_ages', name: 'Amulet of Ages', slot: EquipmentSlot.amulet, rarity: Rarity.epic, hpBonus: 80, attackBonus: 5, magicBonus: 5, value: 340),
  ],
  7: [
    const Equipment(id: 'legendary_sword', name: 'Excalibur', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, attackBonus: 24, magicBonus: 5, speedBonus: 3, value: 500),
    const Equipment(id: 'legendary_shield', name: 'Paladin\'s Bastion', slot: EquipmentSlot.offhand, rarity: Rarity.legendary, defenseBonus: 18, hpBonus: 50, magicBonus: 5, value: 480),
    const Equipment(id: 'legendary_armor', name: 'Armor of the Ancients', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 20, hpBonus: 70, magicBonus: 5, value: 550),
    const Equipment(id: 'legendary_helm', name: 'Crown of Eternity', slot: EquipmentSlot.helm, rarity: Rarity.legendary, defenseBonus: 12, hpBonus: 30, magicBonus: 8, value: 400),
    const Equipment(id: 'legendary_ring', name: 'Ring of Power', slot: EquipmentSlot.ring, rarity: Rarity.legendary, attackBonus: 10, magicBonus: 10, speedBonus: 5, value: 450),
    const Equipment(id: 'legendary_amulet', name: 'Heart of the World', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, hpBonus: 100, attackBonus: 8, magicBonus: 8, value: 500),
  ],
  8: [
    const Equipment(id: 'godslayer', name: 'Godslayer', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, attackBonus: 30, magicBonus: 8, speedBonus: 5, value: 800),
    const Equipment(id: 'divine_aegis', name: 'Divine Aegis', slot: EquipmentSlot.offhand, rarity: Rarity.legendary, defenseBonus: 22, hpBonus: 60, magicBonus: 8, value: 750),
    const Equipment(id: 'god_armor', name: 'Armor of the Gods', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 24, hpBonus: 90, magicBonus: 8, value: 850),
    const Equipment(id: 'god_helm', name: 'Helm of Omniscience', slot: EquipmentSlot.helm, rarity: Rarity.legendary, defenseBonus: 16, hpBonus: 40, magicBonus: 12, speedBonus: 3, value: 650),
    const Equipment(id: 'god_ring', name: 'Ring of Destiny', slot: EquipmentSlot.ring, rarity: Rarity.legendary, attackBonus: 14, magicBonus: 14, speedBonus: 6, value: 700),
    const Equipment(id: 'god_amulet', name: 'Amulet of Infinity', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, hpBonus: 120, attackBonus: 12, magicBonus: 12, value: 750),
  ],
};

// Treasure drop pool (random loot from treasure nodes)
List<Equipment> getTreasurePool(int mapNumber) {
  final pool = <Equipment>[];
  // Include current map's items and some from the next
  if (shopItemsByMap.containsKey(mapNumber)) {
    pool.addAll(shopItemsByMap[mapNumber]!);
  }
  if (shopItemsByMap.containsKey(mapNumber + 1)) {
    pool.addAll(shopItemsByMap[mapNumber + 1]!);
  }
  return pool;
}
