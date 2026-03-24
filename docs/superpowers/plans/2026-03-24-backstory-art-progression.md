# Backstory & Art Progression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 8-chapter backstories for all 16 classes in the Guide screen, with art that upgrades based on story progress.

**Architecture:** Sprite functions updated to read from `assets/new_art/` with tier-aware paths. Story data moves to its own file. Guide screen redesigned with side-by-side abilities + timeline layout. Codex Stories tab removed.

**Tech Stack:** Flutter, Riverpod, GoRouter, SharedPreferences

**Spec:** `docs/superpowers/specs/2026-03-24-backstory-art-progression-design.md`

---

### Task 1: Update sprite_data.dart for new art paths

**Files:**
- Modify: `lib/data/sprite_data.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Rewrite sprite_data.dart**

Replace the entire file with:

```dart
import '../models/enums.dart';

/// Returns 'low', 'mid', or 'high' based on story chapter progress.
String artTierForProgress(int progress) {
  if (progress >= 8) return 'high';
  if (progress >= 4) return 'mid';
  return 'low';
}

String classSpritePath(CharacterClass cls, [int storyProgress = 0]) {
  final tier = artTierForProgress(storyProgress);
  return 'assets/new_art/${cls.name}_${tier}_128x128.png';
}

/// Maps enemy types to asset filenames where they differ.
const _enemyTypeToAsset = {
  'orc': 'orc_grunt',
  'spider': 'giant_spider',
  'archdemon': 'arch_demon',
};

String enemySpritePath(String enemyType) {
  if (enemyType == 'boss') {
    return 'assets/new_art/goblin_king_256x256.png'; // fallback
  }
  final assetName = _enemyTypeToAsset[enemyType] ?? enemyType;
  return 'assets/new_art/${assetName}_low_128x128.png';
}

/// Maps enemy display names to sprite paths.
/// For bosses, uses 256x256 assets (no boss_ prefix in new_art).
/// For regular enemies, applies type-to-asset mapping then uses _low variant.
String enemySpritePathByName(String enemyName) {
  final normalized = enemyName
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll("'", '');

  const bosses = [
    'goblin_king',
    'bone_lord',
    'shadow_witch',
    'mountain_giant',
    'lich_king',
    'demon_prince',
    'dragon_emperor',
    'the_dark_one',
  ];

  for (final boss in bosses) {
    if (normalized == boss) {
      return 'assets/new_art/${boss}_256x256.png';
    }
  }

  final assetName = _enemyTypeToAsset[normalized] ?? normalized;
  return 'assets/new_art/${assetName}_low_128x128.png';
}
```

Note: `storyProgress` has a default of 0, so existing call sites that don't pass it will compile and show basic art. We update call sites in Task 4.

- [ ] **Step 2: Update pubspec.yaml assets**

In `pubspec.yaml`, add `assets/new_art/` and remove old sprite entries:

```yaml
  assets:
    - assets/new_art/
    - assets/sprites/abilities/
    - assets/sprites/backgrounds/
    - assets/audio/music/
    - assets/audio/sfx/
```

Keep `abilities/` and `backgrounds/` — only the character/enemy sprites moved. Remove `assets/sprites/` and `assets/sprites/enemies/`.

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/data/sprite_data.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/data/sprite_data.dart pubspec.yaml
git commit -m "feat: update sprite paths for new_art with art tier progression"
```

---

### Task 2: Remove Stories tab from Codex

**Why this comes before Task 3:** The codex screen imports `ClassStoryChapter` and `classStories` from `codex_data.dart`. Task 3 removes those symbols from `codex_data.dart`. We must remove the consumer (Stories tab) before removing the symbols it depends on.

**Files:**
- Modify: `lib/ui/screens/codex/codex_screen.dart`

- [ ] **Step 1: Update CodexScreen**

In `codex_screen.dart`:

1. Change `DefaultTabController` length from `3` to `2`
2. Remove the `Tab(text: 'Stories')` from the `TabBar`
3. Remove `_buildStoriesTab(profile, theme)` from the `TabBarView` children
4. Delete the entire `_buildStoriesTab` method (lines 207-269)
5. Keep the `codex_data.dart` import — bestiary and lore still use it

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze lib/ui/screens/codex/`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/codex/codex_screen.dart
git commit -m "feat: remove Stories tab from Codex (moved to Guide)"
```

