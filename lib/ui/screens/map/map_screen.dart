import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/map_backgrounds.dart';
import '../../../data/mutator_data.dart';
import '../../../models/enums.dart';
import '../../../models/map_node.dart';
import '../../../providers/game_state_provider.dart';
import '../../../services/progression_service.dart';
import '../../../services/scouting_service.dart';
import '../../widgets/audio_controls.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showMutatorAnnouncement());
  }

  void _showMutatorAnnouncement() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    if (gameState.currentMapNumber != 1) return;
    if (gameState.mapsCompletedThisRun > 0) return;

    final mutator = getMutatorById(gameState.activeMutator);
    if (mutator == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(child: Text(mutator.name)),
          ],
        ),
        content: Text(mutator.description),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Begin!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    // Safety: if army is somehow past the player on map load, push it back
    final notifier = ref.read(gameStateProvider.notifier);
    if (notifier.isArmyCatching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.defeatArmy();
      });
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Map ${gameState.currentMapNumber} of 8'),
        actions: [
          const AudioMuteButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${gameState.gold}g',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Compact party HP bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: gameState.party.map((c) {
                return Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          Text(
                            c.name.split(' ').first,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Lv ${c.level}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.amber[300],
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (c.isAlive) ...[
                            LinearProgressIndicator(
                              value: c.currentHp / c.totalMaxHp,
                              color: c.currentHp / c.totalMaxHp > 0.5
                                  ? Colors.green
                                  : c.currentHp / c.totalMaxHp > 0.25
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            Text(
                              '${c.currentHp}/${c.totalMaxHp}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ] else
                            Text(
                              'KO',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          const SizedBox(height: 2),
                          // XP bar
                          LinearProgressIndicator(
                            value: c.xp / ProgressionService.xpForLevel(c.level),
                            backgroundColor: Colors.grey[800],
                            color: Colors.blue[300],
                            minHeight: 3,
                          ),
                          Text(
                            '${c.xp}/${ProgressionService.xpForLevel(c.level)} XP',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: Colors.blue[200],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Map area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mapWidth = constraints.maxWidth;
                final mapHeight = constraints.maxHeight;
                final map = gameState.currentMap;
                final currentNode = map.currentNode;
                const nodeRadius = 22.0;

                final bgPath = mapBackground(gameState.currentMapNumber);

                return ClipRect(
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.asset(
                          bgPath,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1A2A1A)),
                        ),
                      ),
                      // Dim overlay for readability
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                      // Connections, army wave overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapPainter(
                            nodes: map.nodes,
                            armyColumn: map.armyColumn,
                            currentNodeId: currentNode.id,
                          ),
                        ),
                      ),
                      // Tappable node circles
                      for (final node in map.nodes)
                        Positioned(
                          left: node.x * mapWidth - nodeRadius,
                          top: node.y * mapHeight - nodeRadius,
                          child: _NodeWidget(
                            node: node,
                            currentNode: currentNode,
                            radius: nodeRadius,
                            onTap: currentNode.connections.contains(node.id) &&
                                    node.id != currentNode.id
                                ? () => _moveToNode(node)
                                : null,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _moveToNode(MapNode node) {
    final notifier = ref.read(gameStateProvider.notifier);

    // Safety: if army was already past player before this move, push it back
    if (notifier.isArmyCatching) {
      notifier.defeatArmy();
    }

    notifier.moveToNode(node.id);

    // Check if army caught up during this move
    if (notifier.isArmyCatching) {
      context.go('/combat');
      return;
    }

    switch (node.type) {
      case NodeType.combat:
        context.go('/combat');
      case NodeType.shop:
        context.go('/shop');
      case NodeType.rest:
        context.go('/rest');
      case NodeType.treasure:
        context.go('/treasure');
      case NodeType.boss:
        context.go('/combat');
      case NodeType.event:
        context.go('/event');
      case NodeType.start:
        break;
      case NodeType.recruit:
        context.go('/recruit');
    }
  }
}

// ---------------------------------------------------------------------------
// Node widget (tappable circle with icon)
// ---------------------------------------------------------------------------
class _NodeWidget extends StatelessWidget {
  final MapNode node;
  final MapNode currentNode;
  final double radius;
  final VoidCallback? onTap;

  const _NodeWidget({
    required this.node,
    required this.currentNode,
    required this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = node.id == currentNode.id;
    final isReachable = onTap != null;
    final showType =
        node.visited || node.scouted || node.type == NodeType.boss;

    Color bgColor;
    Color borderColor;
    double borderWidth;

    if (isCurrent) {
      bgColor = const Color(0xFFB8860B);
      borderColor = const Color(0xFFFFD54F);
      borderWidth = 3;
    } else if (node.visited) {
      bgColor = const Color(0x99546E7A);
      borderColor = const Color(0xFF78909C);
      borderWidth = 1.5;
    } else if (isReachable) {
      bgColor = const Color(0xFF1B5E20);
      borderColor = const Color(0xFF69F0AE);
      borderWidth = 2.5;
    } else {
      bgColor = const Color(0xAA37474F);
      borderColor = const Color(0xFF616161);
      borderWidth = 1;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.6),
                blurRadius: 14,
                spreadRadius: 3,
              ),
            if (isReachable)
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: Text(
            showType ? ScoutingService.nodeTypeIcon(node.type) : '?',
            style: TextStyle(
              fontSize: radius * 0.7,
              color: !showType ? const Color(0xFF9E9E9E) : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map painter: background, army wave, connection lines
// ---------------------------------------------------------------------------
class _MapPainter extends CustomPainter {
  final List<MapNode> nodes;
  final double armyColumn;
  final String currentNodeId;

  _MapPainter({
    required this.nodes,
    required this.armyColumn,
    required this.currentNodeId,
  });

  /// Convert a column value (0-7 scale) to a fraction of the map width.
  static double _colToFrac(double column) {
    return 0.07 + (column / 7.0) * 0.86;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawArmy(canvas, size);
    _drawConnections(canvas, size);
  }

  // -- Army wave ------------------------------------------------------------
  void _drawArmy(Canvas canvas, Size size) {
    final armyX = _colToFrac(armyColumn) * size.width;
    if (armyX <= 0) return;
    final cx = armyX.clamp(0.0, size.width); // clamped x

    // 1. Red gradient overlay
    final rect = Rect.fromLTWH(0, 0, cx, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0x60CC0000),
            Color(0x45CC0000),
            Color(0x20CC0000),
            Color(0x00CC0000),
          ],
          stops: const [0.0, 0.6, 0.85, 1.0],
        ).createShader(rect),
    );

    if (cx < 6) return;

    // 2. Wavy leading edge
    final edgePaint = Paint()
      ..color = const Color(0x70FF2200)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final edge = Path()..moveTo(cx, 0);
    for (double y = 0; y <= size.height; y += 3) {
      edge.lineTo(cx + sin(y * 0.08) * 8 + sin(y * 0.17) * 4, y);
    }
    canvas.drawPath(edge, edgePaint);

    // 3. Spear points along the leading edge
    final spearPaint = Paint()
      ..color = const Color(0x50FF3300)
      ..style = PaintingStyle.fill;
    for (double y = 14; y < size.height - 8; y += 16) {
      final bx = cx + sin(y * 0.08) * 8 + sin(y * 0.17) * 4;
      canvas.drawPath(
        Path()
          ..moveTo(bx + 7, y)
          ..lineTo(bx, y - 5)
          ..lineTo(bx, y + 5)
          ..close(),
        spearPaint,
      );
    }

    // 4. Banner flags scattered inside the army zone
    if (cx > 50) {
      final polePaint = Paint()
        ..color = const Color(0x20900000)
        ..strokeWidth = 1.2;
      final flagPaint = Paint()
        ..color = const Color(0x28CC0000)
        ..style = PaintingStyle.fill;

      for (double bx = 30; bx < cx - 40; bx += 60) {
        for (double by = 40; by < size.height - 30; by += 50) {
          final ox = bx + sin(by * 0.7) * 10;
          final oy = by + cos(bx * 0.5) * 8;
          if (ox >= cx - 25 || ox < 10) continue;
          canvas.drawLine(
              Offset(ox, oy - 10), Offset(ox, oy + 12), polePaint);
          canvas.drawPath(
            Path()
              ..moveTo(ox, oy - 10)
              ..lineTo(ox + 11, oy - 4)
              ..lineTo(ox, oy + 2)
              ..close(),
            flagPaint,
          );
        }
      }

      // "THE ARMY" label — only if there's enough room
      final tp = TextPainter(
        text: const TextSpan(
          text: '⚔ THE ARMY ⚔',
          style: TextStyle(
            color: Color(0x70FF4444),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (cx > tp.width + 20) {
        tp.paint(
          canvas,
          Offset(
            (cx / 2 - tp.width / 2).clamp(8.0, cx - tp.width - 8),
            10,
          ),
        );
      }
    }
  }

  // -- Connection lines -----------------------------------------------------
  void _drawConnections(Canvas canvas, Size size) {
    for (final node in nodes) {
      final from = Offset(node.x * size.width, node.y * size.height);

      for (final connId in node.connections) {
        final conn = nodes.firstWhere((n) => n.id == connId);
        // Draw forward connections only to avoid doubling
        if (conn.column <= node.column) continue;

        final to = Offset(conn.x * size.width, conn.y * size.height);

        final touchesCurrent =
            node.id == currentNodeId || conn.id == currentNodeId;
        final bothVisited = node.visited && conn.visited;

        final paint = Paint()
          ..strokeWidth = touchesCurrent ? 2.5 : 1.5
          ..style = PaintingStyle.stroke
          ..color = touchesCurrent
              ? const Color(0x80FFCC00)
              : bothVisited
                  ? const Color(0x50AAAAAA)
                  : const Color(0x35CCAA66);

        canvas.drawLine(from, to, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
