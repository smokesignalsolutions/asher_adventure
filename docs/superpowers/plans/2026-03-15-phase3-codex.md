# Phase 3: Codex — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the Codex system: bestiary (enemy kill tracking with progressive reveals), lore pages (collectible world-building text found at event/treasure nodes), and class stories (chapter unlocks from completing maps with specific classes). Add a Codex viewer screen accessible from the title screen.

**Architecture:** Codex data stored in PlayerProfile (bestiary kills map, lore pages found set, class story chapters map). Bestiary updates happen when enemies are killed via completeCombat flow. Lore pages drop randomly at event/treasure nodes. Class stories progress when maps are completed with a class alive. Codex screen is a 3-tab viewer.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, GoRouter

---

## Task 1: Define codex content data

**Files:**
- Create: `lib/data/codex_data.dart`

Static data for bestiary entries, lore pages, and class story text.

- [ ] **Step 1: Create codex_data.dart**

```dart
// lib/data/codex_data.dart
import '../models/enums.dart';

class BestiaryDefinition {
  final String enemyType; // matches Enemy.type field
  final String name;
  final String description;
  final int mapTier; // 1-4 (maps 1-2, 3-4, 5-6, 7-8)

  const BestiaryDefinition({
    required this.enemyType,
    required this.name,
    required this.description,
    required this.mapTier,
  });
}

class LorePageDefinition {
  final String id;
  final int mapTier; // 1-4
  final String title;
  final String content;

  const LorePageDefinition({
    required this.id,
    required this.mapTier,
    required this.title,
    required this.content,
  });
}

class ClassStoryChapter {
  final CharacterClass characterClass;
  final int chapter; // 1-3
  final String title;
  final String content;

  const ClassStoryChapter({
    required this.characterClass,
    required this.chapter,
    required this.title,
    required this.content,
  });
}

// Bestiary entries keyed by enemy type string
const List<BestiaryDefinition> bestiaryEntries = [
  // Tier 1 (Maps 1-2)
  BestiaryDefinition(enemyType: 'goblin', name: 'Goblin', description: 'Small but vicious green-skinned creatures that attack in groups.', mapTier: 1),
  BestiaryDefinition(enemyType: 'wolf', name: 'Dire Wolf', description: 'Massive wolves corrupted by dark magic. Fast and relentless.', mapTier: 1),
  BestiaryDefinition(enemyType: 'bandit', name: 'Bandit', description: 'Desperate outlaws who prey on travelers. Well-armed but cowardly.', mapTier: 1),
  BestiaryDefinition(enemyType: 'skeleton', name: 'Skeleton', description: 'Reanimated bones held together by necromantic energy.', mapTier: 1),
  BestiaryDefinition(enemyType: 'orc', name: 'Orc', description: 'Brutish warriors driven by rage. Strong but slow to react.', mapTier: 1),
  BestiaryDefinition(enemyType: 'spider', name: 'Giant Spider', description: 'Venomous arachnids that lurk in dark corners of the world.', mapTier: 1),
  // Tier 2 (Maps 3-4)
  BestiaryDefinition(enemyType: 'dark_mage', name: 'Dark Mage', description: 'Sorcerers corrupted by forbidden knowledge. Dangerous at range.', mapTier: 2),
  BestiaryDefinition(enemyType: 'ogre', name: 'Ogre', description: 'Towering brutes with incredible strength but dim wits.', mapTier: 2),
  BestiaryDefinition(enemyType: 'harpy', name: 'Harpy', description: 'Winged terrors that swoop down from above with piercing shrieks.', mapTier: 2),
  BestiaryDefinition(enemyType: 'troll', name: 'Troll', description: 'Regenerating monstrosities that must be overwhelmed quickly.', mapTier: 2),
  BestiaryDefinition(enemyType: 'wraith', name: 'Wraith', description: 'Ghostly remnants of fallen warriors. Partially resistant to physical attacks.', mapTier: 2),
  BestiaryDefinition(enemyType: 'minotaur', name: 'Minotaur', description: 'Half-bull warriors that charge with devastating force.', mapTier: 2),
  // Tier 3 (Maps 5-6)
  BestiaryDefinition(enemyType: 'wyvern', name: 'Wyvern', description: 'Lesser dragons with venomous tails. Fast flyers and fierce fighters.', mapTier: 3),
  BestiaryDefinition(enemyType: 'lich_acolyte', name: 'Lich Acolyte', description: 'Apprentice necromancers seeking immortality through dark rituals.', mapTier: 3),
  BestiaryDefinition(enemyType: 'golem', name: 'Stone Golem', description: 'Animated stone guardians. Nearly impervious to magic.', mapTier: 3),
  BestiaryDefinition(enemyType: 'vampire', name: 'Vampire', description: 'Ancient undead that drain the life from their victims.', mapTier: 3),
  BestiaryDefinition(enemyType: 'chimera', name: 'Chimera', description: 'Three-headed abominations with the fury of lion, goat, and serpent.', mapTier: 3),
  BestiaryDefinition(enemyType: 'death_knight', name: 'Death Knight', description: 'Fallen paladins raised to serve darkness. Skilled and merciless.', mapTier: 3),
  // Tier 4 (Maps 7-8)
  BestiaryDefinition(enemyType: 'elder_dragon', name: 'Elder Dragon', description: 'Ancient wyrms of immense power. Their breath melts steel.', mapTier: 4),
  BestiaryDefinition(enemyType: 'archdemon', name: 'Archdemon', description: 'Lords of the abyss, commanding legions of lesser fiends.', mapTier: 4),
  BestiaryDefinition(enemyType: 'titan', name: 'Titan', description: 'Primordial giants from before the age of mortals.', mapTier: 4),
  BestiaryDefinition(enemyType: 'shadow_lord', name: 'Shadow Lord', description: 'Manifestations of pure darkness given terrible form.', mapTier: 4),
  BestiaryDefinition(enemyType: 'ancient_wyrm', name: 'Ancient Wyrm', description: 'The oldest of dragonkind. Their very presence warps reality.', mapTier: 4),
  BestiaryDefinition(enemyType: 'void_walker', name: 'Void Walker', description: 'Beings from between worlds. They unmake what they touch.', mapTier: 4),
  // Boss type
  BestiaryDefinition(enemyType: 'boss', name: 'Boss', description: 'Powerful guardians that block the path forward.', mapTier: 0),
];

// Lore pages: 4 per tier, 16 total
const List<LorePageDefinition> lorePages = [
  // Tier 1
  LorePageDefinition(id: 'lore_1_1', mapTier: 1, title: 'The Kingdom of Ashenvale', content: 'Once, Ashenvale was a land of peace and plenty. The five kingdoms traded freely, and the roads were safe for even the smallest traveler. That all changed when the Dark One rose from the Void Between Worlds.'),
  LorePageDefinition(id: 'lore_1_2', mapTier: 1, title: 'The First Sign', content: 'The crops withered first. Then the animals fled. By the time the shadows began to move on their own, it was too late. The Dark One\'s army marched from the east, consuming everything in its path.'),
  LorePageDefinition(id: 'lore_1_3', mapTier: 1, title: 'The Call to Arms', content: 'King Aldric sent riders to every corner of the realm. Warriors, mages, rogues, and healers — all were needed. The response was overwhelming. Heroes emerged from the most unlikely places.'),
  LorePageDefinition(id: 'lore_1_4', mapTier: 1, title: 'The Legacy Hall', content: 'Deep beneath Castle Ashenvale lies the Legacy Hall, where the deeds of fallen heroes are inscribed in eternal stone. Each name carries power — power that strengthens those who follow.'),
  // Tier 2
  LorePageDefinition(id: 'lore_2_1', mapTier: 2, title: 'The Corrupted Lands', content: 'Beyond the frontier, the land itself has been twisted by the Dark One\'s influence. Trees grow in impossible shapes, rivers run black, and the very air tastes of iron and ash.'),
  LorePageDefinition(id: 'lore_2_2', mapTier: 2, title: 'The Army of Shadows', content: 'The Dark One\'s army is not merely soldiers. It is a living tide of corruption that grows stronger with each victory. Those who fall in battle are raised again to fight against their former allies.'),
  LorePageDefinition(id: 'lore_2_3', mapTier: 2, title: 'The Ancient Weapons', content: 'Legends speak of weapons forged in the first age, when gods still walked the earth. These artifacts hold power enough to wound even the Dark One — if they can be found.'),
  LorePageDefinition(id: 'lore_2_4', mapTier: 2, title: 'The Healers\' Oath', content: 'The clerics of the Silver Order swore to heal any who asked, friend or foe. Even now, in the darkest times, they hold to their oath — though it costs them dearly.'),
  // Tier 3
  LorePageDefinition(id: 'lore_3_1', mapTier: 3, title: 'The Dragon Pact', content: 'Long ago, mortals and dragons fought side by side against a common enemy. That alliance was shattered by betrayal. Now the elder dragons guard their mountain fortresses in bitter isolation.'),
  LorePageDefinition(id: 'lore_3_2', mapTier: 3, title: 'The Necromancer\'s Folly', content: 'The Dark One was once a mortal wizard who sought to conquer death itself. He succeeded — but the price was his humanity. What returned from the Void was something far worse than death.'),
  LorePageDefinition(id: 'lore_3_3', mapTier: 3, title: 'The Void Between', content: 'Between all worlds lies the Void — a place of infinite nothing. Those who glimpse it are forever changed. Those who enter it rarely return. Those who return are never the same.'),
  LorePageDefinition(id: 'lore_3_4', mapTier: 3, title: 'The Last Fortress', content: 'Fort Ironhold stands as the final bastion before the Dark One\'s domain. Its walls have held for a thousand years. Its defenders pray they will hold for one more day.'),
  // Tier 4
  LorePageDefinition(id: 'lore_4_1', mapTier: 4, title: 'The Dark Throne', content: 'At the heart of the corruption sits the Dark Throne — a seat of power carved from the bones of fallen gods. From here, the Dark One commands legions across all the realms.'),
  LorePageDefinition(id: 'lore_4_2', mapTier: 4, title: 'The Final Battle', content: 'Every hero who has challenged the Dark One has fallen. Their spirits are trapped in the Void, feeding the Dark One\'s power. But prophecy speaks of a party of four who will break the cycle.'),
  LorePageDefinition(id: 'lore_4_3', mapTier: 4, title: 'The Price of Victory', content: 'To defeat the Dark One is not to destroy him — for he is beyond destruction. It is to seal him away, to bind him in chains of light and hope. But the seal requires sacrifice.'),
  LorePageDefinition(id: 'lore_4_4', mapTier: 4, title: 'After the Dawn', content: 'When the Dark One falls, the corruption will fade. The land will heal. But the scars will remain — in the earth, in the people, and in the hearts of those who fought. They will remember.'),
];

// Class stories: 3 chapters per class (placeholder text for 4 starter classes, more added later)
const List<ClassStoryChapter> classStories = [
  // Fighter
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 1, title: 'The Broken Sword', content: 'Every fighter begins with a weapon passed down through generations. Yours was shattered in the first battle against the Dark One\'s army. But a broken blade can still cut — and a broken warrior can still fight.'),
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 2, title: 'The Shield Wall', content: 'At Fort Ironhold, you learned that true strength is not in the arm that swings the sword, but in the heart that refuses to retreat. You held the line when others could not.'),
  ClassStoryChapter(characterClass: CharacterClass.fighter, chapter: 3, title: 'The Last Stand', content: 'Before the Dark Throne, you understood. The blade was never broken — it was reforged in every battle, tempered by every wound. You are the weapon. You always were.'),
  // Rogue
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 1, title: 'Shadows and Daggers', content: 'The thieves\' guild fell apart when the Dark One came. Loyalty means nothing when shadows come alive. But you survived — you always survive. That\'s what rogues do.'),
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 2, title: 'The Hidden Path', content: 'You found passages that no map shows. Doors that no key opens. Secrets that the Dark One thought buried. Knowledge is the sharpest blade of all.'),
  ClassStoryChapter(characterClass: CharacterClass.rogue, chapter: 3, title: 'The Final Trick', content: 'They never see it coming. Not the monsters, not the army, not even the Dark One himself. The greatest trick is making them think you\'re just a thief — right until the knife finds its mark.'),
  // Cleric
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 1, title: 'The Healing Light', content: 'When the temples burned, you carried the sacred flame within. Your hands mend what darkness breaks. Your prayers reach ears that even gods have abandoned.'),
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 2, title: 'The Weight of Mercy', content: 'You healed a fallen soldier of the Dark One\'s army. He wept, remembering who he had been before the corruption. Some stains cannot be washed clean — but you try anyway.'),
  ClassStoryChapter(characterClass: CharacterClass.cleric, chapter: 3, title: 'The Sacred Sacrifice', content: 'The final prayer is not for healing. It is for strength — the strength to give everything, to pour out every last drop of light, to burn so brightly that even the Void recoils.'),
  // Wizard
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 1, title: 'The Forbidden Library', content: 'The Academy of Arcane Arts was the first to fall. The Dark One coveted its knowledge. But you smuggled out the most dangerous tome of all — the one that contains his true name.'),
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 2, title: 'The Spell Unwritten', content: 'Magic is not about power. It is about understanding. You have studied the Dark One\'s corruption, learned its patterns, found its weaknesses. Knowledge defeats power.'),
  ClassStoryChapter(characterClass: CharacterClass.wizard, chapter: 3, title: 'The Word of Unmaking', content: 'You speak the Word. Reality trembles. The Dark One\'s true name echoes through the Void, and for the first time in a thousand years, he knows fear.'),
];
```

