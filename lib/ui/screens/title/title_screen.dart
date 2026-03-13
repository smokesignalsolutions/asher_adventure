import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  bool _isLoading = true;
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    _checkSave();
  }

  Future<void> _checkSave() async {
    await ref.read(gameStateProvider.notifier).loadGame();
    setState(() {
      _hasSave = ref.read(gameStateProvider) != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Asher's Adventure",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Grand Quest Awaits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 220,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/party-select'),
                        icon: const Icon(Icons.add),
                        label: const Text('New Game'),
                      ),
                    ),
                    if (_hasSave) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 220,
                        child: FilledButton.tonalIcon(
                          onPressed: () => context.go('/map'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Continue'),
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
