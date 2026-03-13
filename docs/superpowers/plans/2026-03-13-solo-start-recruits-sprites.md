# Solo Start, Recruit Nodes, Sprite Upgrades & Idle Animations — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change the game to start with 1 character, add tavern nodes for recruiting up to 4 party members, upgrade all sprites to 64x64 pixel art, and add idle bob/breathe animations in combat.

**Architecture:** Solo start simplifies party select to single-pick. New `NodeType.recruit` drives tavern nodes on the map with a dedicated recruit screen. `IdleAnimatedSprite` widget wraps all combat sprites with code-based animations. Python PIL script regenerates all 48 sprites at 64x64.

**Tech Stack:** Flutter/Dart, Riverpod, GoRouter, Python PIL (sprite generation)

**Spec:** `docs/superpowers/specs/2026-03-13-solo-start-recruits-sprites-design.md`

---

## Chunk 1: Solo Start + Recruit System (Game Logic)

### Task 1: Add `NodeType.recruit` to enums and update scouting

**Files:**
- Modify: `lib/models/enums.dart:20`
- Modify: `lib/services/scouting_service.dart:32-50,52-62`

- [ ] **Step 1: Add `recruit` at the end of the `NodeType` enum**

In `lib/models/enums.dart`, change line 20 from:
```dart
enum NodeType { combat, shop, rest, treasure, boss, event, start }
```
to:
```dart
enum NodeType { combat, shop, rest, treasure, boss, event, start, recruit }
```

- [ ] **Step 2: Add recruit icon and label to `ScoutingService`**

In `lib/services/scouting_service.dart`, add the recruit case to `nodeTypeIcon` (after `case NodeType.start:`):
```dart
      case NodeType.recruit:
        return '🍺';
```

And add to `nodeTypeLabel`:
```dart
      case NodeType.recruit: return 'Tavern';
```

- [ ] **Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/models/enums.dart lib/services/scouting_service.dart`
Expected: 0 issues (there may be warnings in other files about missing switch cases — we'll fix those next)

- [ ] **Step 4: Fix all switch statements that need the new `recruit` case**

Search the codebase for `switch` on `NodeType` or `node.type`. Add `case NodeType.recruit:` wherever missing. Key locations:
- `lib/ui/screens/map/map_screen.dart` `_moveToNode()` — add `case NodeType.recruit: context.go('/recruit');`

- [ ] **Step 5: Run full `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues

- [ ] **Step 6: Commit**

```bash
git add lib/models/enums.dart lib/services/scouting_service.dart lib/ui/screens/map/map_screen.dart
git commit -m "feat: add NodeType.recruit enum and scouting support for tavern nodes"
```

---

### Task 2: Update map generation to include recruit nodes

**Files:**
- Modify: `lib/models/map_node.dart:7` — change `type` from `final` to mutable
- Modify: `lib/services/map_service.dart:165-172`

- [ ] **Step 1: Make `MapNode.type` mutable**

In `lib/models/map_node.dart`, change line 7 from:
```dart
  final NodeType type;
```
to:
```dart
  NodeType type;
```

This is required so `generateMap()` can convert nodes to recruit type when guaranteeing early placement.

- [ ] **Step 2: Update `_randomNodeType` distribution**

In `lib/services/map_service.dart`, replace `_randomNodeType`:
```dart
  static NodeType _randomNodeType(int mapNumber) {
    final roll = _random.nextInt(100);
    if (roll < 40) return NodeType.combat;
    if (roll < 52) return NodeType.treasure;
    if (roll < 64) return NodeType.event;
    if (roll < 74) return NodeType.rest;
    if (roll < 85) return NodeType.shop;
    return NodeType.recruit;
  }
```

- [ ] **Step 3: Guarantee at least 1 recruit node in columns 1-2**

