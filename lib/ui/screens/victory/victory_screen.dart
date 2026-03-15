import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/legacy_point_calculator.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/lp_breakdown.dart';

class VictoryScreen extends ConsumerStatefulWidget {
  const VictoryScreen({super.key});

  @override
  ConsumerState<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends ConsumerState<VictoryScreen> {
  LegacyPointResult? _lpResult;

  @override
  void initState() {
    super.initState();
    _processRunEnd();
  }

  Future<void> _processRunEnd() async {
    final gameNotifier = ref.read(gameStateProvider.notifier);
    final profileNotifier = ref.read(playerProfileProvider.notifier);

    final snapshot = gameNotifier.endRun();
    if (snapshot == null) return;

    final result = LegacyPointCalculator.calculate(
      mapsCompleted: snapshot.mapsCompletedThisRun + 1, // include final map
      bossesKilled: snapshot.bossesKilledThisRun,
      uniqueEnemyTypesKilled: snapshot.uniqueEnemyTypesKilledThisRun.length,
      isVictory: true,
      difficulty: snapshot.difficulty,
    );

    await profileNotifier.addLegacyPoints(result.totalPoints);
    await profileNotifier.recordRunEnd(
      mapsCompleted: 8,
      isVictory: true,
    );

    // Persist bestiary kills
    if (snapshot.enemyKillCountsThisRun.isNotEmpty) {
      await profileNotifier.recordEnemyKills(snapshot.enemyKillCountsThisRun);
    }

    await gameNotifier.gameOver();

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
              const Text('\u{1F3C6}', style: TextStyle(fontSize: 80)),
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
