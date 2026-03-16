# Help System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a contextual help system where tapping a `?` button enters help mode, then tapping any game element shows a help dialog with stats, ability descriptions, or contextual info.

**Architecture:** A Riverpod `StateProvider<bool>` tracks help mode. A reusable `HelpButton` widget goes in every screen's AppBar. Each screen wraps its tappable elements to check help mode — if active, show a help dialog instead of the normal action, then deactivate help mode. Reusable dialog builder functions handle character stats, ability details, enemy info, items, and node types.

**Tech Stack:** Flutter, Riverpod, existing Material 3 theming

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `lib/providers/help_mode_provider.dart` | Single `StateProvider<bool>` for help mode toggle |
| `lib/ui/widgets/help_button.dart` | AppBar icon button that toggles help mode with visual feedback |
| `lib/ui/widgets/help_dialogs.dart` | All `showHelpDialog*()` functions — character stats, ability details, enemy info, item stats, node types |
| `lib/ui/widgets/character_detail_card.dart` | Reusable widget showing character name, class, level, all stats (with equipment bonuses), all 6 equipment slots with item names/stats, and ability list. Used in help dialogs, shop screen party panel, and party select |

### Modified Files
| File | Changes |
|------|---------|
| `lib/ui/screens/combat/combat_screen.dart` | Add HelpButton to top bar area; wrap ally/enemy/ability taps with help mode check |
| `lib/ui/screens/shop/shop_screen.dart` | Add HelpButton to AppBar; add party panel below shop items showing all characters with gear; wrap items with help mode check |
| `lib/ui/screens/map/map_screen.dart` | Add HelpButton to AppBar; wrap node taps with help mode check to show node type info |
| `lib/ui/screens/party_select/party_select_screen.dart` | Add HelpButton to AppBar; expand class cards to show equipment slots with item stats; wrap cards with help mode check |
| `lib/ui/screens/treasure/treasure_screen.dart` | Add HelpButton to AppBar; wrap loot/party taps with help mode |
| `lib/ui/screens/rest/rest_screen.dart` | Add HelpButton to AppBar |
| `lib/ui/screens/event/event_screen.dart` | Add HelpButton to AppBar |
| `lib/ui/screens/recruit/recruit_screen.dart` | Add HelpButton to AppBar; wrap character taps with help mode |

---

## Chunk 1: Core Help Infrastructure

### Task 1: Help Mode Provider

**Files:**
- Create: `lib/providers/help_mode_provider.dart`

- [ ] **Step 1: Create the provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helpModeProvider = StateProvider<bool>((ref) => false);
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/providers/help_mode_provider.dart`
Expected: No issues found

---

### Task 2: Help Button Widget

**Files:**
- Create: `lib/ui/widgets/help_button.dart`

- [ ] **Step 1: Create the help button widget**

This is an AppBar action button. When help mode is active, it shows a filled `?` icon with primary color background. When tapped, it toggles `helpModeProvider`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/help_mode_provider.dart';

class HelpButton extends ConsumerWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHelpMode = ref.watch(helpModeProvider);
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(
        isHelpMode ? Icons.help : Icons.help_outline,
        color: isHelpMode ? theme.colorScheme.primary : null,
      ),
      tooltip: isHelpMode ? 'Exit Help Mode' : 'Help Mode',
      onPressed: () {
        ref.read(helpModeProvider.notifier).state = !isHelpMode;
      },
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/ui/widgets/help_button.dart`
Expected: No issues found

---

### Task 3: Character Detail Card Widget

**Files:**
- Create: `lib/ui/widgets/character_detail_card.dart`

- [ ] **Step 1: Create the character detail card**

A reusable widget that shows a character's full info: name, class, level, stats (base + equipment bonuses), all 6 equipment slots, and abilities. Used in help dialogs, shop screen party panel, and party select screen.

