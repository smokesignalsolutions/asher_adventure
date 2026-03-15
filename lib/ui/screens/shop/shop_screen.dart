import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/equipment_data.dart';
import '../../../models/character.dart';
import '../../../models/equipment.dart';
import '../../../providers/audio_provider.dart';
import '../../../data/mutator_data.dart';
import '../../../providers/game_state_provider.dart';
import '../../../services/audio_service.dart';
import '../../widgets/audio_controls.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late List<Equipment> _stockItems;
  bool _stockGenerated = false;
  double _shopCostMultiplier = 1.0;

  List<Equipment> _generateStock(int mapNumber, String nodeId) {
    final allItems = shopItemsByMap[mapNumber] ?? [];
    // Seed by node ID so stock is consistent per shop visit
    final shopRng = Random(nodeId.hashCode);
    // Each item has a 65% chance of being in stock
    return allItems.where((_) => shopRng.nextDouble() < 0.65).toList();
  }

  int _potionCost(int mapNumber) => 15 + (mapNumber * 10);

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: Text('No game state')));
    }

    // Generate stock once per shop visit
    if (!_stockGenerated) {
      _stockItems = _generateStock(
        gameState.currentMapNumber,
        gameState.currentMap.currentNodeId,
      );
      _shopCostMultiplier = getMutatorEffect(gameState.activeMutator, 'shop_cost');
      _stockGenerated = true;
    }

    final theme = Theme.of(context);
    final potionCost = (_potionCost(gameState.currentMapNumber) * _shopCostMultiplier).round();

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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Potions section ---
                Card(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_drink,
                      color: Colors.red.shade400,
                      size: 28,
                    ),
                    title: Row(
                      children: [
                        const Text('Health Potion'),
                        const SizedBox(width: 8),
                        if (gameState.healthPotions > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Owned: ${gameState.healthPotions}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    subtitle: const Text('Heals 40% of a character\'s max HP'),
                    trailing: FilledButton(
                      onPressed: gameState.gold >= potionCost
                          ? () => _buyPotion(potionCost)
                          : null,
                      child: Text('${potionCost}g'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_stockItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No equipment in stock today.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                // --- Equipment section ---
                ..._stockItems.map((item) {
                  final adjustedPrice = (item.value * _shopCostMultiplier).round();
                  final canAfford = gameState.gold >= adjustedPrice;
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(_itemStats(item)),
                      trailing: FilledButton(
                        onPressed: canAfford
                            ? () => _showEquipDialog(item)
                            : null,
                        child: Text('${adjustedPrice}g'),
                      ),
                    ),
                  );
                }),
              ],
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

  void _buyPotion(int cost) {
    ref.read(gameStateProvider.notifier).buyPotion(cost);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bought a Health Potion!')),
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
    final adjustedPrice = (item.value * _shopCostMultiplier).round();
    final oldItem = char.equipment[item.slot];
    int sellBack = 0;
    if (oldItem != null) {
      sellBack = (oldItem.value / 2).floor();
    }
    char.equipment[item.slot] = item;
    ref.read(audioProvider.notifier).playSfx(SfxType.goldPickup);
    ref.read(gameStateProvider.notifier).spendGold(adjustedPrice);
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
    if (item.attackBonus != 0) parts.add('${item.attackBonus > 0 ? "+" : ""}${item.attackBonus} ATK');
    if (item.defenseBonus != 0) parts.add('${item.defenseBonus > 0 ? "+" : ""}${item.defenseBonus} DEF');
    if (item.hpBonus != 0) parts.add('${item.hpBonus > 0 ? "+" : ""}${item.hpBonus} HP');
    if (item.speedBonus != 0) parts.add('${item.speedBonus > 0 ? "+" : ""}${item.speedBonus} SPD');
    if (item.magicBonus != 0) parts.add('${item.magicBonus > 0 ? "+" : ""}${item.magicBonus} MAG');
    return parts.join(' ');
  }
}
