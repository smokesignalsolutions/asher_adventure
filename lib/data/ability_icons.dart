/// Maps ability names to their pixel art icon filenames.
const Map<String, String> abilityIconMap = {
  // Fighter
  'Strike': 'sword',
  'Shield Bash': 'shield',
  'Whirlwind': 'whirlwind',
  'Rallying Cry': 'heal_all',
  'Devastating Blow': 'sword_power',

  // Rogue
  'Stab': 'dagger',
  'Backstab': 'dagger',
  'Poison Blade': 'poison',
  'Shadow Step': 'dark',
  'Assassinate': 'sword_power',

  // Cleric
  'Smite': 'holy',
  'Heal': 'heal',
  'Holy Shield': 'shield',
  'Mass Heal': 'heal_all',
  'Divine Wrath': 'holy_aoe',

  // Wizard
  'Arcane Bolt': 'arcane',
  'Fireball': 'fireball',
  'Ice Lance': 'ice',
  'Chain Lightning': 'lightning',
  'Meteor': 'meteor',

  // Paladin
  'Holy Strike': 'holy',
  'Lay on Hands': 'heal',
  'Divine Shield': 'shield',
  'Consecrate': 'holy_aoe',
  'Judgment': 'sword_power',

  // Ranger
  'Arrow Shot': 'arrow',
  'Twin Shot': 'arrow',
  'Volley': 'arrow_rain',
  "Nature's Blessing": 'nature',
  'Headshot': 'arrow',

  // Warlock
  'Eldritch Blast': 'dark',
  'Hex': 'dark',
  'Drain Life': 'dark',
  'Dark Pact': 'skull',
  'Doom': 'dark',

  // Summoner
  'Spirit Bolt': 'arcane',
  'Summon Wolf': 'summon',
  'Spirit Shield': 'shield',
  'Summon Swarm': 'summon',
  'Summon Dragon': 'summon',

  // Spellsword
  'Arcane Slash': 'sword',
  'Flame Blade': 'fireball',
  'Frost Armor': 'ice',
  'Thunder Cleave': 'lightning',
  'Arcane Annihilation': 'sword_power',

  // Druid
  'Thorn Whip': 'nature',
  'Rejuvenate': 'heal',
  'Entangle': 'nature',
  'Wild Growth': 'heal_all',
  'Wrath of Nature': 'meteor',

  // Monk
  'Palm Strike': 'fist',
  'Flurry of Blows': 'fist',
  'Inner Peace': 'shield',
  'Sweeping Kick': 'whirlwind',
  'Quivering Palm': 'sword_power',

  // Barbarian
  'Cleave': 'sword',
  'Rage': 'shield',
  'Reckless Swing': 'sword_power',
  'War Cry': 'whirlwind',
  'Berserker Fury': 'sword_power',

  // Sorcerer
  'Magic Missile': 'arcane',
  'Wild Surge': 'arcane',
  'Chaos Bolt': 'arcane',
  'Arcane Storm': 'lightning',
  'Reality Warp': 'meteor',

  // Necromancer
  'Death Bolt': 'dark',
  'Life Tap': 'dark',
  'Bone Shield': 'skull',
  'Plague': 'poison',
  'Army of the Dead': 'skull',

  // Artificer
  'Wrench Toss': 'bomb',
  'Deploy Turret': 'bomb',
  'Repair': 'heal',
  'Bomb': 'bomb',
  'Mech Suit': 'shield',

  // Templar
  'Righteous Strike': 'holy',
  'Holy Guard': 'heal',
  'Smite Evil': 'holy',
  'Aura of Light': 'holy_aoe',
  "Crusader's Wrath": 'sword_power',
};

String abilityIconPath(String abilityName) {
  final icon = abilityIconMap[abilityName] ?? 'sword';
  return 'assets/sprites/abilities/$icon.png';
}
