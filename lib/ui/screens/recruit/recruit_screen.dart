import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/recruit_data.dart';
import '../../../data/sprite_data.dart';
import '../../../models/enums.dart';
import '../../../providers/game_state_provider.dart';

class RecruitScreen extends ConsumerStatefulWidget {
  const RecruitScreen({super.key});

  @override
  ConsumerState<RecruitScreen> createState() => _RecruitScreenState();
}

class _RecruitScreenState extends ConsumerState<RecruitScreen> {
  late List<CharacterClass> _availableRecruits;

  @override
  void initState() {
    super.initState();
    _generateRecruits();
  }

  void _generateRecruits() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) {
      _availableRecruits = [];
      return;
    }

    // Get unlocked classes, excluding those already in the party
    final partyClasses = gameState.party.map((c) => c.characterClass).toSet();
    final pool = CharacterClass.values.where((c) {
      final def = classDefinitions[c];
      return def != null && def.unlockedByDefault && !partyClasses.contains(c);
    }).toList();

    // Pick 2-4 random classes from the pool
    final rng = Random();
    pool.shuffle(rng);
    final count = min(pool.length, 2 + rng.nextInt(3)); // 2-4
    _availableRecruits = pool.take(count).toList();
  }

  Future<void> _hire(CharacterClass cls) async {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    final cost = recruitCost(cls, gameState.currentMapNumber);
    await ref.read(gameStateProvider.notifier).recruitCharacter(cls, cost);

    if (mounted) {
      setState(() {
        _availableRecruits.remove(cls);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final partyFull = gameState.party.length >= 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Tavern')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Party: ${gameState.party.length}/4',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${gameState.gold}g',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (partyFull) ...[
              const Spacer(),
              Center(
                child: Text(
                  'Your party is full!',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const Spacer(),
            ] else ...[
              Text(
                'Heroes for hire:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableRecruits.length,
                  itemBuilder: (context, index) {
                    final cls = _availableRecruits[index];
                    final def = classDefinitions[cls]!;
                    final cost = recruitCost(cls, gameState.currentMapNumber);
                    final canAfford = gameState.gold >= cost;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Class sprite
                            Image.asset(
                              classSpritePath(cls),
                              width: 48,
                              height: 48,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 48),
                            ),
                            const SizedBox(width: 12),
                            // Class info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    def.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'HP:${def.baseStats.hp} ATK:${def.baseStats.attack} '
                                    'DEF:${def.baseStats.defense} SPD:${def.baseStats.speed} '
                                    'MAG:${def.baseStats.magic}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Hire button
                            FilledButton(
                              onPressed: canAfford ? () => _hire(cls) : null,
                              child: Text('${cost}g'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/map'),
                child: const Text('Leave Tavern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
