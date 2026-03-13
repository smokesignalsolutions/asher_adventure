import 'dart:math';
import '../core/constants/game_constants.dart';
import '../models/character.dart';
import '../models/enums.dart';
import '../models/game_map.dart';
class ScoutingService {
  static final _random = Random();

  static void scoutAdjacentNodes(GameMap map, List<Character> party) {
    final currentNode = map.currentNode;

    // Calculate scout chance based on party composition
    double scoutChance = GameConstants.baseScoutChance;
    if (party.any((c) => c.characterClass == CharacterClass.ranger && c.isAlive)) {
      scoutChance += GameConstants.rangerScoutBonus;
    }
    if (party.any((c) => c.characterClass == CharacterClass.rogue && c.isAlive)) {
      scoutChance += GameConstants.rogueScoutBonus;
    }

    // Try to scout each connected node
    for (final connId in currentNode.connections) {
      final connNode = map.nodeById(connId);
      if (!connNode.scouted && !connNode.visited) {
        if (_random.nextDouble() < scoutChance) {
          connNode.scouted = true;
        }
      }
    }
  }

  static String nodeTypeIcon(NodeType type, {bool scouted = true}) {
    if (!scouted) return '?';
    switch (type) {
      case NodeType.combat:
        return '⚔️';
      case NodeType.shop:
        return '🏪';
      case NodeType.rest:
        return '🏕️';
      case NodeType.treasure:
        return '💎';
      case NodeType.boss:
        return '💀';
      case NodeType.event:
        return '❗';
      case NodeType.start:
        return '🏁';
      case NodeType.recruit:
        return '🍺';
    }
  }

  static String nodeTypeLabel(NodeType type) {
    switch (type) {
      case NodeType.combat: return 'Combat';
      case NodeType.shop: return 'Shop';
      case NodeType.rest: return 'Rest';
      case NodeType.treasure: return 'Treasure';
      case NodeType.boss: return 'Boss';
      case NodeType.event: return 'Event';
      case NodeType.start: return 'Start';
      case NodeType.recruit: return 'Tavern';
    }
  }
}