- [ ] **Step 2: Commit**

---

## Task 2: Add codex fields to PlayerProfile

**Files:**
- Modify: `lib/models/player_profile.dart`
- Modify: `test/models/player_profile_test.dart`

Add three new fields:
- `Map<String, int> bestiaryKills` — enemy type → total kills across all runs
- `Set<String> loreFound` — set of lore page IDs found
- `Map<String, int> classStoryProgress` — class name → highest chapter completed (0-3)

With serialization and tests.

- [ ] **Step 1: Add fields, toJson, fromJson**
- [ ] **Step 2: Add test for serialization**
- [ ] **Step 3: Run tests, commit**

---

## Task 3: Add codex update methods to PlayerProfileProvider

**Files:**
- Modify: `lib/providers/player_profile_provider.dart`
- Modify: `test/providers/player_profile_provider_test.dart`

Add methods:
```dart
Future<void> recordEnemyKills(Map<String, int> killCounts) async
Future<void> recordLorePageFound(String pageId) async
Future<void> recordClassStoryProgress(CharacterClass cls, int chapter) async
```

With tests.

- [ ] **Step 1: Add methods**
- [ ] **Step 2: Add tests**
- [ ] **Step 3: Run tests, commit**

---

## Task 4: Update run-end flow to persist bestiary kills

