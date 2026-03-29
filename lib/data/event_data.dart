import 'dart:math';
import '../models/enums.dart';

class EventChoice {
  final String text;
  final String result;
  final int goldChange;
  final int hpChange;
  final int hpChangeSingle; // damages/heals ONE random alive party member
  const EventChoice({required this.text, required this.result, this.goldChange = 0, this.hpChange = 0, this.hpChangeSingle = 0});
}

class GameEvent {
  final String title;
  final String description;
  final String theme;
  final String? mapName; // if set, this is a map-specific hazard event
  final List<EventChoice> choices;
  const GameEvent({required this.title, required this.description, required this.theme, this.mapName, required this.choices});
}

const Map<String, List<CharacterClass>> themeClassAffinities = {
  'forest': [CharacterClass.ranger, CharacterClass.druid],
  'dark': [CharacterClass.warlock, CharacterClass.necromancer, CharacterClass.rogue],
  'holy': [CharacterClass.cleric, CharacterClass.paladin, CharacterClass.templar],
  'arcane': [CharacterClass.wizard, CharacterClass.sorcerer, CharacterClass.summoner, CharacterClass.artificer],
  'martial': [CharacterClass.fighter, CharacterClass.barbarian, CharacterClass.monk, CharacterClass.spellsword],
  'wild': [CharacterClass.barbarian, CharacterClass.druid, CharacterClass.ranger, CharacterClass.monk],
};


