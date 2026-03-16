import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/legacy_data.dart';
import '../../../data/mutator_data.dart';
import '../../../models/enums.dart';
import '../../../models/player_profile.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../../providers/help_mode_provider.dart';
import '../../widgets/audio_controls.dart';
import '../../widgets/help_button.dart';

class PartySelectScreen extends ConsumerStatefulWidget {
  const PartySelectScreen({super.key});

  @override
  ConsumerState<PartySelectScreen> createState() => _PartySelectScreenState();
}

class _PartySelectScreenState extends ConsumerState<PartySelectScreen> {
  final _selectedClasses = <CharacterClass>[];
  DifficultyLevel _difficulty = DifficultyLevel.normal;
  String? _selectedPerk;

  List<StartingPerkDefinition> get _availablePerks {
    final profile = ref.read(playerProfileProvider);
    if (profile == null) return [];
    return startingPerks
        .where((p) => profile.unlockedPerks.contains(p.id))
        .toList();
  }

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

    final mutator = runMutators[Random().nextInt(runMutators.length)];

    final profile = ref.read(playerProfileProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    await notifier.startNewGame(
      _selectedClasses,
      _difficulty,
      profile: profile,
      activePerk: _selectedPerk,
      activeMutator: mutator.id,
    );

    if (mounted) context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Hero'),
        actions: const [HelpButton(), AudioMuteButton()],
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
                  segments: DifficultyLevel.values.map((d) {
                    final profile = ref.read(playerProfileProvider);
                    final unlocked = profile?.unlockedDifficulties.contains(d) ?? false;
                    return ButtonSegment(
                      value: d,
                      label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                      enabled: unlocked,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Perk selection (only if perks unlocked)
          if (_availablePerks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Starting Perk',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // "None" option
                  ChoiceChip(
                    label: const Text('None'),
                    selected: _selectedPerk == null,
                    onSelected: (_) => setState(() => _selectedPerk = null),
                  ),
                  // Unlocked perks
                  ..._availablePerks.map((perk) => ChoiceChip(
                    label: Text(perk.name),
                    selected: _selectedPerk == perk.id,
                    onSelected: (_) => setState(() => _selectedPerk = perk.id),
                    tooltip: perk.description,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
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
                    onTap: () {
                      if (ref.read(helpModeProvider)) {
                        ref.read(helpModeProvider.notifier).state = false;
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(def.name),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Base Stats:', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('HP: ${def.baseStats.hp}  ATK: ${def.baseStats.attack}  DEF: ${def.baseStats.defense}  SPD: ${def.baseStats.speed}  MAG: ${def.baseStats.magic}'),
                                  const Divider(),
                                  Text('Abilities:', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  ...def.abilities.map((a) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                        Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                          ),
                        );
                        return;
                      }
                      _toggleClass(cls);
                    },
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
