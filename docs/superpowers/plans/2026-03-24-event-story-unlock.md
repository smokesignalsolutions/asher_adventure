# Event Story Unlock Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire up event nodes to unlock backstory chapters via an "explore" follow-up choice, with themed events and art upgrade animations.

**Architecture:** Extract event data to a dedicated file with theme tags and class affinities. Add an explore/move-on follow-up after each event. Explore triggers a story unlock for an eligible party member. Chapters 4 and 8 show art tier upgrade animation.

**Tech Stack:** Flutter, Riverpod, GoRouter

**Spec:** `docs/superpowers/specs/2026-03-24-event-story-unlock-design.md`

---

### Task 1: Create event_data.dart with themed events

**Files:**
- Create: `lib/data/event_data.dart`

- [ ] **Step 1: Create the event data file**

Create `lib/data/event_data.dart` with:

1. `GameEvent` and `EventChoice` const-compatible classes (replacing the private `_GameEvent` and `_EventChoice` from event_screen.dart)
2. `themeClassAffinities` map
3. `mapThemeWeights` map (placeholder weights)
4. All 34 existing events, each tagged with a theme

```dart
import '../models/enums.dart';

class EventChoice {
  final String text;
  final String result;
  final int goldChange;
  final int hpChange;
  const EventChoice({required this.text, required this.result, this.goldChange = 0, this.hpChange = 0});
}

class GameEvent {
  final String title;
  final String description;
  final String theme;
  final List<EventChoice> choices;
  const GameEvent({required this.title, required this.description, required this.theme, required this.choices});
}

const Map<String, List<CharacterClass>> themeClassAffinities = {
  'forest': [CharacterClass.ranger, CharacterClass.druid],
  'dark': [CharacterClass.warlock, CharacterClass.necromancer, CharacterClass.rogue],
  'holy': [CharacterClass.cleric, CharacterClass.paladin, CharacterClass.templar],
  'arcane': [CharacterClass.wizard, CharacterClass.sorcerer, CharacterClass.summoner, CharacterClass.artificer],
  'martial': [CharacterClass.fighter, CharacterClass.barbarian, CharacterClass.monk, CharacterClass.spellsword],
  'wild': [CharacterClass.barbarian, CharacterClass.druid, CharacterClass.ranger, CharacterClass.monk],
};

/// Placeholder weights — will be updated when new map system arrives.
const Map<int, Map<String, int>> mapThemeWeights = {
  1: {'forest': 40, 'martial': 30, 'wild': 20, 'holy': 10},
  2: {'forest': 30, 'arcane': 25, 'martial': 25, 'wild': 20},
  3: {'martial': 30, 'arcane': 25, 'wild': 25, 'holy': 20},
  4: {'arcane': 30, 'dark': 25, 'martial': 25, 'holy': 20},
  5: {'dark': 30, 'wild': 25, 'arcane': 25, 'martial': 20},
  6: {'dark': 30, 'martial': 25, 'holy': 25, 'arcane': 20},
  7: {'dark': 35, 'arcane': 25, 'holy': 25, 'martial': 15},
  8: {'dark': 40, 'holy': 25, 'arcane': 20, 'martial': 15},
};
```

Then the 34 events, each tagged with a `theme`. Theme assignments:

- **forest** (6): Enchanted Forest, Fairy Ring, Mushroom Grove, Dragon Egg, Witch's Garden, Fairy Court
- **dark** (6): The Cursed Blade, The Cursed Mirror, The Dark Portal, Ambushed!, The Haunted Tavern, Pirate Ghost Ship
- **holy** (5): Ancient Shrine, Lost Traveler, The Weary Soldier, The Oracle's Pool, The Phoenix Nest
- **arcane** (6): Mysterious Well, Magic Fountain, Wizard Duel, Crystal Cave, Fallen Meteor, Ancient Golem
- **martial** (6): Bridge Troll, Collapsed Mine, The Sleeping Giant, Merchant Caravan, The Riddle Sphinx, Goblin Market
- **wild** (5): Wandering Merchant, The Gambling Imp, Talking Crow, Abandoned Forge, Traveling Circus

