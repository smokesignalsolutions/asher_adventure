import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.heart_broken, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                'Game Over',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your party has fallen. The quest remains unfulfilled...\nBut heroes never truly give up!',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