```dart
import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/enums.dart';

class CharacterDetailCard extends StatelessWidget {
  final Character character;
  final bool showAbilities;
  final bool compact;

  const CharacterDetailCard({
    super.key,
    required this.character,
    this.showAbilities = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final char = character;
    final className = char.characterClass.name[0].toUpperCase() +
        char.characterClass.name.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: Name, Class, Level
        Text(
          '${char.name} - $className (Lv ${char.level})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Stats
        Text(
          'HP: ${char.currentHp}/${char.totalMaxHp}  '
          'ATK: ${char.totalAttack}  DEF: ${char.totalDefense}  '
          'SPD: ${char.totalSpeed}  MAG: ${char.totalMagic}',
          style: theme.textTheme.bodySmall,
        ),
        if (char.shieldHp > 0)
          Text(
            'Shield: ${char.shieldHp}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.cyan,
            ),
          ),
        const Divider(),

        // Equipment Slots
        Text('Equipment', style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 4),
        ...EquipmentSlot.values.map((slot) {
          final item = char.equipment[slot];
          final slotName = slot.name[0].toUpperCase() + slot.name.substring(1);
          if (item != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '$slotName: ${item.name} (${_itemBonuses(item)})',
                style: theme.textTheme.bodySmall,
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '$slotName: —',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            );
          }
        }),

        // Abilities
        if (showAbilities && !compact) ...[
          const Divider(),
          Text('Abilities', style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 4),
          ...char.abilities.map((ability) {
            final dmgLabel = ability.damage < 0
                ? 'Heal ${-ability.damage}'
                : ability.damage > 0
                    ? 'Dmg ${ability.damage}'
                    : '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ability.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dmgLabel.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          dmgLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ability.damage < 0
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                      if (ability.refreshChance > 0 &&
                          !ability.isBasicAttack) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${ability.refreshChance}% refresh',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    ability.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  String _itemBonuses(dynamic item) {
    final parts = <String>[];
    if (item.attackBonus != 0) parts.add('${item.attackBonus > 0 ? "+" : ""}${item.attackBonus} ATK');
    if (item.defenseBonus != 0) parts.add('${item.defenseBonus > 0 ? "+" : ""}${item.defenseBonus} DEF');
    if (item.hpBonus != 0) parts.add('${item.hpBonus > 0 ? "+" : ""}${item.hpBonus} HP');
    if (item.speedBonus != 0) parts.add('${item.speedBonus > 0 ? "+" : ""}${item.speedBonus} SPD');
    if (item.magicBonus != 0) parts.add('${item.magicBonus > 0 ? "+" : ""}${item.magicBonus} MAG');
    return parts.isEmpty ? 'no bonuses' : parts.join(', ');
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/ui/widgets/character_detail_card.dart`
Expected: No issues found

---

### Task 4: Help Dialogs

**Files:**
- Create: `lib/ui/widgets/help_dialogs.dart`

- [ ] **Step 1: Create all help dialog functions**

These are top-level functions that show contextual help dialogs. Each takes a `BuildContext` and the relevant data object.

