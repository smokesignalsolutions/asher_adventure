import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/class_data.dart';
import '../data/enemy_data.dart';
import '../data/name_generator.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../data/map_data.dart';
import '../services/map_service.dart';
import '../services/progression_service.dart';
import '../models/player_profile.dart';
import '../services/save_service.dart';
import '../data/mutator_data.dart';
import '../services/scouting_service.dart';

const _uuid = Uuid();
final _random = Random();

class GameStateNotifier extends StateNotifier<GameState?> {
  GameStateNotifier() : super(null);

  Future<void> loadGame() async {
    final json = await SaveService.loadRunSaveJson();
    if (json != null) {
      state = GameState.fromJson(jsonDecode(json));
    }
  }

  Future<void> startNewGame(
    List<CharacterClass> selectedClasses,
    DifficultyLevel difficulty, {
    PlayerProfile? profile,
    String? activePerk,
    String? activeMutator,
    bool testMode = false,
  }) async {
    NameGenerator.reset();
    final party = <Character>[];

    for (final cls in selectedClasses) {
      final classDef = classDefinitions[cls]!;
      final name = NameGenerator.generate(cls.name[0].toUpperCase() + cls.name.substring(1));

      // Gather abilities — all in test mode, level 1 only otherwise
      final startingAbilities = testMode
          ? classDef.abilities.map((a) => a.copyWith(unlockedAtLevel: 1)).toList()
          : classDef.abilities
              .where((a) => a.unlockedAtLevel <= 1)
              .map((a) => a.copyWith())
              .toList();

      // Melee classes default to front line, casters to back
      final isFront = !magicDamageClasses.contains(cls);

      party.add(Character(
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
        isFrontLine: isFront,
      ));
    }

    // Apply passive bonuses from profile
    if (profile != null) {
      final bonuses = profile.passiveBonuses;
      for (final char in party) {
        char.maxHp += (bonuses['hp'] ?? 0) * 5;
        char.currentHp = char.maxHp;
        char.attack += bonuses['attack'] ?? 0;
        char.defense += bonuses['defense'] ?? 0;
        char.speed += bonuses['speed'] ?? 0;
        char.magic += bonuses['magic'] ?? 0;
      }
    }

    // Calculate starting resources
    int startingGold = 0;
    int startingPotions = 0;
    double armyStartColumn = -1.0;

    if (profile != null) {
      startingPotions += profile.passiveBonuses['health_potion'] ?? 0;
      armyStartColumn -= (profile.passiveBonuses['army_delay'] ?? 0).toDouble();
    }

    if (activePerk == 'merchant_purse') startingGold += 50;
    if (activePerk == 'veteran') {
      for (final char in party) {
        ProgressionService.addXp(char, ProgressionService.xpForLevel(2));
      }
    }
    if (activePerk == 'healer_blessing') {
      for (final char in party) {
        char.shieldHp = (char.totalMaxHp * 0.20).round();
      }
    }

    final mapPool = generateMapPool();

    final map = MapService.generateMap(1);
    map.armyColumn = armyStartColumn;

    state = GameState(
      party: party,
      gold: startingGold,
      healthPotions: startingPotions,
      currentMap: map,
      difficulty: difficulty,
      activePerk: activePerk,
      activeMutator: activeMutator,
      mapPool: mapPool,
    );

    // Scout from starting position (unless scouting is disabled by mutator)
    if (activeMutator != 'fog_of_war') {
      ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
    }
    await _autoSave();
  }

  GameState _refreshState() => GameState(
    party: state!.party,
    gold: state!.gold,
    healthPotions: state!.healthPotions,
    currentMapNumber: state!.currentMapNumber,
    currentMap: state!.currentMap,
    difficulty: state!.difficulty,
    totalEnemiesDefeated: state!.totalEnemiesDefeated,
    totalGoldEarned: state!.totalGoldEarned,
    armyMoveAccumulator: state!.armyMoveAccumulator,
    mapsCompletedThisRun: state!.mapsCompletedThisRun,
    bossesKilledThisRun: state!.bossesKilledThisRun,
    uniqueEnemyTypesKilledThisRun: Set.from(state!.uniqueEnemyTypesKilledThisRun),
    enemyKillCountsThisRun: Map.from(state!.enemyKillCountsThisRun),
    activePerk: state!.activePerk,
    activeMutator: state!.activeMutator,
    mapPool: List.from(state!.mapPool),
  );