In `generateMap()`, after all nodes are generated (after the column 1-6 loop, before the column 7 boss node), add:
```dart
    // Guarantee at least 1 recruit node in columns 1-2
    final hasRecruit = nodes.any((n) => n.column >= 1 && n.column <= 2 && n.type == NodeType.recruit);
    if (!hasRecruit) {
      // Find a non-combat, non-start node in columns 1-2 to convert
      final candidates = nodes.where((n) =>
          n.column >= 1 && n.column <= 2 &&
          n.type != NodeType.combat && n.type != NodeType.start).toList();
      if (candidates.isNotEmpty) {
        candidates[_random.nextInt(candidates.length)].type = NodeType.recruit;
      } else {
        // If all nodes are combat, convert one anyway
        final combatNodes = nodes.where((n) => n.column >= 1 && n.column <= 2).toList();
        if (combatNodes.isNotEmpty) {
          combatNodes[_random.nextInt(combatNodes.length)].type = NodeType.recruit;
        }
      }
    }
```

- [ ] **Step 4: Run `flutter analyze`**

Run: `flutter analyze lib/services/map_service.dart lib/models/map_node.dart`
Expected: 0 issues

- [ ] **Step 5: Commit**

```bash
git add lib/services/map_service.dart lib/models/map_node.dart
git commit -m "feat: add recruit nodes to map generation with guaranteed early placement"
```

---

### Task 3: Update starting gold and party select for solo start

**Files:**
- Modify: `lib/models/game_state.dart:18`
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`

- [ ] **Step 1: Change default starting gold to 50**

In `lib/models/game_state.dart`, change line 18:
```dart
    this.gold = 50,
```

- [ ] **Step 2: Change party select to single-select**

In `lib/ui/screens/party_select/party_select_screen.dart`:

a) Change `_toggleClass` to single-select (replace lines 26-34):
```dart
  void _toggleClass(CharacterClass cls) {
    setState(() {
      if (_selectedClasses.contains(cls)) {
        _selectedClasses.remove(cls);
      } else {
        _selectedClasses.clear();
        _selectedClasses.add(cls);
      }
    });
  }
```

b) Change `_startGame` check from 4 to 1 (line 37):
```dart
    if (_selectedClasses.length != 1) return;
```

c) Update the AppBar title (line 52):
```dart
      appBar: AppBar(title: const Text('Choose Your Hero')),
```

d) Update the counter text (line 76):
```dart
              'Select your starting class',
```

e) Update the button check (line 127):
```dart
                onPressed: _selectedClasses.length == 1 ? _startGame : null,
```

- [ ] **Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/models/game_state.dart lib/ui/screens/party_select/party_select_screen.dart`
Expected: 0 issues

- [ ] **Step 4: Commit**

```bash
git add lib/models/game_state.dart lib/ui/screens/party_select/party_select_screen.dart
git commit -m "feat: solo start - pick 1 class, start with 50 gold"
```

---

### Task 4: Add recruit cost data

**Files:**
- Create: `lib/data/recruit_data.dart`

- [ ] **Step 1: Create recruit cost tier data**

Create `lib/data/recruit_data.dart`:
```dart
import '../models/enums.dart';

/// Base gold cost per class tier for recruiting at taverns.
const Map<CharacterClass, int> recruitBaseCost = {
  // Starter tier — 40g base
  CharacterClass.fighter: 40,
  CharacterClass.rogue: 40,
  CharacterClass.cleric: 40,
  CharacterClass.wizard: 40,
  // Mid tier — 60g base
  CharacterClass.paladin: 60,
  CharacterClass.ranger: 60,
  CharacterClass.monk: 60,
  CharacterClass.barbarian: 60,
  CharacterClass.druid: 60,
  CharacterClass.spellsword: 60,
  // Advanced tier — 80g base
  CharacterClass.warlock: 80,
  CharacterClass.summoner: 80,
  CharacterClass.sorcerer: 80,
  CharacterClass.necromancer: 80,
  CharacterClass.artificer: 80,
  CharacterClass.templar: 80,
};

/// Total recruit cost = base + mapNumber * 20
int recruitCost(CharacterClass cls, int mapNumber) {
  return (recruitBaseCost[cls] ?? 60) + mapNumber * 20;
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/data/recruit_data.dart`
Expected: 0 issues