```dart
import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/enemy.dart';
import '../../models/ability.dart';
import '../../models/enums.dart';
import 'character_detail_card.dart';

/// Show help dialog for a party character (stats, gear, abilities).
void showCharacterHelp(BuildContext context, Character character) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(character.name),
      content: SingleChildScrollView(
        child: CharacterDetailCard(character: character),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Show help dialog for an enemy (stats, debuffs, abilities).
void showEnemyHelp(BuildContext context, Enemy enemy) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(enemy.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HP: ${enemy.currentHp}/${enemy.maxHp}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'ATK: ${enemy.effectiveAttack.round()}  '
              'DEF: ${enemy.effectiveDefense.round()}  '
              'SPD: ${enemy.speed}  MAG: ${enemy.magic}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'XP: ${enemy.xpReward}  Gold: ${enemy.goldReward}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber,
              ),
            ),
            if (enemy.isVulnerable || enemy.isStunned ||
                enemy.attackMultiplier < 1.0 ||
                enemy.defenseMultiplier < 1.0) ...[
              const Divider(),
              Text('Status Effects',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              if (enemy.isVulnerable)
                Text('Vulnerable (takes extra damage)',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange)),
              if (enemy.isStunned)
                Text('Stunned (skips next turn)',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.yellow)),
              if (enemy.attackMultiplier < 1.0)
                Text('Attack reduced to ${(enemy.attackMultiplier * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red)),
              if (enemy.defenseMultiplier < 1.0)
                Text('Defense reduced to ${(enemy.defenseMultiplier * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red)),
            ],
            if (enemy.abilities.isNotEmpty) ...[
              const Divider(),
              Text('Abilities',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              ...enemy.abilities.map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${a.name}: ${a.description}',
                      style: theme.textTheme.bodySmall,
                    ),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Show help dialog for an ability (full details).
void showAbilityHelp(BuildContext context, Ability ability) {
  final theme = Theme.of(context);
  final effects = <String>[];
  if (ability.damage > 0) effects.add('Damage: ${ability.damage}');
  if (ability.damage < 0) effects.add('Healing: ${-ability.damage}');
  if (ability.healPercentMaxHp > 0)
    effects.add('Heals ${ability.healPercentMaxHp}% of max HP');
  if (ability.lifeDrain) effects.add('Drains 50% of damage as healing');
  if (ability.appliesVulnerability) effects.add('Makes target vulnerable');
  if (ability.stunChance > 0) effects.add('${ability.stunChance}% stun chance');
  if (ability.attackBuffPercent > 0)
    effects.add('+${ability.attackBuffPercent}% attack buff');
  if (ability.defenseBuffPercent > 0)
    effects.add('+${ability.defenseBuffPercent}% defense buff');
  if (ability.enemyAttackDebuffPercent > 0)
    effects.add('-${ability.enemyAttackDebuffPercent}% enemy attack');
  if (ability.enemyDefenseDebuffPercent > 0)
    effects.add('-${ability.enemyDefenseDebuffPercent}% enemy defense');
  if (ability.grantCasterDefensePercent > 0)
    effects.add('Grants ${ability.grantCasterDefensePercent}% of caster defense');
  if (ability.darkPact) effects.add('Sacrifices HP to damage all enemies');
  if (ability.chaotic) effects.add('Chaotic: random variance, may bounce');

  final targetLabel = switch (ability.targetType) {
    AbilityTarget.singleEnemy => 'Single Enemy',
    AbilityTarget.allEnemies => 'All Enemies',
    AbilityTarget.singleAlly => 'Single Ally',
    AbilityTarget.allAllies => 'All Allies',
    AbilityTarget.self => 'Self',
  };

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ability.name),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ability.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Target: $targetLabel', style: theme.textTheme.bodySmall),
          if (ability.refreshChance > 0 && !ability.isBasicAttack)
            Text('Refresh: ${ability.refreshChance}% per round',
                style: theme.textTheme.bodySmall),
          if (effects.isNotEmpty) ...[
            const Divider(),
            Text('Effects',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            ...effects.map((e) => Text('  $e',
                style: theme.textTheme.bodySmall)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Show help dialog for a map node type.
void showNodeHelp(BuildContext context, NodeType nodeType) {
  final info = switch (nodeType) {
    NodeType.combat => ('Combat', 'Fight a group of enemies. Defeat them all to earn XP and gold.'),
    NodeType.boss => ('Boss', 'A powerful boss guards this node. Bosses have double HP and act twice per round.'),
    NodeType.shop => ('Shop', 'Buy equipment and potions. Old gear is sold back for half its original value.'),
    NodeType.rest => ('Rest Stop', 'Heal your entire party. A good time to recover before the next fight.'),
    NodeType.treasure => ('Treasure', 'Find gold and a piece of equipment. You can equip it to any party member.'),
    NodeType.event => ('Event', 'A random encounter with choices. Each choice has different rewards and risks.'),
    NodeType.start => ('Start', 'Your starting position on this map.'),
    NodeType.recruit => ('Tavern', 'Recruit a new party member to replace one of your current characters.'),
  };

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(info.$1),
      content: Text(info.$2),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Show help dialog for an equipment item.
void showItemHelp(BuildContext context, dynamic item) {
  final theme = Theme.of(context);
  final parts = <String>[];
  if (item.attackBonus != 0) parts.add('${item.attackBonus > 0 ? "+" : ""}${item.attackBonus} ATK');
  if (item.defenseBonus != 0) parts.add('${item.defenseBonus > 0 ? "+" : ""}${item.defenseBonus} DEF');
  if (item.hpBonus != 0) parts.add('${item.hpBonus > 0 ? "+" : ""}${item.hpBonus} HP');
  if (item.speedBonus != 0) parts.add('${item.speedBonus > 0 ? "+" : ""}${item.speedBonus} SPD');
  if (item.magicBonus != 0) parts.add('${item.magicBonus > 0 ? "+" : ""}${item.magicBonus} MAG');

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(item.name),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Slot: ${item.slot.name}', style: theme.textTheme.bodyMedium),
          Text('Rarity: ${item.rarity.name}', style: theme.textTheme.bodyMedium),
          Text('Value: ${item.value}g', style: theme.textTheme.bodyMedium),
          if (parts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Bonuses:', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            ...parts.map((p) => Text('  $p', style: theme.textTheme.bodySmall)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/ui/widgets/help_dialogs.dart`
