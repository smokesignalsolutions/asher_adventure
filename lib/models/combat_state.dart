import 'character.dart';
import 'enemy.dart';

class CombatantEntry {
  final String id;
  final String name;
  final bool isAlly;
  final double initiative;

  CombatantEntry({
    required this.id,
    required this.name,
    required this.isAlly,
    required this.initiative,
  });
}

class CombatState {
  final List<Character> allies;
  final List<Enemy> enemies;
  final List<CombatantEntry> turnOrder;
  int currentTurnIndex;
  int roundNumber;
  final List<String> combatLog;
  bool isComplete;
  bool isVictory;

  CombatState({
    required this.allies,
    required this.enemies,
    required this.turnOrder,
    this.currentTurnIndex = 0,
    this.roundNumber = 1,
    List<String>? combatLog,
    this.isComplete = false,
    this.isVictory = false,
  }) : combatLog = combatLog ?? [];

  CombatantEntry get currentCombatant => turnOrder[currentTurnIndex];

  bool get allAlliesDead => allies.every((a) => !a.isAlive);
  bool get allEnemiesDead => enemies.every((e) => !e.isAlive);
}
