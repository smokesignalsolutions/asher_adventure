# Status Effects & Custom Map Enemies Design

**Date:** 2026-03-25
**Scope:** Unified status effect system, 60 custom map enemies, retrofit all existing enemies with special attacks

---

## 1. Status Effect System

### StatusEffect Model (`lib/models/status_effect.dart`)

New enum `StatusEffectType` and class `StatusEffect`:

```dart
enum StatusEffectType {
  weakened,   // Deal reduced damage
  exposed,    // Reduced defense
  slowed,     // Reduced speed
  stunned,    // Lose next turn
  blinded,    // % chance attacks miss
  poisoned,   // Damage each turn
  burning,    // Damage each turn (higher, shorter)
  bleeding,   // Damage each turn
  silenced,   // Only basic attack available
  frozen,     // Stunned + next hit deals bonus damage
  cursed,     // Healing received halved
}

class StatusEffect {
  final StatusEffectType type;
  int duration;          // Turns remaining (-1 = permanent for this combat)
  final int magnitude;   // % for debuffs, flat damage for DoTs
  final String sourceId; // Who applied it
}
```

### Effect Categories & Behavior

**Offensive Debuffs:**
| Type | Effect | Magnitude meaning |
|------|--------|-------------------|
| weakened | Target deals reduced damage | % damage reduction (e.g., 75 = deals 25% damage) |
| exposed | Target has reduced defense | % defense reduction |
| slowed | Target has reduced speed | % speed reduction |

**Damage Over Time (DoTs):**
| Type | Effect | Magnitude meaning |
|------|--------|-------------------|
| poisoned | Take damage at start of turn | Flat damage per tick |
| burning | Take damage at start of turn | Flat damage per tick |
| bleeding | Take damage at start of turn | Flat damage per tick |

**Control:**
| Type | Effect | Magnitude meaning |
|------|--------|-------------------|
| stunned | Skip next turn | N/A (binary) |
| blinded | Attacks have % chance to miss | Miss chance % |
| silenced | Only basic attack available | N/A (binary) |
| frozen | Stunned + next hit deals bonus damage | Bonus damage % on next hit |
| cursed | Healing received halved | N/A (binary) |

### Processing Order (per combatant turn start)

1. Tick DoTs (poison, burning, bleeding) — apply damage, decrement duration
2. Check stunned/frozen — if active, skip turn, decrement duration
3. Apply stat debuffs (weakened, exposed, slowed) via effective stat getters
4. Check silenced — filter available abilities to basic attacks only
5. On attack: check blinded — roll miss chance before damage
6. On hit: check frozen on target — if frozen, bonus damage, remove frozen
7. On heal received: check cursed — halve healing
8. End of turn: remove effects with duration <= 0

### Ability Integration

New field on `Ability`:

```dart
class AppliedEffect {
  final StatusEffectType type;
  final int duration;
  final int magnitude;
  final int chance; // 0-100% chance to apply on hit
}

// On Ability:
List<AppliedEffect> appliesStatusEffects;
```

Each effect rolls independently on hit. Example: Gore Charge has `[{stunned, 1, 0, 60%}, {bleeding, 1, dmg, 80%}]` — might stun but not bleed, or both, or neither.

---

## 2. Model Migration

### Character (`lib/models/character.dart`)

**Remove:**
- `combatAttackMultiplier`
- `combatDefenseMultiplier`
- `combatSpeedMultiplier`
- `combatMagicMultiplier`
- `combatDefenseBonus`

**Add:**
- `List<StatusEffect> statusEffects`
- Getter `effectiveAttack` — base attack modified by weakened effects
- Getter `effectiveDefense` — base defense modified by exposed effects
- Getter `effectiveSpeed` — base speed modified by slowed effects
- Getter `isStunned` — checks for stunned/frozen effects
- Getter `isSilenced` — checks for silenced effect
- Getter `isBlinded` — checks for blinded effect, returns miss chance
- Getter `isCursed` — checks for cursed effect
- Getter `activeStatusLabels` — returns list of display strings for UI
- Helper `addStatusEffect(StatusEffect)` — adds to list (stacks or refreshes duration)
- Helper `removeExpiredEffects()`
- Helper `tickDoTs()` — returns total DoT damage this turn

**Keep as-is:** `shieldHp`, `isFrontLine`, `activeSummons`, `skeletonCount`, `lastAttackWasPhysical` (these are class mechanic fields, not status effects)

### Enemy (`lib/models/enemy.dart`)

**Remove:**
- `isVulnerable`
- `attackMultiplier`
- `defenseMultiplier`
- `tempAttackMultiplier`
- `tempAttackDebuffTurns`
- `isStunned`

