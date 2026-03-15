import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/legacy_point_calculator.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/lp_breakdown.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  LegacyPointResult? _lpResult;

  @override
  void initState() {
    super.initState();
    _processRunEnd();
  }

  Future<void> _processRunEnd() async {
    final gameNotifier = ref.read(gameStateProvider.notifier);
    final profileNotifier = ref.read(playerProfileProvider.notifier);

    // Step 1: Snapshot state before clearing
    final snapshot = gameNotifier.endRun();
    if (snapshot == null) return;

    // Step 2: Calculate LP
    final result = LegacyPointCalculator.calculate(
      mapsCompleted: snapshot.mapsCompletedThisRun,
      bossesKilled: snapshot.bossesKilledThisRun,
      uniqueEnemyTypesKilled: snapshot.uniqueEnemyTypesKilledThisRun.length,
      isVictory: false,
      difficulty: snapshot.difficulty,
    );

    // Step 3: Update profile
    await profileNotifier.addLegacyPoints(result.totalPoints);
    await profileNotifier.recordRunEnd(
      mapsCompleted: snapshot.currentMapNumber,
      isVictory: false,
    );

    // Step 4: Persist bestiary kills
    if (snapshot.enemyKillCountsThisRun.isNotEmpty) {
      await profileNotifier.recordEnemyKills(snapshot.enemyKillCountsThisRun);
    }

    // Step 4b: Check class story progress for alive party members
    for (final char in snapshot.party.where((c) => c.isAlive)) {
      final className = char.characterClass.name;
      final maps = snapshot.mapsCompletedThisRun;
      if (maps >= 5) {
        await profileNotifier.recordClassStoryProgress(className, 2);
      } else if (maps >= 2) {
        await profileNotifier.recordClassStoryProgress(className, 1);
      }
    }

    // Step 5: Delete run save
    await gameNotifier.gameOver();

    // Step 6: Display
    if (mounted) {
      setState(() => _lpResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
                'Your party has fallen...\nBut the knowledge you gained lives on.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_lpResult != null) ...[
                SizedBox(
                  width: 300,
                  child: LpBreakdown(result: _lpResult!),
                ),
                const SizedBox(height: 24),
              ] else
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: _lpResult != null ? () => context.go('/') : null,
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
