import 'package:flutter/material.dart';

import '../../models/character.dart';
import '../../models/enums.dart';

class CharacterDetailCard extends StatelessWidget {
  final Character character;
  final bool showAbilities;
  final bool compact;

  const CharacterDetailCard({
    super.key,
    required this.character,
    this.showAbilities = true,
    this.compact = false,
  });

  String _slotLabel(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return 'Weapon';
      case EquipmentSlot.offhand:
        return 'Offhand';
      case EquipmentSlot.armor:
        return 'Armor';
      case EquipmentSlot.helm:
        return 'Helm';
      case EquipmentSlot.ring:
        return 'Ring';
      case EquipmentSlot.amulet:
        return 'Amulet';
    }
  }

  String _equipmentBonuses(dynamic item) {
    final parts = <String>[];
    if (item.attackBonus != 0) parts.add('+${item.attackBonus} ATK');
    if (item.defenseBonus != 0) parts.add('+${item.defenseBonus} DEF');
    if (item.hpBonus != 0) parts.add('+${item.hpBonus} HP');
    if (item.speedBonus != 0) parts.add('+${item.speedBonus} SPD');
    if (item.magicBonus != 0) parts.add('+${item.magicBonus} MAG');
    return parts.isEmpty ? '' : ' (${parts.join(', ')})';
  }

  String _targetLabel(AbilityTarget target) {
    switch (target) {
      case AbilityTarget.singleEnemy:
        return 'Single Enemy';
      case AbilityTarget.allEnemies:
        return 'All Enemies';
      case AbilityTarget.singleAlly:
        return 'Single Ally';
      case AbilityTarget.allAllies:
        return 'All Allies';
      case AbilityTarget.self:
        return 'Self';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = character;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name, class, level
        Text(
          '${c.name} — Lv.${c.level} ${c.characterClass.name[0].toUpperCase()}${c.characterClass.name.substring(1)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Stats
        Text(
          'HP: ${c.currentHp}/${c.totalMaxHp}   ATK: ${c.totalAttack}   DEF: ${c.totalDefense}   SPD: ${c.totalSpeed}   MAG: ${c.totalMagic}',
          style: theme.textTheme.bodyMedium,
        ),

        // Shield HP
        if (c.shieldHp > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Shield: ${c.shieldHp} HP',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.cyan),
          ),
        ],

        const SizedBox(height: 12),

        // Equipment
        Text('Equipment', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        ...EquipmentSlot.values.map((slot) {
          final item = c.equipment[slot];
          final label = _slotLabel(slot);
          if (item != null) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$label: ${item.name}${_equipmentBonuses(item)}',
                style: theme.textTheme.bodySmall,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '$label: \u2014',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }),

        // Abilities
        if (showAbilities && c.abilities.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Abilities', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ...c.abilities.map((ability) {
            final dmgLabel = ability.damage < 0
                ? 'Heal: ${-ability.damage}'
                : ability.damage > 0
                    ? 'Damage: ${ability.damage}'
                    : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ability.name}${dmgLabel != null ? " ($dmgLabel)" : ""}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!compact) ...[
                    Text(
                      ability.description,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Target: ${_targetLabel(ability.targetType)}  |  Refresh: ${ability.refreshChance}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
