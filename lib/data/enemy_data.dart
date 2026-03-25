import '../models/ability.dart';
import '../models/enums.dart';
import '../models/status_effect.dart';

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
    EnemyTemplate(name: 'Goblin', type: 'goblin', hp: 30, attack: 6, defense: 2, speed: 7, magic: 0, xpReward: 20, goldReward: 8,
      abilities: [
        Ability(name: 'Scratch', description: 'A clumsy scratch.', damage: 6, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Dirty Throw', description: 'Throws dirt in your eyes.', damage: 3, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.blinded, duration: 1, magnitude: 40)]),
      ]),
    EnemyTemplate(name: 'Wolf', type: 'wolf', hp: 36, attack: 8, defense: 1, speed: 9, magic: 0, xpReward: 22, goldReward: 6,
      abilities: [
        Ability(name: 'Bite', description: 'A savage bite.', damage: 8, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Trip', description: 'Lunges at your legs.', damage: 4, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1)]),
      ]),
    EnemyTemplate(name: 'Bandit', type: 'bandit', hp: 40, attack: 8, defense: 3, speed: 6, magic: 0, xpReward: 25, goldReward: 12,
      abilities: [
        Ability(name: 'Slash', description: 'A quick slash.', damage: 8, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Low Blow', description: 'A dirty fighting move.', damage: 4, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)]),
      ]),
  ],
  2: [
    EnemyTemplate(name: 'Skeleton', type: 'skeleton', hp: 50, attack: 10, defense: 4, speed: 6, magic: 2, xpReward: 30, goldReward: 10,
      abilities: [
        Ability(name: 'Bone Club', description: 'Whack with a bone.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Bone Rattle', description: 'An unnerving clatter.', damage: 5, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.silenced, duration: 2)]),
      ]),
    EnemyTemplate(name: 'Orc Grunt', type: 'orc', hp: 64, attack: 14, defense: 5, speed: 5, magic: 0, xpReward: 35, goldReward: 14,
      abilities: [
        Ability(name: 'Smash', description: 'A brutal smash.', damage: 14, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'War Stomp', description: 'Shakes the ground.', damage: 7, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)]),
      ]),
    EnemyTemplate(name: 'Giant Spider', type: 'spider', hp: 48, attack: 12, defense: 3, speed: 8, magic: 0, xpReward: 32, goldReward: 10,
      abilities: [
        Ability(name: 'Venomous Bite', description: 'A poisonous bite.', damage: 12, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Web Shot', description: 'Cocooned in webbing.', damage: 6, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)]),
      ]),
  ],
  3: [
    EnemyTemplate(name: 'Dark Mage', type: 'dark_mage', hp: 84, attack: 10, defense: 4, speed: 8, magic: 20, xpReward: 40, goldReward: 18,
      abilities: [
        Ability(name: 'Shadow Bolt', description: 'Dark magic strikes.', damage: 20, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Hex Bolt', description: 'Dark magic dampens healing.', damage: 10, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.cursed, duration: 2)]),
      ]),
    EnemyTemplate(name: 'Ogre', type: 'ogre', hp: 130, attack: 22, defense: 7, speed: 3, magic: 0, xpReward: 45, goldReward: 20,
      abilities: [
        Ability(name: 'Club Slam', description: 'A massive club attack.', damage: 22, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Ground Pound', description: 'Shakes the earth.', damage: 11, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1)]),
      ]),
    EnemyTemplate(name: 'Harpy', type: 'harpy', hp: 76, attack: 18, defense: 4, speed: 11, magic: 8, xpReward: 38, goldReward: 15,
      abilities: [
        Ability(name: 'Talon Strike', description: 'Razor talons slash.', damage: 18, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Shriek', description: 'Ear-piercing scream.', damage: 9, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.silenced, duration: 2)]),
      ]),
  ],
  4: [
    EnemyTemplate(name: 'Troll', type: 'troll', hp: 200, attack: 32, defense: 10, speed: 4, magic: 0, xpReward: 55, goldReward: 25,
      abilities: [
        Ability(name: 'Rend', description: 'Tear flesh with claws.', damage: 32, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Savage Tear', description: 'Ripping claws.', damage: 16, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: 14)]),
      ]),
    EnemyTemplate(name: 'Wraith', type: 'wraith', hp: 120, attack: 16, defense: 3, speed: 11, magic: 32, xpReward: 58, goldReward: 22,
      abilities: [
        Ability(name: 'Life Drain', description: 'Drain the life force.', damage: 32, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Soul Chill', description: 'Drains vitality.', damage: 16, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30), AppliedEffect(type: StatusEffectType.weakened, duration: 1, magnitude: 25)]),
      ]),
    EnemyTemplate(name: 'Minotaur', type: 'minotaur', hp: 180, attack: 36, defense: 9, speed: 6, magic: 0, xpReward: 60, goldReward: 28,
      abilities: [
        Ability(name: 'Gore', description: 'Charge with horns.', damage: 36, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Gore Charge', description: 'Charges horns-first.', damage: 18, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1, chance: 60), AppliedEffect(type: StatusEffectType.bleeding, duration: 1, magnitude: 14, chance: 80)]),
      ]),
  ],
  5: [
    EnemyTemplate(name: 'Wyvern', type: 'wyvern', hp: 220, attack: 40, defense: 12, speed: 10, magic: 16, xpReward: 75, goldReward: 35,
      abilities: [
        Ability(name: 'Tail Lash', description: 'A whipping tail strike.', damage: 40, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Poison Barb', description: 'Venomous tail stinger.', damage: 20, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.poisoned, duration: 3, magnitude: 17)]),
      ]),
    EnemyTemplate(name: 'Lich Acolyte', type: 'lich_acolyte', hp: 140, attack: 16, defense: 6, speed: 7, magic: 44, xpReward: 80, goldReward: 40,
      abilities: [
        Ability(name: 'Necrotic Blast', description: 'Death magic strikes.', damage: 44, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Withering Curse', description: 'Necrotic magic.', damage: 22, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.cursed, duration: 2), AppliedEffect(type: StatusEffectType.weakened, duration: 1, magnitude: 25)]),
      ]),
    EnemyTemplate(name: 'Golem', type: 'golem', hp: 280, attack: 32, defense: 18, speed: 2, magic: 0, xpReward: 70, goldReward: 30,
      abilities: [
        Ability(name: 'Stone Fist', description: 'A crushing stone punch.', damage: 32, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Crushing Slam', description: 'Sheer force cracks armor.', damage: 16, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1), AppliedEffect(type: StatusEffectType.exposed, duration: 1, magnitude: 30)]),
      ]),
  ],
  6: [
    EnemyTemplate(name: 'Vampire', type: 'vampire', hp: 200, attack: 36, defense: 10, speed: 12, magic: 32, xpReward: 95, goldReward: 50,
      abilities: [
        Ability(name: 'Blood Drain', description: 'Drink your blood.', damage: 36, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Mesmerize', description: 'Hypnotic gaze.', damage: 18, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1), AppliedEffect(type: StatusEffectType.cursed, duration: 1)]),
      ]),
    EnemyTemplate(name: 'Chimera', type: 'chimera', hp: 260, attack: 44, defense: 14, speed: 8, magic: 20, xpReward: 100, goldReward: 45,
      abilities: [
        Ability(name: 'Triple Strike', description: 'Three heads attack.', damage: 44, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Venomous Bite', description: 'Fire and snake heads.', damage: 22, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.poisoned, duration: 2, magnitude: 20), AppliedEffect(type: StatusEffectType.burning, duration: 1, magnitude: 20)]),
      ]),
    EnemyTemplate(name: 'Death Knight', type: 'death_knight', hp: 240, attack: 40, defense: 16, speed: 6, magic: 24, xpReward: 105, goldReward: 55,
      abilities: [
        Ability(name: 'Unholy Slash', description: 'A cursed blade strike.', damage: 40, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Cursed Blade', description: 'Unholy wound.', damage: 20, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: 20), AppliedEffect(type: StatusEffectType.cursed, duration: 1)]),
      ]),
  ],
  7: [
    EnemyTemplate(name: 'Elder Dragon', type: 'elder_dragon', hp: 320, attack: 52, defense: 18, speed: 10, magic: 40, xpReward: 130, goldReward: 70,
      abilities: [
        Ability(name: 'Fire Breath', description: 'Breathe searing fire.', damage: 52, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Immolate', description: 'Melts armor with flame.', damage: 26, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.burning, duration: 3, magnitude: 23), AppliedEffect(type: StatusEffectType.exposed, duration: 1, magnitude: 30)]),
      ]),
    EnemyTemplate(name: 'Archdemon', type: 'archdemon', hp: 280, attack: 48, defense: 14, speed: 12, magic: 44, xpReward: 135, goldReward: 65,
      abilities: [
        Ability(name: 'Hellfire', description: 'Demonic fire engulfs you.', damage: 48, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Abyssal Chains', description: 'Demonic binding.', damage: 24, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30), AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)]),
      ]),
    EnemyTemplate(name: 'Titan', type: 'titan', hp: 400, attack: 44, defense: 20, speed: 4, magic: 20, xpReward: 140, goldReward: 60,
      abilities: [
        Ability(name: 'Colossal Stomp', description: 'Shake the earth.', damage: 44, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Earthshatter', description: 'Ground-breaking stomp.', damage: 22, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1), AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)]),
      ]),
  ],
  8: [
    EnemyTemplate(name: 'Shadow Lord', type: 'shadow_lord', hp: 360, attack: 56, defense: 16, speed: 14, magic: 52, xpReward: 170, goldReward: 80,
      abilities: [
        Ability(name: 'Void Strike', description: 'Strike from the void.', damage: 56, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Void Grip', description: 'Consumed by void.', damage: 28, refreshChance: 40, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.silenced, duration: 2), AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)]),
      ]),
    EnemyTemplate(name: 'Ancient Wyrm', type: 'ancient_wyrm', hp: 440, attack: 60, defense: 22, speed: 8, magic: 36, xpReward: 180, goldReward: 90,
      abilities: [
        Ability(name: 'Cataclysm', description: 'Devastation incarnate.', damage: 60, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Cataclysmic Roar', description: 'Shattering sound.', damage: 30, refreshChance: 40, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.exposed, duration: 2, magnitude: 30), AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)]),
      ]),
    EnemyTemplate(name: 'Void Walker', type: 'void_walker', hp: 300, attack: 48, defense: 12, speed: 16, magic: 60, xpReward: 175, goldReward: 85,
      abilities: [
        Ability(name: 'Reality Tear', description: 'Tear the fabric of reality.', damage: 60, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Phase Strike', description: 'Reality distortion.', damage: 30, refreshChance: 40, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40), AppliedEffect(type: StatusEffectType.cursed, duration: 2)]),
      ]),
  ],
};

// Boss for each map
final Map<int, EnemyTemplate> bossByMap = {
  1: EnemyTemplate(name: 'Goblin King', type: 'boss', hp: 90, attack: 14, defense: 4, speed: 7, magic: 4, xpReward: 80, goldReward: 50,
    abilities: [
      Ability(name: 'Royal Slash', description: 'The king strikes!', damage: 14, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Call Minions', description: 'Summon goblins to help.', damage: 8, refreshChance: 50, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.slowed, duration: 1, magnitude: 30)]),
    ]),
  2: EnemyTemplate(name: 'Bone Lord', type: 'boss', hp: 160, attack: 20, defense: 7, speed: 5, magic: 12, xpReward: 120, goldReward: 80,
    abilities: [
      Ability(name: 'Bone Crush', description: 'Crushing bones!', damage: 20, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.exposed, duration: 2, magnitude: 30)]),
      Ability(name: 'Summon Skeletons', description: 'Raise the dead.', damage: 12, refreshChance: 45, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1),
    ]),
  3: EnemyTemplate(name: 'Shadow Witch', type: 'boss', hp: 240, attack: 16, defense: 6, speed: 10, magic: 32, xpReward: 160, goldReward: 110,
    abilities: [
      Ability(name: 'Dark Blast', description: 'Blasts of shadow magic.', damage: 32, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Curse All', description: 'Curse the entire party.', damage: 20, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.cursed, duration: 2)]),
    ]),
  4: EnemyTemplate(name: 'Mountain Giant', type: 'boss', hp: 500, attack: 44, defense: 16, speed: 3, magic: 0, xpReward: 200, goldReward: 140,
    abilities: [
      Ability(name: 'Boulder Throw', description: 'Hurl a massive boulder.', damage: 44, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Earthquake', description: 'The ground shakes!', damage: 32, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)]),
    ]),
  5: EnemyTemplate(name: 'Lich King', type: 'boss', hp: 400, attack: 28, defense: 12, speed: 8, magic: 60, xpReward: 250, goldReward: 180,
    abilities: [
      Ability(name: 'Death Ray', description: 'A beam of pure death.', damage: 60, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Mass Wither', description: 'Wither all life.', damage: 36, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.cursed, duration: 3)]),
    ]),
  6: EnemyTemplate(name: 'Demon Prince', type: 'boss', hp: 560, attack: 52, defense: 18, speed: 10, magic: 48, xpReward: 300, goldReward: 220,
    abilities: [
      Ability(name: 'Infernal Blade', description: 'A sword of pure flame.', damage: 52, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Rain of Fire', description: 'Fire falls from above.', damage: 40, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: 20)]),
    ]),
  7: EnemyTemplate(name: 'Dragon Emperor', type: 'boss', hp: 700, attack: 64, defense: 22, speed: 12, magic: 56, xpReward: 400, goldReward: 300,
    abilities: [
      Ability(name: 'Dragon Fury', description: 'Unleash draconic power.', damage: 64, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Inferno', description: 'Engulf all in flame.', damage: 48, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.burning, duration: 3, magnitude: 23)]),
    ]),
  8: EnemyTemplate(name: 'The Dark One', type: 'boss', hp: 1000, attack: 72, defense: 24, speed: 14, magic: 72, xpReward: 600, goldReward: 500,
    abilities: [
      Ability(name: 'Oblivion', description: 'Erase from existence.', damage: 72, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Apocalypse', description: 'End of all things.', damage: 56, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.cursed, duration: 2), AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: 26)]),
      Ability(name: 'Dark Heal', description: 'Consume darkness to heal.', damage: -100, refreshChance: 30, targetType: AbilityTarget.self, unlockedAtLevel: 1),
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
      hp: 50 + s * 24, attack: 10 + s * 6, defense: 4 + s * 2,
      speed: 5 + s, magic: 0,
      xpReward: 15 + s * 5, goldReward: 5 + s * 3,
      abilities: [
        Ability(name: 'Sword Slash', description: 'A disciplined slash.', damage: 10 + s * 6, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Shield Bash', description: 'Bash with a heavy shield.', damage: 6 + s * 4, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.stunned, duration: 1)]),
      ],
    ),
    // Army Clerics - heal allies
    EnemyTemplate(
      name: 'Army Cleric', type: 'dark_mage',
      hp: 40 + s * 16, attack: 6 + s * 4, defense: 3 + s * 2,
      speed: 4 + s, magic: 8 + s * 6,
      xpReward: 18 + s * 5, goldReward: 8 + s * 3,
      abilities: [
        Ability(name: 'Mace Strike', description: 'A holy mace blow.', damage: 6 + s * 4, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Heal Ally', description: 'Heal a wounded soldier.', damage: -(12 + s * 6), refreshChance: 60, targetType: AbilityTarget.self, unlockedAtLevel: 1),
        Ability(name: 'Holy Smite', description: 'Divine judgment.', damage: 4 + s * 3, refreshChance: 40, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.silenced, duration: 2)]),
      ],
    ),
    // Army Wizards - high damage, low hp
    EnemyTemplate(
      name: 'Army Wizard', type: 'dark_mage',
      hp: 32 + s * 12, attack: 4 + s * 2, defense: 2 + s,
      speed: 5 + s, magic: 10 + s * 8,
      xpReward: 20 + s * 6, goldReward: 10 + s * 4,
      abilities: [
        Ability(name: 'Fire Bolt', description: 'A bolt of fire.', damage: 10 + s * 8, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
        Ability(name: 'Arcane Blast', description: 'Blast all foes.', damage: 6 + s * 4, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 1, appliesStatusEffects: [AppliedEffect(type: StatusEffectType.burning, duration: 1, magnitude: s * 3 + 2)]),
      ],
    ),
  ];
}

/// Helper to create a custom enemy scaled to 120% of tier average stats.
EnemyTemplate _customEnemy(String name, String type, int tier,
    List<AppliedEffect> specialEffects, String specialName, String specialDesc,
    {AbilityTarget specialTarget = AbilityTarget.singleEnemy, int specialRefresh = 50}) {
  final templates = enemiesByMap[tier] ?? enemiesByMap[1]!;
  final avgHp = (templates.fold(0, (sum, t) => sum + t.hp) / templates.length * 1.2).round();
  final avgAtk = (templates.fold(0, (sum, t) => sum + t.attack) / templates.length * 1.2).round();
  final avgDef = (templates.fold(0, (sum, t) => sum + t.defense) / templates.length * 1.2).round();
  final avgSpd = (templates.fold(0, (sum, t) => sum + t.speed) / templates.length * 1.2).round();
  final avgMag = (templates.fold(0, (sum, t) => sum + t.magic) / templates.length * 1.2).round();
  final avgXp = (templates.fold(0, (sum, t) => sum + t.xpReward) / templates.length * 1.15).round();
  final avgGold = (templates.fold(0, (sum, t) => sum + t.goldReward) / templates.length * 1.15).round();
  final specialDmg = (avgAtk * 0.55).round();

  return EnemyTemplate(
    name: name, type: type,
    hp: avgHp, attack: avgAtk, defense: avgDef, speed: avgSpd, magic: avgMag,
    xpReward: avgXp, goldReward: avgGold,
    abilities: [
      Ability(name: 'Attack', description: 'A basic attack.', damage: avgAtk,
        refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: specialName, description: specialDesc, damage: specialDmg,
        refreshChance: specialRefresh, targetType: specialTarget, unlockedAtLevel: 1,
        appliesStatusEffects: specialEffects),
    ],
  );
}

/// Custom map enemies: 2 per map definition.
/// Key = map definition ID, Value = list of 2 factory functions (tier -> EnemyTemplate).
typedef CustomEnemyFactory = EnemyTemplate Function(int tier);

final Map<int, List<CustomEnemyFactory>> customEnemiesByMap = {
  // === Natural/Overworld Maps ===
  // 1: Forest
  1: [
    (tier) => _customEnemy('Thornbear', 'thornbear', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Thorn Maul', 'Bramble-covered claws rend flesh.'),
    (tier) => _customEnemy('Woodland Stalker', 'woodland_stalker', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)],
      'Snare Shot', 'A well-aimed snare.'),
  ],
  // 2: Desert
  2: [
    (tier) => _customEnemy('Sand Wurm', 'sand_wurm', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40)],
      'Sandblast', 'A blinding spray of sand.'),
    (tier) => _customEnemy('Dust Wraith', 'dust_wraith', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Scorching Touch', 'Desert heat burns.'),
  ],
  // 3: Swamp
  3: [
    (tier) => _customEnemy('Bog Zombie', 'bog_zombie', tier,
      [AppliedEffect(type: StatusEffectType.poisoned, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Toxic Grasp', 'Waterlogged claws drip poison.'),
    (tier) => _customEnemy('Swamp Hag', 'swamp_hag', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 3)],
      'Hex', 'A twisted swamp curse.'),
  ],
  // 4: Tundra
  4: [
    (tier) => _customEnemy('Frost Stalker', 'frost_stalker', tier,
      [AppliedEffect(type: StatusEffectType.frozen, duration: 1, magnitude: 30)],
      'Flash Freeze', 'Ice-cold strike freezes.'),
    (tier) => _customEnemy('Snow Wraith', 'snow_wraith', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 3, magnitude: 30)],
      'Chilling Wind', 'A bone-chilling gust.'),
  ],
  // 5: Volcano
  5: [
    (tier) => _customEnemy('Magma Golem', 'magma_golem', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Eruption', 'Molten rock erupts.'),
    (tier) => _customEnemy('Ember Imp', 'ember_imp', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Flame Burst', 'Fire engulfs all.', specialTarget: AbilityTarget.allEnemies),
  ],
  // 6: Mountain Pass
  6: [
    (tier) => _customEnemy('Rock Troll', 'rock_troll', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1)],
      'Boulder Slam', 'A crushing boulder strike.'),
    (tier) => _customEnemy('Mountain Eagle', 'mountain_eagle', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Diving Talon', 'Razor talons from above.'),
  ],
  // 7: Coastal Cliffs
  7: [
    (tier) => _customEnemy('Sea Serpent', 'sea_serpent', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)],
      'Constrict', 'Coils tighten around you.'),
    (tier) => _customEnemy('Siren', 'siren', tier,
      [AppliedEffect(type: StatusEffectType.silenced, duration: 2)],
      'Siren Song', 'Enchanted melody silences.'),
  ],
  // 8: Plains
  8: [
    (tier) => _customEnemy('War Centaur', 'war_centaur', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1)],
      'Trample', 'Thundering hooves.'),
    (tier) => _customEnemy('Prairie Stalker', 'prairie_stalker', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)],
      'Hamstring', 'Crippling bite to the legs.'),
  ],
  // 9: Deep Jungle
  9: [
    (tier) => _customEnemy('Venomspitter', 'venomspitter', tier,
      [AppliedEffect(type: StatusEffectType.poisoned, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Venom Spray', 'Toxic spray from fangs.'),
    (tier) => _customEnemy('Canopy Spider', 'canopy_spider', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)],
      'Web Shot', 'Sticky web restricts movement.'),
  ],
  // 10: Cursed Wasteland
  10: [
    (tier) => _customEnemy('Blight Walker', 'blight_walker', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 3)],
      'Corrupting Touch', 'Corruption spreads.'),
    (tier) => _customEnemy('Ash Phantom', 'ash_phantom', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40)],
      'Ashen Veil', 'Ash clouds obscure vision.'),
  ],
  // 21: Badlands
  21: [
    (tier) => _customEnemy('Dust Devil', 'dust_devil', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40)],
      'Sand Cyclone', 'Whirling sand blinds.'),
    (tier) => _customEnemy('Scorpion Brute', 'scorpion_brute', tier,
      [AppliedEffect(type: StatusEffectType.poisoned, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Venomous Sting', 'Armored tail strikes.'),
  ],
  // 22: Mushroom Forest
  22: [
    (tier) => _customEnemy('Spore Beast', 'spore_beast', tier,
      [AppliedEffect(type: StatusEffectType.poisoned, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Spore Cloud', 'Toxic spores fill the air.', specialTarget: AbilityTarget.allEnemies),
    (tier) => _customEnemy('Myconid Guardian', 'myconid_guardian', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)],
      'Fungal Slam', 'Heavy fungal fists.'),
  ],
  // 23: Sunken Marsh
  23: [
    (tier) => _customEnemy('Marsh Lurker', 'marsh_lurker', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Death Roll', 'Crocodilian ambush.'),
    (tier) => _customEnemy('Will-o-Wisp', 'will_o_wisp', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40)],
      'Bewildering Glow', 'Deceptive light dazzles.'),
  ],

  // === Dungeon/Underground Maps ===
  // 11: Cave System
  11: [
    (tier) => _customEnemy('Cave Troll', 'cave_troll', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25)],
      'Crushing Grip', 'Blind but powerful grip.'),
    (tier) => _customEnemy('Crystal Bat', 'crystal_bat', tier,
      [AppliedEffect(type: StatusEffectType.silenced, duration: 2)],
      'Sonic Screech', 'Razor-winged screech.'),
  ],
  // 12: Ancient Ruins
  12: [
    (tier) => _customEnemy('Animated Guardian', 'animated_guardian', tier,
      [AppliedEffect(type: StatusEffectType.frozen, duration: 1, magnitude: 30)],
      'Petrifying Strike', 'Stone fist freezes.'),
    (tier) => _customEnemy('Rune Wraith', 'rune_wraith', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: StatusDefaults.dotDamage(tier)),
       AppliedEffect(type: StatusEffectType.silenced, duration: 1)],
      'Rune Burn', 'Ancient runes sear flesh.'),
  ],
  // 13: Catacombs
  13: [
    (tier) => _customEnemy('Crypt Stalker', 'crypt_stalker', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 2)],
      'Gravetouched Claws', 'Death-tainted claws.'),
    (tier) => _customEnemy('Bone Colossus', 'bone_colossus', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Bone Shrapnel', 'Exploding bone fragments.'),
  ],
  // 14: Underground Lake
  14: [
    (tier) => _customEnemy('Deep Angler', 'deep_angler', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1)],
      'Lure Snap', 'Bioluminescent ambush.'),
    (tier) => _customEnemy('Lake Serpent', 'lake_serpent', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 3, magnitude: 25)],
      'Tidal Coil', 'Aquatic constriction.'),
  ],
  // 15: Goblin Warren
  15: [
    (tier) => _customEnemy('Goblin Alchemist', 'goblin_alchemist', tier,
      [AppliedEffect(type: StatusEffectType.exposed, duration: 3, magnitude: 30)],
      'Acid Flask', 'Corrosive potion.'),
    (tier) => _customEnemy('Goblin Trapper', 'goblin_trapper', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30),
       AppliedEffect(type: StatusEffectType.weakened, duration: 1, magnitude: 25)],
      'Net Toss', 'Tangled in a net.'),
  ],
  // 24: Crystal Caverns
  24: [
    (tier) => _customEnemy('Crystal Golem', 'crystal_golem', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 2, magnitude: 40)],
      'Prism Blast', 'Blinding light refracts.'),
    (tier) => _customEnemy('Gem Viper', 'gem_viper', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 2, magnitude: StatusDefaults.dotDamage(tier)),
       AppliedEffect(type: StatusEffectType.exposed, duration: 1, magnitude: 30)],
      'Crystal Fang', 'Crystalline fangs pierce.'),
  ],
  // 25: Haunted Graveyard
  25: [
    (tier) => _customEnemy('Grave Knight', 'grave_knight', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 3)],
      'Spectral Cleave', 'Ghostly blade curses.'),
    (tier) => _customEnemy('Banshee', 'banshee', tier,
      [AppliedEffect(type: StatusEffectType.silenced, duration: 2),
       AppliedEffect(type: StatusEffectType.weakened, duration: 1, magnitude: 25)],
      'Death Wail', 'Wailing spirit screams.'),
  ],
  // 26: Abandoned Mine
  26: [
    (tier) => _customEnemy('Mine Creeper', 'mine_creeper', tier,
      [AppliedEffect(type: StatusEffectType.exposed, duration: 3, magnitude: 30)],
      'Acid Spit', 'Corrosive insect spit.'),
    (tier) => _customEnemy('Dynamite Goblin', 'dynamite_goblin', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1),
       AppliedEffect(type: StatusEffectType.burning, duration: 1, magnitude: StatusDefaults.dotDamage(tier))],
      'Blast Charge', 'Explosive blast.'),
  ],

  // === Magical/Special Maps ===
  // 16: Shadow Realm
  16: [
    (tier) => _customEnemy('Void Stalker', 'void_stalker', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 3),
       AppliedEffect(type: StatusEffectType.weakened, duration: 1, magnitude: 25)],
      'Void Touch', 'Darkness consumes.'),
    (tier) => _customEnemy('Shadow Devourer', 'shadow_devourer', tier,
      [AppliedEffect(type: StatusEffectType.blinded, duration: 3, magnitude: 40)],
      'Engulfing Dark', 'Light is devoured.'),
  ],
  // 17: Enchanted Grove
  17: [
    (tier) => _customEnemy('Treant Sentinel', 'treant_sentinel', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1),
       AppliedEffect(type: StatusEffectType.exposed, duration: 2, magnitude: 30)],
      'Root Bind', 'Living roots entangle.'),
    (tier) => _customEnemy('Pixie Swarm', 'pixie_swarm', tier,
      [AppliedEffect(type: StatusEffectType.silenced, duration: 2)],
      'Fairy Dust', 'Mischievous fae magic.'),
  ],
  // 18: Demon Fortress
  18: [
    (tier) => _customEnemy('Hellhound', 'hellhound', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 3, magnitude: StatusDefaults.dotDamage(tier))],
      'Infernal Bite', 'Fire-breathing maw.'),
    (tier) => _customEnemy('Demon Sentry', 'demon_sentry', tier,
      [AppliedEffect(type: StatusEffectType.exposed, duration: 2, magnitude: 30),
       AppliedEffect(type: StatusEffectType.bleeding, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Abyssal Strike', 'Demonic blade rends.'),
  ],
  // 19: Sky Islands
  19: [
    (tier) => _customEnemy('Storm Hawk', 'storm_hawk', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1)],
      'Lightning Dive', 'Lightning-charged strike.'),
    (tier) => _customEnemy('Cloud Elemental', 'cloud_elemental', tier,
      [AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30),
       AppliedEffect(type: StatusEffectType.burning, duration: 1, magnitude: StatusDefaults.dotDamage(tier))],
      'Static Shock', 'Living storm crackles.'),
  ],
  // 20: The Void
  20: [
    (tier) => _customEnemy('Void Reaver', 'void_reaver', tier,
      [AppliedEffect(type: StatusEffectType.exposed, duration: 2, magnitude: 30),
       AppliedEffect(type: StatusEffectType.cursed, duration: 2)],
      'Reality Tear', 'Tears the fabric of reality.'),
    (tier) => _customEnemy('Entropy Shade', 'entropy_shade', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25),
       AppliedEffect(type: StatusEffectType.poisoned, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Entropic Decay', 'Entropy incarnate.'),
  ],
  // 27: Pirate Cove
  27: [
    (tier) => _customEnemy('Cursed Buccaneer', 'cursed_buccaneer', tier,
      [AppliedEffect(type: StatusEffectType.cursed, duration: 2),
       AppliedEffect(type: StatusEffectType.bleeding, duration: 2, magnitude: StatusDefaults.dotDamage(tier))],
      'Cursed Cutlass', 'Undead pirate slashes.'),
    (tier) => _customEnemy('Kraken Spawn', 'kraken_spawn', tier,
      [AppliedEffect(type: StatusEffectType.weakened, duration: 2, magnitude: 25),
       AppliedEffect(type: StatusEffectType.slowed, duration: 1, magnitude: 30)],
      'Tentacle Lash', 'Tentacles constrict.'),
  ],
  // 28: Arcane Tower
  28: [
    (tier) => _customEnemy('Arcane Sentinel', 'arcane_sentinel', tier,
      [AppliedEffect(type: StatusEffectType.silenced, duration: 3)],
      'Mana Burn', 'Magical constructs drain mana.'),
    (tier) => _customEnemy('Spell Wraith', 'spell_wraith', tier,
      [AppliedEffect(type: StatusEffectType.burning, duration: 2, magnitude: StatusDefaults.dotDamage(tier)),
       AppliedEffect(type: StatusEffectType.exposed, duration: 1, magnitude: 30)],
      'Arcane Overload', 'Rogue magical energy.'),
  ],
  // 29: Gladiator Arena
  29: [
    (tier) => _customEnemy('Arena Champion', 'arena_champion', tier,
      [AppliedEffect(type: StatusEffectType.stunned, duration: 1),
       AppliedEffect(type: StatusEffectType.exposed, duration: 1, magnitude: 30)],
      'Shield Bash', 'Veteran gladiator strikes.'),
    (tier) => _customEnemy('Beast Master', 'beast_master', tier,
      [AppliedEffect(type: StatusEffectType.bleeding, duration: 2, magnitude: StatusDefaults.dotDamage(tier)),
       AppliedEffect(type: StatusEffectType.slowed, duration: 2, magnitude: 30)],
      'Command Attack', 'Trained beasts attack.'),
  ],
  // 30: Frozen Citadel
  30: [
    (tier) => _customEnemy('Frost Knight', 'frost_knight', tier,
      [AppliedEffect(type: StatusEffectType.frozen, duration: 1, magnitude: 30),
       AppliedEffect(type: StatusEffectType.slowed, duration: 1, magnitude: 30)],
      'Glacial Strike', 'Ice-armored blow.'),
    (tier) => _customEnemy('Ice Wraith', 'ice_wraith', tier,
      [AppliedEffect(type: StatusEffectType.frozen, duration: 1, magnitude: 30)],
      'Frozen Grasp', 'Freezing spirit grips.'),
  ],
};