Each event gets exactly one theme. Copy all 34 events from `event_screen.dart`, changing `_GameEvent` → `GameEvent` and `_EventChoice` → `EventChoice`, adding `theme: 'xxx'` to each.

- [ ] **Step 2: Add theme-weighted event selection helper**

Add to `event_data.dart`:

```dart
import 'dart:math';

/// Selects a random event themed for the given map number.
GameEvent selectEventForMap(int mapNumber, [Random? rng]) {
  rng ??= Random();
  final weights = mapThemeWeights[mapNumber.clamp(1, 8)] ?? mapThemeWeights[1]!;

  // Pick a theme based on weights
  final totalWeight = weights.values.fold(0, (sum, w) => sum + w);
  var roll = rng.nextInt(totalWeight);
  String selectedTheme = weights.keys.first;
  for (final entry in weights.entries) {
    roll -= entry.value;
    if (roll < 0) {
      selectedTheme = entry.key;
      break;
    }
  }

  // Filter events by theme, pick one randomly
  final themed = gameEvents.where((e) => e.theme == selectedTheme).toList();
  if (themed.isEmpty) {
    // Fallback: pick any event
    return gameEvents[rng.nextInt(gameEvents.length)];
  }
  return themed[rng.nextInt(themed.length)];
}
```

The event list should be named `gameEvents` (a `const List<GameEvent>`).

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/data/event_data.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/data/event_data.dart
git commit -m "feat: create event_data.dart with themed events and selection logic"
```

---

### Task 2: Add story unlock service function

**Files:**
- Create: `lib/services/story_unlock_service.dart`

- [ ] **Step 1: Create story unlock service**

This is a pure function (no widget dependency) that determines which class gets a story unlock.

```dart
import 'dart:math';
import '../data/event_data.dart';
import '../models/character.dart';
import '../models/enums.dart';

class StoryUnlockResult {
  final CharacterClass characterClass;
  final int chapter; // The chapter that was just unlocked
  final String className; // String name for profile lookup

  const StoryUnlockResult({
    required this.characterClass,
    required this.chapter,
    required this.className,
  });

  /// True if this unlock triggers an art tier upgrade (chapters 4 and 8)
  bool get isArtUpgrade => chapter == 4 || chapter == 8;
}