Expected: No issues found

- [ ] **Step 3: Run all tests**

Run: `flutter test`
Expected: All 33 tests pass

- [ ] **Step 4: Commit core help infrastructure**

```bash
git add lib/providers/help_mode_provider.dart lib/ui/widgets/help_button.dart lib/ui/widgets/character_detail_card.dart lib/ui/widgets/help_dialogs.dart
git commit -m "feat: add core help system infrastructure — provider, button, dialogs, character detail card"
```

---

## Chunk 2: Combat Screen Integration

### Task 5: Add Help Mode to Combat Screen

**Files:**
- Modify: `lib/ui/screens/combat/combat_screen.dart`

The combat screen doesn't have a standard AppBar — it has a custom top bar built with `_buildTopBar()`. Add the HelpButton to this custom bar. Wrap ally taps, enemy taps, and ability taps with help mode checks.

- [ ] **Step 1: Add imports**

Add at the top of the file:
```dart
import '../../../providers/help_mode_provider.dart';
import '../../widgets/help_button.dart';
import '../../widgets/help_dialogs.dart';
```

- [ ] **Step 2: Add HelpButton to the top bar**

In the `_buildTopBar()` method, add the HelpButton alongside the existing UI. Find the Row/layout that contains the turn order bar and add HelpButton to its trailing side.

- [ ] **Step 3: Wrap ally taps with help mode check**

In the ally GestureDetector's onTap (around line 683), add a help mode check:
```dart
onTap: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    showCharacterHelp(context, ally);
    return;
  }
  // ... existing tap logic
},
```

- [ ] **Step 4: Wrap enemy taps with help mode check**

In the enemy GestureDetector's onTap (around line 759), add a help mode check:
```dart
onTap: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    showEnemyHelp(context, enemy);
    return;
  }
  // ... existing tap logic
},
```

- [ ] **Step 5: Wrap ability taps with help mode check**

In the ability GestureDetector's onTap (around the ability bar area), add a help mode check:
```dart
onTap: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    showAbilityHelp(context, ability);
    return;
  }
  // ... existing tap logic
},
```

- [ ] **Step 6: Verify no analysis errors**

Run: `flutter analyze lib/ui/screens/combat/combat_screen.dart`
Expected: No issues found