const List<GameEvent> gameEvents = [
  // ── forest ───────────────────────────────────────────────────
  GameEvent(
    theme: 'forest',
    title: 'Enchanted Forest',
    description: 'The trees ahead glow with silver light. Tiny sprites dart between the branches, giggling.',
    choices: [
      EventChoice(text: 'Follow the sprites (+20 HP, -10 gold)', result: 'The sprites lead you to a healing spring, but steal a few coins along the way!', hpChange: 20, goldChange: -10),
      EventChoice(text: 'Gather glowing fruit (+10 HP)', result: 'The silver fruit tastes like starlight. Your wounds tingle and start to close.', hpChange: 10),
      EventChoice(text: 'Pass through quickly', result: 'The sprites wave goodbye. One sticks its tongue out at you.'),
    ],
  ),
  GameEvent(
    theme: 'forest',
    title: 'Fairy Ring',
    description: 'You stumble upon a circle of mushrooms glowing with faint light.',
    choices: [
      EventChoice(text: 'Step inside', result: 'The fairies heal your wounds and give you gifts!', hpChange: 35, goldChange: 15),
      EventChoice(text: 'Leave an offering (-10g)', result: 'The fairies are pleased and bless your journey!', goldChange: -10, hpChange: 20),
      EventChoice(text: 'Walk around it', result: 'Better safe than sorry with fairy magic.'),
    ],
  ),
  GameEvent(
    theme: 'forest',
    title: 'Mushroom Grove',
    description: 'Glowing mushrooms fill a moonlit clearing. Their spores shimmer in the air.',
    choices: [
      EventChoice(text: 'Eat the blue ones (+15 HP)', result: 'Sweet and refreshing! Your wounds close slightly.', hpChange: 15),
      EventChoice(text: 'Eat the red ones (-10 HP, +30 gold)', result: 'Bitter! But your vision sharpens and you spot a hidden treasure cache.', goldChange: 30, hpChange: -10),
      EventChoice(text: 'Gather them to sell (+15 gold)', result: 'An alchemist will pay well for these.', goldChange: 15),
    ],
  ),
  GameEvent(
    theme: 'forest',
    title: 'Dragon Egg',
    description: 'A shimmering egg sits in a nest of warm stones, pulsing with a faint glow. Is that... a dragon egg?',
    choices: [
      EventChoice(text: 'Keep it warm (+15 HP)', result: 'The egg hums happily. A wave of warmth heals your party!', hpChange: 15),
      EventChoice(text: 'Sell it (+35 gold)', result: 'A collector pays a fortune for the egg. You hope the dragon mom doesn\'t find out.', goldChange: 35),
      EventChoice(text: 'Leave it alone', result: 'Probably best not to mess with dragon eggs. You walk away quickly.'),
    ],
  ),
  GameEvent(
    theme: 'forest',
    title: 'The Witch\'s Garden',
    description: 'A cozy cottage surrounded by an impossible garden. A friendly witch waves from her porch.',
    choices: [
      EventChoice(text: 'Accept her tea (+25 HP)', result: 'The tea tastes like sunshine and honey. Your wounds melt away!', hpChange: 25),
      EventChoice(text: 'Help with her garden (+15 gold, +5 HP)', result: 'She pays you for pulling weeds and sends you off with a cookie. Nice lady!', goldChange: 15, hpChange: 5),
      EventChoice(text: 'Decline politely', result: 'She nods. "Come back anytime, dears!" She seems genuinely kind.'),
    ],
  ),
  GameEvent(
    theme: 'forest',
    title: 'The Fairy Court',
    description: 'Tiny fairy nobles hold court on a toadstool throne. They regard you with curious eyes.',
    choices: [
      EventChoice(text: 'Bow and show respect (+20 HP, +10 gold)', result: 'The fairies are delighted by your manners! They shower you with blessings and tiny gold coins.', hpChange: 20, goldChange: 10),
      EventChoice(text: 'Dance with them (+15 HP)', result: 'You dance a silly jig and the fairies laugh. Their magic heals you as you twirl!', hpChange: 15),
      EventChoice(text: 'Ask them for directions', result: 'The fairies point you onward with glowing arrows. How helpful!'),
    ],
  ),

  // ── dark ─────────────────────────────────────────────────────
  GameEvent(
    theme: 'dark',
    title: 'The Cursed Blade',
    description: 'A dark sword lies embedded in a stone altar. It radiates power... and malice.',
    choices: [
      EventChoice(text: 'Take it (+15 gold, -20 HP)', result: 'The blade cuts your hand as you grasp it, but its power is undeniable.', goldChange: 15, hpChange: -20),
      EventChoice(text: 'Destroy it (+5 HP)', result: 'You shatter the blade. A wave of warmth washes over your party.', hpChange: 5),
      EventChoice(text: 'Leave it', result: 'Some things are best left alone.'),
    ],
  ),
  GameEvent(
    theme: 'dark',
    title: 'The Cursed Mirror',
    description: 'A tall mirror stands alone in a clearing. Your reflections look... wrong. They\'re smiling when you\'re not.',
    choices: [
      EventChoice(text: 'Smash the mirror (+5 HP)', result: 'The glass shatters and a dark mist escapes. Your party feels lighter.', hpChange: 5),
      EventChoice(text: 'Talk to your reflection (+25 gold, -20 HP)', result: 'Your reflection hands you a bag of gold through the glass, then scratches you. Weird.', goldChange: 25, hpChange: -20),
      EventChoice(text: 'Cover it and leave', result: 'You drape a cloak over it. Some things are better left unreflected.'),
    ],
  ),
  GameEvent(
    theme: 'dark',
    title: 'The Dark Portal',
    description: 'A swirling purple portal hovers in the air. Strange whispers drift from the other side.',
    choices: [
      EventChoice(text: 'Reach through (+25 gold, -15 HP)', result: 'You grab something shiny and yank your hand back. Treasure! And only minor void burns.', goldChange: 25, hpChange: -15),
      EventChoice(text: 'Seal the portal (+10 HP)', result: 'You push the portal closed with all your might. The land around it brightens.', hpChange: 10),
      EventChoice(text: 'Back away slowly', result: 'You leave the portal alone. The whispers sound disappointed.'),
    ],
  ),
  GameEvent(
    theme: 'dark',
    title: 'Ambushed!',
    description: 'Bandits leap from the shadows! They demand your gold or your lives.',
    choices: [
      EventChoice(text: 'Pay them (-30 gold)', result: 'The bandits take your gold and vanish. At least no one was hurt.', goldChange: -30),
      EventChoice(text: 'Fight back (-15 HP, +20 gold)', result: 'A fierce scuffle! You take some hits but loot their camp.', goldChange: 20, hpChange: -15),
      EventChoice(text: 'Bluff them (+10 gold)', result: 'You convince them a dragon is following you. They flee, dropping coins.', goldChange: 10),
    ],
  ),
  GameEvent(
    theme: 'dark',
    title: 'The Haunted Tavern',
    description: 'A dusty tavern stands at the crossroads. Through the windows, ghostly figures raise their mugs.',
    choices: [
      EventChoice(text: 'Join the ghosts for a drink (+20 HP)', result: 'The spirits are friendly! Their ghostly ale is surprisingly refreshing.', hpChange: 20),
      EventChoice(text: 'Search behind the bar (+25 gold)', result: 'You find a stash of coins the innkeeper left behind centuries ago.', goldChange: 25),
      EventChoice(text: 'Run away', result: 'Nope. Nope nope nope. You sprint down the road.'),
    ],
  ),
  GameEvent(
    theme: 'dark',
    title: 'Pirate Ghost Ship',
    description: 'A spectral ship floats above a dried-up riverbed. A ghostly captain leans over the rail.',
    choices: [
      EventChoice(text: 'Challenge the captain (+40 gold, -25 HP)', result: 'You beat the ghost in a duel! He tosses you his treasure chest, grumbling.', goldChange: 40, hpChange: -25),
      EventChoice(text: 'Trade with the crew (+15 gold)', result: 'The ghost pirates have some surprisingly good deals on slightly haunted merchandise.', goldChange: 15),
      EventChoice(text: 'Sail away on foot', result: 'You power-walk away from the ghost ship. Dignity intact.'),
    ],
  ),

  // ── holy ─────────────────────────────────────────────────────
  GameEvent(
    theme: 'holy',
    title: 'Ancient Shrine',
    description: 'An ancient shrine stands before you, covered in moss and runes.',
    choices: [
      EventChoice(text: 'Pray at the shrine', result: 'A warm light washes over your party.', hpChange: 25),
      EventChoice(text: 'Search for treasure', result: 'You find some coins hidden in the stones!', goldChange: 20),
      EventChoice(text: 'Read the runes', result: 'The runes speak of an ancient power. Interesting...'),
    ],
  ),
  GameEvent(
    theme: 'holy',
    title: 'Lost Traveler',
    description: 'A lost traveler stumbles out of the bushes. "Please, can you help me?"',
    choices: [
      EventChoice(text: 'Give them gold (-15g)', result: 'The traveler thanks you profusely and gives you a blessing!', goldChange: -15, hpChange: 15),
      EventChoice(text: 'Point them to safety', result: '"Thank you, kind adventurers!"'),
      EventChoice(text: 'Rob them (+25g)', result: 'Not very heroic, but profitable...', goldChange: 25),
    ],
  ),
  GameEvent(
    theme: 'holy',
    title: 'The Weary Soldier',
    description: 'A wounded soldier from the king\'s army sits by the road, clutching a sealed letter.',
    choices: [
      EventChoice(text: 'Heal him (+10 HP, -10 gold)', result: 'He shares healing herbs with your party in gratitude.', goldChange: -10, hpChange: 10),
      EventChoice(text: 'Take the letter (+25 gold)', result: 'The letter contained a bounty notice. You claim the reward at the next town.', goldChange: 25),
    ],
  ),
  GameEvent(
    theme: 'holy',
    title: 'The Oracle\'s Pool',
    description: 'A still pool of silver water. Legend says it shows visions of what lies ahead.',
    choices: [
      EventChoice(text: 'Drink deeply (+20 HP, -15 gold)', result: 'Visions of the future flood your mind. Your body feels renewed.', goldChange: -15, hpChange: 20),
      EventChoice(text: 'Toss in a coin (-5 gold, +5 HP)', result: 'The water shimmers. A gentle warmth spreads through your party.', goldChange: -5, hpChange: 5),
      EventChoice(text: 'Walk away', result: 'The pool grows still once more. Some mysteries are meant to remain.'),
    ],
  ),
  GameEvent(
    theme: 'holy',
    title: 'The Phoenix Nest',
    description: 'High on a cliff, a nest of golden feathers smolders. A tiny phoenix chick chirps at you.',
    choices: [
      EventChoice(text: 'Feed it (+20 HP)', result: 'The chick nuzzles you and its warmth heals your party! It chirps a thank you.', hpChange: 20),
      EventChoice(text: 'Gather fallen feathers (+30 gold)', result: 'Phoenix feathers are worth a fortune! The chick doesn\'t mind — they grow back.', goldChange: 30),
      EventChoice(text: 'Warm your hands (-5 gold, +5 HP)', result: 'The fire is cozy. You accidentally melt a few coins but feel refreshed.', goldChange: -5, hpChange: 5),
    ],
  ),

  // ── arcane ───────────────────────────────────────────────────
  GameEvent(
    theme: 'arcane',
    title: 'Mysterious Well',
    description: 'You find an old stone well. Faint magical light glows from within.',
    choices: [
      EventChoice(text: 'Toss in a coin (-5g)', result: 'The well shimmers! Your party feels refreshed.', goldChange: -5, hpChange: 20),
      EventChoice(text: 'Drink from the well', result: 'The water is cool and slightly magical.', hpChange: 10),
      EventChoice(text: 'Walk away', result: 'Probably wise. Who knows what\'s down there.'),
    ],
  ),
  GameEvent(
    theme: 'arcane',
    title: 'Magic Fountain',
    description: 'A beautiful fountain flows with sparkling water. Different colored streams pour from three spouts.',
    choices: [
      EventChoice(text: 'Drink the golden stream (+20 gold)', result: 'You cough up a gold coin! Then another! Weird, but profitable.', goldChange: 20),
      EventChoice(text: 'Drink the blue stream (+15 HP)', result: 'Cool, refreshing magic flows through your body, mending cuts and bruises.', hpChange: 15),
      EventChoice(text: 'Drink the red stream (-10 HP, +30 gold)', result: 'Spicy! Very spicy! But a pile of rubies appears at your feet.', hpChange: -10, goldChange: 30),
    ],
  ),
  GameEvent(
    theme: 'arcane',
    title: 'Wizard Duel',
    description: 'Two wizards argue in the road, sparks flying from their staffs. "You there! Settle this for us!"',
    choices: [
      EventChoice(text: 'Side with the blue wizard (+20 gold)', result: 'Blue wins! He rewards you with gold. The red wizard huffs and teleports away.', goldChange: 20),
      EventChoice(text: 'Side with the red wizard (+15 HP)', result: 'Red wins! She heals your party as thanks. The blue wizard grumbles and vanishes.', hpChange: 15),
      EventChoice(text: 'Tell them to share (+10 gold, +10 HP)', result: 'They blink, then laugh. "Fair point!" They both give you a small reward.', goldChange: 10, hpChange: 10),
    ],
  ),
  GameEvent(
    theme: 'arcane',
    title: 'Crystal Cave',
    description: 'A cavern of glowing crystals hums with magical energy. The walls pulse with rainbow light.',
    choices: [
      EventChoice(text: 'Harvest crystals (+30 gold, -10 HP)', result: 'The crystals are sharp but valuable! You fill your bags, nursing a few cuts.', goldChange: 30, hpChange: -10),
      EventChoice(text: 'Meditate inside (+20 HP)', result: 'The crystal energy flows through your party. Wounds close and spirits lift.', hpChange: 20),
      EventChoice(text: 'Explore deeper (-20 HP, +40 gold)', result: 'The cave goes deep! You take some falls but find a treasure trove at the bottom.', hpChange: -20, goldChange: 40),
    ],
  ),
  GameEvent(
    theme: 'arcane',
    title: 'Fallen Meteor',
    description: 'A glowing rock lies in a smoking crater. Strange energy crackles from its surface.',
    choices: [
      EventChoice(text: 'Touch the meteor (-15 HP, +35 gold)', result: 'It burns! But fragments of star-metal break off. These are incredibly valuable.', hpChange: -15, goldChange: 35),
      EventChoice(text: 'Absorb its energy (+10 HP)', result: 'Cosmic energy flows through your party. You feel stronger somehow.', hpChange: 10),
      EventChoice(text: 'Mark it on your map', result: 'You\'ll come back for this later. Maybe. If the world survives.'),
    ],
  ),
  GameEvent(
    theme: 'arcane',
    title: 'Ancient Golem',
    description: 'A towering stone golem blocks the road. Its eyes flicker between red and blue.',
    choices: [
      EventChoice(text: 'Repair its rune (+20 HP)', result: 'You fix the cracked rune on its chest. It bows and blesses your party with ancient magic.', hpChange: 20),
      EventChoice(text: 'Mine its gems (+30 gold, -15 HP)', result: 'You pry out some valuable gemstones, but it takes a swipe at you. Worth the bruises!', goldChange: 30, hpChange: -15),
      EventChoice(text: 'Walk around it', result: 'The golem watches you go with sad, flickering eyes.'),
    ],
  ),

  // ── martial ──────────────────────────────────────────────────
  GameEvent(
    theme: 'martial',
    title: 'Bridge Troll',
    description: '"You gotta pay the toll to cross my bridge!" says a large, grumpy troll.',
    choices: [
      EventChoice(text: 'Pay the toll (-30g)', result: '"Pleasure doing business!" The troll steps aside.', goldChange: -30),
      EventChoice(text: 'Tell a joke', result: 'The troll laughs so hard he falls over. You cross freely!'),
      EventChoice(text: 'Intimidate', result: 'The troll reconsiders and lets you pass. "Fine, just go!"'),
    ],
  ),
  GameEvent(
    theme: 'martial',
    title: 'Collapsed Mine',
    description: 'An old mine entrance, partially collapsed. You can hear something glittering inside.',
    choices: [
      EventChoice(text: 'Crawl in (+35 gold, -15 HP)', result: 'Tight squeeze! Rocks scrape and cut, but the gems inside are worth it.', goldChange: 35, hpChange: -15),
      EventChoice(text: 'Send the smallest hero (-5 HP, +20 gold)', result: 'They squeeze through and return with a handful of gems.', goldChange: 20, hpChange: -5),
      EventChoice(text: 'Move on', result: 'Not worth the risk. The road calls.'),
    ],
  ),
  GameEvent(
    theme: 'martial',
    title: 'The Sleeping Giant',
    description: 'A hill-sized giant snores peacefully in a meadow. His pockets are the size of houses.',
    choices: [
      EventChoice(text: 'Climb into a pocket (+35 gold, -15 HP)', result: 'You grab fistfuls of giant-sized coins! But the giant rolls over on you. Oof.', goldChange: 35, hpChange: -15),
      EventChoice(text: 'Sing a lullaby (+15 HP)', result: 'Your singing keeps the giant asleep. Peaceful vibes heal your party.', hpChange: 15),
      EventChoice(text: 'Tiptoe past', result: 'You hold your breath and sneak by. No one wants to wake a giant.'),
    ],
  ),
  GameEvent(
    theme: 'martial',
    title: 'Merchant Caravan',
    description: 'A merchant caravan has been attacked! Goods are scattered everywhere.',
    choices: [
      EventChoice(text: 'Help the merchants (+10 HP, +10 gold)', result: 'Grateful, they share supplies and gold for your kindness.', goldChange: 10, hpChange: 10),
      EventChoice(text: 'Loot the wreckage (+40 gold)', result: 'No one is watching. The gold flows freely from broken chests.', goldChange: 40),
      EventChoice(text: 'Pursue the attackers (-20 HP, +25 gold)', result: 'You catch the thieves! A rough fight, but you recover some of the stolen goods.', goldChange: 25, hpChange: -20),
    ],
  ),
  GameEvent(
    theme: 'martial',
    title: 'The Riddle Sphinx',
    description: 'A stone sphinx blocks the path. "Answer my riddle, or pay the price," it rumbles.',
    choices: [
      EventChoice(text: 'Try to answer (+30 gold)', result: '"What has keys but no locks?" A piano! The sphinx grumbles and drops a bag of gold.', goldChange: 30),
      EventChoice(text: 'Pay the toll (-20 gold)', result: 'The sphinx accepts your gold and slides aside with a grinding of stone.', goldChange: -20),
      EventChoice(text: 'Climb over it (-10 HP)', result: 'The sphinx snaps at you! You scramble over with a few scratches.', hpChange: -10),
    ],
  ),
  GameEvent(
    theme: 'martial',
    title: 'Goblin Market',
    description: 'A rowdy goblin bazaar fills a clearing. Goblins hawk bizarre wares from rickety stalls.',
    choices: [
      EventChoice(text: 'Buy a mystery potion (-15 gold, +15 HP)', result: 'It tastes like old socks, but it works! Your party feels much better.', goldChange: -15, hpChange: 15),
      EventChoice(text: 'Trade stories (+10 gold)', result: 'The goblins love your adventure tales and toss you some coins as thanks.', goldChange: 10),
      EventChoice(text: 'Pickpocket a goblin (+20 gold, -5 HP)', result: 'You snag a coin purse but one of them bites your hand. Worth it!', goldChange: 20, hpChange: -5),
    ],
  ),

  // ── wild ─────────────────────────────────────────────────────
  GameEvent(
    theme: 'wild',
    title: 'Wandering Merchant',
    description: 'A cheerful merchant waves you down. "I have a special deal for travelers!"',
    choices: [
      EventChoice(text: 'Buy supplies (-20g, heal 30hp)', result: 'The supplies restore your party!', goldChange: -20, hpChange: 30),
      EventChoice(text: 'Chat and move on', result: 'The merchant waves goodbye cheerfully.'),
    ],
  ),
  GameEvent(
    theme: 'wild',
    title: 'The Gambling Imp',
    description: 'A tiny imp sits cross-legged on a rock, shuffling cards. "Care for a wager?" it grins.',
    choices: [
      EventChoice(text: 'Play it safe (+5 gold)', result: 'A boring game. The imp yawns and tosses you a coin.', goldChange: 5),
      EventChoice(text: 'Go all in (+40 gold, -25 HP)', result: 'You win big! But the imp hexes you on the way out.', goldChange: 40, hpChange: -25),
      EventChoice(text: 'Refuse', result: 'The imp shrugs and disappears in a puff of smoke.'),
    ],
  ),
  GameEvent(
    theme: 'wild',
    title: 'The Talking Crow',
    description: 'A large crow lands on a branch and stares at you. "I know things," it says. "Useful things."',
    choices: [
      EventChoice(text: 'Pay for information (-15 gold, +10 HP)', result: 'The crow tells you about a shortcut and a healing herb nearby. Smart bird!', goldChange: -15, hpChange: 10),
      EventChoice(text: 'Offer it food (+5 HP)', result: 'The crow eats your crumbs and caws a blessing. Crows remember kindness.', hpChange: 5),
      EventChoice(text: 'Shoo it away', result: 'The crow flies off, muttering rude words. Some of them are surprisingly creative.'),
    ],
  ),
  GameEvent(
    theme: 'wild',
    title: 'Abandoned Forge',
    description: 'A dwarven forge sits cold and silent. Tools and half-finished weapons line the walls.',
    choices: [
      EventChoice(text: 'Fire it up and craft (+10 HP, +10 gold)', result: 'You repair some gear and forge a few trinkets to sell. Good honest work!', hpChange: 10, goldChange: 10),
      EventChoice(text: 'Scavenge for valuables (+25 gold)', result: 'The dwarves left behind some fine metals and gems. Finders keepers!', goldChange: 25),
      EventChoice(text: 'Rest by the cold forge (+10 HP)', result: 'It\'s quiet and sheltered. Your party gets some much-needed rest.', hpChange: 10),
    ],
  ),
  GameEvent(
    theme: 'wild',
    title: 'Traveling Circus',
    description: 'A colorful circus tent appears out of nowhere. A ringmaster in a top hat beckons you inside.',
    choices: [
      EventChoice(text: 'Watch the show (-10 gold, +15 HP)', result: 'Fire-breathers and acrobats! The show is amazing and lifts everyone\'s spirits.', goldChange: -10, hpChange: 15),
      EventChoice(text: 'Join the act (+20 gold)', result: 'You juggle swords for the crowd. They shower you with coins!', goldChange: 20),
      EventChoice(text: 'Sneak backstage (+15 gold, -10 HP)', result: 'You find a chest of coins but trip over a sleeping lion. Ouch!', goldChange: 15, hpChange: -10),
    ],
  ),
];

