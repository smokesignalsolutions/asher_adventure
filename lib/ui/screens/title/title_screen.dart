import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/save_service.dart';
import '../../widgets/audio_controls.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  bool _isLoading = true;
  bool _hasAnySave = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize player profile (creates default if first launch)
    await ref.read(playerProfileProvider.notifier).initialize();

    // Check for existing run save
    final runJson = await SaveService.loadRunSaveJson();
    setState(() {
      _hasAnySave = runJson != null;
      _isLoading = false;
    });
  }

  void _handleLoadGame() {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    _loadSlot();
  }

  void _handleNewGame() {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    if (_hasAnySave) {
      _confirmOverwrite();
    } else {
      _startNew();
    }
  }

  void _confirmOverwrite() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Overwrite Save?'),
        content: const Text(
          'You have an existing run in progress. '
          'Start a new game and overwrite it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startNew();
            },
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSlot() async {
    await ref.read(gameStateProvider.notifier).loadGame();
    if (mounted) context.go('/map');
  }

  void _startNew() {
    context.go('/party-select');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    if (profile != null && profile.totalRuns > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${profile.legacyPoints} Legacy Points'
                        '  \u2022  ${profile.totalRuns} runs'
                        '  \u2022  ${profile.totalVictories} wins',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 220,
                      child: FilledButton.icon(
                        onPressed: _handleNewGame,
                        icon: const Icon(Icons.add),
                        label: const Text('New Game'),
                      ),
                    ),
                    if (_hasAnySave) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 220,
                        child: FilledButton.tonalIcon(
                          onPressed: _handleLoadGame,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Continue'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(audioProvider.notifier)
                              .playSfx(SfxType.menuSelect);
                          context.go('/help');
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Guide'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
