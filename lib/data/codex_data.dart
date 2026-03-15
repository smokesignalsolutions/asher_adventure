import '../models/enums.dart';

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

class ClassStoryChapter {
  final CharacterClass characterClass;
  final int chapter;
  final String title;
  final String content;
  const ClassStoryChapter({required this.characterClass, required this.chapter, required this.title, required this.content});
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

const List<ClassStoryChapter> classStories = [
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 1, title: 'The Broken Sword', content: 'Every fighter begins with a weapon passed down through generations. Yours was shattered in the first battle against the Dark One\'s army. But a broken blade can still cut — and a broken warrior can still fight.'),
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 2, title: 'The Shield Wall', content: 'At Fort Ironhold, you learned that true strength is not in the arm that swings the sword, but in the heart that refuses to retreat. You held the line when others could not.'),
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 3, title: 'The Last Stand', content: 'Before the Dark Throne, you understood. The blade was never broken — it was reforged in every battle, tempered by every wound. You are the weapon. You always were.'),
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 1, title: 'Shadows and Daggers', content: 'The thieves\' guild fell apart when the Dark One came. Loyalty means nothing when shadows come alive. But you survived — you always survive. That\'s what rogues do.'),
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 2, title: 'The Hidden Path', content: 'You found passages that no map shows. Doors that no key opens. Secrets that the Dark One thought buried. Knowledge is the sharpest blade of all.'),
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 3, title: 'The Final Trick', content: 'They never see it coming. Not the monsters, not the army, not even the Dark One himself. The greatest trick is making them think you\'re just a thief — right until the knife finds its mark.'),
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 1, title: 'The Healing Light', content: 'When the temples burned, you carried the sacred flame within. Your hands mend what darkness breaks. Your prayers reach ears that even gods have abandoned.'),
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 2, title: 'The Weight of Mercy', content: 'You healed a fallen soldier of the Dark One\'s army. He wept, remembering who he had been before the corruption. Some stains cannot be washed clean — but you try anyway.'),
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 3, title: 'The Sacred Sacrifice', content: 'The final prayer is not for healing. It is for strength — the strength to give everything, to pour out every last drop of light, to burn so brightly that even the Void recoils.'),
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 1, title: 'The Forbidden Library', content: 'The Academy of Arcane Arts was the first to fall. The Dark One coveted its knowledge. But you smuggled out the most dangerous tome of all — the one that contains his true name.'),
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 2, title: 'The Spell Unwritten', content: 'Magic is not about power. It is about understanding. You have studied the Dark One\'s corruption, learned its patterns, found its weaknesses. Knowledge defeats power.'),
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 3, title: 'The Word of Unmaking', content: 'You speak the Word. Reality trembles. The Dark One\'s true name echoes through the Void, and for the first time in a thousand years, he knows fear.'),

  // Paladin
  ClassStoryChapter(characterClass: CharacterClass.paladin, chapter: 1, title: 'The Oath of Dawn', content: 'When the Dark One\'s shadow fell across the land, you knelt in the ruins of the Silver Cathedral and swore an oath. No darkness would go unchallenged. No innocent would be abandoned. The light chose you — and you chose to answer.'),
  ClassStoryChapter(characterClass: CharacterClass.paladin, chapter: 2, title: 'The Fallen Fortress', content: 'At the siege of Brightkeep, your shield shattered and your armor cracked. But when your allies fell behind you, the oath burned brighter than any blade. You held the gate alone until dawn, and the darkness could not pass.'),
  ClassStoryChapter(characterClass: CharacterClass.paladin, chapter: 3, title: 'The Light Unbroken', content: 'Before the Dark Throne, the shadows press in from every side. But your oath is a sun that never sets. You raise your sword and the light pours forth — pure, blinding, unstoppable. The Dark One shields his eyes for the first time in an age.'),

  // Ranger
  ClassStoryChapter(characterClass: CharacterClass.ranger, chapter: 1, title: 'The Wild Road', content: 'The forests knew the Dark One was coming before anyone else. The birds stopped singing. The deer fled south. You read the signs and strung your bow. The wilds raised you, and now you fight for them.'),
  ClassStoryChapter(characterClass: CharacterClass.ranger, chapter: 2, title: 'The Poisoned Trail', content: 'Deep in the Blackwood, the corruption turned every stream to sludge and every root to rot. You tracked the source for seven days through terrain no army could cross. Your arrow found the dark totem, and the forest began to breathe again.'),
  ClassStoryChapter(characterClass: CharacterClass.ranger, chapter: 3, title: 'The Final Arrow', content: 'One arrow. That is all you have left, and you have saved it for this moment. The wind dies. The world holds its breath. You loose — and it flies true, striking the heart of the Dark One\'s power.'),

  // Warlock
  ClassStoryChapter(characterClass: CharacterClass.warlock, chapter: 1, title: 'The Forbidden Pact', content: 'Others pray to gods. You made a deal with something older and stranger. The power it gave you is terrifying, but the Dark One threatens everything — even the thing that lurks beyond your shadow. For now, your goals align.'),
  ClassStoryChapter(characterClass: CharacterClass.warlock, chapter: 2, title: 'The Price of Power', content: 'Your patron demanded a memory as payment. You chose the memory of fear. Now nothing frightens you — not the monsters, not the dark, not even the creeping suspicion that you gave away more than you intended.'),
  ClassStoryChapter(characterClass: CharacterClass.warlock, chapter: 3, title: 'The Pact Fulfilled', content: 'At the Dark Throne, your patron whispers one final secret: the Dark One was once a warlock too, and his patron abandoned him. Yours will not. Eldritch fire erupts from your hands, fueled by a bond that even the Void cannot break.'),

  // Summoner
  ClassStoryChapter(characterClass: CharacterClass.summoner, chapter: 1, title: 'The First Companion', content: 'Most wizards study spells. You studied friendship — the magical kind. Your first summon was a tiny fire sprite named Ember who refused to go back. Together, you decided that if darkness was coming, you would not face it alone.'),
  ClassStoryChapter(characterClass: CharacterClass.summoner, chapter: 2, title: 'The Severed Bond', content: 'The Dark One\'s magic tried to turn your summons against you. For a terrible moment, Ember\'s eyes turned black. But the bond held. Love is a magic older than corruption, and your creatures chose you over the darkness.'),
  ClassStoryChapter(characterClass: CharacterClass.summoner, chapter: 3, title: 'The Grand Summoning', content: 'Before the Dark Throne, you open every gate at once. Creatures of fire, frost, stone, and starlight pour forth. An army of loyal friends, each one called by name, each one fighting for the world that gave them a home.'),

  // Spellsword
  ClassStoryChapter(characterClass: CharacterClass.spellsword, chapter: 1, title: 'The Dual Path', content: 'The warriors mocked your magic. The wizards mocked your sword. But you learned both, weaving steel and sorcery into something neither school had ever seen. When the Dark One came, you were ready in ways no one expected.'),
  ClassStoryChapter(characterClass: CharacterClass.spellsword, chapter: 2, title: 'The Arcane Edge', content: 'In the Battle of Ashenmoor, a lich\'s barrier shrugged off every spell your allies cast. But your enchanted blade cut through it like paper. Magic resists magic — it has no answer for a sword that speaks both languages.'),
  ClassStoryChapter(characterClass: CharacterClass.spellsword, chapter: 3, title: 'The Perfect Strike', content: 'Steel and spell become one. Your blade burns with arcane fire as you charge the Dark Throne. Every cut is a spell, every spell is a cut. You are the bridge between two worlds, and you bring both crashing down on the Dark One.'),

  // Druid
  ClassStoryChapter(characterClass: CharacterClass.druid, chapter: 1, title: 'The Circle\'s Warning', content: 'The ancient oak in the heart of the Emerald Grove wept sap like tears. The druids read the omen clearly: the balance was breaking. You left the grove for the first time in your life, carrying the forest\'s fury with you.'),
  ClassStoryChapter(characterClass: CharacterClass.druid, chapter: 2, title: 'The Withered Land', content: 'You pressed your hands to the corrupted earth and felt its agony. The land was dying, poisoned by the Dark One\'s touch. But deep below, the roots still lived. You fed them with your magic, and green shoots broke through the blackened soil.'),
  ClassStoryChapter(characterClass: CharacterClass.druid, chapter: 3, title: 'Nature\'s Wrath', content: 'Before the Dark Throne, you call upon the oldest magic of all. The earth shakes. Roots burst from the stone floor, vines wrap the pillars, and the wild, untamable force of nature rises to reclaim what the darkness stole.'),

  // Monk
  ClassStoryChapter(characterClass: CharacterClass.monk, chapter: 1, title: 'The Empty Hand', content: 'The monastery on Mount Serenity taught you that the greatest weapon is the self. No sword, no armor — just discipline, breath, and the quiet certainty that your fists can shatter stone. The Dark One\'s army has a lot of stone to shatter.'),
  ClassStoryChapter(characterClass: CharacterClass.monk, chapter: 2, title: 'The Broken Silence', content: 'You had taken a vow of silence, but when the village children screamed for help, you broke it. Some vows matter less than others. Your war cry echoed through the valley as you leapt into battle with nothing but your bare hands.'),
  ClassStoryChapter(characterClass: CharacterClass.monk, chapter: 3, title: 'The Still Point', content: 'In the chaos before the Dark Throne, you find perfect stillness. Time slows. You see every attack before it comes, dodge every shadow, and strike with a force that flows from the center of the world itself. Peace is the ultimate weapon.'),

  // Barbarian
  ClassStoryChapter(characterClass: CharacterClass.barbarian, chapter: 1, title: 'The Northland Fury', content: 'Your clan was the first to fall. The Dark One\'s army swept through the frozen north like a black blizzard. You alone survived, carrying nothing but rage and a battle-axe too heavy for two ordinary people to lift.'),
  ClassStoryChapter(characterClass: CharacterClass.barbarian, chapter: 2, title: 'The Blood Rage', content: 'They surrounded you — fifty of the Dark One\'s soldiers against one barbarian. When the red mist cleared, you stood alone in a field of broken shields. You don\'t remember the fight. You never do.'),
  ClassStoryChapter(characterClass: CharacterClass.barbarian, chapter: 3, title: 'The Unstoppable', content: 'The Dark One throws everything at you. Spells, shadows, fear itself. You shrug it all off and keep walking forward. One step. Another. Another. Nothing can stop you. Nothing ever could. Your axe rises, and the Dark Throne cracks.'),

  // Sorcerer
  ClassStoryChapter(characterClass: CharacterClass.sorcerer, chapter: 1, title: 'The Wild Gift', content: 'You didn\'t learn magic — it learned you. One day sparks flew from your fingers, the next day lightning. The Academy wouldn\'t take you because your power was "unstable." Perfect. Stable never saved the world.'),
  ClassStoryChapter(characterClass: CharacterClass.sorcerer, chapter: 2, title: 'The Uncontrolled Burst', content: 'In the battle at Crimson Pass, your magic surged beyond anything you\'d felt before. The explosion carved a crater where the enemy army had stood. Your allies stared in awe and terror. You just grinned — that one actually went where you aimed it.'),
  ClassStoryChapter(characterClass: CharacterClass.sorcerer, chapter: 3, title: 'The Raw Power', content: 'Before the Dark Throne, you stop holding back. Every wall you built to contain your power crumbles. Pure, wild, beautiful magic erupts from your very soul — chaotic, unpredictable, and more powerful than anything the Dark One has ever faced.'),

  // Necromancer
  ClassStoryChapter(characterClass: CharacterClass.necromancer, chapter: 1, title: 'The Misunderstood Art', content: 'People call you evil. They don\'t understand — death magic isn\'t about killing, it\'s about remembering. You speak to the fallen, honor the dead, and when they choose to rise and fight again, it is their choice, not yours.'),
  ClassStoryChapter(characterClass: CharacterClass.necromancer, chapter: 2, title: 'The Grateful Dead', content: 'At the Battle of Hollow Fields, you raised the ancient heroes buried beneath the battlefield. They thanked you. A thousand years of rest was enough, they said. They had unfinished business with darkness.'),
  ClassStoryChapter(characterClass: CharacterClass.necromancer, chapter: 3, title: 'The Army of Ancestors', content: 'Before the Dark Throne, you call upon every hero who has ever fallen fighting the Dark One. They answer. A ghostly army rises, each spirit burning with the desire for justice. Death is not the end — it is reinforcements.'),

  // Artificer
  ClassStoryChapter(characterClass: CharacterClass.artificer, chapter: 1, title: 'The Tinkerer\'s Workshop', content: 'While others trained with swords and spells, you built things. Clockwork soldiers, explosive potions, a crossbow that reloads itself. The Dark One has magic and monsters. You have engineering, and engineering always wins eventually.'),
  ClassStoryChapter(characterClass: CharacterClass.artificer, chapter: 2, title: 'The Mechanical Marvel', content: 'Your greatest invention — a walking siege tower powered by captured lightning — broke through the Dark One\'s wall at Irongate. The other heroes called it a miracle. You called it Tuesday. You were already designing something better.'),
  ClassStoryChapter(characterClass: CharacterClass.artificer, chapter: 3, title: 'The Grand Design', content: 'Before the Dark Throne, you deploy every gadget, every device, every brilliant invention you\'ve ever made. Turrets whir, bombs fly, and clockwork guardians march. The Dark One relied on ancient magic. You brought the future.'),

  // Templar
  ClassStoryChapter(characterClass: CharacterClass.templar, chapter: 1, title: 'The Sacred Charge', content: 'The Templar Order was founded to guard the world against exactly this kind of threat. You trained your whole life for a battle you hoped would never come. It came. And you are ready.'),
  ClassStoryChapter(characterClass: CharacterClass.templar, chapter: 2, title: 'The Unbreakable Vow', content: 'When the other Templars fell at the Siege of Ashwatch, you carried their banners forward alone. One warrior, twelve banners, and a vow that would not break. The enemy parted before you like water before a stone.'),
  ClassStoryChapter(characterClass: CharacterClass.templar, chapter: 3, title: 'The Final Vigil', content: 'Before the Dark Throne, you plant every fallen Templar\'s banner in the ground. Their strength flows through the sacred cloth and into you. You are not one warrior — you are every Templar who ever lived, united for this final stand.'),
];
