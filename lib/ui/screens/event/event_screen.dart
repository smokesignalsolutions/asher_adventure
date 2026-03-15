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
        actions: const [AudioMuteButton()],
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