**Add:**
- `List<StatusEffect> statusEffects`
- Same getters and helpers as Character (effective stats, status checks, tick/remove)

### Existing Player Abilities Migration

All existing player abilities that use inline debuff fields get migrated to `appliesStatusEffects`:
- `stunChance` → `appliesStatusEffects: [{stunned, 1, 0, stunChance%}]`
- `appliesVulnerability` → `appliesStatusEffects: [{exposed, -1, 10, 100%}]`
- `enemyAttackDebuffPercent` → `appliesStatusEffects: [{weakened, -1, percent, 100%}]`
- `enemyDefenseDebuffPercent` → `appliesStatusEffects: [{exposed, -1, percent, 100%}]`
- `tempEnemyAttackDebuffPercent` + `debuffDuration` → `appliesStatusEffects: [{weakened, duration, percent, 100%}]`

---

## 3. Combat Service Changes (`lib/services/combat_service.dart`)

### Unified Turn Processing

Replace all inline status effect logic with centralized processing:

```
processTurnStart(combatant):
  1. tickDoTs() — apply poison/burning/bleeding damage
  2. if stunned or frozen → skip turn, decrement, return
  3. decrement all effect durations
  4. removeExpiredEffects()

processAbilityHit(ability, target):
  1. if attacker blinded → roll miss chance, if miss → log miss, return
  2. if target frozen → apply bonus damage, remove frozen
  3. calculate damage using target.effectiveDefense, attacker.effectiveAttack
  4. apply damage (shield absorb first, then HP)
  5. for each appliesStatusEffects on ability → roll chance, if success → target.addStatusEffect()

processHeal(target, amount):
  1. if target cursed → amount = amount / 2
  2. apply healing
```

### Stat Computation

All damage/defense calculations use the `effective*` getters which factor in active status effects. This replaces the old inline multiplier approach.

---

## 4. Custom Map Enemies

### Architecture

**Map definition change** (`lib/data/map_data.dart`):
Each map definition gets a `customEnemies` field — a list of 2 `EnemyTemplate` references.

**Enemy data** (`lib/data/enemy_data.dart`):
New section of custom enemy templates. Stats are defined at a base level and scaled at runtime.

**Scaling formula:**
```
Custom enemy stats = tier base stats × 1.2
Custom enemy XP = tier XP × 1.15
Custom enemy gold = tier gold × 1.15
```

Where "tier" is determined by which slot (1-8) the map lands in during a run.

**Encounter generation** (`lib/services/map_service.dart`):
When building a combat encounter for a map node, custom map enemies are added to the pool alongside generic tier enemies. Not every fight will have one — they're mixed in randomly.

### Full Custom Enemy Roster (60 enemies)

Each has a basic attack + one special ability with status effects.

#### Natural/Overworld Maps

**1. Forest**
- **Thornbear** — Special: *Thorn Maul* → bleeding 3 turns
- **Woodland Stalker** — Special: *Snare Shot* → slowed 2 turns

**2. Desert**
- **Sand Wurm** — Special: *Sandblast* → blinded 2 turns
- **Dust Wraith** — Special: *Scorching Touch* → burning 2 turns

**3. Swamp**
- **Bog Zombie** — Special: *Toxic Grasp* → poisoned 3 turns
- **Swamp Hag** — Special: *Hex* → cursed 3 turns

**4. Tundra**
- **Frost Stalker** — Special: *Flash Freeze* → frozen 1 turn
- **Snow Wraith** — Special: *Chilling Wind* → slowed 3 turns

**5. Volcano**
- **Magma Golem** — Special: *Eruption* → burning 3 turns
- **Ember Imp** — Special: *Flame Burst* → burning 2 turns (AOE, hits all)

**6. Mountain Pass**
- **Rock Troll** — Special: *Boulder Slam* → stunned 1 turn
- **Mountain Eagle** — Special: *Diving Talon* → bleeding 2 turns

**7. Coastal Cliffs**
- **Sea Serpent** — Special: *Constrict* → weakened 2 turns
- **Siren** — Special: *Siren Song* → silenced 2 turns

**8. Plains**
- **War Centaur** — Special: *Trample* → stunned 1 turn
- **Prairie Stalker** — Special: *Hamstring* → slowed 2 turns

**9. Deep Jungle**
- **Venomspitter** — Special: *Venom Spray* → poisoned 3 turns
- **Canopy Spider** — Special: *Web Shot* → weakened 2 turns

**10. Cursed Wasteland**
- **Blight Walker** — Special: *Corrupting Touch* → cursed 3 turns
- **Ash Phantom** — Special: *Ashen Veil* → blinded 2 turns

