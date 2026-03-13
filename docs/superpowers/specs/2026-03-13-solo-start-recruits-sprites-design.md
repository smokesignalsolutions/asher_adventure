# Solo Start, Recruit Nodes, Sprite Upgrades & Idle Animations

## 1. Solo Start

**Current behavior:** Player picks 4 classes at party select, game starts with full party.

**New behavior:** Player picks 1 class from all unlocked classes. Game starts with that single party member.

### Changes
- `party_select_screen.dart`: Change from multi-select (max 4) to single-select. Tap a class to select, tap again to deselect. "Begin Adventure" enabled when exactly 1 class is selected.
- `game_state_provider.dart` `startNewGame()`: Accept a list with 1 class instead of 4. No other changes needed — party is already a `List<Character>`.
- Combat, map, shop, etc. all already iterate over `party` — a 1-member party works without changes.
- Starting gold increased to 50g so the player can afford an early recruit.

### Solo Difficulty
- A solo squishy class (Wizard, 70 HP) will be fragile early. This is intentional — class choice matters.
- Game over triggers correctly when the solo character dies (existing `allAlliesDead` check works with 1 member).

## 2. Recruit (Tavern) Nodes

### New Node Type
- Add `NodeType.recruit` **at the end** of the `NodeType` enum (after `start`) to preserve save compatibility with existing `NodeType.values[index]` deserialization.
- Map icon: tankard/mug emoji
- Scouting service: add recruit to icon map

### Map Generation
- `map_service.dart`: Add `recruit` to node type distribution
- New distribution for columns 1-6:
  - 40% combat
  - 12% treasure
  - 12% event
  - 10% rest
  - 11% shop
  - 15% recruit
- Guarantee at least 1 recruit node in **columns 1-2** so solo players can recruit early.
- If none generated randomly, convert one non-combat node in columns 1-2 to recruit.

### Recruit Screen (`lib/ui/screens/recruit/recruit_screen.dart`)
- Shows 2-4 random classes from all unlocked classes (same `unlockedByDefault` filter as party select)
- **No duplicate classes** — excludes classes already in the party from the random pool
- Each option displays: class name, base stats (HP/ATK/DEF/SPD/MAG), recruit cost
- "Hire" button per class — disabled if not enough gold or party already has 4
- Party count shown: "Party: 2/4"
- If party is already 4/4: show a message "Your party is full!" with a "Continue" button (no need to browse)
- If player can't afford any recruit: buttons disabled, can still browse and leave
- Hired character: auto-named, level 1, base stats, starting abilities, no equipment
- After hiring (or choosing to leave), route back to `/map`
- Player can hire multiple recruits in one visit (if they have the gold and party slots)

### Recruit Level Scaling
- Recruits start at **party average level** (rounded down, minimum 1), not always level 1. This prevents late-game recruits from being useless.
- Stats scale using the same `ProgressionService.levelUp()` logic applied repeatedly from level 1 to the target level.
- Abilities unlocked up to the recruit's starting level.

### Recruit Cost
- Formula: `baseClassPrice + mapNumber * 20`
- Class price tiers:
  - **Starter (40g base):** Fighter, Rogue, Cleric, Wizard
  - **Mid-tier (60g base):** Paladin, Ranger, Monk, Barbarian, Druid, Spellsword
  - **Advanced (80g base):** Warlock, Summoner, Sorcerer, Necromancer, Artificer, Templar
- Examples: Hiring a Wizard on map 1 = 60g. Hiring a Necromancer on map 5 = 180g.

### Provider Changes
- `game_state_provider.dart`: Add `recruitCharacter(CharacterClass cls, int cost)` method
  - Creates new Character (same logic as startNewGame character creation)
  - Levels up to party average level via ProgressionService
  - Deducts gold
  - Appends to party list
  - Refreshes state and auto-saves
- `game_state.dart`: Increase default starting gold to 50

