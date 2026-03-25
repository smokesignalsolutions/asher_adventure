import 'package:flutter/material.dart';

import '../../models/ability.dart';
import '../../models/character.dart';
import '../../models/enemy.dart';
import '../../models/enums.dart';
import '../../models/equipment.dart';
import '../../models/status_effect.dart';
import 'character_detail_card.dart';

void showCharacterHelp(BuildContext context, Character character) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(character.name),
      content: SingleChildScrollView(
        child: CharacterDetailCard(character: character),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void showEnemyHelp(BuildContext context, Enemy enemy) {
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final statusLabels = enemy.activeStatusLabels;
      final statusEffects = statusLabels.map((e) => e.$1).toList();
      if (enemy.enrageMultiplier != 1.0) {
        statusEffects.add('ATK x${enemy.enrageMultiplier.toStringAsFixed(2)}');
      }
      if (enemy.baseDefenseMultiplier != 1.0) {
        statusEffects.add('DEF x${enemy.baseDefenseMultiplier.toStringAsFixed(2)}');
      }

      return AlertDialog(
        title: Text(enemy.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HP: ${enemy.currentHp}/${enemy.maxHp}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'ATK: ${enemy.effectiveAttack}   DEF: ${enemy.effectiveDefense}   SPD: ${enemy.speed}   MAG: ${enemy.magic}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'XP Reward: ${enemy.xpReward}   Gold: ${enemy.goldReward}',
                style: theme.textTheme.bodyMedium,
              ),
              if (statusEffects.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Status Effects', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  statusEffects.join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ],
              if (enemy.abilities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Abilities', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ...enemy.abilities.map((ability) {
                  final dmgLabel = ability.damage < 0
                      ? 'Heal: ${-ability.damage}'
                      : ability.damage > 0
                          ? 'Damage: ${ability.damage}'
                          : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${ability.name}${dmgLabel != null ? " ($dmgLabel)" : ""} — ${ability.description}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void showAbilityHelp(BuildContext context, Ability ability) {
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      String targetLabel(AbilityTarget t) {
        switch (t) {
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

      final effects = <String>[];
      if (ability.damage > 0) effects.add('Damage: ${ability.damage}');
      if (ability.damage < 0) effects.add('Healing: ${-ability.damage}');
      if (ability.healPercentMaxHp > 0) {
        effects.add('Heals ${ability.healPercentMaxHp}% of max HP');
      }
      if (ability.lifeDrain) effects.add('Life Drain (heals 50% of damage)');
      for (final fx in ability.appliesStatusEffects) {
        final label = StatusEffect(type: fx.type, duration: fx.duration, magnitude: fx.magnitude).displayName;
        if (fx.chance < 100) {
          effects.add('${fx.chance}% chance: $label${fx.magnitude > 0 ? ' (${fx.magnitude}%)' : ''}');
        } else {
          effects.add('Applies $label${fx.magnitude > 0 ? ' (${fx.magnitude}%)' : ''}');
        }
      }
      if (ability.attackBuffPercent > 0) {
        effects.add('+${ability.attackBuffPercent}% ATK buff');
      }
      if (ability.defenseBuffPercent > 0) {
        effects.add('+${ability.defenseBuffPercent}% DEF buff');
      }
      if (ability.grantCasterDefensePercent > 0) {
        effects.add('Grants ${ability.grantCasterDefensePercent}% of caster DEF');
      }
      if (ability.darkPact) {
        effects.add('Dark Pact (sacrifice HP, deal 1.5x to all enemies)');
      }
      if (ability.chaotic) {
        effects.add('Chaotic (wide variance, 50% bounce chance)');
      }

      return AlertDialog(
        title: Text(ability.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ability.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Target: ${targetLabel(ability.targetType)}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                'Refresh Chance: ${ability.refreshChance}%',
                style: theme.textTheme.bodyMedium,
              ),
              if (effects.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Effects', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ...effects.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('  $e', style: theme.textTheme.bodySmall),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void showNodeHelp(BuildContext context, NodeType nodeType) {
  String name;
  String description;

  switch (nodeType) {
    case NodeType.combat:
      name = 'Combat';
      description = 'Fight a group of enemies. Earn XP and gold for winning.';
    case NodeType.boss:
      name = 'Boss';
      description =
          'A powerful enemy guards the end of the map. Defeat it to advance to the next area.';
    case NodeType.shop:
      name = 'Shop';
      description =
          'Spend gold to buy equipment and items. Gear up your party for tougher fights ahead.';
    case NodeType.rest:
      name = 'Rest';
      description =
          'Take a breather and restore some HP. A safe place to recover between battles.';
    case NodeType.treasure:
      name = 'Treasure';
      description =
          'Discover a treasure chest with gold or equipment inside.';
    case NodeType.event:
      name = 'Event';
      description =
          'A random encounter with choices that can help or hinder your party.';
    case NodeType.start:
      name = 'Start';
      description = 'The beginning of the map. Your adventure starts here.';
    case NodeType.recruit:
      name = 'Recruit';
      description =
          'Find a new adventurer willing to join your party.';
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(name),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void showItemHelp(BuildContext context, Equipment item) {
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      String slotLabel(EquipmentSlot s) {
        switch (s) {
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

      String rarityLabel(Rarity r) {
        return r.name[0].toUpperCase() + r.name.substring(1);
      }

      final bonuses = <String>[];
      if (item.attackBonus != 0) bonuses.add('+${item.attackBonus} ATK');
      if (item.defenseBonus != 0) bonuses.add('+${item.defenseBonus} DEF');
      if (item.hpBonus != 0) bonuses.add('+${item.hpBonus} HP');
      if (item.speedBonus != 0) bonuses.add('+${item.speedBonus} SPD');
      if (item.magicBonus != 0) bonuses.add('+${item.magicBonus} MAG');

      return AlertDialog(
        title: Text(item.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Slot: ${slotLabel(item.slot)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Rarity: ${rarityLabel(item.rarity)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Value: ${item.value} gold',
              style: theme.textTheme.bodyMedium,
            ),
            if (bonuses.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Stat Bonuses', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              ...bonuses.map((b) => Text(
                '  $b',
                style: theme.textTheme.bodySmall,
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
