import '../models/ability.dart';
import '../models/enums.dart';

class EnemyTemplate {
  final String name;
  final String type;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int magic;
  final int xpReward;
  final int goldReward;
  final List<Ability> abilities;

  const EnemyTemplate({
    required this.name,
    required this.type,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.magic,
    required this.xpReward,
    required this.goldReward,
    required this.abilities,
  });
}

// Enemies scale per map tier. Each map uses enemies from its tier.
final Map<int, List<EnemyTemplate>> enemiesByMap = {
  1: [
    EnemyTemplate(name: 'Goblin', type: 'goblin', hp: 18, attack: 4, defense: 2, speed: 7, magic: 0, xpReward: 20, goldReward: 8,
      abilities: [Ability(name: 'Scratch', description: 'A clumsy scratch.', damage: 4, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Wolf', type: 'wolf', hp: 22, attack: 5, defense: 1, speed: 9, magic: 0, xpReward: 22, goldReward: 6,
      abilities: [Ability(name: 'Bite', description: 'A savage bite.', damage: 5, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Bandit', type: 'bandit', hp: 25, attack: 5, defense: 3, speed: 6, magic: 0, xpReward: 25, goldReward: 12,
      abilities: [Ability(name: 'Slash', description: 'A quick slash.', damage: 5, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  2: [
    EnemyTemplate(name: 'Skeleton', type: 'skeleton', hp: 30, attack: 6, defense: 4, speed: 6, magic: 1, xpReward: 30, goldReward: 10,
      abilities: [Ability(name: 'Bone Club', description: 'Whack with a bone.', damage: 6, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Orc Grunt', type: 'orc', hp: 38, attack: 8, defense: 5, speed: 5, magic: 0, xpReward: 35, goldReward: 14,
      abilities: [Ability(name: 'Smash', description: 'A brutal smash.', damage: 8, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Giant Spider', type: 'spider', hp: 28, attack: 7, defense: 3, speed: 8, magic: 0, xpReward: 32, goldReward: 10,
      abilities: [Ability(name: 'Venomous Bite', description: 'A poisonous bite.', damage: 7, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  3: [
    EnemyTemplate(name: 'Dark Mage', type: 'dark_mage', hp: 42, attack: 5, defense: 4, speed: 8, magic: 10, xpReward: 40, goldReward: 18,
      abilities: [Ability(name: 'Shadow Bolt', description: 'Dark magic strikes.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Ogre', type: 'ogre', hp: 65, attack: 11, defense: 7, speed: 3, magic: 0, xpReward: 45, goldReward: 20,
      abilities: [Ability(name: 'Club Slam', description: 'A massive club attack.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Harpy', type: 'harpy', hp: 38, attack: 9, defense: 4, speed: 11, magic: 4, xpReward: 38, goldReward: 15,
      abilities: [Ability(name: 'Talon Strike', description: 'Razor talons slash.', damage: 9, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  4: [
    EnemyTemplate(name: 'Troll', type: 'troll', hp: 100, attack: 16, defense: 10, speed: 4, magic: 0, xpReward: 55, goldReward: 25,
      abilities: [Ability(name: 'Rend', description: 'Tear flesh with claws.', damage: 16, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Wraith', type: 'wraith', hp: 60, attack: 8, defense: 3, speed: 11, magic: 16, xpReward: 58, goldReward: 22,
      abilities: [Ability(name: 'Life Drain', description: 'Drain the life force.', damage: 16, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Minotaur', type: 'minotaur', hp: 90, attack: 18, defense: 9, speed: 6, magic: 0, xpReward: 60, goldReward: 28,
      abilities: [Ability(name: 'Gore', description: 'Charge with horns.', damage: 18, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  5: [
    EnemyTemplate(name: 'Wyvern', type: 'wyvern', hp: 110, attack: 20, defense: 12, speed: 10, magic: 8, xpReward: 75, goldReward: 35,
      abilities: [Ability(name: 'Tail Lash', description: 'A whipping tail strike.', damage: 20, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Lich Acolyte', type: 'lich_acolyte', hp: 70, attack: 8, defense: 6, speed: 7, magic: 22, xpReward: 80, goldReward: 40,
      abilities: [Ability(name: 'Necrotic Blast', description: 'Death magic strikes.', damage: 22, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Golem', type: 'golem', hp: 140, attack: 16, defense: 18, speed: 2, magic: 0, xpReward: 70, goldReward: 30,
      abilities: [Ability(name: 'Stone Fist', description: 'A crushing stone punch.', damage: 16, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  6: [
    EnemyTemplate(name: 'Vampire', type: 'vampire', hp: 100, attack: 18, defense: 10, speed: 12, magic: 16, xpReward: 95, goldReward: 50,
      abilities: [Ability(name: 'Blood Drain', description: 'Drink your blood.', damage: 18, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Chimera', type: 'chimera', hp: 130, attack: 22, defense: 14, speed: 8, magic: 10, xpReward: 100, goldReward: 45,
      abilities: [Ability(name: 'Triple Strike', description: 'Three heads attack.', damage: 22, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Death Knight', type: 'death_knight', hp: 120, attack: 20, defense: 16, speed: 6, magic: 12, xpReward: 105, goldReward: 55,
      abilities: [Ability(name: 'Unholy Slash', description: 'A cursed blade strike.', damage: 20, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  7: [
    EnemyTemplate(name: 'Elder Dragon', type: 'elder_dragon', hp: 160, attack: 26, defense: 18, speed: 10, magic: 20, xpReward: 130, goldReward: 70,
      abilities: [Ability(name: 'Fire Breath', description: 'Breathe searing fire.', damage: 26, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Archdemon', type: 'archdemon', hp: 140, attack: 24, defense: 14, speed: 12, magic: 22, xpReward: 135, goldReward: 65,
      abilities: [Ability(name: 'Hellfire', description: 'Demonic fire engulfs you.', damage: 24, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Titan', type: 'titan', hp: 200, attack: 22, defense: 20, speed: 4, magic: 10, xpReward: 140, goldReward: 60,
      abilities: [Ability(name: 'Colossal Stomp', description: 'Shake the earth.', damage: 22, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
  8: [
    EnemyTemplate(name: 'Shadow Lord', type: 'shadow_lord', hp: 180, attack: 28, defense: 16, speed: 14, magic: 26, xpReward: 170, goldReward: 80,
      abilities: [Ability(name: 'Void Strike', description: 'Strike from the void.', damage: 28, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Ancient Wyrm', type: 'ancient_wyrm', hp: 220, attack: 30, defense: 22, speed: 8, magic: 18, xpReward: 180, goldReward: 90,
      abilities: [Ability(name: 'Cataclysm', description: 'Devastation incarnate.', damage: 30, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
    EnemyTemplate(name: 'Void Walker', type: 'void_walker', hp: 150, attack: 24, defense: 12, speed: 16, magic: 30, xpReward: 175, goldReward: 85,
      abilities: [Ability(name: 'Reality Tear', description: 'Tear the fabric of reality.', damage: 30, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true)]),
  ],
};

// Boss for each map
final Map<int, EnemyTemplate> bossByMap = {
  1: EnemyTemplate(name: 'Goblin King', type: 'boss', hp: 55, attack: 7, defense: 4, speed: 7, magic: 2, xpReward: 80, goldReward: 50,
    abilities: [
      Ability(name: 'Royal Slash', description: 'The king strikes!', damage: 7, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Call Minions', description: 'Summon goblins to help.', damage: 4, refreshChance: 50, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  2: EnemyTemplate(name: 'Bone Lord', type: 'boss', hp: 90, attack: 10, defense: 7, speed: 5, magic: 6, xpReward: 120, goldReward: 80,
    abilities: [
      Ability(name: 'Bone Crush', description: 'Crushing bones!', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Summon Skeletons', description: 'Raise the dead.', damage: 6, refreshChance: 45, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  3: EnemyTemplate(name: 'Shadow Witch', type: 'boss', hp: 120, attack: 8, defense: 6, speed: 10, magic: 16, xpReward: 160, goldReward: 110,
    abilities: [
      Ability(name: 'Dark Blast', description: 'Blasts of shadow magic.', damage: 16, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Curse All', description: 'Curse the entire party.', damage: 10, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  4: EnemyTemplate(name: 'Mountain Giant', type: 'boss', hp: 250, attack: 22, defense: 16, speed: 3, magic: 0, xpReward: 200, goldReward: 140,
    abilities: [
      Ability(name: 'Boulder Throw', description: 'Hurl a massive boulder.', damage: 22, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Earthquake', description: 'The ground shakes!', damage: 16, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  5: EnemyTemplate(name: 'Lich King', type: 'boss', hp: 200, attack: 14, defense: 12, speed: 8, magic: 30, xpReward: 250, goldReward: 180,
    abilities: [
      Ability(name: 'Death Ray', description: 'A beam of pure death.', damage: 30, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Mass Wither', description: 'Wither all life.', damage: 18, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  6: EnemyTemplate(name: 'Demon Prince', type: 'boss', hp: 280, attack: 26, defense: 18, speed: 10, magic: 24, xpReward: 300, goldReward: 220,
    abilities: [
      Ability(name: 'Infernal Blade', description: 'A sword of pure flame.', damage: 26, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Rain of Fire', description: 'Fire falls from above.', damage: 20, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  7: EnemyTemplate(name: 'Dragon Emperor', type: 'boss', hp: 350, attack: 32, defense: 22, speed: 12, magic: 28, xpReward: 400, goldReward: 300,
    abilities: [
      Ability(name: 'Dragon Fury', description: 'Unleash draconic power.', damage: 32, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Inferno', description: 'Engulf all in flame.', damage: 24, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  8: EnemyTemplate(name: 'The Dark One', type: 'boss', hp: 500, attack: 36, defense: 24, speed: 14, magic: 36, xpReward: 600, goldReward: 500,
    abilities: [
      Ability(name: 'Oblivion', description: 'Erase from existence.', damage: 36, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Apocalypse', description: 'End of all things.', damage: 28, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
      Ability(name: 'Dark Heal', description: 'Consume darkness to heal.', damage: -50, refreshChance: 30, targetType: AbilityTarget.self, unlockedAtLevel: 1),
    ]),
};

// Army soldiers - scales with current map (gentler at low maps)
List<EnemyTemplate> armySoldiers(int mapNumber) {
  // Softer early scaling: maps 1-2 use reduced multiplier
  final scale = mapNumber <= 2 ? mapNumber * 0.5 : mapNumber.toDouble();
  final s = scale.round();
  return [
    // Army Fighters (most common) - tanky melee
    EnemyTemplate(
      name: 'Army Fighter', type: 'bandit',
      hp: 25 + s * 12, attack: 5 + s * 3, defense: 4 + s * 2,
      speed: 5 + s, magic: 0,
      xpReward: 15 + s * 5, goldReward: 5 + s * 3,
      abilities: [
        Ability(name: 'Sword Slash', description: 'A disciplined slash.', damage: 5 + s * 3, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Shield Bash', description: 'Bash with a heavy shield.', damage: 3 + s * 2, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1),
      ],
    ),
    // Army Clerics - heal allies
    EnemyTemplate(
      name: 'Army Cleric', type: 'dark_mage',
      hp: 20 + s * 8, attack: 3 + s * 2, defense: 3 + s * 2,
      speed: 4 + s, magic: 4 + s * 3,
      xpReward: 18 + s * 5, goldReward: 8 + s * 3,
      abilities: [
        Ability(name: 'Mace Strike', description: 'A holy mace blow.', damage: 3 + s * 2, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Heal Ally', description: 'Heal a wounded soldier.', damage: -(6 + s * 3), refreshChance: 60, targetType: AbilityTarget.self, unlockedAtLevel: 1),
      ],
    ),
    // Army Wizards - high damage, low hp
    EnemyTemplate(
      name: 'Army Wizard', type: 'dark_mage',
      hp: 16 + s * 6, attack: 2 + s, defense: 2 + s,
      speed: 5 + s, magic: 5 + s * 4,
      xpReward: 20 + s * 6, goldReward: 10 + s * 4,
      abilities: [
        Ability(name: 'Fire Bolt', description: 'A bolt of fire.', damage: 5 + s * 4, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Arcane Blast', description: 'Blast all foes.', damage: 3 + s * 2, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
      ],
    ),
  ];
}
