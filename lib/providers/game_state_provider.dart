import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/class_data.dart';
import '../data/enemy_data.dart';
import '../data/name_generator.dart';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../services/map_service.dart';
import '../services/progression_service.dart';
import '../services/save_service.dart';
import '../services/scouting_service.dart';

const _uuid = Uuid();
final _random = Random();

class GameStateNotifier extends StateNotifier<GameState?> {
  GameStateNotifier() : super(null);

  Future<void> loadGame() async {
    state = await SaveService.loadSave();
  }

  Future<void> startNewGame(
    List<CharacterClass> selectedClasses,
    DifficultyLevel difficulty,
  ) async {
    NameGenerator.reset();
    final party = <Character>[];

    for (final cls in selectedClasses) {
      final classDef = classDefinitions[cls]!;
      final name = NameGenerator.generate(cls.name[0].toUpperCase() + cls.name.substring(1));

      // Gather starting abilities (level 1)
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
      ));
    }

    final map = MapService.generateMap(1);

    state = GameState(
      party: party,
      currentMap: map,
      difficulty: difficulty,
    );

    // Scout from starting position
    ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
    await _autoSave();
  }

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

    // Scout adjacent nodes
    ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);

    // Force state update
    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: state!.armyMoveAccumulator,
    );

    await _autoSave();
  }

  bool get isArmyCatching {
    if (state == null) return false;
    return state!.currentMap.armyColumn >= state!.currentMap.currentNode.column;
  }

  double _getArmySpeed() {
    switch (state!.difficulty) {
      case DifficultyLevel.easy:
        return 3.0;
      case DifficultyLevel.normal:
        return 2.0;
      case DifficultyLevel.hard:
        return 1.5;
      case DifficultyLevel.nightmare:
        return 1.0;
    }
  }

  List<Enemy> generateEnemies() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final templates = enemiesByMap[mapNum] ?? enemiesByMap[1]!;
    final count = 1 + _random.nextInt(3); // 1-3 enemies

    return List.generate(count, (_) {
      final template = templates[_random.nextInt(templates.length)];
      return Enemy(
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
            .map((a) => Ability(
                  name: a.name,
                  description: a.description,
                  damage: a.damage,
                  refreshChance: a.refreshChance,
                  targetType: a.targetType,
                  unlockedAtLevel: a.unlockedAtLevel,
                  isBasicAttack: a.isBasicAttack,
                ))
            .toList(),
      );
    });
  }

  List<Enemy> generateBoss() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final template = bossByMap[mapNum] ?? bossByMap[1]!;
    return [
      Enemy(
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
            .map((a) => Ability(
                  name: a.name,
                  description: a.description,
                  damage: a.damage,
                  refreshChance: a.refreshChance,
                  targetType: a.targetType,
                  unlockedAtLevel: a.unlockedAtLevel,
                  isBasicAttack: a.isBasicAttack,
                ))
            .toList(),
      ),
    ];
  }

  Future<void> completeCombat(int xpGained, int goldGained) async {
    if (state == null) return;

    // Everyone gets full XP (alive or dead)
    for (final char in state!.party) {
      ProgressionService.addXp(char, xpGained);
    }

    state!.gold += goldGained;
    state!.totalGoldEarned += goldGained;

    // Refresh state
    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: state!.armyMoveAccumulator,
    );
    await _autoSave();
  }

  Future<void> addGold(int amount) async {
    if (state == null) return;
    state!.gold += amount;
    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: state!.armyMoveAccumulator,
    );
    await _autoSave();
  }

  Future<void> restParty() async {
    if (state == null) return;
    // Revive dead characters and heal everyone to full
    for (final char in state!.party) {
      char.currentHp = char.totalMaxHp;
    }
    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: state!.armyMoveAccumulator,
    );
    await _autoSave();
  }

  List<Enemy> generateArmyEnemies() {
    if (state == null) return [];
    final mapNum = state!.currentMapNumber;
    final templates = armySoldiers(mapNum);
    final count = 5 + _random.nextInt(6); // 5-10 soldiers

    return List.generate(count, (_) {
      final template = templates[_random.nextInt(templates.length)];
      return Enemy(
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
            .map((a) => Ability(
                  name: a.name,
                  description: a.description,
                  damage: a.damage,
                  refreshChance: a.refreshChance,
                  targetType: a.targetType,
                  unlockedAtLevel: a.unlockedAtLevel,
                  isBasicAttack: a.isBasicAttack,
                ))
            .toList(),
      );
    });
  }

  Future<void> defeatArmy() async {
    if (state == null) return;
    // Push the army back 2 columns behind the player
    final playerCol = state!.currentMap.currentNode.column.toDouble();
    state!.currentMap.armyColumn = (playerCol - 2).clamp(-2.0, 7.0);

    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: 0.0,
    );
    await _autoSave();
  }

  Future<void> advanceToNextMap() async {
    if (state == null) return;
    final nextMap = state!.currentMapNumber + 1;
    if (nextMap > 8) return; // Game won!

    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: nextMap,
      currentMap: MapService.generateMap(nextMap),
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
    );

    ScoutingService.scoutAdjacentNodes(state!.currentMap, state!.party);
    await _autoSave();
  }

  Future<void> spendGold(int amount) async {
    if (state == null) return;
    state!.gold -= amount;
    state = GameState(
      party: state!.party,
      gold: state!.gold,
      currentMapNumber: state!.currentMapNumber,
      currentMap: state!.currentMap,
      difficulty: state!.difficulty,
      totalEnemiesDefeated: state!.totalEnemiesDefeated,
      totalGoldEarned: state!.totalGoldEarned,
      armyMoveAccumulator: state!.armyMoveAccumulator,
    );
    await _autoSave();
  }

  Future<void> gameOver() async {
    await SaveService.deleteSave();
    state = null;
  }

  Future<void> _autoSave() async {
    if (state != null) {
      await SaveService.autoSave(state!);
    }
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState?>((ref) {
  return GameStateNotifier();
});
