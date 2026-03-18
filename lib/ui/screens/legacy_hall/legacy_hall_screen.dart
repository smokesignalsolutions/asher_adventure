import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/legacy_data.dart';
import '../../../models/enums.dart';
import '../../../models/player_profile.dart';
import '../../../providers/player_profile_provider.dart';

class LegacyHallScreen extends ConsumerWidget {
  const LegacyHallScreen({super.key});

  /// Cost for the next class unlock: 50, 75, 100, 125, ...
  /// Based on how many non-starter classes the player already owns.
  static int _nextClassCost(PlayerProfile profile) {
    final bought = profile.unlockedClasses
        .where((cls) => !PlayerProfile.starterClasses.contains(cls))
        .length;
    return 50 + bought * 25;
  }

  /// Total passive ranks + perks the player has purchased.
  static int _totalPassiveAndPerkPurchases(PlayerProfile profile) {
    final ranks = profile.passiveBonuses.values.fold(0, (sum, rank) => sum + rank);
    final perks = profile.unlockedPerks.length;
    return ranks + perks;
  }

  /// Scaled cost for a passive or perk: base cost * 1.1^(total purchases).
  static int _scaledCost(int baseCost, PlayerProfile profile) {
    final purchases = _totalPassiveAndPerkPurchases(profile);
    if (purchases == 0) return baseCost;
    return (baseCost * _pow(1.1, purchases)).round();
  }

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => GoRouter.of(context).go('/'),
          ),
          title: const Text('Legacy Hall'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Classes'),
              Tab(text: 'Passives'),
              Tab(text: 'Perks'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.legacyPoints} Legacy Points',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildClassesTab(context, ref, profile, theme),
                  _buildPassivesTab(context, ref, profile, theme),
                  _buildPerksTab(context, ref, profile, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTab(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    ThemeData theme,
  ) {
    final unlockableClasses = CharacterClass.values
        .where((cls) => !PlayerProfile.starterClasses.contains(cls))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: unlockableClasses.length,
      itemBuilder: (context, index) {
        final cls = unlockableClasses[index];
        final def = classDefinitions[cls]!;
        final isOwned = profile.unlockedClasses.contains(cls);
        final cost = _nextClassCost(profile);
        final canAfford = profile.legacyPoints >= cost;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HP ${def.baseStats.hp}  ATK ${def.baseStats.attack}'
                  '  DEF ${def.baseStats.defense}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                if (isOwned)
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 18,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Owned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          )),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$cost LP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      FilledButton(
                        onPressed: canAfford
                            ? () => ref
                                .read(playerProfileProvider.notifier)
                                .purchaseClassUnlock(cls, cost)
                            : null,
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPassivesTab(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: passiveBonuses.length,
      itemBuilder: (context, index) {
        final bonus = passiveBonuses[index];
        final currentRank = profile.passiveBonuses[bonus.id] ?? 0;
        final isMaxed = currentRank >= bonus.maxRanks;
        final cost = _scaledCost(bonus.costPerRank, profile);
        final canAfford = profile.legacyPoints >= cost;

        return Card(
          child: ListTile(
            title: Text(bonus.name),
            subtitle: Text(bonus.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$currentRank / ${bonus.maxRanks}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    if (!isMaxed)
                      Text('$cost LP',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (!isMaxed && canAfford)
                      ? () => ref
                          .read(playerProfileProvider.notifier)
                          .purchasePassiveBonus(
                              bonus.id, cost, bonus.maxRanks)
                      : null,
                  child: Text(isMaxed ? 'MAX' : 'Buy'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerksTab(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: startingPerks.length,
      itemBuilder: (context, index) {
        final perk = startingPerks[index];
        final isOwned = profile.unlockedPerks.contains(perk.id);
        final cost = _scaledCost(perk.cost, profile);
        final canAfford = profile.legacyPoints >= cost;

        return Card(
          child: ListTile(
            title: Text(perk.name),
            subtitle: Text(perk.description),
            trailing: isOwned
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 18,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Owned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          )),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$cost LP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: canAfford
                            ? () => ref
                                .read(playerProfileProvider.notifier)
                                .purchasePerk(perk.id, cost)
                            : null,
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
