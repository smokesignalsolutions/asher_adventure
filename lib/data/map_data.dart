import 'dart:math';
import '../models/enums.dart';

class StatModifier {
  final double atkPercent;
  final double magPercent;
  final double defPercent;
  final double spdPercent;
  const StatModifier({this.atkPercent = 0, this.magPercent = 0, this.defPercent = 0, this.spdPercent = 0});
}

class MapDefinition {
  final int id;
  final String name;
  final String category; // 'natural', 'dungeon', 'magical'
  final String imagePath;
  final String eventTheme;
  final String? secondaryEventTheme;
  final Map<CharacterClass, StatModifier> classModifiers;
  const MapDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.eventTheme,
    this.secondaryEventTheme,
    required this.classModifiers,
  });
}

/// Lookup a map definition by its ID (1-30).
MapDefinition getMapDefinition(int id) =>
    mapDefinitions.firstWhere((m) => m.id == id);

/// Pool categories for map selection.
const naturalMapIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22, 23];
const dungeonMapIds = [11, 12, 13, 14, 15, 24, 25, 26];
const magicalMapIds = [16, 17, 18, 19, 20, 27, 28, 29, 30];

/// Generate a pool of 8 unique map IDs for a run.
/// Slots 1-4: from natural/overworld pool.
/// Slots 5-8: from dungeon + magical pool.
List<int> generateMapPool([Random? rng]) {
  rng ??= Random();
  final natural = [...naturalMapIds]..shuffle(rng);
  final advanced = [...dungeonMapIds, ...magicalMapIds]..shuffle(rng);
  return [...natural.take(4), ...advanced.take(4)];
}

