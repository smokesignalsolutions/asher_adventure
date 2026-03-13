import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
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