- [ ] **Step 7: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 8: Commit**

```bash
git add lib/ui/screens/combat/combat_screen.dart
git commit -m "feat: add help mode to combat screen — tap allies/enemies/abilities for info"
```

---

## Chunk 3: Shop Screen Integration + Party Panel

### Task 6: Add Help Mode and Party Panel to Shop Screen

**Files:**
- Modify: `lib/ui/screens/shop/shop_screen.dart`

Add HelpButton to AppBar. Add a "Your Party" section below shop items showing each party member with their stats and equipment slots. Wrap shop items with help mode check.

- [ ] **Step 1: Add imports**

```dart
import '../../../providers/help_mode_provider.dart';
import '../../widgets/help_button.dart';
import '../../widgets/help_dialogs.dart';
import '../../widgets/character_detail_card.dart';
```

- [ ] **Step 2: Add HelpButton to AppBar actions**

In the AppBar actions array, add `const HelpButton()` before `const AudioMuteButton()`.

- [ ] **Step 3: Add party panel to the ListView**

After the equipment items section in the ListView children, add a "Your Party" header and a card for each party member using `CharacterDetailCard(character: char, showAbilities: false, compact: true)`. Each card should be tappable — in help mode show full help dialog, otherwise also show help dialog (since party panel is informational).

```dart
// After equipment items in ListView children:
const SizedBox(height: 16),
Text('Your Party', style: theme.textTheme.titleMedium?.copyWith(
  fontWeight: FontWeight.bold,
)),
const SizedBox(height: 8),
...gameState.party.map((char) => Card(
  child: InkWell(
    onTap: () => showCharacterHelp(context, char),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: CharacterDetailCard(
        character: char,
        showAbilities: false,
      ),
    ),
  ),
)),
```

- [ ] **Step 4: Wrap shop item taps with help mode check**

In the equipment item's FilledButton onPressed, check help mode first:
```dart
onPressed: canAfford
    ? () {
        if (ref.read(helpModeProvider)) {
          ref.read(helpModeProvider.notifier).state = false;
          showItemHelp(context, item);
          return;
        }
        _showEquipDialog(item);
      }
    : null,
```

- [ ] **Step 5: Verify no analysis errors and run tests**

Run: `flutter analyze lib/ui/screens/shop/shop_screen.dart && flutter test`
Expected: No issues, all tests pass

- [ ] **Step 6: Commit**

```bash
git add lib/ui/screens/shop/shop_screen.dart
git commit -m "feat: add help mode + party equipment panel to shop screen"
```

---

## Chunk 4: Map, Party Select, Treasure Screens

### Task 7: Add Help Mode to Map Screen

**Files:**
- Modify: `lib/ui/screens/map/map_screen.dart`

- [ ] **Step 1: Add imports and HelpButton to AppBar**

Add help imports. Add `const HelpButton()` to AppBar actions before AudioMuteButton.

- [ ] **Step 2: Wrap node taps with help mode check**

In the node onTap callback, check help mode and show node type info:
```dart
onTap: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    showNodeHelp(context, node.type);
    return;
  }
  // ... existing navigation logic
},
```

- [ ] **Step 3: Verify and commit**

Run: `flutter analyze lib/ui/screens/map/map_screen.dart && flutter test`

```bash
git add lib/ui/screens/map/map_screen.dart
git commit -m "feat: add help mode to map screen — tap nodes for type info"
```

---

### Task 8: Add Help Mode + Equipment Display to Party Select Screen

**Files:**
- Modify: `lib/ui/screens/party_select/party_select_screen.dart`

- [ ] **Step 1: Add imports**

Add help imports and `CharacterDetailCard` import.

- [ ] **Step 2: Add HelpButton to AppBar**

Add `const HelpButton()` to AppBar actions.

- [ ] **Step 3: Expand class cards to show equipment slots**