/// Selects a random event matching the given theme.
GameEvent selectEventForTheme(String theme, [Random? rng]) {
  rng ??= Random();
  final themed = gameEvents.where((e) => e.theme == theme).toList();
  if (themed.isEmpty) {
    return gameEvents[rng.nextInt(gameEvents.length)];
  }
  return themed[rng.nextInt(themed.length)];
}

/// Selects a map-specific hazard event, or null if none exist for this map.
GameEvent? selectHazardForMap(String mapName, [Random? rng]) {
  rng ??= Random();
  final hazards = mapHazardEvents.where((e) => e.mapName == mapName).toList();
  if (hazards.isEmpty) return null;
  return hazards[rng.nextInt(hazards.length)];
}

// ── MAP-SPECIFIC HAZARD EVENTS ─────────────────────────────────
const List<GameEvent> mapHazardEvents = [

  // ── Forest ──
  GameEvent(
    theme: 'forest', mapName: 'Forest',
    title: 'Falling Branch',
    description: 'A loud CRACK echoes above. A massive branch is plummeting toward your party!',
    choices: [
      EventChoice(text: 'Dive out of the way', result: 'You dodge just in time, but one of your party catches a scrape.', hpChangeSingle: -10),
      EventChoice(text: 'Try to catch it', result: 'Bad idea. The branch is way heavier than it looked.', hpChangeSingle: -20),
      EventChoice(text: 'Shield the party', result: 'You take the hit but protect everyone else.', hpChangeSingle: -15),
    ],
  ),

  // ── Desert ──
  GameEvent(
    theme: 'wild', mapName: 'Desert',
    title: 'Sandstorm',
    description: 'The horizon darkens. A wall of sand barrels toward you with terrifying speed.',
    choices: [
      EventChoice(text: 'Hunker down', result: 'You cover your faces and wait it out. The sand stings but you survive.', hpChange: -8),
      EventChoice(text: 'Run for shelter', result: 'One of your party trips in the blinding sand.', hpChangeSingle: -18),
      EventChoice(text: 'Push through it', result: 'You press on through the storm. Everyone takes a beating.', hpChange: -12),
    ],
  ),

  // ── Swamp ──
  GameEvent(
    theme: 'wild', mapName: 'Swamp',
    title: 'Bog Sinkhole',
    description: 'The ground gives way! One of your party sinks waist-deep into thick, bubbling muck.',
    choices: [
      EventChoice(text: 'Pull them out quickly', result: 'You yank them free, but the suction wrenches their leg.', hpChangeSingle: -15),
      EventChoice(text: 'Throw a rope', result: 'It takes a while but you haul them out safely. Just some bruises.', hpChangeSingle: -8),
      EventChoice(text: 'Everyone help at once', result: 'You all crowd too close and the bank starts crumbling too.', hpChange: -5),
    ],
  ),

  // ── Tundra ──
  GameEvent(
    theme: 'wild', mapName: 'Tundra',
    title: 'Thin Ice',
    description: 'You hear a sickening crack beneath your feet. The ice is giving way!',
    choices: [
      EventChoice(text: 'Spread out and crawl', result: 'You inch across on your bellies. Cold but safe. Mostly.', hpChange: -5),
      EventChoice(text: 'Sprint across', result: 'One of your party plunges through into the freezing water!', hpChangeSingle: -22),
      EventChoice(text: 'Go around', result: 'The long way takes its toll in the bitter cold.', hpChange: -8),
    ],
  ),

  // ── Volcano ──
  GameEvent(
    theme: 'arcane', mapName: 'Volcano',
    title: 'Lava Geyser',
    description: 'The ground rumbles and a jet of molten rock erupts right beside the path!',
    choices: [
      EventChoice(text: 'Jump back!', result: 'You dodge the worst of it, but the heat singes everyone.', hpChange: -8),
      EventChoice(text: 'Shield your face and run', result: 'Splatter catches one of your party. Ow!', hpChangeSingle: -20),
      EventChoice(text: 'Wait for it to stop', result: 'The heat is brutal while you wait. Everyone is drenched in sweat.', hpChange: -10),
    ],
  ),

  // ── Mountain Pass ──
  GameEvent(
    theme: 'martial', mapName: 'Mountain Pass',
    title: 'Rockslide',
    description: 'Boulders tumble down the mountainside! The path ahead is a gauntlet of falling stone.',
    choices: [
      EventChoice(text: 'Dash through', result: 'A rock clips one of your party on the shoulder. Could have been worse!', hpChangeSingle: -18),
      EventChoice(text: 'Take cover under an overhang', result: 'Smart thinking. You wait it out with only minor debris.', hpChange: -5),
      EventChoice(text: 'Try to climb above it', result: 'The climb is treacherous. Everyone takes scrapes.', hpChange: -8),
    ],
  ),

  // ── Coastal Cliffs ──
  GameEvent(
    theme: 'wild', mapName: 'Coastal Cliffs',
    title: 'Rogue Wave',
    description: 'A massive wave surges up the cliffside, crashing over the narrow path!',
    choices: [
      EventChoice(text: 'Grab onto the rocks', result: 'The water batters you but you hold on. One party member loses their grip briefly.', hpChangeSingle: -15),
      EventChoice(text: 'Drop flat and hold', result: 'The water washes over everyone. Cold and bruised but alive.', hpChange: -8),
      EventChoice(text: 'Run to higher ground', result: 'You scramble up in time. Just some wet boots.', hpChange: -3),
    ],
  ),

  // ── Plains ──
  GameEvent(
    theme: 'martial', mapName: 'Plains',
    title: 'Stampede',
    description: 'The ground shakes. A herd of wild beasts thunders across the plains directly at you!',
    choices: [
      EventChoice(text: 'Stand your ground and part them', result: 'Brave but risky. One of your party gets clipped by a horn.', hpChangeSingle: -18),
      EventChoice(text: 'Dive to the side', result: 'You barely avoid the stampede. Everyone is shaken.', hpChange: -5),
      EventChoice(text: 'Try to ride one', result: 'This was a terrible idea. Getting bucked off hurts.', hpChangeSingle: -25),
    ],
  ),

  // ── Deep Jungle ──
  GameEvent(
    theme: 'forest', mapName: 'Deep Jungle',
    title: 'Venomous Vines',
    description: 'Barbed vines lash out from the undergrowth, wrapping around one of your party!',
    choices: [
      EventChoice(text: 'Cut them free', result: 'You hack through the vines. The thorns leave nasty cuts.', hpChangeSingle: -15),
      EventChoice(text: 'Burn the vines', result: 'The fire works but the smoke chokes everyone.', hpChange: -8),
      EventChoice(text: 'Pull them out by force', result: 'The thorns dig deeper as you pull. Painful but effective.', hpChangeSingle: -20),
    ],
  ),

  // ── Cursed Wasteland ──
  GameEvent(
    theme: 'dark', mapName: 'Cursed Wasteland',
    title: 'Curse Miasma',
    description: 'A sickly purple fog rolls across the wasteland. It burns where it touches skin.',
    choices: [
      EventChoice(text: 'Hold your breath and push through', result: 'You make it through but the curse saps everyone\'s strength.', hpChange: -12),
      EventChoice(text: 'Cover up and go slow', result: 'One party member\'s cloth slips. The miasma finds bare skin.', hpChangeSingle: -20),
      EventChoice(text: 'Wait for it to pass', result: 'It lingers for hours. The ambient curse takes a toll.', hpChange: -10),
    ],
  ),

  // ── Cave System ──
  GameEvent(
    theme: 'martial', mapName: 'Cave System',
    title: 'Stalactite Collapse',
    description: 'A tremor shakes the cave. Stalactites crack and plummet from the ceiling!',
    choices: [
      EventChoice(text: 'Shield your heads and run', result: 'A stalactite smashes into one of your party\'s shoulder!', hpChangeSingle: -18),
      EventChoice(text: 'Hug the cave wall', result: 'Most debris misses you. A few sharp chips nick everyone.', hpChange: -6),
      EventChoice(text: 'Freeze and hope for the best', result: 'A big one comes straight down. Direct hit!', hpChangeSingle: -25),
    ],
  ),

  // ── Ancient Ruins ──
  GameEvent(
    theme: 'arcane', mapName: 'Ancient Ruins',
    title: 'Trap Glyph',
    description: 'One of your party steps on a glowing rune carved into the ancient floor. It flashes bright!',
    choices: [
      EventChoice(text: 'Jump away!', result: 'The blast catches them mid-air. At least it wasn\'t a direct hit.', hpChangeSingle: -15),
      EventChoice(text: 'Try to dispel it', result: 'You channel your will but the glyph was too old and too strong.', hpChangeSingle: -20),
      EventChoice(text: 'Everyone scatter!', result: 'The explosion sends shrapnel everywhere. Nobody escapes clean.', hpChange: -8),
    ],
  ),

  // ── Catacombs ──
  GameEvent(
    theme: 'dark', mapName: 'Catacombs',
    title: 'Collapsing Floor',
    description: 'The ancient stonework crumbles. The floor opens up beneath one of your party!',
    choices: [
      EventChoice(text: 'Grab their hand!', result: 'You catch them! But the jagged stone cuts deep.', hpChangeSingle: -15),
      EventChoice(text: 'Let them fall and find a way down', result: 'They land hard on a pile of bones below. Nothing broken... barely.', hpChangeSingle: -22),
      EventChoice(text: 'Everyone back up', result: 'The whole section collapses. Dust and debris hurt everyone.', hpChange: -8),
    ],
  ),

  // ── Underground Lake ──
  GameEvent(
    theme: 'martial', mapName: 'Underground Lake',
    title: 'Whirlpool Current',
    description: 'The underground lake surges! A powerful current drags at your legs as you cross a shallow.',
    choices: [
      EventChoice(text: 'Link arms and wade through', result: 'The current pulls hard but you stay together. Bruised ankles.', hpChange: -6),
      EventChoice(text: 'Swim for it', result: 'One party member gets pulled under briefly. They swallow a lot of water.', hpChangeSingle: -18),
      EventChoice(text: 'Find another way', result: 'The detour through narrow tunnels scrapes everyone up.', hpChange: -8),
    ],
  ),

  // ── Goblin Warren ──
  GameEvent(
    theme: 'martial', mapName: 'Goblin Warren',
    title: 'Goblin Trap',
    description: 'CLICK. A tripwire. A net of thorny wire springs from the walls!',
    choices: [
      EventChoice(text: 'Cut through the net', result: 'The barbs shred one party member\'s arms as they hack through.', hpChangeSingle: -15),
      EventChoice(text: 'Carefully untangle it', result: 'Slow but safe. Only minor pricks.', hpChange: -5),
      EventChoice(text: 'Rip it apart by force', result: 'The barbs catch everyone as the net tears. Goblins build nasty traps.', hpChange: -10),
    ],
  ),

  // ── Shadow Realm ──
  GameEvent(
    theme: 'dark', mapName: 'Shadow Realm',
    title: 'Shadow Grasp',
    description: 'Hands of pure darkness rise from the ground and claw at your party!',
    choices: [
      EventChoice(text: 'Fight through them', result: 'The shadows tear at one of your party before dissolving.', hpChangeSingle: -20),
      EventChoice(text: 'Channel light energy', result: 'The light pushes them back but the effort exhausts everyone.', hpChange: -8),
      EventChoice(text: 'Run!', result: 'The shadows give chase. Their cold touch saps life from everyone.', hpChange: -10),
    ],
  ),

  // ── Enchanted Grove ──
  GameEvent(
    theme: 'forest', mapName: 'Enchanted Grove',
    title: 'Wild Magic Surge',
    description: 'The grove\'s magic pulses out of control! Sparks of raw enchantment crackle through the air.',
    choices: [
      EventChoice(text: 'Absorb the energy', result: 'Too much! The magic burns through one party member.', hpChangeSingle: -18),
      EventChoice(text: 'Ground the magic', result: 'You redirect it into the earth. The backlash stings everyone.', hpChange: -6),
      EventChoice(text: 'Wait it out behind a tree', result: 'A stray bolt finds one of you anyway. Trees don\'t stop magic.', hpChangeSingle: -15),
    ],
  ),

  // ── Demon Fortress ──
  GameEvent(
    theme: 'arcane', mapName: 'Demon Fortress',
    title: 'Fire Trap',
    description: 'Jets of hellfire erupt from the fortress walls! The corridor becomes an inferno.',
    choices: [
      EventChoice(text: 'Sprint through', result: 'The flames lick at everyone. One party member gets singed badly.', hpChangeSingle: -20),
      EventChoice(text: 'Time the jets and weave through', result: 'Mostly successful. Just some singed eyebrows.', hpChange: -5),
      EventChoice(text: 'Barrel through together', result: 'The fire is brutal. Everyone feels the burn.', hpChange: -12),
    ],
  ),

  // ── Sky Islands ──
  GameEvent(
    theme: 'dark', mapName: 'Sky Islands',
    title: 'Crumbling Bridge',
    description: 'The floating bridge between islands starts disintegrating beneath your feet!',
    choices: [
      EventChoice(text: 'Run for it!', result: 'One party member nearly falls through before being pulled to safety.', hpChangeSingle: -15),
      EventChoice(text: 'Jump the gaps', result: 'Everyone makes it but the landings are rough.', hpChange: -8),
      EventChoice(text: 'Grab the chains and swing', result: 'The chain snaps. One of you has a rough landing.', hpChangeSingle: -22),
    ],
  ),

  // ── The Void ──
  GameEvent(
    theme: 'dark', mapName: 'The Void',
    title: 'Reality Tear',
    description: 'Space itself cracks open. A rift of raw void energy pulls at your very essence.',
    choices: [
      EventChoice(text: 'Resist the pull', result: 'The void rips at one party member\'s life force before the tear seals.', hpChangeSingle: -22),
      EventChoice(text: 'Redirect the energy', result: 'The effort costs everyone but you seal the rift.', hpChange: -10),
      EventChoice(text: 'Flee from the tear', result: 'The void\'s touch chills everyone to the bone.', hpChange: -8),
    ],
  ),

  // ── Badlands ──
  GameEvent(
    theme: 'wild', mapName: 'Badlands',
    title: 'Dust Devil',
    description: 'A swirling column of red dust tears across the badlands straight at your party!',
    choices: [
      EventChoice(text: 'Drop flat', result: 'The debris pelts everyone. Sand gets EVERYWHERE.', hpChange: -6),
      EventChoice(text: 'Try to outrun it', result: 'One party member gets swept off their feet by the wind.', hpChangeSingle: -18),
      EventChoice(text: 'Find a ditch', result: 'The ditch helps. Only minor scratches from flying debris.', hpChange: -4),
    ],
  ),

  // ── Mushroom Forest ──
  GameEvent(
    theme: 'forest', mapName: 'Mushroom Forest',
    title: 'Toxic Spore Cloud',
    description: 'A giant mushroom ruptures, releasing a cloud of choking purple spores!',
    choices: [
      EventChoice(text: 'Hold breath and run', result: 'One party member inhales a lungful. They\'re coughing for hours.', hpChangeSingle: -15),
      EventChoice(text: 'Cover faces and back away', result: 'The spores settle on everyone. Mild irritation but manageable.', hpChange: -5),
      EventChoice(text: 'Fan the spores away', result: 'You spread them further. Nice going. Everyone is wheezing.', hpChange: -10),
    ],
  ),

  // ── Sunken Marsh ──
  GameEvent(
    theme: 'wild', mapName: 'Sunken Marsh',
    title: 'Quicksand',
    description: 'The ground turns to liquid! One of your party is sinking fast!',
    choices: [
      EventChoice(text: 'Throw them a branch', result: 'They grab on. The pull wrenches their arms but they\'re free.', hpChangeSingle: -12),
      EventChoice(text: 'Wade in to help', result: 'Now two of you are stuck. Eventually you both struggle free.', hpChange: -8),
      EventChoice(text: 'Use a rope', result: 'Smart thinking. They\'re out with just some bruises.', hpChangeSingle: -8),
    ],
  ),

  // ── Crystal Caverns ──
  GameEvent(
    theme: 'arcane', mapName: 'Crystal Caverns',
    title: 'Crystal Shatter',
    description: 'A resonant hum builds until a massive crystal explodes into razor-sharp fragments!',
    choices: [
      EventChoice(text: 'Duck behind a boulder', result: 'Shards pepper one party member who wasn\'t fast enough.', hpChangeSingle: -18),
      EventChoice(text: 'Shield your eyes and brace', result: 'Tiny crystal shards embed in everyone\'s armor. Some get through.', hpChange: -8),
      EventChoice(text: 'Try to stop the resonance', result: 'Too late. The explosion catches you at close range.', hpChangeSingle: -22),
    ],
  ),

  // ── Haunted Graveyard ──
  GameEvent(
    theme: 'dark', mapName: 'Haunted Graveyard',
    title: 'Spectral Wail',
    description: 'The gravestones glow and an unearthly shriek pierces the air! Your soul feels cold.',
    choices: [
      EventChoice(text: 'Cover your ears', result: 'The wail still seeps through. One party member staggers in pain.', hpChangeSingle: -15),
      EventChoice(text: 'Shout back at it', result: 'Surprisingly effective! But the effort leaves everyone drained.', hpChange: -6),
      EventChoice(text: 'Pray for protection', result: 'A faint warmth surrounds you. The wail still hurts but less.', hpChange: -4),
    ],
  ),

  // ── Abandoned Mine ──
  GameEvent(
    theme: 'martial', mapName: 'Abandoned Mine',
    title: 'Mine Cart Runaway',
    description: 'A rusted mine cart comes barreling down the tracks straight at your party!',
    choices: [
      EventChoice(text: 'Jump to the side', result: 'One party member isn\'t quick enough and gets clipped.', hpChangeSingle: -18),
      EventChoice(text: 'Try to stop it', result: 'It\'s heavier than it looks. The impact hurts.', hpChangeSingle: -22),
      EventChoice(text: 'Flatten against the wall', result: 'It scrapes past everyone. That was close!', hpChange: -4),
    ],
  ),

  // ── Pirate Cove ──
  GameEvent(
    theme: 'dark', mapName: 'Pirate Cove',
    title: 'Booby-Trapped Chest',
    description: 'A treasure chest! But something about it seems too convenient...',
    choices: [
      EventChoice(text: 'Open it anyway', result: 'BANG! A blunderbuss trap fires. One party member takes the blast.', hpChangeSingle: -20, goldChange: 15),
      EventChoice(text: 'Check for traps first', result: 'You disarm the trap and claim the loot. Smart!', goldChange: 20),
      EventChoice(text: 'Leave it alone', result: 'Probably wise. Pirates were devious.'),
    ],
  ),

  // ── Arcane Tower ──
  GameEvent(
    theme: 'arcane', mapName: 'Arcane Tower',
    title: 'Unstable Ward',
    description: 'A protective ward on the wall crackles and surges! The magic is failing!',
    choices: [
      EventChoice(text: 'Reinforce it', result: 'The magic backfires through one party member!', hpChangeSingle: -18),
      EventChoice(text: 'Run past it', result: 'The ward detonates as you pass. Everyone catches some of the blast.', hpChange: -8),
      EventChoice(text: 'Drain the magic safely', result: 'It fizzles out. The residual energy tingles unpleasantly.', hpChange: -3),
    ],
  ),

  // ── Gladiator Arena ──
  GameEvent(
    theme: 'martial', mapName: 'Gladiator Arena',
    title: 'Arena Hazard',
    description: 'The arena floor shifts! Spike traps and spinning blades emerge from hidden panels!',
    choices: [
      EventChoice(text: 'Dodge through the pattern', result: 'One party member mistimes a jump. The spikes find their mark.', hpChangeSingle: -20),
      EventChoice(text: 'Wait for the cycle to reset', result: 'A blade nicks everyone while you study the pattern.', hpChange: -6),
      EventChoice(text: 'Smash the mechanism', result: 'It works! But the breaking mechanism flings debris everywhere.', hpChange: -8),
    ],
  ),

  // ── Frozen Citadel ──
  GameEvent(
    theme: 'martial', mapName: 'Frozen Citadel',
    title: 'Ice Sheet Collapse',
    description: 'The frozen floor of the citadel cracks and gives way to a sheet of jagged ice!',
    choices: [
      EventChoice(text: 'Slide across carefully', result: 'One party member slips and crashes into an ice spike.', hpChangeSingle: -18),
      EventChoice(text: 'Crawl across on hands and knees', result: 'Slow and painful. The ice bites through everyone\'s gloves.', hpChange: -6),
      EventChoice(text: 'Jump to stable ground', result: 'One of you doesn\'t make the jump.', hpChangeSingle: -22),
    ],
  ),
];
