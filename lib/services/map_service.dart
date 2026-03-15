import 'dart:math';
import '../core/constants/game_constants.dart';
import '../models/enums.dart';
import '../models/game_map.dart';
import '../models/map_node.dart';

class MapService {
  static final _random = Random();

  // Node x positions map column 0-7 into the range 0.07 - 0.93
  static const _startX = 0.07;
  static const _endX = 0.93;

  static double columnCenterX(int col) {
    return _startX + (col / 7.0) * (_endX - _startX);
  }

  static GameMap generateMap(int mapNumber) {
    final nodes = <MapNode>[];

    // Column 0: single start node, centered
    nodes.add(MapNode(
      id: 'map${mapNumber}_0_0',
      column: 0,
      row: 0,
      type: NodeType.start,
      x: _startX,
      y: 0.5,
      connections: [],
      visited: true,
      scouted: true,
    ));

    // Columns 1-6: 3-5 scattered nodes each
    for (int col = 1; col <= 6; col++) {
      final count = GameConstants.minNodesPerColumn +
          _random.nextInt(
              GameConstants.maxNodesPerColumn - GameConstants.minNodesPerColumn + 1);

      final xCenter = columnCenterX(col);
      final yPositions = _spreadYPositions(count);

      for (int row = 0; row < count; row++) {
        // Scatter x within ±0.04 of the column center
        final x = (xCenter + (_random.nextDouble() - 0.5) * 0.08)
            .clamp(0.06, 0.94);

        nodes.add(MapNode(
          id: 'map${mapNumber}_${col}_$row',
          column: col,
          row: row,
          type: _randomNodeType(mapNumber),
          x: x,
          y: yPositions[row],
          connections: [],
        ));
      }
    }

    // Column 7: single boss node, centered
    nodes.add(MapNode(
      id: 'map${mapNumber}_7_0',
      column: 7,
      row: 0,
      type: NodeType.boss,
      x: _endX,
      y: 0.5,
      connections: [],
    ));

    // Generate connections between adjacent columns
    _generateConnections(nodes);

    return GameMap(
      mapNumber: mapNumber,
      nodes: nodes,
      currentNodeId: nodes.first.id,
      armyColumn: -2.0,
    );
  }

  /// Generate well-spaced y positions for nodes in a column.
  static List<double> _spreadYPositions(int count) {
    final positions = <double>[];
    const minY = 0.12;
    const maxY = 0.88;
    const minDistance = 0.13;

    for (int i = 0; i < count; i++) {
      double y;
      int attempts = 0;
      do {
        y = minY + _random.nextDouble() * (maxY - minY);
        attempts++;
      } while (
          attempts < 80 && positions.any((p) => (p - y).abs() < minDistance));
      positions.add(y);
    }
    positions.sort();
    return positions;
  }

  /// Connect nodes between adjacent columns based on proximity.
  static void _generateConnections(List<MapNode> nodes) {
    for (int col = 0; col < 7; col++) {
      final currentCol = nodes.where((n) => n.column == col).toList();
      final nextCol = nodes.where((n) => n.column == col + 1).toList();

      // Each node connects to 1-2 closest nodes in the next column
      for (final node in currentCol) {
        final sorted = List<MapNode>.from(nextCol)
          ..sort(
              (a, b) => (a.y - node.y).abs().compareTo((b.y - node.y).abs()));

        final connectCount = 1 + _random.nextInt(2); // 1-2 connections
        for (int i = 0; i < connectCount && i < sorted.length; i++) {
          _addBidirectional(node, sorted[i]);
        }
      }

      // Ensure every next-column node has at least one incoming connection
      for (final next in nextCol) {
        final hasIncoming =
            currentCol.any((n) => n.connections.contains(next.id));
        if (!hasIncoming) {
          final closest = currentCol.reduce((a, b) =>
              (a.y - next.y).abs() < (b.y - next.y).abs() ? a : b);
          _addBidirectional(closest, next);
        }
      }

      // Ensure every current-column node has at least one forward connection
      for (final curr in currentCol) {
        final hasForward =
            nextCol.any((n) => curr.connections.contains(n.id));
        if (!hasForward) {
          final closest = nextCol.reduce((a, b) =>
              (a.y - curr.y).abs() < (b.y - curr.y).abs() ? a : b);
          _addBidirectional(curr, closest);
        }
      }

      // Extra connections (~20% of nodes get one more link)
      for (final node in currentCol) {
        if (_random.nextInt(100) >= 40) continue; // 40% chance per node
        final sorted = List<MapNode>.from(nextCol)
          ..sort((a, b) =>
              (a.y - node.y).abs().compareTo((b.y - node.y).abs()));
        // Connect to the next closest node not already connected
        for (final candidate in sorted) {
          if (!node.connections.contains(candidate.id)) {
            _addBidirectional(node, candidate);
            break;
          }
        }
      }
    }
  }

  static void _addBidirectional(MapNode a, MapNode b) {
    if (!a.connections.contains(b.id)) a.connections.add(b.id);
    if (!b.connections.contains(a.id)) b.connections.add(a.id);
  }

  static NodeType _randomNodeType(int mapNumber) {
    final roll = _random.nextInt(100);
    if (roll < 50) return NodeType.combat;
    if (roll < 62) return NodeType.treasure;
    if (roll < 74) return NodeType.event;
    if (roll < 84) return NodeType.rest;
    return NodeType.shop;
  }

  static double advanceArmy(
      double currentArmyColumn, DifficultyLevel difficulty) {
    final speed = GameConstants.armySpeed[difficulty.name] ?? 2.0;
    return currentArmyColumn + (1.0 / speed);
  }
}
