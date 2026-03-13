import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/equipment_data.dart';
import '../../../models/character.dart';
import '../../../models/enums.dart';
import '../../../models/equipment.dart';
import '../../../providers/game_state_provider.dart';

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

    final pool = getTreasurePool(gameState.currentMapNumber);
    final random = Random();

    _loot = pool[random.nextInt(pool.length)];
    _goldFound = 10 + random.nextInt(20) * gameState.currentMapNumber;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: Text('No game state')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Treasure!')),
      body: Center(
        child: Padding(
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
                  ...gameState.party.map((char) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: SizedBox(
                      width: 220,
                      child: OutlinedButton(
                        onPressed: () => _equipTo(char),
                        child: Text('Give to ${char.name.split(' ').first}'),
                      ),
                    ),
                  )),
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
