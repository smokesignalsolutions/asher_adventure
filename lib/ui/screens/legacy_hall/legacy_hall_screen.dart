import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/class_data.dart';
import '../../../data/legacy_data.dart';
import '../../../models/enums.dart';
import '../../../models/player_profile.dart';
import '../../../providers/player_profile_provider.dart';

class LegacyHallScreen extends ConsumerWidget {
  const LegacyHallScreen({super.key});

  static const _classUnlockCosts = [
    50, 75, 100, 150, 200, 250, 300, 350, 400, 500, 600, 750,
  ];

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
        final cost = _classUnlockCosts[index];
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
        final canAfford = profile.legacyPoints >= bonus.costPerRank;

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
                      Text('${bonus.costPerRank} LP',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (!isMaxed && canAfford)
                      ? () => ref
                          .read(playerProfileProvider.notifier)
                          .purchasePassiveBonus(
                              bonus.id, bonus.costPerRank, bonus.maxRanks)
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
        final canAfford = profile.legacyPoints >= perk.cost;

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
                      Text('${perk.cost} LP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: canAfford
                            ? () => ref
                                .read(playerProfileProvider.notifier)
                                .purchasePerk(perk.id, perk.cost)
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