  Future<void> moveToNode(String nodeId) async {
    if (state == null) return;

    final node = state!.currentMap.nodeById(nodeId);
    node.visited = true;
    state!.currentMap.currentNodeId = nodeId;

    // Advance army
    state!.armyMoveAccumulator += 1.0;
    final armySpeed = _getArmySpeed();
    while (state!.armyMoveAccumulator >= armySpeed) {
      state!.armyMoveAccumulator -= armySpeed;
      state!.currentMap.armyColumn += 1.0;
    }

    // Scout adjacent nodes (unless scouting is disabled by mutator)
    final scoutingDisabled = state!.activeMutator == 'fog_of_war';
    if (!scoutingDisabled) {
      ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
    }

    state = _refreshState();
    await _autoSave();
  }

  bool get isArmyCatching {
    if (state == null) return false;
    return state!.currentMap.armyColumn >= state!.currentMap.currentNode.column;
  }

  double _getArmySpeed() {
    double speed;
    switch (state!.difficulty) {
      case DifficultyLevel.easy:
        speed = 3.0;
      case DifficultyLevel.normal:
        speed = 2.0;
      case DifficultyLevel.hard:
        speed = 1.5;
      case DifficultyLevel.nightmare:
        speed = 1.0;
    }
    // Lower speed = faster army. Mutator > 1.0 means faster, so divide.
    final mutator = getMutatorEffect(state!.activeMutator, 'army_speed');
    return speed / mutator;
  }

  Enemy _enemyFromTemplate(EnemyTemplate template) => Enemy(
    id: _uuid.v4(),
    name: template.name,
    type: template.type,
    currentHp: template.hp,
    maxHp: template.hp,
    attack: template.attack,
    defense: template.defense,
    speed: template.speed,
    magic: template.magic,
    xpReward: template.xpReward,
    goldReward: template.goldReward,
    abilities: template.abilities
        .map((a) => a.copyWith())
        .toList(),
  );

  List<Enemy> generateEnemies() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final templates = enemiesByMap[mapNum] ?? enemiesByMap[1]!;
    // Base count from party size + 1-3 extra
    final partySize = state!.party.where((c) => c.isAlive).length;
    final baseMax = partySize <= 1 ? 1 : partySize <= 2 ? 2 : 3;
    final extra = 1 + _random.nextInt(3); // 1-3 extra
    final count = (1 + _random.nextInt(baseMax)) + extra;