**Files:**
- Modify: `lib/ui/screens/game_over/game_over_screen.dart`
- Modify: `lib/ui/screens/victory/victory_screen.dart`

The combat screen already tracks `uniqueEnemyTypesKilledThisRun` in GameState. We need to also track kill counts per type. Update the run-end flow in both screens to call `recordEnemyKills()` on the profile provider.

Also need to add a `Map<String, int> enemyKillCountsThisRun` field to GameState (simple counter map) and update `completeCombat()` to increment it.

**Files also modified:**
- `lib/models/game_state.dart` — add enemyKillCountsThisRun field
- `lib/providers/game_state_provider.dart` — increment in completeCombat, carry in refresh/advance

- [ ] **Step 1: Add enemyKillCountsThisRun to GameState**
- [ ] **Step 2: Increment in completeCombat**
- [ ] **Step 3: Update game over and victory screens to persist kills**
- [ ] **Step 4: Run tests, commit**

---

## Task 5: Add lore page drops to event and treasure screens

**Files:**
- Modify: `lib/ui/screens/event/event_screen.dart`
- Modify: `lib/ui/screens/treasure/treasure_screen.dart`

At event and treasure nodes, there's a 20% chance to find a lore page. The page must be from the current map's tier and not already found. Show the lore text in a dialog. Call `recordLorePageFound()` on the profile.

