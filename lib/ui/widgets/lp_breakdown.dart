import 'package:flutter/material.dart';
import '../../services/legacy_point_calculator.dart';

class LpBreakdown extends StatelessWidget {
  final LegacyPointResult result;

  const LpBreakdown({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legacy Points Earned',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _row('Maps completed', '+${result.basePoints}'),
            if (result.bossBonus > 0) _row('Bosses slain', '+${result.bossBonus}'),
            if (result.enemyTypeBonus > 0)
              _row('Enemy types discovered', '+${result.enemyTypeBonus}'),
            if (result.victoryBonus > 0) _row('Victory!', '+${result.victoryBonus}'),
            if (result.difficultyMultiplier != 1.0)
              _row('Difficulty bonus', 'x${result.difficultyMultiplier}'),
            const Divider(),
            _row(
              'Total',
              '+${result.totalPoints} LP',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }
}
