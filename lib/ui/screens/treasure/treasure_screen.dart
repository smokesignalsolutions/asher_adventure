import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/codex_data.dart';
import '../../../data/equipment_data.dart';
import '../../../data/legendary_data.dart';
import '../../../models/character.dart';
import '../../../models/enums.dart';
import '../../../models/equipment.dart';
import '../../../providers/audio_provider.dart';
import '../../../data/mutator_data.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/player_profile_provider.dart';
import '../../../services/audio_service.dart';
import '../../widgets/audio_controls.dart';

class TreasureScreen extends ConsumerStatefulWidget {
  const TreasureScreen({super.key});

  @override
  ConsumerState<TreasureScreen> createState() => _TreasureScreenState();
}

class _TreasureScreenState extends ConsumerState<TreasureScreen> {
  Equipment? _loot;
  int _goldFound = 0;
  bool _equipped = false;

  @override
  void initState() {
    super.initState();
    _generateLoot();
  }

  void _generateLoot() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    final random = Random();

    if (random.nextInt(100) < 10 && legendaryItems.isNotEmpty) {
      _loot = legendaryItems[random.nextInt(legendaryItems.length)];
    } else {
      final pool = getTreasurePool(gameState.currentMapNumber);
      _loot = pool[random.nextInt(pool.length)];
    }
    final treasureGoldMultiplier = getMutatorEffect(gameState.activeMutator, 'treasure_gold');
    _goldFound = ((10 + random.nextInt(20) * gameState.currentMapNumber) * treasureGoldMultiplier).round();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioProvider.notifier).playSfx(SfxType.goldPickup);
      _checkForLoreDrop();
    });
  }

  void _checkForLoreDrop() {
    final random = Random();
    if (random.nextInt(100) >= 20) return; // 80% chance to skip

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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: Text('No game state')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure!'),
        actions: const [AudioMuteButton()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💎', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                'You found treasure!',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (_goldFound > 0) ...[
                Text(
                  '+$_goldFound gold',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_loot != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _loot!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _rarityColor(_loot!.rarity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_itemStats(_loot!)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_equipped)
                  ...gameState.party.map((char) {
                    final className = char.characterClass.name[0].toUpperCase() +
                        char.characterClass.name.substring(1);
                    final currentItem = char.equipment[_loot!.slot];
                    final currentLabel = currentItem != null
                        ? currentItem.name
                        : 'Empty';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(
                        width: 280,
                        child: OutlinedButton(
                          onPressed: () => _equipTo(char),
                          child: Text(
                            '${char.name.split(' ').first} ($className)\n'
                            'Current: $currentLabel',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).completeCombat(0, _goldFound);
                    context.go('/map');
                  },
                  child: Text(_equipped ? 'Continue' : 'Take Gold & Leave'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _equipTo(Character char) {
    if (_loot == null) return;
    final oldItem = char.equipment[_loot!.slot];
    int sellBack = 0;
    if (oldItem != null) {
      sellBack = (oldItem.value / 2).floor();
      ref.read(gameStateProvider.notifier).addGold(sellBack);
    }
    char.equipment[_loot!.slot] = _loot;
    setState(() => _equipped = true);
    final msg = sellBack > 0
        ? '${char.name} equipped ${_loot!.name}! (Sold ${oldItem!.name} for ${sellBack}g)'
        : '${char.name} equipped ${_loot!.name}!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Color _rarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common: return Colors.grey;
      case Rarity.uncommon: return Colors.green;
      case Rarity.rare: return Colors.blue;
      case Rarity.epic: return Colors.purple;
      case Rarity.legendary: return Colors.orange;
    }
  }

  String _itemStats(Equipment item) {
    final parts = <String>[];
    parts.add(item.slot.name);
    if (item.attackBonus > 0) parts.add('+${item.attackBonus} ATK');
    if (item.defenseBonus > 0) parts.add('+${item.defenseBonus} DEF');
    if (item.hpBonus > 0) parts.add('+${item.hpBonus} HP');
    if (item.speedBonus > 0) parts.add('+${item.speedBonus} SPD');
    if (item.magicBonus > 0) parts.add('+${item.magicBonus} MAG');
    return parts.join(' ');
  }
}