- [ ] **Step 3: Commit**

```bash
git add lib/data/recruit_data.dart
git commit -m "feat: add recruit cost tier data for tavern hiring"
```

---

### Task 5: Add `recruitCharacter` to the game state provider

**Files:**
- Modify: `lib/providers/game_state_provider.dart`

- [ ] **Step 1: Add the `recruitCharacter` method**

Add this method to `GameStateNotifier` (after `usePotion`):
```dart
  Future<void> recruitCharacter(CharacterClass cls, int cost) async {
    if (state == null) return;
    if (state!.gold < cost) return;
    if (state!.party.length >= 4) return;

    final classDef = classDefinitions[cls]!;
    final name = NameGenerator.generate(
        cls.name[0].toUpperCase() + cls.name.substring(1));

    // Gather abilities for level 1
    final startingAbilities = classDef.abilities
        .where((a) => a.unlockedAtLevel <= 1)
        .map((a) => Ability(
              name: a.name,
              description: a.description,
              damage: a.damage,
              refreshChance: a.refreshChance,
              targetType: a.targetType,
              unlockedAtLevel: a.unlockedAtLevel,
              isBasicAttack: a.isBasicAttack,
            ))
        .toList();

    final recruit = Character(
      id: _uuid.v4(),
      name: name,
      characterClass: cls,
      currentHp: classDef.baseStats.hp,
      maxHp: classDef.baseStats.hp,
      attack: classDef.baseStats.attack,
      defense: classDef.baseStats.defense,
      speed: classDef.baseStats.speed,
      magic: classDef.baseStats.magic,
      abilities: startingAbilities,
    );

    // Level up to party average level
    final avgLevel = state!.party.fold<int>(0, (sum, c) => sum + c.level) ~/
        state!.party.length;
    for (int i = 1; i < avgLevel; i++) {
      ProgressionService.levelUp(recruit);
    }
    recruit.currentHp = recruit.totalMaxHp; // Full health after leveling

    state!.gold -= cost;
    state!.party.add(recruit);
    state = _refreshState();
    await _autoSave();
  }
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/providers/game_state_provider.dart`
Expected: 0 issues

- [ ] **Step 3: Commit**

```bash
git add lib/providers/game_state_provider.dart
git commit -m "feat: add recruitCharacter method to game state provider"
```

---

### Task 6: Create the recruit screen

**Files:**
- Create: `lib/ui/screens/recruit/recruit_screen.dart`

- [ ] **Step 1: Create the recruit screen**

Create `lib/ui/screens/recruit/recruit_screen.dart`:
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/class_data.dart';
import '../../../data/recruit_data.dart';
import '../../../data/sprite_data.dart';
import '../../../models/enums.dart';
import '../../../providers/game_state_provider.dart';

class RecruitScreen extends ConsumerStatefulWidget {
  const RecruitScreen({super.key});

  @override
  ConsumerState<RecruitScreen> createState() => _RecruitScreenState();
}

class _RecruitScreenState extends ConsumerState<RecruitScreen> {
  late List<CharacterClass> _availableRecruits;

  @override
  void initState() {
    super.initState();
    _generateRecruits();
  }

