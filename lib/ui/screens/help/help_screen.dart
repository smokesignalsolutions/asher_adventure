import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/class_stories.dart';
import '../../../data/sprite_data.dart';
import '../../../models/ability.dart';
import '../../../models/enums.dart';
import '../../../models/player_profile.dart';
import '../../../providers/player_profile_provider.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
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
            _buildClassesTab(theme, classes, profile),
            _buildNodesTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTab(ThemeData theme, List<ClassDefinition> classes, PlayerProfile? profile) {
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
        return _ClassCard(cls: cls, theme: theme, profile: profile);
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
      itemCount: nodes.length + 1,
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
  final PlayerProfile? profile;

  const _ClassCard({required this.cls, required this.theme, required this.profile});

  @override
  Widget build(BuildContext context) {
    final progress = profile?.classStoryProgress[cls.characterClass.name] ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Image.asset(
          classSpritePath(cls.characterClass, progress),
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
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                'HP:${cls.baseStats.hp}  ATK:${cls.baseStats.attack}  DEF:${cls.baseStats.defense}  '
                'SPD:${cls.baseStats.speed}  MAG:${cls.baseStats.magic}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        children: [
          // Art tiers row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildArtTiers(cls, progress, theme),
          ),
          // Two-column body: abilities left, story timeline right
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Abilities
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABILITIES',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final ability in cls.abilities)
                        _buildAbilityRow(ability, theme),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Story Timeline
                Expanded(
                  child: _buildStoryTimeline(cls, progress, theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtTiers(ClassDefinition cls, int progress, ThemeData theme) {
    final currentTier = artTierForProgress(progress);
    final tiers = [
      ('low', 'Basic', 0),
      ('mid', '4/8 chapters', 4),
      ('high', '8/8 chapters', 8),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < tiers.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.arrow_forward, size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          _buildArtTierImage(cls, tiers[i], currentTier, progress, theme),
        ],
      ],
    );
  }

  Widget _buildArtTierImage(
    ClassDefinition cls,
    (String tier, String label, int threshold) tierInfo,
    String currentTier,
    int progress,
    ThemeData theme,
  ) {
    final (tier, label, threshold) = tierInfo;
    final isUnlocked = progress >= threshold;
    final isCurrent = currentTier == tier;
    final path = 'assets/new_art/${cls.characterClass.name}_${tier}_128x128.png';

    Widget image = Image.asset(
      path, width: 64, height: 64,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 64),
    );

    if (!isUnlocked) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(opacity: 0.4, child: image),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              width: isCurrent ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: image,
        ),
        const SizedBox(height: 2),
        Text(
          isCurrent && threshold == 0 ? 'Basic' : label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryTimeline(ClassDefinition cls, int progress, ThemeData theme) {
    final stories = classStories
        .where((s) => s.characterClass == cls.characterClass)
        .toList()
      ..sort((a, b) => a.chapter.compareTo(b.chapter));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BACKSTORY',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$progress/8',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(stories.length, (i) {
          final chapter = stories[i];
          final isUnlocked = progress >= chapter.chapter;
          final isLast = i == stories.length - 1;
          return _buildTimelineEntry(chapter, isUnlocked, isLast, theme);
        }),
      ],
    );
  }

  Widget _buildTimelineEntry(ClassStoryChapter chapter, bool isUnlocked, bool isLast, ThemeData theme) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node + connecting line
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${chapter.chapter}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isUnlocked
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          // Chapter content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? theme.colorScheme.surfaceContainerLow
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border(
                  left: BorderSide(
                    color: isUnlocked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 3,
                  ),
                ),
              ),
              child: isUnlocked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.content,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Chapter ${chapter.chapter}: Not unlocked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 6),
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