### Router
- Add `/recruit` route pointing to `RecruitScreen`
- `map_screen.dart`: Handle `NodeType.recruit` in `_moveToNode()` — navigate to `/recruit`

## 3. Sprite Upgrades

### Scope
- 16 character class sprites (no large variants — not used anywhere) = 16 PNGs
- 24 regular enemy sprites (no large variants) = 24 PNGs
- 8 boss sprites (no large variants) = 8 PNGs
- **Total: 48 PNGs to regenerate**

Note: `_large.png` variants exist in the assets but are not referenced anywhere in the codebase. We skip regenerating them. They can be removed in a future cleanup.

### Specifications
- All sprites: 64x64 pixels (up from 32x32)
- Format: PNG with transparency
- Style: 16-bit pixel art, same retro palette as ability icons
- More detail than current sprites: better shading, recognizable silhouettes, distinct color schemes per class/enemy

### Generation
- Python PIL script (similar to `/tmp/generate_ability_icons_v2.py`)
- One generator function per sprite
- Output directly to `assets/sprites/` and `assets/sprites/enemies/`
- Same filenames as current sprites (drop-in replacement)

### Character Design Guidelines (all 16 classes)
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

### Enemy Design Guidelines
- Enemies should look threatening, distinct from player characters
- Bosses should be more imposing with larger weapons/features
- Color-code by threat: greens/browns for early, reds/purples for late
- Each enemy gets a unique silhouette matching their name (wolf = quadruped, skeleton = bones, dragon = wings + horns, etc.)

## 4. Idle Animations

### Approach
Code-based animation in Flutter — no sprite sheets. Single image per character/enemy, animated via `AnimationController`.

### Animation Details
- **Vertical bob**: 2-3px up/down sinusoidal movement, 1.5s period
- **Breathing scale**: 1.0x to 1.02x scale, 2.0s period (offset from bob)
- Animations loop infinitely
- Each combatant gets a slightly randomized phase offset so they don't all bob in sync

### Implementation
- Create an `IdleAnimatedSprite` `StatefulWidget` in `lib/ui/widgets/idle_animated_sprite.dart`
- Each widget instance manages its own `AnimationController` via `SingleTickerProviderStateMixin`
- Takes: image path, size, and optional phase offset
- Applies `Transform.translate` (for bob) and `Transform.scale` (for breathing) via `AnimatedBuilder`
- Replace direct `Image.asset` calls in combat screen with `IdleAnimatedSprite`
- Apply to both ally and enemy sprites
- KO'd characters: animation stops (no bobbing when dead)

### Performance
- Lightweight — only transforms, no texture swapping
- Each widget manages its own `AnimationController` lifecycle (init/dispose)
- Up to ~14 simultaneous controllers in large fights — no performance concern

## Files Modified

### New Files
- `lib/ui/screens/recruit/recruit_screen.dart` — tavern recruit screen
- `lib/ui/widgets/idle_animated_sprite.dart` — reusable animated sprite widget
- `/tmp/generate_sprites_64.py` — Python sprite generation script

### Modified Files
- `lib/models/enums.dart` — add `NodeType.recruit` at end of enum
- `lib/models/game_state.dart` — starting gold = 50
- `lib/ui/screens/party_select/party_select_screen.dart` — single-select instead of multi-select
- `lib/services/map_service.dart` — add recruit nodes to generation
- `lib/services/scouting_service.dart` — add recruit node icon
- `lib/providers/game_state_provider.dart` — add `recruitCharacter()` method
- `lib/core/router/app_router.dart` — add `/recruit` route
- `lib/ui/screens/map/map_screen.dart` — handle recruit node navigation
- `lib/ui/screens/combat/combat_screen.dart` — replace Image.asset with IdleAnimatedSprite
- `assets/sprites/*.png` — regenerated 64x64 character sprites
- `assets/sprites/enemies/*.png` — regenerated 64x64 enemy sprites