/// Determines which class (if any) should get a story unlock from an event.
/// Returns null if no eligible class found.
StoryUnlockResult? determineStoryUnlock({
  required String eventTheme,
  required List<Character> party,
  required Map<String, int> classStoryProgress,
  required int currentMapNumber,
  Random? rng,
}) {
  rng ??= Random();

  final affinityClasses = themeClassAffinities[eventTheme];
  if (affinityClasses == null) return null;

  // Max chapter that can be unlocked on this map
  final maxChapter = currentMapNumber >= 8 ? 8 : 7;

  // Get party classes that match the theme affinity
  final partyClasses = party.map((c) => c.characterClass).toSet();

  // Find eligible classes: in party, in affinity list, and have chapters left
  final eligible = affinityClasses.where((cls) {
    if (!partyClasses.contains(cls)) return false;
    final progress = classStoryProgress[cls.name] ?? 0;
    return progress < maxChapter;
  }).toList();

  if (eligible.isEmpty) return null;

  final chosen = eligible[rng.nextInt(eligible.length)];
  final currentProgress = classStoryProgress[chosen.name] ?? 0;
  final nextChapter = currentProgress + 1;

  return StoryUnlockResult(
    characterClass: chosen,
    chapter: nextChapter,
    className: chosen.name,
  );
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze lib/services/story_unlock_service.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/services/story_unlock_service.dart
git commit -m "feat: add story unlock service with theme-based class selection"
```

---

### Task 3: Refactor event_screen.dart to use event_data and add explore flow

**Files:**
- Modify: `lib/ui/screens/event/event_screen.dart`

This is the biggest task. The event screen gets:
1. Refactored to use `GameEvent`/`EventChoice` from `event_data.dart`
2. Theme-weighted event selection via `selectEventForMap`
3. A new state: after the initial event result, show an "explore" follow-up
4. Story unlock dialog when explore succeeds
5. Art upgrade animation for chapters 4 and 8

- [ ] **Step 1: Rewrite event_screen.dart**

Key changes to the state machine:

**States:**
- `_result == null` → showing event choices (existing)
- `_result != null && !_showExplorePrompt && !_showStoryDialog && !_showArtUpgrade` → showing result + "Continue" (existing, but Continue now goes to explore prompt)
- `_showExplorePrompt == true` → showing "Explore" / "Move on" buttons
- `_showStoryDialog == true` → showing story chapter text
- `_showArtUpgrade == true` → showing art tier upgrade animation

**New state variables:**
```dart
bool _showExplorePrompt = false;
bool _showStoryDialog = false;
bool _showArtUpgrade = false;
bool _animationShowNew = false;
StoryUnlockResult? _unlockResult;
ClassStoryChapter? _unlockedChapter;
```

**Flow:**
1. Remove `_GameEvent` and `_EventChoice` classes (now in event_data.dart)
2. Import `event_data.dart`, `story_unlock_service.dart`, `class_stories.dart`, `sprite_data.dart`
3. In `initState()`, replace random selection with `selectEventForMap(gameState.currentMapNumber)`
4. In `_choose()`, after setting `_result`, lore drop fires as before
5. The "Continue" button after result → sets `_showExplorePrompt = true`
6. "Explore" button → calls `_handleExplore()`:
   - Calls `determineStoryUnlock()` with event theme, party, progress, map number
   - If result is null: show flavor text dialog ("You search but find nothing of note.")
   - If result found: call `recordClassStoryProgress(className, chapter)`
   - Look up the `ClassStoryChapter` from `classStories`
   - Set `_showExplorePrompt = false`, `_showStoryDialog = true`
7. "Move on" button → `context.go('/map')`
8. Story dialog dismiss → if `_unlockResult!.isArtUpgrade`, set `_showArtUpgrade = true`, else `context.go('/map')`
9. Art upgrade animation dismiss → `context.go('/map')`

**Updated `_handleKeyPress` method:**

```dart
void _handleKeyPress(KeyEvent event) {
  if (event is! KeyDownEvent) return;
  final key = event.logicalKey;

  if (_showArtUpgrade && _animationShowNew) {
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
      context.go('/map');
    }
  } else if (_showStoryDialog) {
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
      _dismissStoryDialog();
    }
  } else if (_showExplorePrompt) {
    if (key == LogicalKeyboardKey.keyE) {
      _handleExplore();
    } else if (key == LogicalKeyboardKey.keyM) {
      context.go('/map');
    }
  } else if (_result != null) {
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyC) {
      setState(() => _showExplorePrompt = true);
    }
  }
}
```

**Art upgrade animation widget:**

```dart
Widget _buildArtUpgrade(ThemeData theme) {
  final cls = _unlockResult!.characterClass;
  final chapter = _unlockResult!.chapter;
  // Chapter 4: low → mid, Chapter 8: mid → high
  final oldTier = chapter == 4 ? 'low' : 'mid';
  final newTier = chapter == 4 ? 'mid' : 'high';
  final oldPath = 'assets/new_art/${cls.name}_${oldTier}_128x128.png';
  final newPath = 'assets/new_art/${cls.name}_${newTier}_128x128.png';

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Art Upgraded!', style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.amber, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_unlockResult!.className[0].toUpperCase() + _unlockResult!.className.substring(1),
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Image.asset(
            _animationShowNew ? newPath : oldPath,
            key: ValueKey(_animationShowNew),
            width: 128, height: 128,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 128),
          ),
        ),
        const SizedBox(height: 24),
        if (_animationShowNew)
          FilledButton(
            onPressed: () => context.go('/map'),
            child: const Text('Continue'),
          ),
      ],
    ),
  );
}
```

Add a `bool _animationShowNew = false;` state variable. When entering the art upgrade state, use `Future.delayed(const Duration(milliseconds: 600))` to flip `_animationShowNew = true` and trigger the `AnimatedSwitcher`.

**Story dialog widget:**

```dart
Widget _buildStoryDialog(ThemeData theme) {
  final chapter = _unlockedChapter!;
  final className = _unlockResult!.className;
  final displayName = className[0].toUpperCase() + className.substring(1);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_stories, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('$displayName — Chapter ${chapter.chapter}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(chapter.title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(chapter.content,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _dismissStoryDialog,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _dismissStoryDialog() {
  if (_unlockResult!.isArtUpgrade) {
    setState(() {
      _showStoryDialog = false;
      _showArtUpgrade = true;
      _animationShowNew = false;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _animationShowNew = true);
    });
  } else {
    context.go('/map');
  }
}
```

**Explore prompt widget:**

```dart
Widget _buildExplorePrompt(ThemeData theme) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You notice something interesting nearby...',
            style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: 300,
            child: FilledButton(
              onPressed: _handleExplore,
              child: const Text('Explore'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            child: OutlinedButton(
              onPressed: () => context.go('/map'),
              child: const Text('Move on'),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**`_handleExplore` method:**

```dart
void _handleExplore() {
  final gameState = ref.read(gameStateProvider);
  final profile = ref.read(playerProfileProvider);
  if (gameState == null || profile == null) {
    context.go('/map');
    return;
  }

  final result = determineStoryUnlock(
    eventTheme: _event.theme,
    party: gameState.party,
    classStoryProgress: profile.classStoryProgress,
    currentMapNumber: gameState.currentMapNumber,
  );

  if (result == null) {
    // No eligible class — show flavor text inline (same pattern as story dialog)
    setState(() {
      _showExplorePrompt = false;
      _showStoryDialog = false;
      _unlockResult = null;
      _unlockedChapter = null;
    });
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          content: const Text('You search the area but find nothing of note.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (mounted) context.go('/map');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
    return;
  }

  // Unlock the chapter
  ref.read(playerProfileProvider.notifier).recordClassStoryProgress(result.className, result.chapter);

  // Find the story content (with safety check)
  final chapter = classStories.cast<ClassStoryChapter?>().firstWhere(
    (s) => s!.characterClass == result.characterClass && s.chapter == result.chapter,
    orElse: () => null,
  );

  if (chapter == null) {
    // Story data missing — treat as "nothing found"
    if (mounted) context.go('/map');
    return;
  }

  setState(() {
    _unlockResult = result;
    _unlockedChapter = chapter;
    _showExplorePrompt = false;
    _showStoryDialog = true;
  });
}
```

**Updated build method body logic:**

```dart
if (_showArtUpgrade) {
  return _buildArtUpgrade(theme);
} else if (_showStoryDialog) {
  return _buildStoryDialog(theme);
} else if (_showExplorePrompt) {
  return _buildExplorePrompt(theme);
} else {
  // Existing event display logic (choices or result)
  // Change "Continue" button to go to explore prompt instead of map:
  // onPressed: () => setState(() => _showExplorePrompt = true),
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze lib/ui/screens/event/`
Expected: No errors (or only pre-existing issues from other files)

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/event/event_screen.dart
git commit -m "feat: add explore follow-up with story unlock and art upgrade animation"
```

---

### Task 4: Final verification

**Files:** None (verification only)

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 2: Run flutter analyze on full project**

Run: `flutter analyze lib/`
Expected: Only pre-existing issues (combat_service curly braces, combat_screen unused vars)

- [ ] **Step 3: Visual verification**

Run the app and test:
- Start a run → reach an event node
- Event shows normally with choices
- After picking a choice, result shows, then "Continue" goes to explore prompt
- "Move on" returns to map
- "Explore" either shows flavor text (no eligible class) or unlocks a story chapter
- Story dialog shows class name, chapter number, title, and text
- If chapter 4 or 8: art upgrade animation plays after story dialog
- Check Guide screen to confirm the unlocked chapter persists

---

### Known Limitations

- **Theme weights are placeholder** — will be tuned when the 30-map system lands
- **Theme assignments to existing events are approximate** — can be adjusted later
- **No gameplay tradeoff for explore vs move-on yet** — explore is free, tune later
- **Art upgrade animation is simple** — `AnimatedSwitcher` with fade/scale, can be polished later