---

### Task 3: Create class_stories.dart with 8 chapters per class

**Files:**
- Create: `lib/data/class_stories.dart`
- Modify: `lib/data/codex_data.dart`

- [ ] **Step 1: Create lib/data/class_stories.dart**

Move `ClassStoryChapter` class from `codex_data.dart` to this new file. Expand stories from 3 to 8 chapters per class following this arc:

1. Origin — who they were before
2. The call to action — why they fight
3. Early adventure — first challenge
4. A setback or loss
5. A key ally or discovery
6. Growing mastery
7. The darkest moment
8. Final revelation — who they've become

**Style guidance:** Each chapter should be 2-3 sentences, matching the tone and length of existing chapters. The writing is evocative and personal ("you" perspective), with a lighthearted high-fantasy feel appropriate for a kid named Asher. Keep each entry under 60 words.

Reuse existing chapter 1 content as chapter 1 (origin). Reuse existing chapter 2 content where it fits the arc (usually chapter 2 or 3). Rewrite existing chapter 3 (final confrontation) as chapter 8. Write new chapters to fill the remaining slots.

File structure:
```dart
import '../models/enums.dart';

class ClassStoryChapter {
  final CharacterClass characterClass;
  final int chapter;
  final String title;
  final String content;
  const ClassStoryChapter({required this.characterClass, required this.chapter, required this.title, required this.content});
}

const List<ClassStoryChapter> classStories = [
  // Fighter (8 chapters)
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 1, title: 'The Broken Sword', content: '...'),
  // ... all 8 chapters per class
  // ... all 16 classes = 128 total entries
];
```

- [ ] **Step 2: Update codex_data.dart**

Remove the `ClassStoryChapter` class and `classStories` list from `codex_data.dart`. Also remove the `import '../models/enums.dart';` line — the remaining types (`BestiaryDefinition`, `LorePageDefinition`) only use `String` and `int`, not `CharacterClass`.

