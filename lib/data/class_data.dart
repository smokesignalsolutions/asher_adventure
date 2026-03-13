import '../models/ability.dart';
import '../models/character.dart';
import '../models/enums.dart';

class ClassDefinition {
  final String name;
  final CharacterClass characterClass;
  final CharacterStats baseStats;
  final CharacterStats growthRates;
  final double initiativeModifier;
  final List<Ability> abilities;
  final bool unlockedByDefault;

  const ClassDefinition({
    required this.name,
    required this.characterClass,
    required this.baseStats,
    required this.growthRates,
    required this.initiativeModifier,
    required this.abilities,
    required this.unlockedByDefault,
  });
}

final Map<CharacterClass, ClassDefinition> classDefinitions = {
  CharacterClass.fighter: ClassDefinition(
    name: 'Fighter',
    characterClass: CharacterClass.fighter,
    baseStats: const CharacterStats(hp: 120, attack: 14, defense: 12, speed: 8, magic: 2),
    growthRates: const CharacterStats(hp: 15, attack: 3, defense: 2, speed: 1, magic: 0),
    initiativeModifier: 1.0,
    unlockedByDefault: true,
    abilities: [
      Ability(name: 'Strike', description: 'A basic melee attack.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Shield Bash', description: 'Slam your shield into the enemy.', damage: 14, refreshChance: 60, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 3),
      Ability(name: 'Whirlwind', description: 'Spin and strike all enemies.', damage: 8, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 6),
      Ability(name: 'Rallying Cry', description: 'Inspire the party, boosting morale.', damage: -15, refreshChance: 35, targetType: AbilityTarget.allAllies, unlockedAtLevel: 9),
      Ability(name: 'Devastating Blow', description: 'A powerful strike that deals massive damage.', damage: 30, refreshChance: 25, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.rogue: ClassDefinition(
    name: 'Rogue',
    characterClass: CharacterClass.rogue,
    baseStats: const CharacterStats(hp: 85, attack: 12, defense: 6, speed: 14, magic: 4),
    growthRates: const CharacterStats(hp: 10, attack: 3, defense: 1, speed: 3, magic: 0),
    initiativeModifier: 3.0,
    unlockedByDefault: true,
    abilities: [
      Ability(name: 'Stab', description: 'A quick dagger thrust.', damage: 9, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Backstab', description: 'Strike from the shadows for double damage.', damage: 22, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Poison Blade', description: 'Coat your weapon in venom.', damage: 16, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 5),
      Ability(name: 'Shadow Step', description: 'Vanish and strike all foes.', damage: 10, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Assassinate', description: 'A lethal strike to a single target.', damage: 40, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.cleric: ClassDefinition(
    name: 'Cleric',
    characterClass: CharacterClass.cleric,
    baseStats: const CharacterStats(hp: 100, attack: 8, defense: 10, speed: 6, magic: 14),
    growthRates: const CharacterStats(hp: 12, attack: 1, defense: 2, speed: 1, magic: 3),
    initiativeModifier: 0.0,
    unlockedByDefault: true,
    abilities: [
      Ability(name: 'Smite', description: 'Strike with holy light.', damage: 8, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Heal', description: 'Restore an ally\'s health.', damage: -25, refreshChance: 60, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 1),
      Ability(name: 'Holy Shield', description: 'Protect yourself with divine energy.', damage: -20, refreshChance: 50, targetType: AbilityTarget.self, unlockedAtLevel: 4),
      Ability(name: 'Mass Heal', description: 'Heal the entire party.', damage: -15, refreshChance: 30, targetType: AbilityTarget.allAllies, unlockedAtLevel: 7),
      Ability(name: 'Divine Wrath', description: 'Call down holy fire on all enemies.', damage: 20, refreshChance: 25, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.wizard: ClassDefinition(
    name: 'Wizard',
    characterClass: CharacterClass.wizard,
    baseStats: const CharacterStats(hp: 70, attack: 4, defense: 4, speed: 7, magic: 18),
    growthRates: const CharacterStats(hp: 8, attack: 0, defense: 1, speed: 1, magic: 4),
    initiativeModifier: -1.0,
    unlockedByDefault: true,
    abilities: [
      Ability(name: 'Arcane Bolt', description: 'A bolt of pure magic.', damage: 12, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Fireball', description: 'Launch a ball of fire at all enemies.', damage: 14, refreshChance: 50, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 2),
      Ability(name: 'Ice Lance', description: 'A piercing shard of ice.', damage: 22, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 5),
      Ability(name: 'Chain Lightning', description: 'Lightning arcs between all foes.', damage: 18, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Meteor', description: 'Call a meteor from the sky.', damage: 35, refreshChance: 20, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.paladin: ClassDefinition(
    name: 'Paladin',
    characterClass: CharacterClass.paladin,
    baseStats: const CharacterStats(hp: 110, attack: 12, defense: 14, speed: 5, magic: 10),
    growthRates: const CharacterStats(hp: 14, attack: 2, defense: 3, speed: 1, magic: 2),
    initiativeModifier: 0.0,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Holy Strike', description: 'A righteous blow.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Lay on Hands', description: 'Heal an ally with divine touch.', damage: -20, refreshChance: 55, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 2),
      Ability(name: 'Divine Shield', description: 'Protect yourself from harm.', damage: -30, refreshChance: 40, targetType: AbilityTarget.self, unlockedAtLevel: 5),
      Ability(name: 'Consecrate', description: 'Holy ground damages all foes.', damage: 15, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Judgment', description: 'Pass divine judgment on an enemy.', damage: 35, refreshChance: 25, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.ranger: ClassDefinition(
    name: 'Ranger',
    characterClass: CharacterClass.ranger,
    baseStats: const CharacterStats(hp: 90, attack: 13, defense: 7, speed: 12, magic: 6),
    growthRates: const CharacterStats(hp: 11, attack: 3, defense: 1, speed: 2, magic: 1),
    initiativeModifier: 2.0,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Arrow Shot', description: 'Fire an arrow at the enemy.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Twin Shot', description: 'Fire two arrows rapidly.', damage: 16, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 3),
      Ability(name: 'Volley', description: 'Rain arrows on all foes.', damage: 10, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 5),
      Ability(name: 'Nature\'s Blessing', description: 'The forest heals an ally.', damage: -18, refreshChance: 45, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 7),
      Ability(name: 'Headshot', description: 'A precise shot to the head.', damage: 38, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.warlock: ClassDefinition(
    name: 'Warlock',
    characterClass: CharacterClass.warlock,
    baseStats: const CharacterStats(hp: 80, attack: 6, defense: 5, speed: 8, magic: 16),
    growthRates: const CharacterStats(hp: 9, attack: 1, defense: 1, speed: 1, magic: 4),
    initiativeModifier: 0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Eldritch Blast', description: 'Dark energy lashes out.', damage: 12, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Hex', description: 'Curse an enemy, weakening them.', damage: 16, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Drain Life', description: 'Steal life from an enemy.', damage: 14, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 5),
      Ability(name: 'Dark Pact', description: 'Sacrifice HP to blast all foes.', damage: 22, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Doom', description: 'Mark an enemy for destruction.', damage: 42, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.summoner: ClassDefinition(
    name: 'Summoner',
    characterClass: CharacterClass.summoner,
    baseStats: const CharacterStats(hp: 75, attack: 5, defense: 5, speed: 7, magic: 15),
    growthRates: const CharacterStats(hp: 8, attack: 1, defense: 1, speed: 1, magic: 4),
    initiativeModifier: -0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Spirit Bolt', description: 'Command a spirit to attack.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Summon Wolf', description: 'A wolf spirit attacks an enemy.', damage: 18, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Spirit Shield', description: 'Spirits protect an ally.', damage: -20, refreshChance: 45, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 4),
      Ability(name: 'Summon Swarm', description: 'A swarm of spirits attacks all foes.', damage: 14, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 7),
      Ability(name: 'Summon Dragon', description: 'Call forth a spectral dragon.', damage: 36, refreshChance: 20, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.spellsword: ClassDefinition(
    name: 'Spellsword',
    characterClass: CharacterClass.spellsword,
    baseStats: const CharacterStats(hp: 95, attack: 11, defense: 8, speed: 9, magic: 11),
    growthRates: const CharacterStats(hp: 11, attack: 2, defense: 2, speed: 1, magic: 2),
    initiativeModifier: 1.0,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Arcane Slash', description: 'A magic-infused sword strike.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Flame Blade', description: 'Your sword erupts in flame.', damage: 18, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 3),
      Ability(name: 'Frost Armor', description: 'Coat yourself in protective ice.', damage: -18, refreshChance: 45, targetType: AbilityTarget.self, unlockedAtLevel: 5),
      Ability(name: 'Thunder Cleave', description: 'Lightning-charged slash hits all.', damage: 14, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Arcane Annihilation', description: 'Unleash all magical energy in one strike.', damage: 38, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.druid: ClassDefinition(
    name: 'Druid',
    characterClass: CharacterClass.druid,
    baseStats: const CharacterStats(hp: 95, attack: 8, defense: 8, speed: 8, magic: 14),
    growthRates: const CharacterStats(hp: 11, attack: 1, defense: 2, speed: 1, magic: 3),
    initiativeModifier: 0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Thorn Whip', description: 'Lash out with thorny vines.', damage: 9, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Rejuvenate', description: 'Nature restores an ally.', damage: -22, refreshChance: 55, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 2),
      Ability(name: 'Entangle', description: 'Roots trap all enemies.', damage: 12, refreshChance: 45, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 4),
      Ability(name: 'Wild Growth', description: 'Heal the entire party with nature.', damage: -14, refreshChance: 30, targetType: AbilityTarget.allAllies, unlockedAtLevel: 7),
      Ability(name: 'Wrath of Nature', description: 'The forest itself attacks.', damage: 28, refreshChance: 25, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.monk: ClassDefinition(
    name: 'Monk',
    characterClass: CharacterClass.monk,
    baseStats: const CharacterStats(hp: 90, attack: 12, defense: 8, speed: 13, magic: 6),
    growthRates: const CharacterStats(hp: 10, attack: 2, defense: 2, speed: 3, magic: 1),
    initiativeModifier: 2.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Palm Strike', description: 'A focused open-hand blow.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Flurry of Blows', description: 'Rapid strikes on one enemy.', damage: 18, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Inner Peace', description: 'Meditate to restore health.', damage: -20, refreshChance: 45, targetType: AbilityTarget.self, unlockedAtLevel: 4),
      Ability(name: 'Sweeping Kick', description: 'Kick that hits all enemies.', damage: 12, refreshChance: 40, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 7),
      Ability(name: 'Quivering Palm', description: 'A devastating pressure point strike.', damage: 40, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.barbarian: ClassDefinition(
    name: 'Barbarian',
    characterClass: CharacterClass.barbarian,
    baseStats: const CharacterStats(hp: 140, attack: 16, defense: 6, speed: 9, magic: 1),
    growthRates: const CharacterStats(hp: 18, attack: 4, defense: 1, speed: 1, magic: 0),
    initiativeModifier: 1.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Cleave', description: 'A brutal axe swing.', damage: 12, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Rage', description: 'Enter a rage, boosting damage.', damage: -10, refreshChance: 55, targetType: AbilityTarget.self, unlockedAtLevel: 2),
      Ability(name: 'Reckless Swing', description: 'Wild attack that hits hard.', damage: 24, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 4),
      Ability(name: 'War Cry', description: 'Terrify all enemies.', damage: 14, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 7),
      Ability(name: 'Berserker Fury', description: 'Unleash unstoppable fury.', damage: 45, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.sorcerer: ClassDefinition(
    name: 'Sorcerer',
    characterClass: CharacterClass.sorcerer,
    baseStats: const CharacterStats(hp: 68, attack: 4, defense: 3, speed: 9, magic: 20),
    growthRates: const CharacterStats(hp: 7, attack: 0, defense: 1, speed: 1, magic: 5),
    initiativeModifier: 0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Magic Missile', description: 'Unerring bolts of force.', damage: 13, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Wild Surge', description: 'Chaotic magic blasts a foe.', damage: 20, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Chaos Bolt', description: 'Unpredictable magical damage.', damage: 24, refreshChance: 45, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 5),
      Ability(name: 'Arcane Storm', description: 'Raw magic strikes all foes.', damage: 20, refreshChance: 30, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 8),
      Ability(name: 'Reality Warp', description: 'Bend reality to devastate enemies.', damage: 38, refreshChance: 20, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 12),
    ],
  ),

  CharacterClass.necromancer: ClassDefinition(
    name: 'Necromancer',
    characterClass: CharacterClass.necromancer,
    baseStats: const CharacterStats(hp: 72, attack: 5, defense: 4, speed: 7, magic: 17),
    growthRates: const CharacterStats(hp: 8, attack: 1, defense: 1, speed: 1, magic: 4),
    initiativeModifier: -0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Death Bolt', description: 'A bolt of necrotic energy.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Life Tap', description: 'Drain life from an enemy to heal.', damage: 16, refreshChance: 55, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Bone Shield', description: 'Surround yourself with bones.', damage: -22, refreshChance: 45, targetType: AbilityTarget.self, unlockedAtLevel: 4),
      Ability(name: 'Plague', description: 'Spread disease to all enemies.', damage: 16, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 7),
      Ability(name: 'Army of the Dead', description: 'Raise the fallen to fight.', damage: 34, refreshChance: 20, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.artificer: ClassDefinition(
    name: 'Artificer',
    characterClass: CharacterClass.artificer,
    baseStats: const CharacterStats(hp: 85, attack: 10, defense: 9, speed: 8, magic: 12),
    growthRates: const CharacterStats(hp: 10, attack: 2, defense: 2, speed: 1, magic: 2),
    initiativeModifier: 0.5,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Wrench Toss', description: 'Hurl a wrench at the enemy.', damage: 10, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Deploy Turret', description: 'A turret blasts an enemy.', damage: 18, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 2),
      Ability(name: 'Repair', description: 'Patch up an ally.', damage: -18, refreshChance: 50, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 4),
      Ability(name: 'Bomb', description: 'Throw a bomb at all enemies.', damage: 16, refreshChance: 35, targetType: AbilityTarget.allEnemies, unlockedAtLevel: 7),
      Ability(name: 'Mech Suit', description: 'Don a powerful mechanical suit.', damage: -30, refreshChance: 20, targetType: AbilityTarget.self, unlockedAtLevel: 11),
    ],
  ),

  CharacterClass.templar: ClassDefinition(
    name: 'Templar',
    characterClass: CharacterClass.templar,
    baseStats: const CharacterStats(hp: 105, attack: 13, defense: 13, speed: 6, magic: 8),
    growthRates: const CharacterStats(hp: 13, attack: 2, defense: 3, speed: 1, magic: 1),
    initiativeModifier: 0.0,
    unlockedByDefault: false,
    abilities: [
      Ability(name: 'Righteous Strike', description: 'A blow guided by faith.', damage: 11, refreshChance: 100, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 1, isBasicAttack: true),
      Ability(name: 'Holy Guard', description: 'Divine protection for an ally.', damage: -18, refreshChance: 55, targetType: AbilityTarget.singleAlly, unlockedAtLevel: 2),
      Ability(name: 'Smite Evil', description: 'Punish an unholy enemy.', damage: 22, refreshChance: 50, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 5),
      Ability(name: 'Aura of Light', description: 'Heal all allies with radiance.', damage: -12, refreshChance: 30, targetType: AbilityTarget.allAllies, unlockedAtLevel: 8),
      Ability(name: 'Crusader\'s Wrath', description: 'Channel all faith into one strike.', damage: 38, refreshChance: 20, targetType: AbilityTarget.singleEnemy, unlockedAtLevel: 11),
    ],
  ),
};