**21. Badlands**
- **Dust Devil** — Special: *Sand Cyclone* → blinded 2 turns
- **Scorpion Brute** — Special: *Venomous Sting* → poisoned 3 turns

**22. Mushroom Forest**
- **Spore Beast** — Special: *Spore Cloud* → poisoned 2 turns (AOE)
- **Myconid Guardian** — Special: *Fungal Slam* → slowed 2 turns

**23. Sunken Marsh**
- **Marsh Lurker** — Special: *Death Roll* → bleeding 3 turns
- **Will-o-Wisp** — Special: *Bewildering Glow* → blinded 2 turns

#### Dungeon/Underground Maps

**11. Cave System**
- **Cave Troll** — Special: *Crushing Grip* → weakened 2 turns
- **Crystal Bat** — Special: *Sonic Screech* → silenced 2 turns

**12. Ancient Ruins**
- **Animated Guardian** — Special: *Petrifying Strike* → frozen 1 turn
- **Rune Wraith** — Special: *Rune Burn* → burning 2 turns + silenced 1 turn

**13. Catacombs**
- **Crypt Stalker** — Special: *Gravetouched Claws* → cursed 2 turns
- **Bone Colossus** — Special: *Bone Shrapnel* → bleeding 3 turns

**14. Underground Lake**
- **Deep Angler** — Special: *Lure Snap* → stunned 1 turn
- **Lake Serpent** — Special: *Tidal Coil* → weakened 3 turns

**15. Goblin Warren**
- **Goblin Alchemist** — Special: *Acid Flask* → exposed 3 turns
- **Goblin Trapper** — Special: *Net Toss* → slowed 2 turns + weakened 1 turn

**24. Crystal Caverns**
- **Crystal Golem** — Special: *Prism Blast* → blinded 2 turns
- **Gem Viper** — Special: *Crystal Fang* → bleeding 2 turns + exposed 1 turn

**25. Haunted Graveyard**
- **Grave Knight** — Special: *Spectral Cleave* → cursed 3 turns
- **Banshee** — Special: *Death Wail* → silenced 2 turns + weakened 1 turn

**26. Abandoned Mine**
- **Mine Creeper** — Special: *Acid Spit* → exposed 3 turns
- **Dynamite Goblin** — Special: *Blast Charge* → stunned 1 turn + burning 1 turn

#### Magical/Special Maps

**16. Shadow Realm**
- **Void Stalker** — Special: *Void Touch* → cursed 3 turns + weakened 1 turn
- **Shadow Devourer** — Special: *Engulfing Dark* → blinded 3 turns

**17. Enchanted Grove**
- **Treant Sentinel** — Special: *Root Bind* → stunned 1 turn + exposed 2 turns
- **Pixie Swarm** — Special: *Fairy Dust* → silenced 2 turns

**18. Demon Fortress**
- **Hellhound** — Special: *Infernal Bite* → burning 3 turns
- **Demon Sentry** — Special: *Abyssal Strike* → exposed 2 turns + bleeding 2 turns

**19. Sky Islands**
- **Storm Hawk** — Special: *Lightning Dive* → stunned 1 turn
- **Cloud Elemental** — Special: *Static Shock* → slowed 2 turns + burning 1 turn

**20. The Void**
- **Void Reaver** — Special: *Reality Tear* → exposed 2 turns + cursed 2 turns
- **Entropy Shade** — Special: *Entropic Decay* → weakened 2 turns + poisoned 2 turns

**27. Pirate Cove**
- **Cursed Buccaneer** — Special: *Cursed Cutlass* → cursed 2 turns + bleeding 2 turns
- **Kraken Spawn** — Special: *Tentacle Lash* → weakened 2 turns + slowed 1 turn

**28. Arcane Tower**
- **Arcane Sentinel** — Special: *Mana Burn* → silenced 3 turns
- **Spell Wraith** — Special: *Arcane Overload* → burning 2 turns + exposed 1 turn

**29. Gladiator Arena**
- **Arena Champion** — Special: *Shield Bash* → stunned 1 turn + exposed 1 turn
- **Beast Master** — Special: *Command Attack* → bleeding 2 turns + slowed 2 turns

**30. Frozen Citadel**
- **Frost Knight** — Special: *Glacial Strike* → frozen 1 turn + slowed 1 turn
- **Ice Wraith** — Special: *Frozen Grasp* → frozen 1 turn

---

## 5. Existing Enemy Special Abilities (Retrofit)

Every existing enemy gets a new special ability (refresh 40-60%) that applies status effects. Bosses get status effects added to an existing ability or gain a third ability.