The file should only contain `BestiaryDefinition`, `LorePageDefinition`, `bestiaryEntries`, and `lorePages`.

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/`
Expected: No errors across the whole project (codex screen no longer references classStories since Task 2 removed the Stories tab)

- [ ] **Step 4: Commit**

```bash
git add lib/data/class_stories.dart lib/data/codex_data.dart
git commit -m "feat: add 8-chapter backstories for all 16 classes"
```

---

### Task 4: Update classSpritePath call sites to pass story progress

**Files:**
- Modify: `lib/ui/screens/combat/combat_screen.dart`
- Modify: `lib/ui/screens/recruit/recruit_screen.dart`

Note: `help_screen.dart` also calls `classSpritePath` but gets a full rewrite in Task 5, so it's handled there.

Using `ref.read` (not `ref.watch`) is intentional here — story progress cannot change during combat or recruiting, so there's no need to rebuild on profile changes. This avoids unnecessary rebuilds in performance-sensitive screens.

- [ ] **Step 1: Update combat_screen.dart**

The combat screen is already a `ConsumerStatefulWidget`. Add the player profile import and read story progress at the two call sites.

Add import at top:
```dart
import '../../../providers/player_profile_provider.dart';
```

At line ~1324 in `_buildAllyWidget`, change:
```dart
final spritePath = classSpritePath(ally.characterClass);
```
to:
```dart
final storyProgress = ref.read(playerProfileProvider)?.classStoryProgress[ally.characterClass.name] ?? 0;
final spritePath = classSpritePath(ally.characterClass, storyProgress);
```

At line ~1571, change:
```dart
classSpritePath(char.characterClass),
```
to:
```dart
classSpritePath(char.characterClass, ref.read(playerProfileProvider)?.classStoryProgress[char.characterClass.name] ?? 0),
```

- [ ] **Step 2: Update recruit_screen.dart**

Already a `ConsumerStatefulWidget`. Add import:
```dart
import '../../../providers/player_profile_provider.dart';
```

At line ~168, change:
```dart
classSpritePath(cls),
```
to:
```dart
classSpritePath(cls, ref.read(playerProfileProvider)?.classStoryProgress[cls.name] ?? 0),
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/ui/screens/combat/ lib/ui/screens/recruit/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/combat/combat_screen.dart lib/ui/screens/recruit/recruit_screen.dart
git commit -m "feat: pass story progress to classSpritePath in combat and recruit screens"
```

---

### Task 5: Redesign Guide screen with art tiers and story timeline

**Files:**
- Modify: `lib/ui/screens/help/help_screen.dart`

- [ ] **Step 1: Rewrite help_screen.dart**

Major changes:
1. Convert `HelpScreen` from `StatelessWidget` to `ConsumerWidget`
2. Add imports: `flutter_riverpod`, `player_profile_provider`, `class_stories.dart`, `sprite_data.dart`
3. Read `playerProfileProvider` in `build()` and pass to child widgets
4. Convert `_ClassCard` to a stateless widget that receives `profile` as a parameter (cleaner than making it a ConsumerWidget since the parent already watches the provider)

**Header redesign:**
- Left side: class name + starter badge + stats (keep existing layout)
- Right side: 3 art tier images in a horizontal `Row`:

```dart
Widget _buildArtTiers(ClassDefinition cls, int progress, ThemeData theme) {
  final currentTier = artTierForProgress(progress);
  final tiers = [
    ('low', 'Basic', 0),
    ('mid', '4/8 chapters', 4),
    ('high', '8/8 chapters', 8),
  ];

  return Row(
    mainAxisSize: MainAxisSize.min,
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
    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 64),
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
        isCurrent ? label.split(' ').first : label, // "Basic" or "4/8 chapters"
        style: theme.textTheme.labelSmall?.copyWith(
          color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}
```

**Body redesign — two columns in a Row wrapped in Expanded:**

Left column — abilities (keep existing `_buildAbilityRow`), wrapped in `Expanded`.

Right column — story timeline, wrapped in `Expanded`:

```dart
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
          Text('BACKSTORY', style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(width: 8),
          Text('$progress/8', style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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
                  color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${chapter.chapter}',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold,
                    color: isUnlocked ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.15),
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
                  color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  width: 3,
                ),
              ),
            ),
            child: isUnlocked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter.title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(chapter.content, style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4)),
                    ],
                  )
                : Text(
                    'Chapter ${chapter.chapter}: Not unlocked',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
          ),
        ),
      ],
    ),
  );
}
```

The `ExpansionTile` children should be a single `Padding` wrapping a `Row` of two `Expanded` children: abilities column and timeline column.

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze lib/ui/screens/help/`
Expected: No errors

- [ ] **Step 3: Visual verification**

Run the app and check:
- Guide → Classes tab shows all 16 classes
- Expanding a class shows abilities left, timeline right, side by side
- Art tiers in header: basic full color, mid/high greyed if locked
- Story text shows for unlocked chapters, "Not unlocked" for locked ones
- Scrolling works with the expanded tall content

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/help/help_screen.dart
git commit -m "feat: redesign Guide screen with art tiers and story timeline"
```

---

### Task 6: Final verification

**Files:**
- None (verification only)

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: All tests pass. The `classStoryProgress` field shape is unchanged (still `Map<String, int>`), just the range expanded from 0-3 to 0-8.

- [ ] **Step 2: Run flutter analyze on full project**

Run: `flutter analyze lib/`
Expected: 0 issues

- [ ] **Step 3: Verify class_stories.dart has all 128 entries**

Quick sanity check: `grep -c 'ClassStoryChapter(' lib/data/class_stories.dart` should return 128 (not counting the class definition line).

---

### Known Issues / Future Work

- **Missing asset:** `elder_dragon_mid_128x128.png` does not exist in `assets/new_art/`. Enemies only use `_low_` so this is not a current problem, but it will need to be created before enemy art tiers are implemented.
- **Unlock mechanism:** Event node integration (how chapters actually get unlocked during gameplay) is designed separately.
- **32x32 variants:** `fighter` and `wizard` have 32x32 art variants in `assets/new_art/` — not used currently but available for small UI contexts if needed later.
