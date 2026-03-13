import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';
import '../../widgets/audio_controls.dart';

class RestScreen extends ConsumerWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: Text('No game state')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest Stop'),
        actions: const [AudioMuteButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department,
                  size: 80, color: Colors.orange.shade400),
              const SizedBox(height: 24),
              Text(
                'A Campfire in the Wilderness',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your party rests and recovers their strength.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Show party HP before rest
              ...gameState.party.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(c.name.split(' ').first),
                    ),
                    if (!c.isAlive)
                      Text(
                        'KO -> REVIVE!',
                        style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold),
                      )
                    else ...[
                      Text('${c.currentHp}/${c.totalMaxHp} HP'),
                      if (c.currentHp < c.totalMaxHp)
                        Text(
                          ' -> ${c.totalMaxHp}',
                          style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ],
                ),
              )),

              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).restParty();
                    context.go('/map');
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Rest & Heal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
