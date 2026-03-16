import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/codex_data.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/help_button.dart';

class _EventChoice {
  final String text;
  final String result;
  final int goldChange;
  final int hpChange; // applied to all party members

  const _EventChoice({
    required this.text,
    required this.result,
    this.goldChange = 0,
    this.hpChange = 0,
  });
}

class _GameEvent {
  final String title;
  final String description;
  final List<_EventChoice> choices;

  const _GameEvent({
    required this.title,
    required this.description,
    required this.choices,
  });
}

const _events = [
  _GameEvent(
    title: 'Wandering Merchant',
    description: 'A cheerful merchant waves you down. "I have a special deal for travelers!"',
    choices: [
      _EventChoice(text: 'Buy supplies (-20g, heal 30hp)', result: 'The supplies restore your party!', goldChange: -20, hpChange: 30),
      _EventChoice(text: 'Chat and move on', result: 'The merchant waves goodbye cheerfully.'),
    ],
  ),
  _GameEvent(
    title: 'Mysterious Well',
    description: 'You find an old stone well. Faint magical light glows from within.',
    choices: [
      _EventChoice(text: 'Toss in a coin (-5g)', result: 'The well shimmers! Your party feels refreshed.', goldChange: -5, hpChange: 20),
      _EventChoice(text: 'Drink from the well', result: 'The water is cool and slightly magical.', hpChange: 10),
      _EventChoice(text: 'Walk away', result: 'Probably wise. Who knows what\'s down there.'),
    ],
  ),
  _GameEvent(
    title: 'Lost Traveler',
    description: 'A lost traveler stumbles out of the bushes. "Please, can you help me?"',
    choices: [
      _EventChoice(text: 'Give them gold (-15g)', result: 'The traveler thanks you profusely and gives you a blessing!', goldChange: -15, hpChange: 15),
      _EventChoice(text: 'Point them to safety', result: '"Thank you, kind adventurers!"'),
      _EventChoice(text: 'Rob them (+25g)', result: 'Not very heroic, but profitable...', goldChange: 25),
    ],
  ),
  _GameEvent(
    title: 'Ancient Shrine',
    description: 'An ancient shrine stands before you, covered in moss and runes.',
    choices: [
      _EventChoice(text: 'Pray at the shrine', result: 'A warm light washes over your party.', hpChange: 25),
      _EventChoice(text: 'Search for treasure', result: 'You find some coins hidden in the stones!', goldChange: 20),
      _EventChoice(text: 'Read the runes', result: 'The runes speak of an ancient power. Interesting...'),
    ],
  ),
  _GameEvent(
    title: 'Bridge Troll',
    description: '"You gotta pay the toll to cross my bridge!" says a large, grumpy troll.',
    choices: [
      _EventChoice(text: 'Pay the toll (-30g)', result: '"Pleasure doing business!" The troll steps aside.', goldChange: -30),
      _EventChoice(text: 'Tell a joke', result: 'The troll laughs so hard he falls over. You cross freely!'),
      _EventChoice(text: 'Intimidate', result: 'The troll reconsiders and lets you pass. "Fine, just go!"'),
    ],
  ),
  _GameEvent(
    title: 'Fairy Ring',
    description: 'You stumble upon a circle of mushrooms glowing with faint light.',
    choices: [
      _EventChoice(text: 'Step inside', result: 'The fairies heal your wounds and give you gifts!', hpChange: 35, goldChange: 15),
      _EventChoice(text: 'Leave an offering (-10g)', result: 'The fairies are pleased and bless your journey!', goldChange: -10, hpChange: 20),
      _EventChoice(text: 'Walk around it', result: 'Better safe than sorry with fairy magic.'),
    ],
  ),
  _GameEvent(
    title: 'The Cursed Blade',
    description: 'A dark sword lies embedded in a stone altar. It radiates power... and malice.',
    choices: [
      _EventChoice(text: 'Take it (+15 gold, -20 HP)', result: 'The blade cuts your hand as you grasp it, but its power is undeniable.', goldChange: 15, hpChange: -20),
      _EventChoice(text: 'Destroy it (+5 HP)', result: 'You shatter the blade. A wave of warmth washes over your party.', goldChange: 0, hpChange: 5),
      _EventChoice(text: 'Leave it', result: 'Some things are best left alone.', goldChange: 0, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'Ambushed!',
    description: 'Bandits leap from the shadows! They demand your gold or your lives.',
    choices: [
      _EventChoice(text: 'Pay them (-30 gold)', result: 'The bandits take your gold and vanish. At least no one was hurt.', goldChange: -30, hpChange: 0),
      _EventChoice(text: 'Fight back (-15 HP, +20 gold)', result: 'A fierce scuffle! You take some hits but loot their camp.', goldChange: 20, hpChange: -15),
      _EventChoice(text: 'Bluff them (+10 gold)', result: 'You convince them a dragon is following you. They flee, dropping coins.', goldChange: 10, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'The Weary Soldier',
    description: 'A wounded soldier from the king\'s army sits by the road, clutching a sealed letter.',
    choices: [
      _EventChoice(text: 'Heal him (+10 HP, -10 gold)', result: 'He shares healing herbs with your party in gratitude.', goldChange: -10, hpChange: 10),
      _EventChoice(text: 'Take the letter (+25 gold)', result: 'The letter contained a bounty notice. You claim the reward at the next town.', goldChange: 25, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'Mushroom Grove',
    description: 'Glowing mushrooms fill a moonlit clearing. Their spores shimmer in the air.',
    choices: [
      _EventChoice(text: 'Eat the blue ones (+15 HP)', result: 'Sweet and refreshing! Your wounds close slightly.', goldChange: 0, hpChange: 15),
      _EventChoice(text: 'Eat the red ones (-10 HP, +30 gold)', result: 'Bitter! But your vision sharpens and you spot a hidden treasure cache.', goldChange: 30, hpChange: -10),
      _EventChoice(text: 'Gather them to sell (+15 gold)', result: 'An alchemist will pay well for these.', goldChange: 15, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'The Gambling Imp',
    description: 'A tiny imp sits cross-legged on a rock, shuffling cards. "Care for a wager?" it grins.',
    choices: [
      _EventChoice(text: 'Play it safe (+5 gold)', result: 'A boring game. The imp yawns and tosses you a coin.', goldChange: 5, hpChange: 0),
      _EventChoice(text: 'Go all in (+40 gold, -25 HP)', result: 'You win big! But the imp hexes you on the way out.', goldChange: 40, hpChange: -25),
      _EventChoice(text: 'Refuse', result: 'The imp shrugs and disappears in a puff of smoke.', goldChange: 0, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'Collapsed Mine',
    description: 'An old mine entrance, partially collapsed. You can hear something glittering inside.',
    choices: [
      _EventChoice(text: 'Crawl in (+35 gold, -15 HP)', result: 'Tight squeeze! Rocks scrape and cut, but the gems inside are worth it.', goldChange: 35, hpChange: -15),
      _EventChoice(text: 'Send the smallest hero (-5 HP, +20 gold)', result: 'They squeeze through and return with a handful of gems.', goldChange: 20, hpChange: -5),
      _EventChoice(text: 'Move on', result: 'Not worth the risk. The road calls.', goldChange: 0, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'The Oracle\'s Pool',
    description: 'A still pool of silver water. Legend says it shows visions of what lies ahead.',
    choices: [
      _EventChoice(text: 'Drink deeply (+20 HP, -15 gold)', result: 'Visions of the future flood your mind. Your body feels renewed.', goldChange: -15, hpChange: 20),
      _EventChoice(text: 'Toss in a coin (-5 gold, +5 HP)', result: 'The water shimmers. A gentle warmth spreads through your party.', goldChange: -5, hpChange: 5),
      _EventChoice(text: 'Walk away', result: 'The pool grows still once more. Some mysteries are meant to remain.', goldChange: 0, hpChange: 0),
    ],
  ),
  _GameEvent(
    title: 'Merchant Caravan',
    description: 'A merchant caravan has been attacked! Goods are scattered everywhere.',
    choices: [
      _EventChoice(text: 'Help the merchants (+10 HP, +10 gold)', result: 'Grateful, they share supplies and gold for your kindness.', goldChange: 10, hpChange: 10),
      _EventChoice(text: 'Loot the wreckage (+40 gold)', result: 'No one is watching. The gold flows freely from broken chests.', goldChange: 40, hpChange: 0),
      _EventChoice(text: 'Pursue the attackers (-20 HP, +25 gold)', result: 'You catch the thieves! A rough fight, but you recover some of the stolen goods.', goldChange: 25, hpChange: -20),
    ],
  ),
  _GameEvent(
    title: 'Dragon Egg',
    description: 'A shimmering egg sits in a nest of warm stones, pulsing with a faint glow. Is that... a dragon egg?',
    choices: [
      _EventChoice(text: 'Keep it warm (+15 HP)', result: 'The egg hums happily. A wave of warmth heals your party!', hpChange: 15),
      _EventChoice(text: 'Sell it (+35 gold)', result: 'A collector pays a fortune for the egg. You hope the dragon mom doesn\'t find out.', goldChange: 35),
      _EventChoice(text: 'Leave it alone', result: 'Probably best not to mess with dragon eggs. You walk away quickly.'),
    ],
  ),
  _GameEvent(
    title: 'The Haunted Tavern',
    description: 'A dusty tavern stands at the crossroads. Through the windows, ghostly figures raise their mugs.',
    choices: [
      _EventChoice(text: 'Join the ghosts for a drink (+20 HP)', result: 'The spirits are friendly! Their ghostly ale is surprisingly refreshing.', hpChange: 20),
      _EventChoice(text: 'Search behind the bar (+25 gold)', result: 'You find a stash of coins the innkeeper left behind centuries ago.', goldChange: 25),
      _EventChoice(text: 'Run away', result: 'Nope. Nope nope nope. You sprint down the road.'),
    ],
  ),
  _GameEvent(
    title: 'The Riddle Sphinx',
    description: 'A stone sphinx blocks the path. "Answer my riddle, or pay the price," it rumbles.',
    choices: [
      _EventChoice(text: 'Try to answer (+30 gold)', result: '"What has keys but no locks?" A piano! The sphinx grumbles and drops a bag of gold.', goldChange: 30),
      _EventChoice(text: 'Pay the toll (-20 gold)', result: 'The sphinx accepts your gold and slides aside with a grinding of stone.', goldChange: -20),
      _EventChoice(text: 'Climb over it (-10 HP)', result: 'The sphinx snaps at you! You scramble over with a few scratches.', hpChange: -10),
    ],
  ),
  _GameEvent(
    title: 'Enchanted Forest',
    description: 'The trees ahead glow with silver light. Tiny sprites dart between the branches, giggling.',
    choices: [
      _EventChoice(text: 'Follow the sprites (+20 HP, -10 gold)', result: 'The sprites lead you to a healing spring, but steal a few coins along the way!', hpChange: 20, goldChange: -10),
      _EventChoice(text: 'Gather glowing fruit (+10 HP)', result: 'The silver fruit tastes like starlight. Your wounds tingle and start to close.', hpChange: 10),
      _EventChoice(text: 'Pass through quickly', result: 'The sprites wave goodbye. One sticks its tongue out at you.'),
    ],
  ),
  _GameEvent(
    title: 'Goblin Market',
    description: 'A rowdy goblin bazaar fills a clearing. Goblins hawk bizarre wares from rickety stalls.',
    choices: [
      _EventChoice(text: 'Buy a mystery potion (-15 gold, +15 HP)', result: 'It tastes like old socks, but it works! Your party feels much better.', goldChange: -15, hpChange: 15),
      _EventChoice(text: 'Trade stories (+10 gold)', result: 'The goblins love your adventure tales and toss you some coins as thanks.', goldChange: 10),
      _EventChoice(text: 'Pickpocket a goblin (+20 gold, -5 HP)', result: 'You snag a coin purse but one of them bites your hand. Worth it!', goldChange: 20, hpChange: -5),
    ],
  ),
  _GameEvent(
    title: 'Fallen Meteor',
    description: 'A glowing rock lies in a smoking crater. Strange energy crackles from its surface.',
    choices: [
      _EventChoice(text: 'Touch the meteor (-15 HP, +35 gold)', result: 'It burns! But fragments of star-metal break off. These are incredibly valuable.', hpChange: -15, goldChange: 35),
      _EventChoice(text: 'Absorb its energy (+10 HP)', result: 'Cosmic energy flows through your party. You feel stronger somehow.', hpChange: 10),
      _EventChoice(text: 'Mark it on your map', result: 'You\'ll come back for this later. Maybe. If the world survives.'),
    ],
  ),
  _GameEvent(
    title: 'The Cursed Mirror',
    description: 'A tall mirror stands alone in a clearing. Your reflections look... wrong. They\'re smiling when you\'re not.',
    choices: [
      _EventChoice(text: 'Smash the mirror (+5 HP)', result: 'The glass shatters and a dark mist escapes. Your party feels lighter.', hpChange: 5),
      _EventChoice(text: 'Talk to your reflection (+25 gold, -20 HP)', result: 'Your reflection hands you a bag of gold through the glass, then scratches you. Weird.', goldChange: 25, hpChange: -20),
      _EventChoice(text: 'Cover it and leave', result: 'You drape a cloak over it. Some things are better left unreflected.'),
    ],
  ),
  _GameEvent(
    title: 'Traveling Circus',
    description: 'A colorful circus tent appears out of nowhere. A ringmaster in a top hat beckons you inside.',
    choices: [
      _EventChoice(text: 'Watch the show (-10 gold, +15 HP)', result: 'Fire-breathers and acrobats! The show is amazing and lifts everyone\'s spirits.', goldChange: -10, hpChange: 15),
      _EventChoice(text: 'Join the act (+20 gold)', result: 'You juggle swords for the crowd. They shower you with coins!', goldChange: 20),
      _EventChoice(text: 'Sneak backstage (+15 gold, -10 HP)', result: 'You find a chest of coins but trip over a sleeping lion. Ouch!', goldChange: 15, hpChange: -10),
    ],
  ),
  _GameEvent(
    title: 'Ancient Golem',
    description: 'A towering stone golem blocks the road. Its eyes flicker between red and blue.',
    choices: [
      _EventChoice(text: 'Repair its rune (+20 HP)', result: 'You fix the cracked rune on its chest. It bows and blesses your party with ancient magic.', hpChange: 20),
      _EventChoice(text: 'Mine its gems (+30 gold, -15 HP)', result: 'You pry out some valuable gemstones, but it takes a swipe at you. Worth the bruises!', goldChange: 30, hpChange: -15),
      _EventChoice(text: 'Walk around it', result: 'The golem watches you go with sad, flickering eyes.'),
    ],
  ),
  _GameEvent(
    title: 'The Witch\'s Garden',
    description: 'A cozy cottage surrounded by an impossible garden. A friendly witch waves from her porch.',
    choices: [
      _EventChoice(text: 'Accept her tea (+25 HP)', result: 'The tea tastes like sunshine and honey. Your wounds melt away!', hpChange: 25),
      _EventChoice(text: 'Help with her garden (+15 gold, +5 HP)', result: 'She pays you for pulling weeds and sends you off with a cookie. Nice lady!', goldChange: 15, hpChange: 5),
      _EventChoice(text: 'Decline politely', result: 'She nods. "Come back anytime, dears!" She seems genuinely kind.'),
    ],
  ),
  _GameEvent(
    title: 'Pirate Ghost Ship',
    description: 'A spectral ship floats above a dried-up riverbed. A ghostly captain leans over the rail.',
    choices: [
      _EventChoice(text: 'Challenge the captain (+40 gold, -25 HP)', result: 'You beat the ghost in a duel! He tosses you his treasure chest, grumbling.', goldChange: 40, hpChange: -25),
      _EventChoice(text: 'Trade with the crew (+15 gold)', result: 'The ghost pirates have some surprisingly good deals on slightly haunted merchandise.', goldChange: 15),
      _EventChoice(text: 'Sail away on foot', result: 'You power-walk away from the ghost ship. Dignity intact.'),
    ],
  ),
  _GameEvent(
    title: 'Magic Fountain',
    description: 'A beautiful fountain flows with sparkling water. Different colored streams pour from three spouts.',
    choices: [
      _EventChoice(text: 'Drink the golden stream (+20 gold)', result: 'You cough up a gold coin! Then another! Weird, but profitable.', goldChange: 20),
      _EventChoice(text: 'Drink the blue stream (+15 HP)', result: 'Cool, refreshing magic flows through your body, mending cuts and bruises.', hpChange: 15),
      _EventChoice(text: 'Drink the red stream (-10 HP, +30 gold)', result: 'Spicy! Very spicy! But a pile of rubies appears at your feet.', hpChange: -10, goldChange: 30),
    ],
  ),
  _GameEvent(
    title: 'The Talking Crow',
    description: 'A large crow lands on a branch and stares at you. "I know things," it says. "Useful things."',
    choices: [
      _EventChoice(text: 'Pay for information (-15 gold, +10 HP)', result: 'The crow tells you about a shortcut and a healing herb nearby. Smart bird!', goldChange: -15, hpChange: 10),
      _EventChoice(text: 'Offer it food (+5 HP)', result: 'The crow eats your crumbs and caws a blessing. Crows remember kindness.', hpChange: 5),
      _EventChoice(text: 'Shoo it away', result: 'The crow flies off, muttering rude words. Some of them are surprisingly creative.'),
    ],
  ),
  _GameEvent(
    title: 'Abandoned Forge',
    description: 'A dwarven forge sits cold and silent. Tools and half-finished weapons line the walls.',
    choices: [
      _EventChoice(text: 'Fire it up and craft (+10 HP, +10 gold)', result: 'You repair some gear and forge a few trinkets to sell. Good honest work!', hpChange: 10, goldChange: 10),
      _EventChoice(text: 'Scavenge for valuables (+25 gold)', result: 'The dwarves left behind some fine metals and gems. Finders keepers!', goldChange: 25),
      _EventChoice(text: 'Rest by the cold forge (+10 HP)', result: 'It\'s quiet and sheltered. Your party gets some much-needed rest.', hpChange: 10),
    ],
  ),
  _GameEvent(
    title: 'The Sleeping Giant',
    description: 'A hill-sized giant snores peacefully in a meadow. His pockets are the size of houses.',
    choices: [
      _EventChoice(text: 'Climb into a pocket (+35 gold, -15 HP)', result: 'You grab fistfuls of giant-sized coins! But the giant rolls over on you. Oof.', goldChange: 35, hpChange: -15),
      _EventChoice(text: 'Sing a lullaby (+15 HP)', result: 'Your singing keeps the giant asleep. Peaceful vibes heal your party.', hpChange: 15),
      _EventChoice(text: 'Tiptoe past', result: 'You hold your breath and sneak by. No one wants to wake a giant.'),
    ],
  ),
  _GameEvent(
    title: 'The Fairy Court',
    description: 'Tiny fairy nobles hold court on a toadstool throne. They regard you with curious eyes.',
    choices: [
      _EventChoice(text: 'Bow and show respect (+20 HP, +10 gold)', result: 'The fairies are delighted by your manners! They shower you with blessings and tiny gold coins.', hpChange: 20, goldChange: 10),
      _EventChoice(text: 'Dance with them (+15 HP)', result: 'You dance a silly jig and the fairies laugh. Their magic heals you as you twirl!', hpChange: 15),
      _EventChoice(text: 'Ask them for directions', result: 'The fairies point you onward with glowing arrows. How helpful!'),
    ],
  ),
  _GameEvent(
    title: 'Crystal Cave',
    description: 'A cavern of glowing crystals hums with magical energy. The walls pulse with rainbow light.',
    choices: [
      _EventChoice(text: 'Harvest crystals (+30 gold, -10 HP)', result: 'The crystals are sharp but valuable! You fill your bags, nursing a few cuts.', goldChange: 30, hpChange: -10),
      _EventChoice(text: 'Meditate inside (+20 HP)', result: 'The crystal energy flows through your party. Wounds close and spirits lift.', hpChange: 20),
      _EventChoice(text: 'Explore deeper (-20 HP, +40 gold)', result: 'The cave goes deep! You take some falls but find a treasure trove at the bottom.', hpChange: -20, goldChange: 40),
    ],
  ),
  _GameEvent(
    title: 'The Dark Portal',
    description: 'A swirling purple portal hovers in the air. Strange whispers drift from the other side.',
    choices: [
      _EventChoice(text: 'Reach through (+25 gold, -15 HP)', result: 'You grab something shiny and yank your hand back. Treasure! And only minor void burns.', goldChange: 25, hpChange: -15),
      _EventChoice(text: 'Seal the portal (+10 HP)', result: 'You push the portal closed with all your might. The land around it brightens.', hpChange: 10),
      _EventChoice(text: 'Back away slowly', result: 'You leave the portal alone. The whispers sound disappointed.'),
    ],
  ),
  _GameEvent(
    title: 'Wizard Duel',
    description: 'Two wizards argue in the road, sparks flying from their staffs. "You there! Settle this for us!"',
    choices: [
      _EventChoice(text: 'Side with the blue wizard (+20 gold)', result: 'Blue wins! He rewards you with gold. The red wizard huffs and teleports away.', goldChange: 20),
      _EventChoice(text: 'Side with the red wizard (+15 HP)', result: 'Red wins! She heals your party as thanks. The blue wizard grumbles and vanishes.', hpChange: 15),
      _EventChoice(text: 'Tell them to share (+10 gold, +10 HP)', result: 'They blink, then laugh. "Fair point!" They both give you a small reward.', goldChange: 10, hpChange: 10),
    ],
  ),
  _GameEvent(
    title: 'The Phoenix Nest',
    description: 'High on a cliff, a nest of golden feathers smolders. A tiny phoenix chick chirps at you.',
    choices: [
      _EventChoice(text: 'Feed it (+20 HP)', result: 'The chick nuzzles you and its warmth heals your party! It chirps a thank you.', hpChange: 20),
      _EventChoice(text: 'Gather fallen feathers (+30 gold)', result: 'Phoenix feathers are worth a fortune! The chick doesn\'t mind — they grow back.', goldChange: 30),
      _EventChoice(text: 'Warm your hands (-5 gold, +5 HP)', result: 'The fire is cozy. You accidentally melt a few coins but feel refreshed.', goldChange: -5, hpChange: 5),
    ],
  ),
];

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  late _GameEvent _event;
  String? _result;

  @override
  void initState() {
    super.initState();
    _event = _events[Random().nextInt(_events.length)];
  }

  void _choose(_EventChoice choice) {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    final notifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    if (choice.goldChange != 0) {
      notifier.spendGold(-choice.goldChange); // negative spend = gain
    }
    if (choice.hpChange != 0) {
      for (final char in gameState.party) {
        if (char.isAlive) {
          char.currentHp = (char.currentHp + choice.hpChange).clamp(1, char.totalMaxHp);
        }
      }
    }

    setState(() => _result = choice.result);
    _checkForLoreDrop();
  }

  void _checkForLoreDrop() {
    final random = Random();
    if (random.nextInt(100) >= 20) return; // 80% chance to skip

    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    final tier = ((gameState.currentMapNumber - 1) ~/ 2) + 1;
    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;

    final available = lorePages
        .where((p) => p.mapTier == tier && !profile.loreFound.contains(p.id))
        .toList();
    if (available.isEmpty) return;

    final page = available[random.nextInt(available.length)];
    ref.read(playerProfileProvider.notifier).recordLorePageFound(page.id);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_stories, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(page.title)),
            ],
          ),
          content: Text(page.content),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: const [HelpButton(), AudioMuteButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _event.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _event.description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_result == null)
                ..._event.choices.map((choice) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    width: 300,
                    child: OutlinedButton(
                      onPressed: () => _choose(choice),
                      child: Text(choice.text),
                    ),
                  ),
                ))
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _result!,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 220,
                  child: FilledButton(
                    onPressed: () => context.go('/map'),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