- [ ] **Step 1: Add lore drop logic to both screens**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 6: Add class story progress on map completion

**Files:**
- Modify: `lib/ui/screens/game_over/game_over_screen.dart`
- Modify: `lib/ui/screens/victory/victory_screen.dart`

When a run ends, check each alive party member against class story thresholds:
- Map 2+ completed with class alive → chapter 1
- Map 5+ completed with class alive → chapter 2
- Map 8 completed with class alive → chapter 3

Call `recordClassStoryProgress()` for any newly earned chapters.

- [ ] **Step 1: Add class story checks to run-end flow**
- [ ] **Step 2: Run flutter analyze, commit**

---

## Task 7: Create Codex screen

**Files:**
- Create: `lib/ui/screens/codex/codex_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/ui/screens/title/title_screen.dart`

3-tab viewer: Bestiary, Lore, Class Stories.

**Bestiary tab:** List of all bestiary entries. For each:
- If never encountered (0 kills): show "???" with locked icon
- If encountered (1+ kills): show name and kill count
- If 5+ kills: show description too
- If 15+ kills: show "Mastered!" badge

**Lore tab:** Grouped by tier. For each page:
- If found: show title and content
- If not found: show "???" locked

**Class Stories tab:** List of classes. For each:
- Show class name
- For each of 3 chapters: show title + content if unlocked, "???" if locked
- Show progress (e.g. "2/3 chapters")

- [ ] **Step 1: Create Codex screen**
- [ ] **Step 2: Add route and title button**
- [ ] **Step 3: Run flutter analyze, commit**

---

## Task 8: Final verification

- [ ] **Step 1: Run all tests**
- [ ] **Step 2: Run flutter analyze**
- [ ] **Step 3: Final commit if needed**
