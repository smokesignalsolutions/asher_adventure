import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../models/enums.dart';
import '../../../models/player_profile.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../widgets/audio_controls.dart';

class PartySelectScreen extends ConsumerStatefulWidget {
  const PartySelectScreen({super.key});

  @override
  ConsumerState<PartySelectScreen> createState() => _PartySelectScreenState();
}

class _PartySelectScreenState extends ConsumerState<PartySelectScreen> {
  final _selectedClasses = <CharacterClass>[];
  DifficultyLevel _difficulty = DifficultyLevel.normal;

  List<CharacterClass> get _unlockedClasses {
    final profile = ref.read(playerProfileProvider);
    if (profile == null) {
      return PlayerProfile.starterClasses;
    }
    return profile.unlockedClasses;
  }

  void _toggleClass(CharacterClass cls) {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    setState(() {
      if (_selectedClasses.contains(cls)) {
        _selectedClasses.remove(cls);
      } else if (_selectedClasses.length < 4) {
        _selectedClasses.add(cls);
      }
    });
  }

  Future<void> _startGame() async {
    if (_selectedClasses.length != 4) return;

    final notifier = ref.read(gameStateProvider.notifier);
    await notifier.startNewGame(
      _selectedClasses,
      _difficulty,
    );

    if (mounted) context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Hero'),
        actions: const [AudioMuteButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Difficulty: '),
                SegmentedButton<DifficultyLevel>(
                  selected: {_difficulty},
                  onSelectionChanged: (v) => setState(() => _difficulty = v.first),
                  segments: const [
                    ButtonSegment(value: DifficultyLevel.easy, label: Text('Easy')),
                    ButtonSegment(value: DifficultyLevel.normal, label: Text('Normal')),
                    ButtonSegment(value: DifficultyLevel.hard, label: Text('Hard')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select 4 heroes for your party',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _unlockedClasses.length,
              itemBuilder: (context, index) {
                final cls = _unlockedClasses[index];
                final def = classDefinitions[cls]!;
                final selected = _selectedClasses.contains(cls);

                return Card(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: Icon(
                      _classIcon(cls),
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    title: Text(
                      def.name,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'HP:${def.baseStats.hp} ATK:${def.baseStats.attack} '
                      'DEF:${def.baseStats.defense} SPD:${def.baseStats.speed} '
                      'MAG:${def.baseStats.magic}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : const Icon(Icons.circle_outlined),
                    onTap: () => _toggleClass(cls),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedClasses.length == 4 ? _startGame : null,
                child: Text('Begin Adventure! (${_selectedClasses.length}/4)'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _classIcon(CharacterClass cls) {
    switch (cls) {
      case CharacterClass.fighter: return Icons.shield;
      case CharacterClass.rogue: return Icons.visibility;
      case CharacterClass.cleric: return Icons.local_hospital;
      case CharacterClass.wizard: return Icons.auto_fix_high;
      case CharacterClass.paladin: return Icons.security;
      case CharacterClass.ranger: return Icons.forest;
      case CharacterClass.warlock: return Icons.whatshot;
      case CharacterClass.summoner: return Icons.pets;
      case CharacterClass.spellsword: return Icons.bolt;
      case CharacterClass.druid: return Icons.eco;
      case CharacterClass.monk: return Icons.self_improvement;
      case CharacterClass.barbarian: return Icons.fitness_center;
      case CharacterClass.sorcerer: return Icons.flare;
      case CharacterClass.necromancer: return Icons.dark_mode;
      case CharacterClass.artificer: return Icons.build;
      case CharacterClass.templar: return Icons.church;
    }
  }
}