const List<MapDefinition> mapDefinitions = [
  // ── NATURAL / OVERWORLD ──────────────────────────────────────

  // 1: Forest
  MapDefinition(
    id: 1, name: 'Forest', category: 'natural',
    imagePath: 'assets/maps/01_forest.png',
    eventTheme: 'forest',
    classModifiers: {
      CharacterClass.druid: StatModifier(magPercent: 20, defPercent: 10),
      CharacterClass.ranger: StatModifier(atkPercent: 20, spdPercent: 10),
      CharacterClass.rogue: StatModifier(atkPercent: 15, spdPercent: 15),
      CharacterClass.wizard: StatModifier(magPercent: -15),
      CharacterClass.sorcerer: StatModifier(magPercent: -15),
      CharacterClass.artificer: StatModifier(atkPercent: -10, spdPercent: -10),
    },
  ),

  // 2: Desert
  MapDefinition(
    id: 2, name: 'Desert', category: 'natural',
    imagePath: 'assets/maps/02_desert.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.barbarian: StatModifier(atkPercent: 20, defPercent: 15),
      CharacterClass.monk: StatModifier(atkPercent: 15, spdPercent: 20),
      CharacterClass.ranger: StatModifier(atkPercent: 10),
      CharacterClass.paladin: StatModifier(spdPercent: -20, defPercent: -10),
      CharacterClass.templar: StatModifier(spdPercent: -15),
      CharacterClass.artificer: StatModifier(atkPercent: -20, spdPercent: -10),
    },
  ),

  // 3: Swamp
  MapDefinition(
    id: 3, name: 'Swamp', category: 'natural',
    imagePath: 'assets/maps/03_swamp.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.necromancer: StatModifier(magPercent: 20, defPercent: 10),
      CharacterClass.druid: StatModifier(magPercent: 15, defPercent: 10),
      CharacterClass.artificer: StatModifier(atkPercent: -20, spdPercent: -20),
      CharacterClass.paladin: StatModifier(magPercent: -15),
    },
  ),

  // 4: Tundra / Ice Plains
  MapDefinition(
    id: 4, name: 'Tundra', category: 'natural',
    imagePath: 'assets/maps/04_tundra.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.barbarian: StatModifier(atkPercent: 25, defPercent: 15),
      CharacterClass.monk: StatModifier(spdPercent: 15),
      CharacterClass.sorcerer: StatModifier(magPercent: -20),
      CharacterClass.druid: StatModifier(magPercent: -15),
      CharacterClass.paladin: StatModifier(spdPercent: -10),
    },
  ),

  // 5: Volcano / Lava Fields
  MapDefinition(
    id: 5, name: 'Volcano', category: 'natural',
    imagePath: 'assets/maps/05_volcano.png',
    eventTheme: 'arcane',
    classModifiers: {
      CharacterClass.sorcerer: StatModifier(magPercent: 25),
      CharacterClass.warlock: StatModifier(magPercent: 15),
      CharacterClass.druid: StatModifier(magPercent: -25),
      CharacterClass.ranger: StatModifier(atkPercent: -15, spdPercent: -10),
      CharacterClass.artificer: StatModifier(atkPercent: -15),
    },
  ),

  // 6: Mountain Pass
  MapDefinition(
    id: 6, name: 'Mountain Pass', category: 'natural',
    imagePath: 'assets/maps/06_mountain_pass.png',
    eventTheme: 'martial', secondaryEventTheme: 'holy',
    classModifiers: {
      CharacterClass.monk: StatModifier(atkPercent: 20, spdPercent: 15),
      CharacterClass.barbarian: StatModifier(atkPercent: 15, defPercent: 10),
      CharacterClass.ranger: StatModifier(atkPercent: 15),
      CharacterClass.summoner: StatModifier(magPercent: -15),
      CharacterClass.wizard: StatModifier(magPercent: -10),
    },
  ),

  // 7: Coastal Cliffs
  MapDefinition(
    id: 7, name: 'Coastal Cliffs', category: 'natural',
    imagePath: 'assets/maps/07_coastal_cliffs.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.ranger: StatModifier(atkPercent: 20),
      CharacterClass.rogue: StatModifier(atkPercent: 15, spdPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -25, defPercent: -15),
      CharacterClass.paladin: StatModifier(defPercent: -20),
      CharacterClass.templar: StatModifier(defPercent: -15),
    },
  ),

  // 8: Plains / Grasslands
  MapDefinition(
    id: 8, name: 'Plains', category: 'natural',
    imagePath: 'assets/maps/08_plains.png',
    eventTheme: 'martial', secondaryEventTheme: 'holy',
    classModifiers: {
      CharacterClass.paladin: StatModifier(atkPercent: 20, defPercent: 15),
      CharacterClass.fighter: StatModifier(atkPercent: 20, spdPercent: 10),
      CharacterClass.rogue: StatModifier(atkPercent: -25, spdPercent: -20),
      CharacterClass.necromancer: StatModifier(magPercent: -15),
    },
  ),

  // 9: Deep Jungle
  MapDefinition(
    id: 9, name: 'Deep Jungle', category: 'natural',
    imagePath: 'assets/maps/09_deep_jungle.png',
    eventTheme: 'forest',
    classModifiers: {
      CharacterClass.druid: StatModifier(magPercent: 25, defPercent: 15),
      CharacterClass.ranger: StatModifier(atkPercent: 20, spdPercent: 15),
      CharacterClass.rogue: StatModifier(atkPercent: 15, spdPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -25, spdPercent: -25),
      CharacterClass.spellsword: StatModifier(spdPercent: -15),
    },
  ),

  // 10: Cursed Wasteland
  MapDefinition(
    id: 10, name: 'Cursed Wasteland', category: 'natural',
    imagePath: 'assets/maps/10_cursed_wasteland.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.necromancer: StatModifier(magPercent: 30),
      CharacterClass.warlock: StatModifier(magPercent: 20),
      CharacterClass.cleric: StatModifier(magPercent: -25),
      CharacterClass.paladin: StatModifier(magPercent: -20),
    },
  ),

  // ── DUNGEON / UNDERGROUND ────────────────────────────────────

  // 11: Cave System
  MapDefinition(
    id: 11, name: 'Cave System', category: 'dungeon',
    imagePath: 'assets/maps/11_cave.png',
    eventTheme: 'martial',
    classModifiers: {
      CharacterClass.rogue: StatModifier(atkPercent: 25, spdPercent: 20),
      CharacterClass.ranger: StatModifier(atkPercent: 10, spdPercent: 10),
      CharacterClass.paladin: StatModifier(magPercent: -15),
      CharacterClass.templar: StatModifier(spdPercent: -15, atkPercent: -10),
    },
  ),

  // 12: Ancient Ruins
  MapDefinition(
    id: 12, name: 'Ancient Ruins', category: 'dungeon',
    imagePath: 'assets/maps/12_ancient_ruins.png',
    eventTheme: 'arcane',
    classModifiers: {
      CharacterClass.artificer: StatModifier(atkPercent: 20),
      CharacterClass.wizard: StatModifier(magPercent: 20),
      CharacterClass.barbarian: StatModifier(atkPercent: -20),
      CharacterClass.monk: StatModifier(atkPercent: -15),
    },
  ),

  // 13: Catacombs
  MapDefinition(
    id: 13, name: 'Catacombs', category: 'dungeon',
    imagePath: 'assets/maps/13_catacombs.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.necromancer: StatModifier(magPercent: 30, defPercent: 10),
      CharacterClass.cleric: StatModifier(magPercent: 20),
      CharacterClass.ranger: StatModifier(atkPercent: -20),
      CharacterClass.druid: StatModifier(magPercent: -25),
    },
  ),

  // 14: Underground Lake
  MapDefinition(
    id: 14, name: 'Underground Lake', category: 'dungeon',
    imagePath: 'assets/maps/14_underground_lake.png',
    eventTheme: 'martial',
    classModifiers: {
      CharacterClass.monk: StatModifier(spdPercent: 20, atkPercent: 15),
      CharacterClass.druid: StatModifier(magPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -30, spdPercent: -30),
      CharacterClass.paladin: StatModifier(atkPercent: -25, spdPercent: -25),
    },
  ),

  // 15: Goblin Warren
  MapDefinition(
    id: 15, name: 'Goblin Warren', category: 'dungeon',
    imagePath: 'assets/maps/15_goblin_warren.png',
    eventTheme: 'martial',
    classModifiers: {
      CharacterClass.rogue: StatModifier(atkPercent: 25, spdPercent: 15),
      CharacterClass.ranger: StatModifier(atkPercent: 10),
      CharacterClass.templar: StatModifier(spdPercent: -20, defPercent: -10),
      CharacterClass.paladin: StatModifier(spdPercent: -20),
    },
  ),

  // ── MAGICAL / SPECIAL ────────────────────────────────────────

  // 16: Shadow Realm
  MapDefinition(
    id: 16, name: 'Shadow Realm', category: 'magical',
    imagePath: 'assets/maps/16_shadow_realm.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.warlock: StatModifier(magPercent: 25, spdPercent: 10),
      CharacterClass.necromancer: StatModifier(magPercent: 20),
      CharacterClass.paladin: StatModifier(magPercent: -25),
      CharacterClass.cleric: StatModifier(magPercent: -20, defPercent: -10),
    },
  ),

  // 17: Enchanted Grove
  MapDefinition(
    id: 17, name: 'Enchanted Grove', category: 'magical',
    imagePath: 'assets/maps/17_enchanted_grove.png',
    eventTheme: 'forest', secondaryEventTheme: 'holy',
    classModifiers: {
      CharacterClass.druid: StatModifier(magPercent: 25, defPercent: 15),
      CharacterClass.summoner: StatModifier(magPercent: 20),
      CharacterClass.necromancer: StatModifier(magPercent: -25),
      CharacterClass.warlock: StatModifier(magPercent: -15),
    },
  ),

  // 18: Volcanic Demon Fortress
  MapDefinition(
    id: 18, name: 'Demon Fortress', category: 'magical',
    imagePath: 'assets/maps/18_demon_fortress.png',
    eventTheme: 'arcane',
    classModifiers: {
      CharacterClass.templar: StatModifier(atkPercent: 20, defPercent: 15),
      CharacterClass.fighter: StatModifier(atkPercent: 15),
      CharacterClass.druid: StatModifier(magPercent: -25),
      CharacterClass.ranger: StatModifier(atkPercent: -15, spdPercent: -15),
    },
  ),

  // 19: Floating Sky Islands
  MapDefinition(
    id: 19, name: 'Sky Islands', category: 'magical',
    imagePath: 'assets/maps/19_sky_islands.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.ranger: StatModifier(atkPercent: 20),
      CharacterClass.monk: StatModifier(spdPercent: 25, atkPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -25, spdPercent: -20),
      CharacterClass.barbarian: StatModifier(atkPercent: -20, spdPercent: -15),
    },
  ),

  // 20: The Void
  MapDefinition(
    id: 20, name: 'The Void', category: 'magical',
    imagePath: 'assets/maps/20_the_void.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.warlock: StatModifier(magPercent: 30, spdPercent: 10),
      CharacterClass.summoner: StatModifier(magPercent: 20),
      CharacterClass.barbarian: StatModifier(atkPercent: -25),
      CharacterClass.fighter: StatModifier(atkPercent: -20, spdPercent: -15),
    },
  ),

  // ── MORE NATURAL / OVERWORLD ─────────────────────────────────

  // 21: Badlands
  MapDefinition(
    id: 21, name: 'Badlands', category: 'natural',
    imagePath: 'assets/maps/21_badlands.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.barbarian: StatModifier(atkPercent: 20, defPercent: 10),
      CharacterClass.ranger: StatModifier(atkPercent: 15, spdPercent: 10),
      CharacterClass.wizard: StatModifier(magPercent: -15),
      CharacterClass.sorcerer: StatModifier(magPercent: -15),
    },
  ),

  // 22: Mushroom Forest
  MapDefinition(
    id: 22, name: 'Mushroom Forest', category: 'natural',
    imagePath: 'assets/maps/22_mushroom_forest.png',
    eventTheme: 'forest',
    classModifiers: {
      CharacterClass.druid: StatModifier(magPercent: 20, defPercent: 15),
      CharacterClass.cleric: StatModifier(defPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -15, spdPercent: -10),
      CharacterClass.sorcerer: StatModifier(magPercent: -10),
    },
  ),

  // 23: Sunken Marsh
  MapDefinition(
    id: 23, name: 'Sunken Marsh', category: 'natural',
    imagePath: 'assets/maps/23_sunken_marsh.png',
    eventTheme: 'wild',
    classModifiers: {
      CharacterClass.necromancer: StatModifier(magPercent: 15, defPercent: 10),
      CharacterClass.druid: StatModifier(magPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: -25, spdPercent: -25),
      CharacterClass.paladin: StatModifier(atkPercent: -25, spdPercent: -20),
    },
  ),

  // ── MORE DUNGEON / UNDERGROUND ───────────────────────────────

  // 24: Crystal Caverns
  MapDefinition(
    id: 24, name: 'Crystal Caverns', category: 'dungeon',
    imagePath: 'assets/maps/24_crystal_caverns.png',
    eventTheme: 'arcane',
    classModifiers: {
      CharacterClass.wizard: StatModifier(magPercent: 25),
      CharacterClass.sorcerer: StatModifier(magPercent: 20),
      CharacterClass.barbarian: StatModifier(atkPercent: -25),
      CharacterClass.monk: StatModifier(atkPercent: -15),
    },
  ),

  // 25: Haunted Graveyard
  MapDefinition(
    id: 25, name: 'Haunted Graveyard', category: 'dungeon',
    imagePath: 'assets/maps/25_haunted_graveyard.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.necromancer: StatModifier(magPercent: 30, defPercent: 15),
      CharacterClass.cleric: StatModifier(magPercent: 25),
      CharacterClass.ranger: StatModifier(atkPercent: -20),
      CharacterClass.druid: StatModifier(magPercent: -20),
    },
  ),

  // 26: Abandoned Mine
  MapDefinition(
    id: 26, name: 'Abandoned Mine', category: 'dungeon',
    imagePath: 'assets/maps/26_abandoned_mine.png',
    eventTheme: 'martial',
    classModifiers: {
      CharacterClass.rogue: StatModifier(atkPercent: 20, spdPercent: 15),
      CharacterClass.artificer: StatModifier(atkPercent: 15),
      CharacterClass.druid: StatModifier(magPercent: -20),
      CharacterClass.ranger: StatModifier(atkPercent: -15),
    },
  ),

  // ── MORE MAGICAL / SPECIAL ───────────────────────────────────

  // 27: Pirate Cove
  MapDefinition(
    id: 27, name: 'Pirate Cove', category: 'magical',
    imagePath: 'assets/maps/27_pirate_cove.png',
    eventTheme: 'dark',
    classModifiers: {
      CharacterClass.rogue: StatModifier(atkPercent: 20, spdPercent: 20),
      CharacterClass.ranger: StatModifier(atkPercent: 15),
      CharacterClass.paladin: StatModifier(atkPercent: -15),
      CharacterClass.artificer: StatModifier(atkPercent: -15, defPercent: -10),
    },
  ),

  // 28: Arcane Tower
  MapDefinition(
    id: 28, name: 'Arcane Tower', category: 'magical',
    imagePath: 'assets/maps/28_arcane_tower.png',
    eventTheme: 'arcane',
    classModifiers: {
      CharacterClass.wizard: StatModifier(magPercent: 25),
      CharacterClass.sorcerer: StatModifier(magPercent: 20),
      CharacterClass.artificer: StatModifier(atkPercent: 15),
      CharacterClass.barbarian: StatModifier(atkPercent: -25),
      CharacterClass.monk: StatModifier(atkPercent: -15, spdPercent: -10),
    },
  ),

  // 29: Gladiator Arena
  MapDefinition(
    id: 29, name: 'Gladiator Arena', category: 'magical',
    imagePath: 'assets/maps/29_gladiator_arena.png',
    eventTheme: 'martial',
    classModifiers: {
      CharacterClass.fighter: StatModifier(atkPercent: 25, spdPercent: 10),
      CharacterClass.monk: StatModifier(atkPercent: 20, spdPercent: 20),
      CharacterClass.summoner: StatModifier(magPercent: -20),
      CharacterClass.necromancer: StatModifier(magPercent: -20),
    },
  ),

  // 30: Frozen Citadel
  MapDefinition(
    id: 30, name: 'Frozen Citadel', category: 'magical',
    imagePath: 'assets/maps/30_frozen_citadel.png',
    eventTheme: 'martial', secondaryEventTheme: 'holy',
    classModifiers: {
      CharacterClass.barbarian: StatModifier(atkPercent: 25, defPercent: 20),
      CharacterClass.templar: StatModifier(defPercent: 15, atkPercent: 10),
      CharacterClass.sorcerer: StatModifier(magPercent: -20),
      CharacterClass.druid: StatModifier(magPercent: -25),
    },
  ),
];
