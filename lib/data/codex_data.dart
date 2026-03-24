class BestiaryDefinition {
  final String enemyType;
  final String name;
  final String description;
  final int mapTier;
  const BestiaryDefinition({required this.enemyType, required this.name, required this.description, required this.mapTier});
}

class LorePageDefinition {
  final String id;
  final int mapTier;
  final String title;
  final String content;
  const LorePageDefinition({required this.id, required this.mapTier, required this.title, required this.content});
}

const List<BestiaryDefinition> bestiaryEntries = [
  BestiaryDefinition(enemyType: 'goblin', name: 'Goblin', description: 'Small but vicious green-skinned creatures that attack in groups.', mapTier: 1),
  BestiaryDefinition(enemyType: 'wolf', name: 'Dire Wolf', description: 'Massive wolves corrupted by dark magic. Fast and relentless.', mapTier: 1),
  BestiaryDefinition(enemyType: 'bandit', name: 'Bandit', description: 'Desperate outlaws who prey on travelers. Well-armed but cowardly.', mapTier: 1),
  BestiaryDefinition(enemyType: 'skeleton', name: 'Skeleton', description: 'Reanimated bones held together by necromantic energy.', mapTier: 1),
  BestiaryDefinition(enemyType: 'orc', name: 'Orc', description: 'Brutish warriors driven by rage. Strong but slow to react.', mapTier: 1),
  BestiaryDefinition(enemyType: 'spider', name: 'Giant Spider', description: 'Venomous arachnids that lurk in dark corners of the world.', mapTier: 1),
  BestiaryDefinition(enemyType: 'dark_mage', name: 'Dark Mage', description: 'Sorcerers corrupted by forbidden knowledge. Dangerous at range.', mapTier: 2),
  BestiaryDefinition(enemyType: 'ogre', name: 'Ogre', description: 'Towering brutes with incredible strength but dim wits.', mapTier: 2),
  BestiaryDefinition(enemyType: 'harpy', name: 'Harpy', description: 'Winged terrors that swoop down from above with piercing shrieks.', mapTier: 2),
  BestiaryDefinition(enemyType: 'troll', name: 'Troll', description: 'Regenerating monstrosities that must be overwhelmed quickly.', mapTier: 2),
  BestiaryDefinition(enemyType: 'wraith', name: 'Wraith', description: 'Ghostly remnants of fallen warriors. Partially resistant to physical attacks.', mapTier: 2),
  BestiaryDefinition(enemyType: 'minotaur', name: 'Minotaur', description: 'Half-bull warriors that charge with devastating force.', mapTier: 2),
  BestiaryDefinition(enemyType: 'wyvern', name: 'Wyvern', description: 'Lesser dragons with venomous tails. Fast flyers and fierce fighters.', mapTier: 3),
  BestiaryDefinition(enemyType: 'lich_acolyte', name: 'Lich Acolyte', description: 'Apprentice necromancers seeking immortality through dark rituals.', mapTier: 3),
  BestiaryDefinition(enemyType: 'golem', name: 'Stone Golem', description: 'Animated stone guardians. Nearly impervious to magic.', mapTier: 3),
  BestiaryDefinition(enemyType: 'vampire', name: 'Vampire', description: 'Ancient undead that drain the life from their victims.', mapTier: 3),
  BestiaryDefinition(enemyType: 'chimera', name: 'Chimera', description: 'Three-headed abominations with the fury of lion, goat, and serpent.', mapTier: 3),
  BestiaryDefinition(enemyType: 'death_knight', name: 'Death Knight', description: 'Fallen paladins raised to serve darkness. Skilled and merciless.', mapTier: 3),
  BestiaryDefinition(enemyType: 'elder_dragon', name: 'Elder Dragon', description: 'Ancient wyrms of immense power. Their breath melts steel.', mapTier: 4),
  BestiaryDefinition(enemyType: 'archdemon', name: 'Archdemon', description: 'Lords of the abyss, commanding legions of lesser fiends.', mapTier: 4),
  BestiaryDefinition(enemyType: 'titan', name: 'Titan', description: 'Primordial giants from before the age of mortals.', mapTier: 4),
  BestiaryDefinition(enemyType: 'shadow_lord', name: 'Shadow Lord', description: 'Manifestations of pure darkness given terrible form.', mapTier: 4),
  BestiaryDefinition(enemyType: 'ancient_wyrm', name: 'Ancient Wyrm', description: 'The oldest of dragonkind. Their very presence warps reality.', mapTier: 4),
  BestiaryDefinition(enemyType: 'void_walker', name: 'Void Walker', description: 'Beings from between worlds. They unmake what they touch.', mapTier: 4),
  BestiaryDefinition(enemyType: 'boss', name: 'Boss', description: 'Powerful guardians that block the path forward.', mapTier: 0),
];