  void _generateRecruits() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) {
      _availableRecruits = [];
      return;
    }

    // Get unlocked classes, excluding those already in the party
    final partyClasses = gameState.party.map((c) => c.characterClass).toSet();
    final pool = CharacterClass.values.where((c) {
      final def = classDefinitions[c];
      return def != null && def.unlockedByDefault && !partyClasses.contains(c);
    }).toList();

    // Pick 2-4 random classes from the pool
    final rng = Random();
    pool.shuffle(rng);
    final count = min(pool.length, 2 + rng.nextInt(3)); // 2-4
    _availableRecruits = pool.take(count).toList();
  }

  Future<void> _hire(CharacterClass cls) async {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    final cost = recruitCost(cls, gameState.currentMapNumber);
    await ref.read(gameStateProvider.notifier).recruitCharacter(cls, cost);

    if (mounted) {
      setState(() {
        _availableRecruits.remove(cls);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final partyFull = gameState.party.length >= 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Tavern')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Party: ${gameState.party.length}/4',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${gameState.gold}g',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (partyFull) ...[
              const Spacer(),
              Center(
                child: Text(
                  'Your party is full!',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const Spacer(),
            ] else ...[
              Text(
                'Heroes for hire:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableRecruits.length,
                  itemBuilder: (context, index) {
                    final cls = _availableRecruits[index];
                    final def = classDefinitions[cls]!;
                    final cost = recruitCost(cls, gameState.currentMapNumber);
                    final canAfford = gameState.gold >= cost;
                    final alreadyInParty = gameState.party
                        .any((c) => c.characterClass == cls);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Class sprite
                            Image.asset(
                              classSpritePath(cls),
                              width: 48,
                              height: 48,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person, size: 48),
                            ),
                            const SizedBox(width: 12),
                            // Class info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    def.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'HP:${def.baseStats.hp} ATK:${def.baseStats.attack} '
                                    'DEF:${def.baseStats.defense} SPD:${def.baseStats.speed} '
                                    'MAG:${def.baseStats.magic}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Hire button
                            FilledButton(
                              onPressed:
                                  canAfford && !alreadyInParty ? () => _hire(cls) : null,
                              child: Text('${cost}g'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/map'),
                child: const Text('Leave Tavern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/ui/screens/recruit/recruit_screen.dart`
Expected: 0 issues

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/recruit/recruit_screen.dart
git commit -m "feat: create tavern recruit screen"
```

---

### Task 7: Add recruit route and map navigation

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/ui/screens/map/map_screen.dart:163-178`

- [ ] **Step 1: Add route**

In `lib/core/router/app_router.dart`, add import:
```dart
import '../../ui/screens/recruit/recruit_screen.dart';
```

Add route (after the `/event` route):
```dart
    GoRoute(path: '/recruit', builder: (context, state) => const RecruitScreen()),
```

- [ ] **Step 2: Verify map_screen already handles `NodeType.recruit`**

From Task 1 Step 4, `map_screen.dart` should already have the recruit case in `_moveToNode()`. Verify:
```dart
      case NodeType.recruit:
        context.go('/recruit');
```

- [ ] **Step 3: Run `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat: add /recruit route for tavern screen"
```

---

## Chunk 2: Idle Animations

### Task 8: Create `IdleAnimatedSprite` widget

**Files:**
- Create: `lib/ui/widgets/idle_animated_sprite.dart`

- [ ] **Step 1: Create the widget**

Create `lib/ui/widgets/idle_animated_sprite.dart`:
```dart
import 'dart:math';
import 'package:flutter/material.dart';

class IdleAnimatedSprite extends StatefulWidget {
  final String imagePath;
  final double size;
  final double phaseOffset;
  final bool animate;

  const IdleAnimatedSprite({
    super.key,
    required this.imagePath,
    required this.size,
    this.phaseOffset = 0.0,
    this.animate = true,
  });

  @override
  State<IdleAnimatedSprite> createState() => _IdleAnimatedSpriteState();
}

class _IdleAnimatedSpriteState extends State<IdleAnimatedSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(IdleAnimatedSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildImage();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * pi + widget.phaseOffset;
        // Vertical bob: 2.5px amplitude, 1.5s period (half of 3s controller)
        final bobY = sin(t * 2) * 2.5;
        // Breathing scale: 1.0 to 1.02, 2s period (2/3 of 3s controller)
        final scale = 1.0 + sin(t * 1.5) * 0.02;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      widget.imagePath,
      width: widget.size,
      height: widget.size,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => Container(
        width: widget.size,
        height: widget.size,
        color: Colors.grey[800],
        child: Icon(Icons.person, size: widget.size * 0.5),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze lib/ui/widgets/idle_animated_sprite.dart`
Expected: 0 issues

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/idle_animated_sprite.dart
git commit -m "feat: create IdleAnimatedSprite widget with bob and breathe animations"
```

---

### Task 9: Replace combat screen sprites with `IdleAnimatedSprite`

**Files:**
- Modify: `lib/ui/screens/combat/combat_screen.dart:636-727,730-817`

- [ ] **Step 1: Add import**

Add to top of `combat_screen.dart`:
```dart
import 'dart:math' show Random;
import '../../widgets/idle_animated_sprite.dart';
```

(Note: `dart:math` may already be imported — check first and only add `idle_animated_sprite.dart` if so.)

- [ ] **Step 2: Replace ally sprite `Image.asset` with `IdleAnimatedSprite`**

In `_buildAllyWidget`, replace the `Image.asset` block (lines 676-687) with:
```dart
              child: IdleAnimatedSprite(
                imagePath: spritePath,
                size: spriteSize,
                phaseOffset: ally.id.hashCode.toDouble(),
                animate: ally.isAlive,
              ),
```

The surrounding `Opacity` wrapper stays. The full block becomes:
```dart
          Flexible(
            child: Opacity(
              opacity: ally.isAlive ? 1.0 : 0.3,
              child: IdleAnimatedSprite(
                imagePath: spritePath,
                size: spriteSize,
                phaseOffset: ally.id.hashCode.toDouble(),
                animate: ally.isAlive,
              ),
            ),
          ),
```

- [ ] **Step 3: Replace enemy sprite `Image.asset` with `IdleAnimatedSprite`**

In `_buildEnemyWidget`, replace the `Image.asset` block (lines 766-777) with:
```dart
              child: IdleAnimatedSprite(
                imagePath: spritePath,
                size: spriteSize,
                phaseOffset: enemy.id.hashCode.toDouble(),
                animate: enemy.isAlive,
              ),
```

The full block becomes:
```dart
          Flexible(
            child: Opacity(
              opacity: enemy.isAlive ? 1.0 : 0.3,
              child: IdleAnimatedSprite(
                imagePath: spritePath,
                size: spriteSize,
                phaseOffset: enemy.id.hashCode.toDouble(),
                animate: enemy.isAlive,
              ),
            ),
          ),
```

- [ ] **Step 4: Run `flutter analyze`**

Run: `flutter analyze lib/ui/screens/combat/combat_screen.dart`
Expected: 0 issues

- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/combat/combat_screen.dart
git commit -m "feat: add idle bob/breathe animations to combat sprites"
```

---

## Chunk 3: Sprite Upgrades (Python Generation)

### Task 10: Generate 64x64 character class sprites

**Files:**
- Create: `/tmp/generate_sprites_64.py`
- Output to: `assets/sprites/` (16 character PNGs, replacing existing)

- [ ] **Step 1: Write the Python PIL script for all 16 character sprites**

Create `/tmp/generate_sprites_64.py`. The script should:
- Use the same retro 16-bit palette as `generate_ability_icons_v2.py`
- Generate 64x64 pixel art for each character class
- Fill the full canvas (no wasted transparent space)
- Each class has distinct silhouette and color scheme per the spec:
  - **Fighter**: sword + shield, steel armor, blue/silver
  - **Rogue**: hooded figure, dual daggers, dark green/black
  - **Cleric**: robes, holy symbol on chest, white/gold
  - **Wizard**: pointed hat, staff, purple/blue robes
  - **Paladin**: heavy plate armor, glowing sword, gold/white
  - **Ranger**: bow, green cloak/hood, brown/forest green
  - **Warlock**: dark robes, glowing purple eyes, black/purple
  - **Summoner**: flowing robes, orb floating above hand, teal/cyan
  - **Spellsword**: light armor with runes, sword + magic aura, red/blue
  - **Druid**: leaf crown, wooden staff, green/brown
  - **Monk**: simple tunic, wrapped fists, orange/tan
  - **Barbarian**: bare chest, large axe, red/brown
  - **Sorcerer**: wild hair, crackling energy, magenta/gold
  - **Necromancer**: skull staff, tattered black robes, black/sickly green
  - **Artificer**: goggles, wrench, mechanical arm, brass/brown
  - **Templar**: crusader helm, shield with cross, silver/red

Output directory: project root `assets/sprites/` (provided as CLI arg or hardcoded)

Pattern: one function per class `generate_fighter(img)`, called in a loop that saves to `{classname}.png`.

- [ ] **Step 2: Set up Python venv and run the script**

```bash
source /tmp/pixelart_venv/bin/activate
python /tmp/generate_sprites_64.py
```

Expected: 16 PNG files written to `assets/sprites/` (fighter.png, rogue.png, etc.)

- [ ] **Step 3: Verify sprites exist and are 64x64**

```bash
python -c "from PIL import Image; img = Image.open('assets/sprites/fighter.png'); print(img.size)"
```

Expected: `(64, 64)`

- [ ] **Step 4: Commit**

```bash
git add assets/sprites/fighter.png assets/sprites/rogue.png assets/sprites/cleric.png assets/sprites/wizard.png assets/sprites/paladin.png assets/sprites/ranger.png assets/sprites/warlock.png assets/sprites/summoner.png assets/sprites/spellsword.png assets/sprites/druid.png assets/sprites/monk.png assets/sprites/barbarian.png assets/sprites/sorcerer.png assets/sprites/necromancer.png assets/sprites/artificer.png assets/sprites/templar.png
git commit -m "art: regenerate all 16 character class sprites at 64x64 pixel art"
```

---

### Task 11: Generate 64x64 enemy sprites

**Files:**
- Modify: `/tmp/generate_sprites_64.py` (add enemy generators)
- Output to: `assets/sprites/enemies/` (24 regular + 8 boss PNGs)

- [ ] **Step 1: Add enemy sprite generators to the script**

Add generator functions for all 24 regular enemies:
wolf, skeleton, orc_grunt, goblin, bandit, dark_mage, harpy, lich_acolyte, minotaur, ogre, chimera, giant_spider, troll, wyvern, elder_dragon, ancient_wyrm, golem, shadow_lord, titan, death_knight, vampire, void_walker, wraith, archdemon

And 8 bosses:
boss_goblin_king, boss_bone_lord, boss_shadow_witch, boss_mountain_giant, boss_lich_king, boss_demon_prince, boss_dragon_emperor, boss_the_dark_one

Enemy design guidelines:
- Distinct silhouettes matching their names (wolf=quadruped, skeleton=bones, dragon=wings+horns)
- Color-code by threat: greens/browns for early, reds/purples for late
- Bosses: more imposing, larger features within the 64x64 canvas

- [ ] **Step 2: Run the script for enemies**

```bash
source /tmp/pixelart_venv/bin/activate
python /tmp/generate_sprites_64.py
```

Expected: 32 PNG files written to `assets/sprites/enemies/`

- [ ] **Step 3: Verify enemy sprites exist and are 64x64**

```bash
python -c "from PIL import Image; img = Image.open('assets/sprites/enemies/wolf.png'); print(img.size)"
```

Expected: `(64, 64)`

- [ ] **Step 4: Commit**

```bash
git add assets/sprites/enemies/
git commit -m "art: regenerate all 32 enemy sprites at 64x64 pixel art"
```

---

### Task 12: Final verification

- [ ] **Step 1: Run full `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues

- [ ] **Step 2: Verify all features work together**

Check the following manually on the running app:
- Party select shows single-select with all unlocked classes
- Game starts with 1 character and 50 gold
- Map has at least 1 tavern node (tankard icon) in columns 1-2
- Tavern screen shows 2-4 recruit options with costs
- Hiring a recruit adds them to the party at the right level
- Can't hire past 4 members
- Combat sprites have idle bob/breathe animation
- KO'd characters stop animating
- New 64x64 sprites render cleanly in combat

- [ ] **Step 3: Commit any remaining fixes**

```bash
git add -A
git commit -m "fix: final adjustments for solo start and recruit system"
```
