import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_stories.dart';
import '../../../data/codex_data.dart';
import '../../../data/event_data.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/story_unlock_service.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/help_button.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  late GameEvent _event;
  String? _result;
  bool _showExplorePrompt = false;
  bool _showStoryDialog = false;
  bool _showArtUpgrade = false;
  bool _animationShowNew = false;
  StoryUnlockResult? _unlockResult;
  ClassStoryChapter? _unlockedChapter;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final gameState = ref.read(gameStateProvider);
    final mapNumber = gameState?.currentMapNumber ?? 1;
    _event = selectEventForMap(mapNumber);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (_showArtUpgrade && _animationShowNew) {
      if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
        context.go('/map');
      }
    } else if (_showStoryDialog) {
      if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
        _dismissStoryDialog();
      }
    } else if (_showExplorePrompt) {
      if (key == LogicalKeyboardKey.keyE) {
        _handleExplore();
      } else if (key == LogicalKeyboardKey.keyM) {
        context.go('/map');
      }
    } else if (_result != null) {
      if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
        setState(() => _showExplorePrompt = true);
      }
    }
  }

  void _choose(EventChoice choice) {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    final notifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    if (choice.goldChange != 0) {
      notifier.spendGold(-choice.goldChange);
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
    if (random.nextInt(100) >= 20) return;

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

  void _handleExplore() {
    final gameState = ref.read(gameStateProvider);
    final profile = ref.read(playerProfileProvider);
    if (gameState == null || profile == null) {
      if (mounted) context.go('/map');
      return;
    }

    final result = determineStoryUnlock(
      eventTheme: _event.theme,
      party: gameState.party,
      classStoryProgress: profile.classStoryProgress,
      currentMapNumber: gameState.currentMapNumber,
    );

    if (result == null) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            content: const Text('You search the area but find nothing of note.'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (mounted) context.go('/map');
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Unlock the chapter
    ref.read(playerProfileProvider.notifier).recordClassStoryProgress(result.className, result.chapter);

    // Find the story content (with safety check)
    final chapter = classStories.cast<ClassStoryChapter?>().firstWhere(
      (s) => s!.characterClass == result.characterClass && s.chapter == result.chapter,
      orElse: () => null,
    );

    if (chapter == null) {
      if (mounted) context.go('/map');
      return;
    }

    setState(() {
      _unlockResult = result;
      _unlockedChapter = chapter;
      _showExplorePrompt = false;
      _showStoryDialog = true;
    });
  }

  void _dismissStoryDialog() {
    if (_unlockResult!.isArtUpgrade) {
      setState(() {
        _showStoryDialog = false;
        _showArtUpgrade = true;
        _animationShowNew = false;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _animationShowNew = true);
      });
    } else {
      context.go('/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event'),
          actions: const [HelpButton(), AudioMuteButton()],
        ),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_showArtUpgrade) {
      return _buildArtUpgrade(theme);
    } else if (_showStoryDialog) {
      return _buildStoryDialog(theme);
    } else if (_showExplorePrompt) {
      return _buildExplorePrompt(theme);
    } else {
      return _buildEventContent(theme);
    }
  }

  Widget _buildEventContent(ThemeData theme) {
    return Center(
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
                  onPressed: () => setState(() => _showExplorePrompt = true),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplorePrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You notice something interesting nearby...',
              style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              child: FilledButton(
                onPressed: _handleExplore,
                child: const Text('Explore'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 300,
              child: OutlinedButton(
                onPressed: () => context.go('/map'),
                child: const Text('Move on'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryDialog(ThemeData theme) {
    final chapter = _unlockedChapter!;
    final className = _unlockResult!.className;
    final displayName = className[0].toUpperCase() + className.substring(1);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '$displayName — Chapter ${chapter.chapter}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  chapter.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  chapter.content,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _dismissStoryDialog,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtUpgrade(ThemeData theme) {
    final cls = _unlockResult!.characterClass;
    final chapter = _unlockResult!.chapter;
    final oldTier = chapter == 4 ? 'low' : 'mid';
    final newTier = chapter == 4 ? 'mid' : 'high';
    final oldPath = 'assets/new_art/${cls.name}_${oldTier}_128x128.png';
    final newPath = 'assets/new_art/${cls.name}_${newTier}_128x128.png';
    final displayName = _unlockResult!.className[0].toUpperCase() + _unlockResult!.className.substring(1);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Art Upgraded!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(displayName, style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          Container(
            decoration: _animationShowNew
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Image.asset(
                _animationShowNew ? newPath : oldPath,
                key: ValueKey(_animationShowNew),
                width: 128,
                height: 128,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 128),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_animationShowNew)
            FilledButton(
              onPressed: () => context.go('/map'),
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }
}
