import 'enums.dart';

class MapNode {
  final String id;
  final int column;
  final int row;
  final NodeType type;
  final double x; // 0.0 to 1.0 horizontal position
  final double y; // 0.0 to 1.0 vertical position
  final List<String> connections; // ids of connected nodes
  bool visited;
  bool scouted; // whether the player has revealed this node's type

  MapNode({
    required this.id,
    required this.column,
    required this.row,
    required this.type,
    required this.x,
    required this.y,
    required this.connections,
    this.visited = false,
    this.scouted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'column': column,
    'row': row,
    'type': type.index,
    'x': x,
    'y': y,
    'connections': connections,
    'visited': visited,
    'scouted': scouted,
  };

  factory MapNode.fromJson(Map<String, dynamic> json) => MapNode(
    id: json['id'],
    column: json['column'],
    row: json['row'],
    type: NodeType.values[json['type']],
    x: (json['x'] as num?)?.toDouble() ?? (0.07 + (json['column'] as int) / 7.0 * 0.86),
    y: (json['y'] as num?)?.toDouble() ?? 0.5,
    connections: List<String>.from(json['connections']),
    visited: json['visited'] ?? false,
    scouted: json['scouted'] ?? false,
  );
}