When a class is selected, show its character's equipment slots with item stats below the class card. Find or create the Character object for the selected class from `gameState.party` and use `CharacterDetailCard` to show gear. If the character exists in the party, show their full gear.

For the class list items, when a class card is tapped in help mode, show a help dialog with the class's base stats and full ability list. Reference the class data from `lib/data/class_data.dart`.

- [ ] **Step 4: Wrap class card taps with help mode check**

```dart
onTap: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    // Show class info dialog with stats and abilities
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(def.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Base Stats:'),
              Text('HP: ${def.baseHp}  ATK: ${def.baseAttack}  DEF: ${def.baseDefense}  SPD: ${def.baseSpeed}  MAG: ${def.baseMagic}'),
              const Divider(),
              Text('Abilities:'),
              ...def.abilities.map((a) => Text('${a.name}: ${a.description}')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
    return;
  }
  _toggleClass(cls);
},
```

- [ ] **Step 5: Verify and commit**

Run: `flutter analyze lib/ui/screens/party_select/party_select_screen.dart && flutter test`

```bash
git add lib/ui/screens/party_select/party_select_screen.dart
git commit -m "feat: add help mode + equipment display to party select screen"
```

---

### Task 9: Add Help Mode to Treasure Screen

**Files:**
- Modify: `lib/ui/screens/treasure/treasure_screen.dart`

- [ ] **Step 1: Add imports and HelpButton to AppBar**

- [ ] **Step 2: Wrap loot display with help mode — tapping the loot card shows item stats**

- [ ] **Step 3: Wrap party equip buttons with help mode — shows character stats instead of equipping**

```dart
onPressed: () {
  if (ref.read(helpModeProvider)) {
    ref.read(helpModeProvider.notifier).state = false;
    showCharacterHelp(context, char);
    return;
  }
  _equipTo(char);
},
```

- [ ] **Step 4: Verify and commit**

Run: `flutter analyze lib/ui/screens/treasure/treasure_screen.dart && flutter test`

```bash
git add lib/ui/screens/treasure/treasure_screen.dart
git commit -m "feat: add help mode to treasure screen"
```

---

## Chunk 5: Remaining Screens

### Task 10: Add Help Mode to Rest, Event, Recruit Screens

**Files:**
- Modify: `lib/ui/screens/rest/rest_screen.dart`
- Modify: `lib/ui/screens/event/event_screen.dart`
- Modify: `lib/ui/screens/recruit/recruit_screen.dart`

- [ ] **Step 1: Add imports and HelpButton to each screen's AppBar**

For each of the three screens, add:
```dart
import '../../../providers/help_mode_provider.dart';
import '../../widgets/help_button.dart';
```
And add `const HelpButton()` to the AppBar actions list.

- [ ] **Step 2: For recruit screen, wrap character cards with help mode check**

In the recruit screen's character selection, when help mode is active and a character is tapped, show their stats dialog instead of selecting them.

- [ ] **Step 3: Verify all three screens and run tests**

Run: `flutter analyze lib/ui/screens/rest/rest_screen.dart lib/ui/screens/event/event_screen.dart lib/ui/screens/recruit/recruit_screen.dart && flutter test`

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/rest/rest_screen.dart lib/ui/screens/event/event_screen.dart lib/ui/screens/recruit/recruit_screen.dart
git commit -m "feat: add help button to rest, event, and recruit screens"
```

---

### Task 11: Final Verification

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 3: Deactivate help mode on screen navigation**

Ensure help mode is deactivated when navigating between screens. Add a listener or check in the HelpButton — if the user navigates away, reset help mode. This can be done by reading and resetting the provider in each screen's build method if help mode shouldn't persist across screens. A simple approach: in `help_button.dart`, use a `ref.listen` that resets when the route changes, OR simply reset help mode in the provider whenever any screen's `initState` or `build` fires. The simplest approach: just let it persist — it auto-deactivates after one help tap anyway.

- [ ] **Step 4: Final commit if any cleanup needed**