const List<LorePageDefinition> lorePages = [
  LorePageDefinition(id: 'lore_1_1', mapTier: 1, title: 'The Kingdom of Ashenvale', content: 'Once, Ashenvale was a land of peace and plenty. The five kingdoms traded freely, and the roads were safe for even the smallest traveler. That all changed when the Dark One rose from the Void Between Worlds.'),
  LorePageDefinition(id: 'lore_1_2', mapTier: 1, title: 'The First Sign', content: 'The crops withered first. Then the animals fled. By the time the shadows began to move on their own, it was too late. The Dark One\'s army marched from the east, consuming everything in its path.'),
  LorePageDefinition(id: 'lore_1_3', mapTier: 1, title: 'The Call to Arms', content: 'King Aldric sent riders to every corner of the realm. Warriors, mages, rogues, and healers — all were needed. The response was overwhelming. Heroes emerged from the most unlikely places.'),
  LorePageDefinition(id: 'lore_1_4', mapTier: 1, title: 'The Legacy Hall', content: 'Deep beneath Castle Ashenvale lies the Legacy Hall, where the deeds of fallen heroes are inscribed in eternal stone. Each name carries power — power that strengthens those who follow.'),
  LorePageDefinition(id: 'lore_2_1', mapTier: 2, title: 'The Corrupted Lands', content: 'Beyond the frontier, the land itself has been twisted by the Dark One\'s influence. Trees grow in impossible shapes, rivers run black, and the very air tastes of iron and ash.'),
  LorePageDefinition(id: 'lore_2_2', mapTier: 2, title: 'The Army of Shadows', content: 'The Dark One\'s army is not merely soldiers. It is a living tide of corruption that grows stronger with each victory. Those who fall in battle are raised again to fight against their former allies.'),
  LorePageDefinition(id: 'lore_2_3', mapTier: 2, title: 'The Ancient Weapons', content: 'Legends speak of weapons forged in the first age, when gods still walked the earth. These artifacts hold power enough to wound even the Dark One — if they can be found.'),
  LorePageDefinition(id: 'lore_2_4', mapTier: 2, title: 'The Healers\' Oath', content: 'The clerics of the Silver Order swore to heal any who asked, friend or foe. Even now, in the darkest times, they hold to their oath — though it costs them dearly.'),
  LorePageDefinition(id: 'lore_3_1', mapTier: 3, title: 'The Dragon Pact', content: 'Long ago, mortals and dragons fought side by side against a common enemy. That alliance was shattered by betrayal. Now the elder dragons guard their mountain fortresses in bitter isolation.'),
  LorePageDefinition(id: 'lore_3_2', mapTier: 3, title: 'The Necromancer\'s Folly', content: 'The Dark One was once a mortal wizard who sought to conquer death itself. He succeeded — but the price was his humanity. What returned from the Void was something far worse than death.'),
  LorePageDefinition(id: 'lore_3_3', mapTier: 3, title: 'The Void Between', content: 'Between all worlds lies the Void — a place of infinite nothing. Those who glimpse it are forever changed. Those who enter it rarely return. Those who return are never the same.'),
  LorePageDefinition(id: 'lore_3_4', mapTier: 3, title: 'The Last Fortress', content: 'Fort Ironhold stands as the final bastion before the Dark One\'s domain. Its walls have held for a thousand years. Its defenders pray they will hold for one more day.'),
  LorePageDefinition(id: 'lore_4_1', mapTier: 4, title: 'The Dark Throne', content: 'At the heart of the corruption sits the Dark Throne — a seat of power carved from the bones of fallen gods. From here, the Dark One commands legions across all the realms.'),
  LorePageDefinition(id: 'lore_4_2', mapTier: 4, title: 'The Final Battle', content: 'Every hero who has challenged the Dark One has fallen. Their spirits are trapped in the Void, feeding the Dark One\'s power. But prophecy speaks of a party of four who will break the cycle.'),
  LorePageDefinition(id: 'lore_4_3', mapTier: 4, title: 'The Price of Victory', content: 'To defeat the Dark One is not to destroy him — for he is beyond destruction. It is to seal him away, to bind him in chains of light and hope. But the seal requires sacrifice.'),
  LorePageDefinition(id: 'lore_4_4', mapTier: 4, title: 'After the Dawn', content: 'When the Dark One falls, the corruption will fade. The land will heal. But the scars will remain — in the earth, in the people, and in the hearts of those who fought. They will remember.'),
];
