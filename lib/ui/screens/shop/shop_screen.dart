import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/equipment_data.dart';
import '../../../models/character.dart';
import '../../../models/equipment.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../services/audio_service.dart';
import '../../widgets/audio_controls.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: Text('No game state')));
    }

    final theme = Theme.of(context);
    final items = shopItemsByMap[gameState.currentMapNumber] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          const AudioMuteButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${gameState.gold}g',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final canAfford = gameState.gold >= item.value;

                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(_itemStats(item)),
                    trailing: FilledButton(
                      onPressed: canAfford
                          ? () => _showEquipDialog(item)
                          : null,
                      child: Text('${item.value}g'),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => context.go('/map'),
                child: const Text('Leave Shop'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipDialog(Equipment item) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Equip ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: gameState.party.map((char) {
            final current = char.equipment[item.slot];
            return ListTile(
              title: Text(char.name),
              subtitle: Text(current != null ? 'Replace: ${current.name}' : 'Empty slot'),
              onTap: () {
                Navigator.pop(ctx);
                _buyAndEquip(item, char);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _buyAndEquip(Equipment item, Character char) {
    final oldItem = char.equipment[item.slot];
    int sellBack = 0;
    if (oldItem != null) {
      sellBack = (oldItem.value / 2).floor();
    }
    char.equipment[item.slot] = item;
    ref.read(audioProvider.notifier).playSfx(SfxType.goldPickup);
    ref.read(gameStateProvider.notifier).spendGold(item.value);
    if (sellBack > 0) {
      ref.read(gameStateProvider.notifier).addGold(sellBack);
    }
    setState(() {});
    final msg = sellBack > 0
        ? '${char.name} equipped ${item.name}! (Sold ${oldItem!.name} for ${sellBack}g)'
        : '${char.name} equipped ${item.name}!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _itemStats(Equipment item) {
    final parts = <String>[];
    parts.add(item.slot.name);
    parts.add('(${item.rarity.name})');
    if (item.attackBonus > 0) parts.add('+${item.attackBonus} ATK');
    if (item.defenseBonus > 0) parts.add('+${item.defenseBonus} DEF');
    if (item.hpBonus > 0) parts.add('+${item.hpBonus} HP');
    if (item.speedBonus > 0) parts.add('+${item.speedBonus} SPD');
    if (item.magicBonus > 0) parts.add('+${item.magicBonus} MAG');
    return parts.join(' ');
  }
}
