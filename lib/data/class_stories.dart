import '../models/enums.dart';

class ClassStoryChapter {
  final CharacterClass characterClass;
  final int chapter;
  final String title;
  final String content;
  const ClassStoryChapter({required this.characterClass, required this.chapter, required this.title, required this.content});
}

const List<ClassStoryChapter> classStories = [
  // ── Fighter ──────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 1,
    title: 'The Broken Sword',
    content: 'Every fighter begins with a weapon passed down through generations. Yours was shattered in the first battle against the Dark One\'s army. But a broken blade can still cut — and a broken warrior can still fight.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 2,
    title: 'The Call of Steel',
    content: 'When the village burned, you pulled the old blade from the ashes. The king\'s riders came through at dawn, calling for swords. You didn\'t hesitate. Some are born to answer that call.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 3,
    title: 'The Shield Wall',
    content: 'At Fort Ironhold, you learned that true strength is not in the arm that swings the sword, but in the heart that refuses to retreat. You held the line when others could not.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 4,
    title: 'The Shattered Line',
    content: 'The defense at Redmoor broke. Your shield splintered and allies fell around you. For the first time, you ran. The shame burned hotter than any wound.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 5,
    title: 'The Old Veteran',
    content: 'In a ruined tavern, you met a one-armed swordsman who taught you the Ironwind technique. "Strength breaks," he said. "Skill endures." His lessons changed how you fight forever.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 6,
    title: 'The Reforged Blade',
    content: 'You took your broken sword to the last forge still burning in Ashenvale. The smith melted it down and recast it — stronger, sharper, hungrier. Like you.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 7,
    title: 'The Siege of Blackgate',
    content: 'Three days without sleep. The Dark One\'s army threw wave after wave against the gate, and you stood before it every time. By the third night, even the enemy paused when they saw you coming.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.fighter, chapter: 8,
    title: 'The Last Stand',
    content: 'Before the Dark Throne, you understood. The blade was never broken — it was reforged in every battle, tempered by every wound. You are the weapon. You always were.',
  ),

  // ── Rogue ────────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 1,
    title: 'Shadows and Daggers',
    content: 'The thieves\' guild fell apart when the Dark One came. Loyalty means nothing when shadows come alive. But you survived — you always survive. That\'s what rogues do.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 2,
    title: 'The Poisoned Coin',
    content: 'A merchant offered you gold to look the other way while the Dark One\'s soldiers passed through. You took the coin, then slit the supply wagon\'s ropes in the dark. Some deals work both ways.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 3,
    title: 'The Hidden Path',
    content: 'You found passages that no map shows. Doors that no key opens. Secrets that the Dark One thought buried. Knowledge is the sharpest blade of all.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 4,
    title: 'The Trap Sprung',
    content: 'For the first time, someone out-tricked you. The ambush in the Whispering Caves cost you your best blade and nearly your life. You crawled out through a drainage pipe, bleeding and furious.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 5,
    title: 'The Shadowmancer\'s Gift',
    content: 'A dying shadowmancer pressed a vial of liquid darkness into your hands. "Drink it," she whispered. "The shadows will never betray you again." They haven\'t.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 6,
    title: 'The Invisible War',
    content: 'You dismantled the Dark One\'s spy network one agent at a time. No battles, no glory — just whispered words and daggers in the dark. By the time he noticed, it was already too late.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 7,
    title: 'The Longest Night',
    content: 'Alone in the Dark One\'s fortress, surrounded by guards and wards, you realized there was no way out. For one terrible hour, you believed the shadows had finally caught you.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.rogue, chapter: 8,
    title: 'The Final Trick',
    content: 'They never see it coming. Not the monsters, not the army, not even the Dark One himself. The greatest trick is making them think you\'re just a thief — right until the knife finds its mark.',
  ),

  // ── Cleric ───────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 1,
    title: 'The Healing Light',
    content: 'When the temples burned, you carried the sacred flame within. Your hands mend what darkness breaks. Your prayers reach ears that even gods have abandoned.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 2,
    title: 'The Oath Renewed',
    content: 'At the ruins of the Silver Cathedral, you knelt among the ashes and swore the old oath anew. While one soul still suffers, the light endures. While you still breathe, the light has a voice.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 3,
    title: 'The Weight of Mercy',
    content: 'You healed a fallen soldier of the Dark One\'s army. He wept, remembering who he had been before the corruption. Some stains cannot be washed clean — but you try anyway.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 4,
    title: 'The Silent Prayer',
    content: 'A child died in your arms, beyond all healing. That night your prayers went unanswered for the first time. The silence was deafening, and doubt crept in like a cold wind.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 5,
    title: 'The Wandering Saint',
    content: 'In the mountains, you found an ancient hermit who had kept the old rites alive for a hundred years. She taught you prayers that make the darkness scream. Faith has many voices.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 6,
    title: 'The Radiant Shield',
    content: 'Your healing touch grew stronger, your prayers fiercer. At the Battle of Dawnbreak, you held a shield of pure light that turned back an entire regiment. The wounded behind you lived because you refused to fall.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 7,
    title: 'The Corruption Within',
    content: 'The Dark One\'s poison seeped into your blood through a cursed wound. For three days you burned with shadow fever, fighting the corruption with nothing but willpower and whispered prayers.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.cleric, chapter: 8,
    title: 'The Sacred Sacrifice',
    content: 'The final prayer is not for healing. It is for strength — the strength to give everything, to pour out every last drop of light, to burn so brightly that even the Void recoils.',
  ),

  // ── Wizard ───────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 1,
    title: 'The Forbidden Library',
    content: 'The Academy of Arcane Arts was the first to fall. The Dark One coveted its knowledge. But you smuggled out the most dangerous tome of all — the one that contains his true name.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 2,
    title: 'The Burning Pages',
    content: 'Rather than let the Dark One\'s forces capture the Academy\'s knowledge, you set fire to the great library yourself. You saved one book. Everything else, you carry in your memory.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 3,
    title: 'The Spell Unwritten',
    content: 'Magic is not about power. It is about understanding. You have studied the Dark One\'s corruption, learned its patterns, found its weaknesses. Knowledge defeats power.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 4,
    title: 'The Backfire',
    content: 'A spell went wrong. Terribly wrong. The magical explosion nearly killed your companions and left a scar across the land that still smokes. You learned the cost of hubris that day.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 5,
    title: 'The Rune Stone',
    content: 'Deep beneath a mountain, you found a stone carved with runes older than language itself. Touching it unlocked spells that no living wizard has cast in a thousand years.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 6,
    title: 'The Arcane Mastery',
    content: 'Your spells now bend reality itself. Walls of force spring from thin air, fire dances at your fingertips, and lightning answers your call like an old friend. The elements have accepted you as their voice.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 7,
    title: 'The Mind Trap',
    content: 'The Dark One sent a psychic trap disguised as ancient knowledge. You fell for it. For an eternity that lasted seconds, you were lost in a labyrinth of your own memories, screaming without sound.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.wizard, chapter: 8,
    title: 'The Word of Unmaking',
    content: 'You speak the Word. Reality trembles. The Dark One\'s true name echoes through the Void, and for the first time in a thousand years, he knows fear.',
  ),

  // ── Paladin ──────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 1,
    title: 'The Oath of Dawn',
    content: 'When the Dark One\'s shadow fell across the land, you knelt in the ruins of the Silver Cathedral and swore an oath. No darkness would go unchallenged. No innocent would be abandoned.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 2,
    title: 'The First Crusade',
    content: 'You rode out with the last company of the Silver Order. Twelve paladins against an army of thousands. By nightfall, only you remained. The oath does not promise survival — only purpose.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 3,
    title: 'The Fallen Fortress',
    content: 'At the siege of Brightkeep, your shield shattered and your armor cracked. But when your allies fell behind you, the oath burned brighter than any blade. You held the gate alone until dawn.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 4,
    title: 'The Temptation',
    content: 'A dark spirit offered you power beyond measure — enough to end the war in a single stroke. All it asked was one small compromise. You refused, and the spirit laughed. The doubt lingered.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 5,
    title: 'The Sacred Forge',
    content: 'In the depths of Mount Solace, you found the forge where the first paladin\'s armor was made. The ancient smiths\' spirits tested your conviction, then blessed your blade with holy fire.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 6,
    title: 'The Beacon',
    content: 'Your oath now shines like a physical light. Allies rally around you, the wounded find strength, and the shadows recoil. You have become what the Silver Order always dreamed of — a living beacon.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 7,
    title: 'The Broken Oath',
    content: 'To save a child, you broke the paladin\'s code. The light flickered and nearly died. In the darkness that followed, you discovered that mercy is not weakness — it is the oath\'s truest form.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.paladin, chapter: 8,
    title: 'The Light Unbroken',
    content: 'Before the Dark Throne, the shadows press in from every side. But your oath is a sun that never sets. You raise your sword and the light pours forth — pure, blinding, unstoppable.',
  ),

  // ── Ranger ───────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 1,
    title: 'The Wild Road',
    content: 'The forests knew the Dark One was coming before anyone else. The birds stopped singing. The deer fled south. You read the signs and strung your bow. The wilds raised you, and now you fight for them.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 2,
    title: 'The Hunter\'s Vow',
    content: 'Standing at the edge of the Blackwood, you swore to track the corruption to its source. No trail too cold, no path too dangerous. The hunt had begun, and rangers never quit a trail.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 3,
    title: 'The Poisoned Trail',
    content: 'Deep in the Blackwood, the corruption turned every stream to sludge and every root to rot. You tracked the source for seven days through terrain no army could cross.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 4,
    title: 'The Lost Companion',
    content: 'Your wolf, Shadow, fell to a poisoned arrow meant for you. You buried her beneath an ancient oak and carved her name into the bark. The forest mourned with you that night.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 5,
    title: 'The Eagle\'s Gift',
    content: 'A golden eagle led you to a hidden grove where the trees still grew tall and green. The forest spirits granted you their blessing — your arrows now fly true even in darkness.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 6,
    title: 'The Pathfinder',
    content: 'You can track a shadow across stone now. Every broken twig and disturbed leaf tells a story. Armies move through the wilderness thinking themselves hidden, but nothing escapes your eyes.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 7,
    title: 'The Dying Forest',
    content: 'The Blackwood\'s heart was rotting. Trees that had stood for a thousand years toppled in silence. You walked through the dead forest alone, wondering if there was anything left to save.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.ranger, chapter: 8,
    title: 'The Final Arrow',
    content: 'One arrow. That is all you have left, and you have saved it for this moment. The wind dies. The world holds its breath. You loose — and it flies true, striking the heart of the Dark One\'s power.',
  ),

  // ── Warlock ──────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 1,
    title: 'The Forbidden Pact',
    content: 'Others pray to gods. You made a deal with something older and stranger. The power it gave you is terrifying, but the Dark One threatens everything — even the thing beyond your shadow.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 2,
    title: 'The Second Bargain',
    content: 'Your patron demanded more. It always demands more. This time the price was a year of your life. You paid without hesitation — what good are years if the world ends?',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 3,
    title: 'The Price of Power',
    content: 'Your patron demanded a memory as payment. You chose the memory of fear. Now nothing frightens you — not the monsters, not the dark, not even the creeping suspicion that you gave away more than you intended.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 4,
    title: 'The Leash Tightens',
    content: 'For one terrible moment, your patron took control of your body. You watched your own hands cast a spell you didn\'t choose. When control returned, you understood the leash goes both ways.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 5,
    title: 'The Rival Pact',
    content: 'You met another warlock whose patron was your patron\'s ancient enemy. Instead of fighting, you shared knowledge. Two leashes are harder to pull than one.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 6,
    title: 'The Eldritch Eye',
    content: 'Your patron\'s gifts now let you see things mortals were never meant to see — the threads of fate, the cracks in reality, the true shapes hiding behind familiar faces. Knowledge is terrifying. Knowledge is power.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 7,
    title: 'The Void Stares Back',
    content: 'You peered too deep into the darkness between worlds and something peered back. For three days you couldn\'t close your eyes without seeing it. Some doors, once opened, never fully close.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.warlock, chapter: 8,
    title: 'The Pact Fulfilled',
    content: 'At the Dark Throne, your patron whispers one final secret: the Dark One was once a warlock too, and his patron abandoned him. Yours will not. Eldritch fire erupts from your hands, fueled by a bond the Void cannot break.',
  ),

  // ── Summoner ─────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 1,
    title: 'The First Companion',
    content: 'Most wizards study spells. You studied friendship — the magical kind. Your first summon was a tiny fire sprite named Ember who refused to go back. Together, you decided to face the darkness.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 2,
    title: 'The Growing Pack',
    content: 'Ember was lonely, so you opened another gate. Then another. A frost wolf, a stone golem, a fairy made of starlight. Your little family grew, and each one chose to stay.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 3,
    title: 'The Severed Bond',
    content: 'The Dark One\'s magic tried to turn your summons against you. For a terrible moment, Ember\'s eyes turned black. But the bond held. Love is a magic older than corruption.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 4,
    title: 'The Broken Gate',
    content: 'A summoning went wrong and the gate collapsed with your golem halfway through. You heard it cry out before the portal snapped shut. You couldn\'t reach it. You couldn\'t save it.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 5,
    title: 'The Spirit Tongue',
    content: 'An ancient summoner\'s journal taught you the Spirit Tongue — the language that creatures of all planes understand. Now your summons don\'t just obey. They truly listen.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 6,
    title: 'The Legion of Friends',
    content: 'You can hold a dozen gates open at once now. Creatures of fire, frost, stone, and shadow answer your call instantly. Other mages summon servants. You summon allies.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 7,
    title: 'The Empty Plane',
    content: 'You opened a gate to Ember\'s home plane and found it empty — drained by the Dark One\'s hunger. If the darkness wins, every plane falls. Every friend you\'ve ever summoned loses their home.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.summoner, chapter: 8,
    title: 'The Grand Summoning',
    content: 'Before the Dark Throne, you open every gate at once. Creatures of fire, frost, stone, and starlight pour forth. An army of loyal friends, each one called by name, fighting for the world that gave them a home.',
  ),

  // ── Spellsword ───────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 1,
    title: 'The Dual Path',
    content: 'The warriors mocked your magic. The wizards mocked your sword. But you learned both, weaving steel and sorcery into something neither school had ever seen.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 2,
    title: 'The Outcast\'s Choice',
    content: 'Expelled from the Academy for carrying a blade, banned from the barracks for casting spells. You walked both paths alone, and that solitude forged a discipline neither school could teach.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 3,
    title: 'The Arcane Edge',
    content: 'In the Battle of Ashenmoor, a lich\'s barrier shrugged off every spell your allies cast. But your enchanted blade cut through it like paper. Magic resists magic — not a sword that speaks both languages.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 4,
    title: 'The Overreach',
    content: 'You tried to channel too much magic through your blade. The steel glowed white-hot and melted in your grip, burning your hand to the bone. Mastery demands respect, not just ambition.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 5,
    title: 'The Runesmith',
    content: 'In a forgotten tower, you found a runesmith who had mastered the art of binding spells to steel. She taught you to inscribe runes that make your blade sing with arcane power.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 6,
    title: 'The Harmonic Blade',
    content: 'Your sword and your spells are one instrument now. Each swing releases a wave of force, each parry absorbs energy you can redirect. You fight like music — rhythm, power, and perfect timing.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 7,
    title: 'The Anti-Magic Zone',
    content: 'The Dark One trapped you in a field that silenced all magic. Your spells died on your lips. But you still had a sword, and a sword doesn\'t need magic to kill. You cut your way free.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.spellsword, chapter: 8,
    title: 'The Perfect Strike',
    content: 'Steel and spell become one. Your blade burns with arcane fire as you charge the Dark Throne. Every cut is a spell, every spell is a cut. You are the bridge between two worlds, and you bring both crashing down.',
  ),

  // ── Druid ────────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 1,
    title: 'The Circle\'s Warning',
    content: 'The ancient oak in the heart of the Emerald Grove wept sap like tears. The druids read the omen clearly: the balance was breaking. You left the grove for the first time, carrying the forest\'s fury.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 2,
    title: 'The First Bloom',
    content: 'You pressed your hand to scorched earth and willed it to grow. A single flower pushed through the ash. It was small and fragile, but it was alive. That was enough. That was everything.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 3,
    title: 'The Withered Land',
    content: 'You pressed your hands to the corrupted earth and felt its agony. The land was dying, poisoned by the Dark One\'s touch. But deep below, the roots still lived.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 4,
    title: 'The Grove Falls',
    content: 'Word reached you that the Emerald Grove had fallen. The ancient oaks were burning, the circle was scattered. Your home, the heart of all natural magic, reduced to cinders and smoke.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 5,
    title: 'The World Tree\'s Seed',
    content: 'In a hidden valley, you found a seed from the World Tree — the first tree, the mother of all forests. You carry it close to your heart. When the darkness passes, you will plant it.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 6,
    title: 'The Wild Shape',
    content: 'Nature flows through you like a river now. Bear, eagle, wolf — you shift between forms as naturally as breathing. The corruption cannot touch what refuses to hold a single shape.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 7,
    title: 'The Last Green Place',
    content: 'You found the final patch of uncorrupted forest — three trees and a stream, surrounded by miles of dead earth. You stood guard for a week, pouring your life force into the soil to keep it alive.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.druid, chapter: 8,
    title: 'Nature\'s Wrath',
    content: 'Before the Dark Throne, you call upon the oldest magic of all. The earth shakes. Roots burst from the stone floor, vines wrap the pillars, and the wild, untamable force of nature rises to reclaim what the darkness stole.',
  ),

  // ── Monk ─────────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 1,
    title: 'The Empty Hand',
    content: 'The monastery on Mount Serenity taught you that the greatest weapon is the self. No sword, no armor — just discipline, breath, and the quiet certainty that your fists can shatter stone.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 2,
    title: 'The Descent',
    content: 'When the Dark One\'s army reached the mountain, the masters told you to go. "The world needs what we taught you," they said. You bowed once and descended into the chaos below.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 3,
    title: 'The Broken Silence',
    content: 'You had taken a vow of silence, but when the village children screamed for help, you broke it. Some vows matter less than others. Your war cry echoed through the valley.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 4,
    title: 'The Inner Storm',
    content: 'Rage consumed you after the monastery fell. You fought without discipline, without balance, without thought. A farmer you accidentally hurt during a battle brought you back to your senses with a simple question: "Who are you?"',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 5,
    title: 'The Wandering Master',
    content: 'In a bamboo forest, a blind monk caught your fist mid-strike without looking. "You fight the world," she said. "Fight yourself instead." Her training unlocked the flow of chi within you.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 6,
    title: 'The Iron Body',
    content: 'Blades bounce off your skin. Arrows deflect from your palms. Your body is a weapon the Dark One\'s army has no answer for — no shield can stop what no sword can cut.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 7,
    title: 'The Mountain\'s Silence',
    content: 'You returned to Mount Serenity and found it empty. The training halls, the meditation gardens, the ancient scrolls — all gone. You sat in the ruins and meditated for three days, searching for peace.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.monk, chapter: 8,
    title: 'The Still Point',
    content: 'In the chaos before the Dark Throne, you find perfect stillness. Time slows. You see every attack before it comes, dodge every shadow, and strike with a force that flows from the center of the world itself.',
  ),

  // ── Barbarian ────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 1,
    title: 'The Northland Fury',
    content: 'Your clan was the first to fall. The Dark One\'s army swept through the frozen north like a black blizzard. You alone survived, carrying nothing but rage and a battle-axe too heavy for two ordinary people.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 2,
    title: 'The Lone Wolf',
    content: 'Without your clan, you had nothing but anger. You wandered south, picking fights with anything that moved. Every battle was a funeral pyre for the people you\'d lost.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 3,
    title: 'The Blood Rage',
    content: 'They surrounded you — fifty of the Dark One\'s soldiers against one barbarian. When the red mist cleared, you stood alone in a field of broken shields. You don\'t remember the fight. You never do.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 4,
    title: 'The Rage\'s Cost',
    content: 'The red mist took you during a sparring match. When you came back, your friend was bleeding on the ground. The rage doesn\'t care who it hurts. That terrified you more than any monster.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 5,
    title: 'The Frost Spirit',
    content: 'In the ruins of your village, the spirit of your clan\'s ancestor appeared. "The rage is a gift," it said. "But a gift without control is a curse." It taught you the Berserker\'s Focus.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 6,
    title: 'The Unbreakable',
    content: 'Your body has become a weapon of war. Scars cover you like armor, each one a lesson. You\'ve been stabbed, burned, frozen, and cursed — and every morning you stand up and keep fighting.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 7,
    title: 'The Last Clansman',
    content: 'A survivor from your clan found you — just one, half-starved and nearly dead. You carried them for three days through enemy territory. If even one clansman lives, the clan lives.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.barbarian, chapter: 8,
    title: 'The Unstoppable',
    content: 'The Dark One throws everything at you. Spells, shadows, fear itself. You shrug it all off and keep walking forward. One step. Another. Another. Nothing can stop you. Nothing ever could. Your axe rises, and the Dark Throne cracks.',
  ),

  // ── Sorcerer ─────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 1,
    title: 'The Wild Gift',
    content: 'You didn\'t learn magic — it learned you. One day sparks flew from your fingers, the next day lightning. The Academy wouldn\'t take you because your power was "unstable." Perfect. Stable never saved the world.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 2,
    title: 'The Burning Village',
    content: 'Your power erupted when you were angry — a wave of flame that scorched half the village square. Nobody was hurt, but the looks on their faces said everything. You left that night.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 3,
    title: 'The Uncontrolled Burst',
    content: 'In the battle at Crimson Pass, your magic surged beyond anything you\'d felt before. The explosion carved a crater where the enemy army had stood. Your allies stared in awe and terror.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 4,
    title: 'The Surge',
    content: 'Your magic turned on you. Wild energy crackled through your body for an entire night, burning everything you touched. You lay in a crater of your own making, wondering if the power would consume you.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 5,
    title: 'The Chaos Weaver',
    content: 'A wandering sorcerer — the only other one you\'d ever met — taught you to ride the chaos instead of fighting it. "Don\'t control the wave," she said. "Surf it." Everything clicked.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 6,
    title: 'The Living Storm',
    content: 'Your power is a storm that never ends. Lightning dances in your eyes, fire curls around your fingers, and the air shimmers with barely contained energy. You don\'t cast spells anymore — you unleash them.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 7,
    title: 'The Silence',
    content: 'One morning, the magic was gone. Just — gone. No sparks, no lightning, no warmth. For three days you were ordinary, and the emptiness was worse than any pain you\'d ever felt.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.sorcerer, chapter: 8,
    title: 'The Raw Power',
    content: 'Before the Dark Throne, you stop holding back. Every wall you built to contain your power crumbles. Pure, wild, beautiful magic erupts from your very soul — chaotic, unpredictable, and more powerful than anything the Dark One has ever faced.',
  ),

  // ── Necromancer ──────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 1,
    title: 'The Misunderstood Art',
    content: 'People call you evil. They don\'t understand — death magic isn\'t about killing, it\'s about remembering. You speak to the fallen, honor the dead, and when they choose to rise, it is their choice.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 2,
    title: 'The First Voice',
    content: 'You heard your grandmother\'s voice from beyond the grave when you were twelve. She wasn\'t angry or sad. She just wanted to tell you where she\'d hidden the good biscuits. Death isn\'t what people think.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 3,
    title: 'The Grateful Dead',
    content: 'At the Battle of Hollow Fields, you raised the ancient heroes buried beneath the battlefield. They thanked you. A thousand years of rest was enough, they said. They had unfinished business.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 4,
    title: 'The Dark Mirror',
    content: 'The Dark One uses necromancy too — but his is a perversion, a slavery of souls. Seeing your own art twisted into chains of torment made you sick. You swore your dead would always be free.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 5,
    title: 'The Bone Library',
    content: 'Deep in the catacombs, you found the Bone Library — knowledge inscribed on the skulls of ancient necromancers. They shared their secrets willingly. The dead have no use for secrets.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 6,
    title: 'The Spirit General',
    content: 'Your undead don\'t shamble — they march. They remember their training, their honor, their purpose. You don\'t raise corpses. You recall heroes. And heroes know how to fight.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 7,
    title: 'The Hollow',
    content: 'You raised too many at once and felt your own life force drain away. For a terrible moment, you stood between life and death, and the dead reached for you from both sides.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.necromancer, chapter: 8,
    title: 'The Army of Ancestors',
    content: 'Before the Dark Throne, you call upon every hero who has ever fallen fighting the Dark One. They answer. A ghostly army rises, each spirit burning with the desire for justice. Death is not the end — it is reinforcements.',
  ),

  // ── Artificer ────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 1,
    title: 'The Tinkerer\'s Workshop',
    content: 'While others trained with swords and spells, you built things. Clockwork soldiers, explosive potions, a crossbow that reloads itself. The Dark One has magic and monsters. You have engineering.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 2,
    title: 'The Blueprint',
    content: 'You drew up plans for a weapon that could pierce the Dark One\'s armor. Everyone called you mad. You pinned the blueprint to your workshop wall and got to work. Mad is just another word for ambitious.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 3,
    title: 'The Mechanical Marvel',
    content: 'Your greatest invention — a walking siege tower powered by captured lightning — broke through the Dark One\'s wall at Irongate. The other heroes called it a miracle. You called it Tuesday.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 4,
    title: 'The Catastrophic Failure',
    content: 'The prototype exploded. Your workshop, your tools, months of work — gone in a flash of fire and smoke. You sat in the wreckage, singed and shaking, and started sketching the next version.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 5,
    title: 'The Dwarven Forge',
    content: 'The last dwarven master smith alive agreed to teach you the secrets of runic engineering. "Magic and gears are the same thing," she said. "Forces in, forces out. Just different languages."',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 6,
    title: 'The Arsenal',
    content: 'Your pack is a portable armory now — turrets that deploy in seconds, bombs that target only darkness, shields that regenerate themselves. Every battle teaches you something new to build.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 7,
    title: 'The Stolen Design',
    content: 'The Dark One\'s forces captured your blueprints and built corrupted versions of your machines. Facing your own inventions turned against you was the worst thing you\'ve ever experienced.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.artificer, chapter: 8,
    title: 'The Grand Design',
    content: 'Before the Dark Throne, you deploy every gadget, every device, every brilliant invention you\'ve ever made. Turrets whir, bombs fly, and clockwork guardians march. The Dark One relied on ancient magic. You brought the future.',
  ),

  // ── Templar ──────────────────────────────────────────────────
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 1,
    title: 'The Sacred Charge',
    content: 'The Templar Order was founded to guard the world against exactly this kind of threat. You trained your whole life for a battle you hoped would never come. It came. And you are ready.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 2,
    title: 'The Last Initiation',
    content: 'You were the final templar to complete the rites before the Order\'s fortress fell. The sacred words still echo in your mind. You carry the entire tradition on your shoulders now.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 3,
    title: 'The Unbreakable Vow',
    content: 'When the other Templars fell at the Siege of Ashwatch, you carried their banners forward alone. One warrior, twelve banners, and a vow that would not break.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 4,
    title: 'The Shattered Order',
    content: 'You found the Grand Templar\'s body on the battlefield, still clutching the Order\'s sacred standard. You took the standard and wept. You are the Templar Order now — all of it.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 5,
    title: 'The Reliquary',
    content: 'In a hidden vault beneath the fallen fortress, you found the Templar relics — ancient weapons blessed by the founders. Each one hummed with power when you touched it, recognizing your right.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 6,
    title: 'The Living Fortress',
    content: 'You fight like a fortress walks. Immovable, unbreakable, implacable. Allies shelter behind you. Enemies break upon you. The Dark One\'s army has learned to fear the banner you carry.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 7,
    title: 'The Heretic\'s Doubt',
    content: 'Alone in the darkness, you wondered if the Order was wrong. If all this sacrifice was pointless. The doubt lasted one night. By dawn, you planted the banner and stood watch again.',
  ),
  ClassStoryChapter(
    characterClass: CharacterClass.templar, chapter: 8,
    title: 'The Final Vigil',
    content: 'Before the Dark Throne, you plant every fallen Templar\'s banner in the ground. Their strength flows through the sacred cloth and into you. You are not one warrior — you are every Templar who ever lived, united for this final stand.',
  ),
];