### Tier 1
- **Goblin** — *Dirty Throw* → blinded 1 turn (50% refresh)
- **Wolf** — *Trip* → stunned 1 turn (45% refresh)
- **Bandit** — *Low Blow* → weakened 2 turns (50% refresh)
- **Boss: Goblin King** — *Call Minions* gains: slowed 1 turn on targets

### Tier 2
- **Skeleton** — *Bone Rattle* → silenced 2 turns (45% refresh)
- **Orc Grunt** — *War Stomp* → slowed 2 turns (50% refresh)
- **Giant Spider** — *Web Shot* → weakened 2 turns (50% refresh)
- **Boss: Bone Lord** — *Bone Crush* gains: exposed 2 turns

### Tier 3
- **Dark Mage** — *Hex Bolt* → cursed 2 turns (45% refresh)
- **Ogre** — *Ground Pound* → stunned 1 turn (50% refresh)
- **Harpy** — *Shriek* → silenced 2 turns (50% refresh)
- **Boss: Shadow Witch** — *Curse All* gains: cursed 2 turns

### Tier 4
- **Troll** — *Savage Tear* → bleeding 3 turns (50% refresh)
- **Wraith** — *Soul Chill* → slowed 2 turns + weakened 1 turn (45% refresh)
- **Minotaur** — *Gore Charge* → stunned 1 turn + bleeding 1 turn (50% refresh)
- **Boss: Mountain Giant** — *Earthquake* gains: slowed 2 turns

### Tier 5
- **Wyvern** — *Poison Barb* → poisoned 3 turns (50% refresh)
- **Lich Acolyte** — *Withering Curse* → cursed 2 turns + weakened 1 turn (45% refresh)
- **Golem** — *Crushing Slam* → stunned 1 turn + exposed 1 turn (50% refresh)
- **Boss: Lich King** — *Mass Wither* gains: cursed 3 turns

### Tier 6
- **Vampire** — *Mesmerize* → stunned 1 turn + cursed 1 turn (45% refresh)
- **Chimera** — *Venomous Bite* → poisoned 2 turns + burning 1 turn (50% refresh)
- **Death Knight** — *Cursed Blade* → bleeding 3 turns + cursed 1 turn (45% refresh)
- **Boss: Demon Prince** — *Rain of Fire* gains: burning 2 turns

### Tier 7
- **Elder Dragon** — *Immolate* → burning 3 turns + exposed 1 turn (45% refresh)
- **Archdemon** — *Abyssal Chains* → slowed 2 turns + weakened 2 turns (45% refresh)
- **Titan** — *Earthshatter* → stunned 1 turn + slowed 2 turns (45% refresh)
- **Boss: Dragon Emperor** — *Inferno* gains: burning 3 turns

### Tier 8
- **Shadow Lord** — *Void Grip* → silenced 2 turns + weakened 2 turns (40% refresh)
- **Ancient Wyrm** — *Cataclysmic Roar* → exposed 2 turns + slowed 2 turns (40% refresh)
- **Void Walker** — *Phase Strike* → blinded 2 turns + cursed 2 turns (40% refresh)
- **Boss: The Dark One** — *Apocalypse* gains: cursed 2 turns + burning 2 turns

### Army Soldiers
- **Army Fighter** — *Shield Bash* gains: stunned 1 turn
- **Army Cleric** — *Holy Smite* (new 3rd ability, 40% refresh) → silenced 2 turns
- **Army Wizard** — *Arcane Blast* gains: burning 1 turn

---

## 6. Combat UI Changes (`lib/ui/screens/combat/combat_screen.dart`)

### Status Bar Display

Add a text line below the HP bar for both allies and enemies:

```
HP 84/120
Poisoned · Weakened
```

- Font: same labelSmall style, fontSize 8-9
- Color coding by category:
  - Red: DoTs (poisoned, burning, bleeding)
  - Yellow: Debuffs (weakened, exposed, slowed)
  - Blue/Cyan: Control (stunned, blinded, silenced, frozen, cursed)
- Multiple effects separated by " · "
- Only shown when effects are active (no empty line)

---

## 7. Design Principles

- **Tier 1-3** enemies: single status effects — simple, learnable
- **Tier 4-5** enemies: start getting combo effects (two statuses)
- **Tier 6-8** enemies: all combo effects — appropriately threatening for endgame
- **Bosses**: status effects on AOE abilities for maximum party-wide impact
- **Custom map enemies**: 120% stat scaling, one special + one basic attack
- **Special ability refresh**: 40-60% so enemies don't spam every turn
- **Status durations**: 1-3 turns, nothing permanently crippling
- **Each map's custom pair**: one brawler-type, one caster/tricky type for variety
