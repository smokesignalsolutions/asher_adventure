import '../models/enums.dart';
import '../models/equipment.dart';

// Shop items available per map tier
// Each tier offers physical and magical variants per slot for strategic choices
// Physical gear: high attack/defense, often with speed penalties (heavy)
// Magical gear: boosts healing power, lighter with speed bonuses
final Map<int, List<Equipment>> shopItemsByMap = {
  // === MAP 1: Common Gear ===
  1: [
    // Weapons
    const Equipment(id: 'iron_sword', name: 'Iron Sword', slot: EquipmentSlot.weapon, rarity: Rarity.common, attackBonus: 4, value: 30),
    const Equipment(id: 'gnarled_staff', name: 'Gnarled Staff', slot: EquipmentSlot.weapon, rarity: Rarity.common, magicBonus: 4, value: 30),
    // Offhand
    const Equipment(id: 'wooden_shield', name: 'Wooden Shield', slot: EquipmentSlot.offhand, rarity: Rarity.common, defenseBonus: 3, speedBonus: -1, value: 25),
    const Equipment(id: 'tome_of_sparks', name: 'Tome of Sparks', slot: EquipmentSlot.offhand, rarity: Rarity.common, magicBonus: 3, value: 25),
    // Armor
    const Equipment(id: 'leather_armor', name: 'Leather Armor', slot: EquipmentSlot.armor, rarity: Rarity.common, defenseBonus: 3, hpBonus: 10, value: 40),
    const Equipment(id: 'cloth_robes', name: 'Cloth Robes', slot: EquipmentSlot.armor, rarity: Rarity.common, defenseBonus: 1, magicBonus: 2, hpBonus: 5, value: 35),
    // Helm
    const Equipment(id: 'cloth_cap', name: 'Cloth Cap', slot: EquipmentSlot.helm, rarity: Rarity.common, defenseBonus: 1, hpBonus: 5, value: 15),
    const Equipment(id: 'apprentice_hood', name: 'Apprentice Hood', slot: EquipmentSlot.helm, rarity: Rarity.common, magicBonus: 2, value: 15),
    // Ring
    const Equipment(id: 'copper_ring', name: 'Copper Ring', slot: EquipmentSlot.ring, rarity: Rarity.common, attackBonus: 2, value: 20),
    const Equipment(id: 'amethyst_ring', name: 'Amethyst Ring', slot: EquipmentSlot.ring, rarity: Rarity.common, magicBonus: 2, value: 20),
    // Amulet
    const Equipment(id: 'simple_amulet', name: 'Simple Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.common, hpBonus: 20, value: 25),
    const Equipment(id: 'charm_of_focus', name: 'Charm of Focus', slot: EquipmentSlot.amulet, rarity: Rarity.common, magicBonus: 2, hpBonus: 10, value: 25),
  ],
  // === MAP 2: Uncommon Gear ===
  2: [
    // Weapons
    const Equipment(id: 'steel_sword', name: 'Steel Sword', slot: EquipmentSlot.weapon, rarity: Rarity.uncommon, attackBonus: 6, value: 60),
    const Equipment(id: 'oak_staff', name: 'Oak Staff', slot: EquipmentSlot.weapon, rarity: Rarity.uncommon, magicBonus: 7, value: 60),
    // Offhand
    const Equipment(id: 'iron_shield', name: 'Iron Shield', slot: EquipmentSlot.offhand, rarity: Rarity.uncommon, defenseBonus: 5, hpBonus: 5, speedBonus: -1, value: 55),
    const Equipment(id: 'grimoire_of_flame', name: 'Grimoire of Flame', slot: EquipmentSlot.offhand, rarity: Rarity.uncommon, magicBonus: 4, hpBonus: 5, value: 55),
    // Armor
    const Equipment(id: 'chainmail', name: 'Chainmail', slot: EquipmentSlot.armor, rarity: Rarity.uncommon, defenseBonus: 5, hpBonus: 15, speedBonus: -1, value: 75),
    const Equipment(id: 'mystic_robes', name: 'Mystic Robes', slot: EquipmentSlot.armor, rarity: Rarity.uncommon, defenseBonus: 2, magicBonus: 4, hpBonus: 10, value: 65),
    // Helm
    const Equipment(id: 'iron_helm', name: 'Iron Helm', slot: EquipmentSlot.helm, rarity: Rarity.uncommon, defenseBonus: 3, hpBonus: 10, value: 40),
    const Equipment(id: 'mages_circlet', name: "Mage's Circlet", slot: EquipmentSlot.helm, rarity: Rarity.uncommon, magicBonus: 3, hpBonus: 5, value: 40),
    // Ring
    const Equipment(id: 'silver_ring', name: 'Silver Ring', slot: EquipmentSlot.ring, rarity: Rarity.uncommon, attackBonus: 3, speedBonus: 1, value: 50),
    const Equipment(id: 'sapphire_ring', name: 'Sapphire Ring', slot: EquipmentSlot.ring, rarity: Rarity.uncommon, magicBonus: 4, value: 50),
    // Amulet
    const Equipment(id: 'jade_amulet', name: 'Jade Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.uncommon, hpBonus: 30, defenseBonus: 1, value: 55),
    const Equipment(id: 'pendant_of_insight', name: 'Pendant of Insight', slot: EquipmentSlot.amulet, rarity: Rarity.uncommon, magicBonus: 3, hpBonus: 15, value: 55),
  ],
  // === MAP 3: Rare Gear ===
  3: [
    // Weapons
    const Equipment(id: 'enchanted_blade', name: 'Enchanted Blade', slot: EquipmentSlot.weapon, rarity: Rarity.rare, attackBonus: 8, value: 100),
    const Equipment(id: 'staff_of_storms', name: 'Staff of Storms', slot: EquipmentSlot.weapon, rarity: Rarity.rare, magicBonus: 10, value: 100),
    // Offhand
    const Equipment(id: 'tower_shield', name: 'Tower Shield', slot: EquipmentSlot.offhand, rarity: Rarity.rare, defenseBonus: 7, hpBonus: 10, speedBonus: -2, value: 90),
    const Equipment(id: 'orb_of_binding', name: 'Orb of Binding', slot: EquipmentSlot.offhand, rarity: Rarity.rare, magicBonus: 6, defenseBonus: 1, value: 90),
    // Armor
    const Equipment(id: 'plate_armor', name: 'Plate Armor', slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 8, hpBonus: 25, speedBonus: -2, value: 130),
    const Equipment(id: 'arcane_vestments', name: 'Arcane Vestments', slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 3, magicBonus: 5, hpBonus: 15, speedBonus: 1, value: 110),
    // Helm
    const Equipment(id: 'steel_helm', name: 'Steel Helm', slot: EquipmentSlot.helm, rarity: Rarity.rare, defenseBonus: 5, hpBonus: 10, value: 70),
    const Equipment(id: 'wizards_hat', name: "Wizard's Hat", slot: EquipmentSlot.helm, rarity: Rarity.rare, magicBonus: 5, hpBonus: 5, value: 70),
    // Ring
    const Equipment(id: 'gold_ring', name: 'Gold Ring', slot: EquipmentSlot.ring, rarity: Rarity.rare, attackBonus: 4, speedBonus: 2, value: 90),
    const Equipment(id: 'opal_ring', name: 'Opal Ring', slot: EquipmentSlot.ring, rarity: Rarity.rare, magicBonus: 6, value: 90),
    // Amulet
    const Equipment(id: 'emerald_amulet', name: 'Emerald Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.rare, hpBonus: 40, defenseBonus: 2, value: 95),
    const Equipment(id: 'amulet_of_the_mind', name: 'Amulet of the Mind', slot: EquipmentSlot.amulet, rarity: Rarity.rare, magicBonus: 5, hpBonus: 20, value: 95),
  ],
  // === MAP 4: Rare Gear ===
  4: [
    // Weapons
    const Equipment(id: 'runic_sword', name: 'Runic Sword', slot: EquipmentSlot.weapon, rarity: Rarity.rare, attackBonus: 11, value: 160),
    const Equipment(id: 'staff_of_the_void', name: 'Staff of the Void', slot: EquipmentSlot.weapon, rarity: Rarity.rare, magicBonus: 13, value: 160),
    // Offhand
    const Equipment(id: 'runic_shield', name: 'Runic Shield', slot: EquipmentSlot.offhand, rarity: Rarity.rare, defenseBonus: 9, hpBonus: 15, speedBonus: -2, value: 140),
    const Equipment(id: 'tome_of_shadows', name: 'Tome of Shadows', slot: EquipmentSlot.offhand, rarity: Rarity.rare, magicBonus: 8, defenseBonus: 2, value: 140),
    // Armor
    const Equipment(id: 'dragonscale_armor', name: 'Dragonscale Armor', slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 11, hpBonus: 30, speedBonus: -2, value: 200),
    const Equipment(id: 'druids_mantle', name: "Druid's Mantle", slot: EquipmentSlot.armor, rarity: Rarity.rare, defenseBonus: 4, magicBonus: 7, hpBonus: 20, value: 170),
    // Helm
    const Equipment(id: 'runic_helm', name: 'Runic Helm', slot: EquipmentSlot.helm, rarity: Rarity.rare, defenseBonus: 6, hpBonus: 15, value: 120),
    const Equipment(id: 'crown_of_whispers', name: 'Crown of Whispers', slot: EquipmentSlot.helm, rarity: Rarity.rare, magicBonus: 7, hpBonus: 10, speedBonus: 1, value: 120),
    // Ring
    const Equipment(id: 'ruby_ring', name: 'Ruby Ring', slot: EquipmentSlot.ring, rarity: Rarity.rare, attackBonus: 6, speedBonus: 2, value: 140),
    const Equipment(id: 'ring_of_sorcery', name: 'Ring of Sorcery', slot: EquipmentSlot.ring, rarity: Rarity.rare, magicBonus: 7, value: 140),
    // Amulet
    const Equipment(id: 'dragon_amulet', name: 'Dragon Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.rare, hpBonus: 55, attackBonus: 3, value: 150),
    const Equipment(id: 'amulet_of_brilliance', name: 'Amulet of Brilliance', slot: EquipmentSlot.amulet, rarity: Rarity.rare, magicBonus: 7, hpBonus: 25, value: 150),
  ],
  // === MAP 5: Epic Gear ===
  5: [
    // Weapons
    const Equipment(id: 'mythril_blade', name: 'Mythril Blade', slot: EquipmentSlot.weapon, rarity: Rarity.epic, attackBonus: 14, speedBonus: 1, value: 250),
    const Equipment(id: 'staff_of_elements', name: 'Staff of Elements', slot: EquipmentSlot.weapon, rarity: Rarity.epic, magicBonus: 16, value: 250),
    // Offhand
    const Equipment(id: 'mythril_shield', name: 'Mythril Shield', slot: EquipmentSlot.offhand, rarity: Rarity.epic, defenseBonus: 12, hpBonus: 20, speedBonus: -2, value: 220),
    const Equipment(id: 'crystal_orb', name: 'Crystal Orb', slot: EquipmentSlot.offhand, rarity: Rarity.epic, magicBonus: 10, defenseBonus: 3, value: 220),
    // Armor
    const Equipment(id: 'mythril_armor', name: 'Mythril Armor', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 14, hpBonus: 40, speedBonus: -3, value: 300),
    const Equipment(id: 'starweave_robes', name: 'Starweave Robes', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 5, magicBonus: 9, hpBonus: 20, speedBonus: 1, value: 260),
    // Helm
    const Equipment(id: 'mythril_helm', name: 'Mythril Helm', slot: EquipmentSlot.helm, rarity: Rarity.epic, defenseBonus: 9, hpBonus: 20, value: 180),
    const Equipment(id: 'diadem_of_sight', name: 'Diadem of Sight', slot: EquipmentSlot.helm, rarity: Rarity.epic, magicBonus: 8, hpBonus: 10, speedBonus: 2, value: 180),
    // Ring
    const Equipment(id: 'diamond_ring', name: 'Diamond Ring', slot: EquipmentSlot.ring, rarity: Rarity.epic, attackBonus: 7, speedBonus: 3, value: 220),
    const Equipment(id: 'ring_of_the_archmage', name: 'Ring of the Archmage', slot: EquipmentSlot.ring, rarity: Rarity.epic, magicBonus: 10, value: 220),
    // Amulet
    const Equipment(id: 'phoenix_amulet', name: 'Phoenix Amulet', slot: EquipmentSlot.amulet, rarity: Rarity.epic, hpBonus: 70, defenseBonus: 3, value: 240),
    const Equipment(id: 'amulet_of_the_oracle', name: 'Amulet of the Oracle', slot: EquipmentSlot.amulet, rarity: Rarity.epic, magicBonus: 9, hpBonus: 35, value: 240),
  ],
  // === MAP 6: Epic Gear ===
  6: [
    // Weapons
    const Equipment(id: 'shadow_blade', name: 'Shadow Blade', slot: EquipmentSlot.weapon, rarity: Rarity.epic, attackBonus: 18, speedBonus: 2, defenseBonus: -2, value: 350),
    const Equipment(id: 'staff_of_the_cosmos', name: 'Staff of the Cosmos', slot: EquipmentSlot.weapon, rarity: Rarity.epic, magicBonus: 20, value: 350),
    // Offhand
    const Equipment(id: 'aegis', name: 'Aegis', slot: EquipmentSlot.offhand, rarity: Rarity.epic, defenseBonus: 15, hpBonus: 25, speedBonus: -3, value: 320),
    const Equipment(id: 'orb_of_eternity', name: 'Orb of Eternity', slot: EquipmentSlot.offhand, rarity: Rarity.epic, magicBonus: 12, defenseBonus: 4, value: 320),
    // Armor
    const Equipment(id: 'celestial_armor', name: 'Celestial Armor', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 17, hpBonus: 50, speedBonus: -3, value: 400),
    const Equipment(id: 'voidweave_robes', name: 'Voidweave Robes', slot: EquipmentSlot.armor, rarity: Rarity.epic, defenseBonus: 6, magicBonus: 11, hpBonus: 25, speedBonus: 2, value: 350),
    // Helm
    const Equipment(id: 'crown_of_stars', name: 'Crown of Stars', slot: EquipmentSlot.helm, rarity: Rarity.epic, defenseBonus: 11, hpBonus: 20, value: 280),
    const Equipment(id: 'hood_of_the_arcane', name: 'Hood of the Arcane', slot: EquipmentSlot.helm, rarity: Rarity.epic, magicBonus: 10, hpBonus: 15, speedBonus: 2, value: 280),
    // Ring
    const Equipment(id: 'void_ring', name: 'Void Ring', slot: EquipmentSlot.ring, rarity: Rarity.epic, attackBonus: 9, speedBonus: 3, value: 320),
    const Equipment(id: 'ring_of_the_eclipse', name: 'Ring of the Eclipse', slot: EquipmentSlot.ring, rarity: Rarity.epic, magicBonus: 12, value: 320),
    // Amulet
    const Equipment(id: 'amulet_of_ages', name: 'Amulet of Ages', slot: EquipmentSlot.amulet, rarity: Rarity.epic, hpBonus: 90, defenseBonus: 4, value: 340),
    const Equipment(id: 'pendant_of_ascension', name: 'Pendant of Ascension', slot: EquipmentSlot.amulet, rarity: Rarity.epic, magicBonus: 11, hpBonus: 40, value: 340),
  ],
  // === MAP 7: Legendary Gear ===
  7: [
    // Weapons
    const Equipment(id: 'legendary_sword', name: 'Excalibur', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, attackBonus: 24, speedBonus: 2, value: 500),
    const Equipment(id: 'staff_of_the_ancients', name: 'Staff of the Ancients', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, magicBonus: 26, value: 500),
    // Offhand
    const Equipment(id: 'legendary_shield', name: "Paladin's Bastion", slot: EquipmentSlot.offhand, rarity: Rarity.legendary, defenseBonus: 18, hpBonus: 40, speedBonus: -3, value: 480),
    const Equipment(id: 'tome_of_the_void', name: 'Tome of the Void', slot: EquipmentSlot.offhand, rarity: Rarity.legendary, magicBonus: 16, defenseBonus: 5, value: 480),
    // Armor
    const Equipment(id: 'legendary_armor', name: 'Armor of the Ancients', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 21, hpBonus: 70, speedBonus: -4, value: 550),
    const Equipment(id: 'robes_of_the_archmage', name: 'Robes of the Archmage', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 8, magicBonus: 14, hpBonus: 35, speedBonus: 2, value: 500),
    // Helm
    const Equipment(id: 'legendary_helm', name: 'Crown of Eternity', slot: EquipmentSlot.helm, rarity: Rarity.legendary, defenseBonus: 13, hpBonus: 30, value: 400),
    const Equipment(id: 'hood_of_prophecy', name: 'Hood of Prophecy', slot: EquipmentSlot.helm, rarity: Rarity.legendary, magicBonus: 13, hpBonus: 20, speedBonus: 3, value: 400),
    // Ring
    const Equipment(id: 'legendary_ring', name: 'Ring of Power', slot: EquipmentSlot.ring, rarity: Rarity.legendary, attackBonus: 12, speedBonus: 4, value: 450),
    const Equipment(id: 'ring_of_the_cosmos', name: 'Ring of the Cosmos', slot: EquipmentSlot.ring, rarity: Rarity.legendary, magicBonus: 17, value: 450),
    // Amulet
    const Equipment(id: 'legendary_amulet', name: 'Heart of the World', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, hpBonus: 110, defenseBonus: 5, value: 500),
    const Equipment(id: 'talisman_of_infinity', name: 'Talisman of Infinity', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, magicBonus: 14, hpBonus: 50, speedBonus: 2, value: 500),
  ],
  // === MAP 8: God-tier Gear ===
  8: [
    // Weapons
    const Equipment(id: 'godslayer', name: 'Godslayer', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, attackBonus: 30, speedBonus: 3, value: 800),
    const Equipment(id: 'staff_of_oblivion', name: 'Staff of Oblivion', slot: EquipmentSlot.weapon, rarity: Rarity.legendary, magicBonus: 32, value: 800),
    // Offhand
    const Equipment(id: 'divine_aegis', name: 'Divine Aegis', slot: EquipmentSlot.offhand, rarity: Rarity.legendary, defenseBonus: 22, hpBonus: 50, speedBonus: -3, value: 750),
    const Equipment(id: 'grimoire_of_creation', name: 'Grimoire of Creation', slot: EquipmentSlot.offhand, rarity: Rarity.legendary, magicBonus: 20, defenseBonus: 6, value: 750),
    // Armor
    const Equipment(id: 'god_armor', name: 'Armor of the Gods', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 26, hpBonus: 90, speedBonus: -4, value: 850),
    const Equipment(id: 'robes_of_transcendence', name: 'Robes of Transcendence', slot: EquipmentSlot.armor, rarity: Rarity.legendary, defenseBonus: 10, magicBonus: 18, hpBonus: 50, speedBonus: 3, value: 800),
    // Helm
    const Equipment(id: 'god_helm', name: 'Helm of Omniscience', slot: EquipmentSlot.helm, rarity: Rarity.legendary, defenseBonus: 16, hpBonus: 40, magicBonus: 4, value: 650),
    const Equipment(id: 'circlet_of_the_divine', name: 'Circlet of the Divine', slot: EquipmentSlot.helm, rarity: Rarity.legendary, magicBonus: 16, hpBonus: 25, speedBonus: 4, value: 650),
    // Ring
    const Equipment(id: 'god_ring', name: 'Ring of Destiny', slot: EquipmentSlot.ring, rarity: Rarity.legendary, attackBonus: 16, speedBonus: 5, value: 700),
    const Equipment(id: 'ring_of_the_infinite', name: 'Ring of the Infinite', slot: EquipmentSlot.ring, rarity: Rarity.legendary, magicBonus: 18, hpBonus: 20, value: 700),
    // Amulet
    const Equipment(id: 'god_amulet', name: 'Amulet of Infinity', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, hpBonus: 130, defenseBonus: 6, value: 750),
    const Equipment(id: 'pendant_of_the_gods', name: 'Pendant of the Gods', slot: EquipmentSlot.amulet, rarity: Rarity.legendary, magicBonus: 18, hpBonus: 60, value: 750),
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
