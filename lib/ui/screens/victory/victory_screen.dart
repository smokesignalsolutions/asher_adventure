import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';

class VictoryScreen extends ConsumerWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                'Victory!',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The Dark One has been vanquished!\n'
                'Peace returns to the land.\n\n'
                'Asher, your adventure is complete!',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).gameOver();
                    context.go('/');
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Return Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
