import 'map_node.dart';

class GameMap {
  final int mapNumber;
  final List<MapNode> nodes;
  double armyColumn; // which column the army has reached
  String currentNodeId;

  GameMap({
    required this.mapNumber,
    required this.nodes,
    this.armyColumn = -2.0,
    required this.currentNodeId,
  });

  MapNode get currentNode => nodes.firstWhere((n) => n.id == currentNodeId);

  MapNode nodeById(String id) => nodes.firstWhere((n) => n.id == id);

  List<MapNode> get currentConnections =>
      currentNode.connections.map((id) => nodeById(id)).toList();

  List<MapNode> nodesInColumn(int col) =>
      nodes.where((n) => n.column == col).toList();

  Map<String, dynamic> toJson() => {
    'mapNumber': mapNumber,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'armyColumn': armyColumn,
    'currentNodeId': currentNodeId,
  };

  factory GameMap.fromJson(Map<String, dynamic> json) => GameMap(
    mapNumber: json['mapNumber'],
    nodes: (json['nodes'] as List)
        .map((n) => MapNode.fromJson(n))
        .toList(),
    armyColumn: (json['armyColumn'] as num).toDouble(),
    currentNodeId: json['currentNodeId'],
  );
}
