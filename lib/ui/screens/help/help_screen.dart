import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/sprite_data.dart';
import '../../../models/ability.dart';
import '../../../models/enums.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = classDefinitions.values.toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Guide'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Classes'),
              Tab(text: 'Map Nodes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClassesTab(theme, classes),
            _buildNodesTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTab(ThemeData theme, List<ClassDefinition> classes) {
    // Starter classes first, then the rest
    final sorted = [...classes]..sort((a, b) {
        if (a.unlockedByDefault != b.unlockedByDefault) {
          return a.unlockedByDefault ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final cls = sorted[index];
        return _ClassCard(cls: cls, theme: theme);
      },
    );
  }

  Widget _buildNodesTab(ThemeData theme) {
    final nodes = [
      _NodeInfo('⚔️', 'Combat', 'Fight enemies to earn XP and gold.'),
      _NodeInfo('💀', 'Boss', 'A powerful boss guards the end of each map. Defeat it to advance.'),
      _NodeInfo('🏪', 'Shop', 'Buy equipment and potions with gold.'),
      _NodeInfo('🏕️', 'Rest', 'Heal your party at a campfire.'),
      _NodeInfo('💎', 'Treasure', 'Find gold, potions, or equipment.'),
      _NodeInfo('❗', 'Event', 'A random encounter — could be helpful or dangerous.'),
      _NodeInfo('🍺', 'Tavern', 'Recruit new party members (max 4). Cost scales with map number.'),
      _NodeInfo('🏁', 'Start', 'Your starting position on each map.'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: nodes.length + 1, // +1 for the army info card
      itemBuilder: (context, index) {
        if (index < nodes.length) {
          final node = nodes[index];
          return Card(
            child: ListTile(
              leading: Text(node.icon, style: const TextStyle(fontSize: 28)),
              title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(node.description),
            ),
          );
        }
        // Army info card
        return Card(
          color: theme.colorScheme.errorContainer,
          child: ListTile(
            leading: const Text('⚔', style: TextStyle(fontSize: 28)),
            title: Text(
              'The Army',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            subtitle: Text(
              'A pursuing army advances from the left each time you move. '
              'If it catches you, you must fight a large group of soldiers. '
              'Move quickly to stay ahead!',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        );
      },
    );
  }
}

class _NodeInfo {
  final String icon;
  final String name;
  final String description;
  const _NodeInfo(this.icon, this.name, this.description);
}

class _ClassCard extends StatelessWidget {
  final ClassDefinition cls;
  final ThemeData theme;

  const _ClassCard({required this.cls, required this.theme});

  @override
  Widget build(BuildContext context) {
    final stats = cls.baseStats;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Image.asset(
          classSpritePath(cls.characterClass),
          width: 40,
          height: 40,
          filterQuality: FilterQuality.none,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 40),
        ),
        title: Row(
          children: [
            Text(
              cls.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (cls.unlockedByDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Starter',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'HP:${stats.hp}  ATK:${stats.attack}  DEF:${stats.defense}  '
          'SPD:${stats.speed}  MAG:${stats.magic}',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          for (final ability in cls.abilities)
            _buildAbilityRow(ability, theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAbilityRow(Ability ability, ThemeData theme) {
    final isHeal = ability.damage < 0;
    final dmgLabel = isHeal
        ? 'Heal ${ability.damage.abs()}'
        : 'Dmg ${ability.damage}';

    final targetLabel = switch (ability.targetType) {
      AbilityTarget.singleEnemy => 'Single Enemy',
      AbilityTarget.allEnemies => 'All Enemies',
      AbilityTarget.singleAlly => 'Single Ally',
      AbilityTarget.allAllies => 'All Allies',
      AbilityTarget.self => 'Self',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: ability.isBasicAttack
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ability.isBasicAttack ? 'Lv 1' : 'Lv ${ability.unlockedAtLevel}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Ability details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ability.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ability.isBasicAttack) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Basic',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  ability.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isHeal ? Icons.favorite : Icons.flash_on,
                      size: 12,
                      color: isHeal ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      dmgLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isHeal ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.my_location, size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 2),
                    Text(
                      targetLabel,
                      style: theme.textTheme.labelSmall,
                    ),
                    if (!ability.isBasicAttack) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.refresh, size: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 2),
                      Text(
                        '${ability.refreshChance}%',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
