import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/codex_data.dart';
import '../../../models/player_profile.dart';
import '../../../providers/player_profile_provider.dart';

class CodexScreen extends ConsumerWidget {
  const CodexScreen({super.key});

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
          title: const Text('Codex'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bestiary'),
              Tab(text: 'Lore'),
              Tab(text: 'Stories'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBestiaryTab(profile, theme),
            _buildLoreTab(profile, theme),
            _buildStoriesTab(profile, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBestiaryTab(PlayerProfile profile, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bestiaryEntries.length,
      itemBuilder: (context, index) {
        final entry = bestiaryEntries[index];
        final kills = profile.bestiaryKills[entry.enemyType] ?? 0;

        if (kills == 0) {
          // Locked
          return Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              title: Text(
                '???',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
              subtitle: Text(
                'Unknown creature',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              ),
            ),
          );
        } else if (kills < 5) {
          // Name and kill count, description hidden
          return Card(
            child: ListTile(
              leading: Icon(Icons.pets, color: theme.colorScheme.primary),
              title: Text(entry.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Defeated: $kills'),
                  Text(
                    'Kill 5 to learn more...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (kills < 15) {
          // Name, kill count, and description
          return Card(
            child: ListTile(
              leading: Icon(Icons.pets, color: theme.colorScheme.primary),
              title: Text(entry.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Defeated: $kills'),
                  const SizedBox(height: 4),
                  Text(entry.description),
                ],
              ),
            ),
          );
        } else {
          // Mastered
          return Card(
            child: ListTile(
              leading: Icon(Icons.pets, color: theme.colorScheme.primary),
              title: Row(
                children: [
                  Text(entry.name),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Mastered',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Defeated: $kills'),
                  const SizedBox(height: 4),
                  Text(entry.description),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildLoreTab(PlayerProfile profile, ThemeData theme) {
    const tierNames = {
      1: 'Tier 1: The Frontier',
      2: 'Tier 2: The Corrupted Lands',
      3: 'Tier 3: The Wilds',
      4: 'Tier 4: The Dark Realm',
    };

    final grouped = <int, List<LorePageDefinition>>{};
    for (final page in lorePages) {
      grouped.putIfAbsent(page.mapTier, () => []).add(page);
    }

    final tiers = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: tiers.map((tier) {
        final pages = grouped[tier]!;
        final foundCount = pages.where((p) => profile.loreFound.contains(p.id)).length;

        return ExpansionTile(
          title: Text(tierNames[tier] ?? 'Tier $tier'),
          subtitle: Text('$foundCount/${pages.length} pages found'),
          children: pages.map((page) {
            final found = profile.loreFound.contains(page.id);
            if (found) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(page.content, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              );
            } else {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.lock, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  title: Text(
                    '???',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                ),
              );
            }
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildStoriesTab(PlayerProfile profile, ThemeData theme) {
    // Group stories by class
    final grouped = <String, List<ClassStoryChapter>>{};
    for (final story in classStories) {
      grouped.putIfAbsent(story.characterClass.name, () => []).add(story);
    }

    final classNames = grouped.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: classNames.map((className) {
        final chapters = grouped[className]!..sort((a, b) => a.chapter.compareTo(b.chapter));
        final progress = profile.classStoryProgress[className] ?? 0;
        final displayName = className[0].toUpperCase() + className.substring(1);

        return ExpansionTile(
          title: Text(displayName),
          subtitle: Text('$progress/${chapters.length} chapters'),
          children: chapters.map((ch) {
            final unlocked = progress >= ch.chapter;
            if (unlocked) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${ch.chapter}: ${ch.title}',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(ch.content, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              );
            } else {
              final hintMap = {1: 'Complete map 2', 2: 'Complete map 5', 3: 'Complete map 8'};
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.lock, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  title: Text(
                    'Chapter ${ch.chapter}: ???',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                  subtitle: Text(
                    '${hintMap[ch.chapter] ?? "Complete more maps"} with this class alive',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            }
          }).toList(),
        );
      }).toList(),
    );
  }
}