    return List.generate(count, (_) {
      final template = templates[_random.nextInt(templates.length)];
      return _enemyFromTemplate(template);
    });
  }

  List<Enemy> generateBoss() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final bossTemplate = bossByMap[mapNum] ?? bossByMap[1]!;

    // Boss gets double HP
    final boss = Enemy(
      id: _uuid.v4(),
      name: bossTemplate.name,
      type: bossTemplate.type,
      currentHp: bossTemplate.hp * 2,
      maxHp: bossTemplate.hp * 2,
      attack: bossTemplate.attack,
      defense: bossTemplate.defense,
      speed: bossTemplate.speed,
      magic: bossTemplate.magic,
      xpReward: bossTemplate.xpReward,
      goldReward: bossTemplate.goldReward,
      abilities: bossTemplate.abilities
          .map((a) => a.copyWith())
          .toList(),
    );
    final enemies = <Enemy>[boss];

    // Add 2-10 minions from current map's enemy pool
    // (map 1 uses its own enemies since there's no previous map)
    final minionTemplates = enemiesByMap[mapNum] ?? enemiesByMap[1]!;
    final minionCount = 2 + _random.nextInt(9); // 2-10
    for (int i = 0; i < minionCount; i++) {
      final template = minionTemplates[_random.nextInt(minionTemplates.length)];
      enemies.add(_enemyFromTemplate(template));
    }

    return enemies;
  }

  Future<void> completeCombat(
    int xpGained,
    int goldGained, {
    List<String> killedEnemyTypes = const [],
    bool bossKilled = false,
  }) async {
    if (state == null) return;

    for (final char in state!.party) {
      ProgressionService.addXp(char, xpGained);
    }

    final goldMultiplier = getMutatorEffect(state!.activeMutator, 'gold_drop');
    final adjustedGold = (goldGained * goldMultiplier).round();
    state!.gold += adjustedGold;
    state!.totalGoldEarned += adjustedGold;

    // Track enemy types killed this run
    state!.uniqueEnemyTypesKilledThisRun.addAll(killedEnemyTypes);
    // Track kill counts per type
    for (final type in killedEnemyTypes) {
      state!.enemyKillCountsThisRun[type] = (state!.enemyKillCountsThisRun[type] ?? 0) + 1;
    }
    if (bossKilled) {
      state!.bossesKilledThisRun++;
    }

    state = _refreshState();
    await _autoSave();
  }

  Future<void> addGold(int amount) async {
    if (state == null) return;
    state!.gold += amount;
    state = _refreshState();
    await _autoSave();
  }

  Future<void> restParty({double healFraction = 1.0}) async {
    if (state == null) return;
    // Revive dead characters and heal everyone
    for (final char in state!.party) {
      if (healFraction >= 1.0) {
        char.currentHp = char.totalMaxHp;
      } else {
        // Revive dead characters to the heal fraction amount
        if (!char.isAlive) {
          char.currentHp = (char.totalMaxHp * healFraction).round();
        } else {
          final healAmount = (char.totalMaxHp * healFraction).round();
          char.currentHp = (char.currentHp + healAmount).clamp(0, char.totalMaxHp);
        }
      }
    }
    state = _refreshState();
    await _autoSave();
  }

  List<Enemy> generateArmyEnemies() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final templates = armySoldiers(mapNum);
    final count = 5 + _random.nextInt(6); // 5-10 soldiers

    return List.generate(count, (_) {
      final template = templates[_random.nextInt(templates.length)];
      return _enemyFromTemplate(template);
    });
  }

  Future<void> defeatArmy() async {
    if (state == null) return;
    // Push the army back 2 columns behind the player
    final playerCol = state!.currentMap.currentNode.column.toDouble();
    state!.currentMap.armyColumn = (playerCol - 2).clamp(-2.0, 7.0);
    state!.armyMoveAccumulator = 0.0;

    state = _refreshState();
    await _autoSave();
  }

  Future<void> advanceToNextMap() async {
    if (state == null) return;
    final nextMap = state!.currentMapNumber + 1;
    if (nextMap > 8) return;

    state = GameState(
      party: state!.party,
      gold: state!.gold, // Carry gold to next map (earned from boss fight)
      healthPotions: state!.healthPotions,
      currentMapNumber: nextMap,
      currentMap: MapService.generateMap(nextMap),
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      mapsCompletedThisRun: state!.mapsCompletedThisRun + 1,
      bossesKilledThisRun: state!.bossesKilledThisRun,
      uniqueEnemyTypesKilledThisRun: state!.uniqueEnemyTypesKilledThisRun,
      enemyKillCountsThisRun: state!.enemyKillCountsThisRun,
      activePerk: state!.activePerk,
      activeMutator: state!.activeMutator,
      mapPool: state!.mapPool,
    );

    if (state!.activeMutator != 'fog_of_war') {
      ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
    }
    await _autoSave();
  }

  Future<void> spendGold(int amount) async {
    if (state == null) return;
    state!.gold -= amount;
    state = _refreshState();
    await _autoSave();
  }

  Future<void> buyPotion(int cost) async {
    if (state == null || state!.gold < cost) return;
    state!.gold -= cost;
    state!.healthPotions++;
    state = _refreshState();
    await _autoSave();
  }

  Future<void> usePotion() async {
    if (state == null || state!.healthPotions <= 0) return;
    state!.healthPotions--;
    state = _refreshState();
    await _autoSave();
  }

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
        .map((a) => a.copyWith())
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
      isFrontLine: !magicDamageClasses.contains(cls),
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


  /// Returns the final GameState snapshot for LP calculation, then clears state.
  GameState? endRun() {
    final snapshot = state;
    state = null;
    return snapshot;
  }

  Future<void> gameOver() async {
    await SaveService.deleteRunSave();
    state = null;
  }

  Future<void> _autoSave() async {
    if (state != null) {
      await SaveService.autoSaveRun(state!.toJson());
    }
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState?>((ref) {
  return GameStateNotifier();
});
