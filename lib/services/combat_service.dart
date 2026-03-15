import 'dart:math';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/combat_state.dart';
import '../models/enemy.dart';
import '../models/enums.dart';

class CombatService {
  static final _random = Random();

  static double rollInitiative(double speedModifier) {
    // Roll 1.00 to 20.00 + modifier
    final roll = (_random.nextDouble() * 19.0 + 1.0);
    // Round to 2 decimal places
    final rounded = (roll * 100).roundToDouble() / 100;
    return rounded + speedModifier;
  }

  static CombatState initCombat(List<Character> party, List<Enemy> enemies) {
    final turnOrder = buildGroupedTurnOrder(party, enemies);

    return CombatState(
      allies: party,
      enemies: enemies,
      turnOrder: turnOrder,
      combatLog: ['Combat begins!'],
    );
  }

  /// Build turn order with grouped sides: all allies then all enemies
  /// (or vice versa). Which side goes first is decided by comparing
  /// the best initiative roll from each side.
  static List<CombatantEntry> buildGroupedTurnOrder(
      List<Character> party, List<Enemy> enemies) {
    final allyEntries = <CombatantEntry>[];
    final enemyEntries = <CombatantEntry>[];

    for (final char in party) {
      if (char.isAlive) {
        allyEntries.add(CombatantEntry(
          id: char.id,
          name: char.name,
          isAlly: true,
          initiative: rollInitiative(char.totalSpeed.toDouble()),
        ));
      }
    }

    for (final enemy in enemies) {
      if (enemy.isAlive) {
        enemyEntries.add(CombatantEntry(
          id: enemy.id,
          name: enemy.name,
          isAlly: false,
          initiative: rollInitiative(enemy.speed.toDouble()),
        ));
      }
    }

    // Sort within each group by initiative (highest first)
    allyEntries.sort((a, b) => b.initiative.compareTo(a.initiative));
    enemyEntries.sort((a, b) => b.initiative.compareTo(a.initiative));

    // Best roll from each side decides which group goes first
    final bestAlly = allyEntries.isEmpty ? 0.0 : allyEntries.first.initiative;
    final bestEnemy = enemyEntries.isEmpty ? 0.0 : enemyEntries.first.initiative;

    if (bestAlly >= bestEnemy) {
      return [...allyEntries, ...enemyEntries];
    } else {
      return [...enemyEntries, ...allyEntries];
    }
  }

  static int calculateDamage(int attackStat, int abilityDamage, int targetDefense) {
    // Base damage = attack + ability damage - defense/2
    // Minimum 1 damage
    final raw = attackStat + abilityDamage - (targetDefense ~/ 2);
    // Add some variance: ±20%
    final variance = 0.8 + _random.nextDouble() * 0.4;
    return max(1, (raw * variance).round());
  }

  static int calculateHealing(int magicStat, int abilityHeal) {
    // Heal amount = magic/2 + ability heal amount (stored as negative damage)
    final raw = (magicStat ~/ 2) + abilityHeal.abs();
    final variance = 0.9 + _random.nextDouble() * 0.2;
    return max(1, (raw * variance).round());
  }

  static bool tryRefreshAbility(Ability ability) {
    if (ability.isBasicAttack) return true; // Always available
    final roll = _random.nextInt(100);
    return roll < ability.refreshChance;
  }

  static void refreshAbilities(List<Ability> abilities) {
    for (int i = 0; i < abilities.length; i++) {
      if (!abilities[i].isAvailable && !abilities[i].isBasicAttack) {
        if (tryRefreshAbility(abilities[i])) {
          abilities[i] = abilities[i].copyWith(isAvailable: true);
        }
      }
    }
  }

  /// Returns a log message describing what happened
  static String executeAllyTurn(
    Character attacker,
    Ability ability,
    dynamic target, // Character or Enemy
  ) {
    if (ability.damage < 0) {
      // Healing ability
      final Character healTarget = target as Character;
      final healAmount = calculateHealing(attacker.totalMagic, ability.damage);
      healTarget.currentHp = min(healTarget.totalMaxHp, healTarget.currentHp + healAmount);
      if (!ability.isBasicAttack) {
        // Mark ability as used (needs refresh)
        ability.isAvailable = false;
      }
      return '${attacker.name} uses ${ability.name} on ${healTarget.name} for $healAmount healing!';
    } else {
      // Damage ability
      final Enemy enemyTarget = target as Enemy;
      final damage = calculateDamage(attacker.totalAttack, ability.damage, enemyTarget.defense);
      enemyTarget.currentHp = max(0, enemyTarget.currentHp - damage);
      if (!ability.isBasicAttack) {
        ability.isAvailable = false;
      }
      final result = '${attacker.name} uses ${ability.name} on ${enemyTarget.name} for $damage damage!';
      if (!enemyTarget.isAlive) {
        return '$result ${enemyTarget.name} is defeated!';
      }
      return result;
    }
  }

  /// Enemy AI: pick a random alive ally to attack with basic attack
  static String executeEnemyTurn(Enemy enemy, List<Character> allies) {
    final aliveAllies = allies.where((a) => a.isAlive).toList();
    if (aliveAllies.isEmpty) return '${enemy.name} has no targets.';

    // Pick a random ability (prefer basic attack, sometimes use specials)
    final availableAbilities = enemy.abilities.where((a) => a.isAvailable).toList();
    final ability = availableAbilities[_random.nextInt(availableAbilities.length)];

    if (ability.damage < 0) {
      // Self heal
      final healAmount = calculateHealing(enemy.magic, ability.damage);
      enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healAmount);
      if (!ability.isBasicAttack) ability.isAvailable = false;
      return '${enemy.name} uses ${ability.name} and heals for $healAmount!';
    }

    if (ability.targetType == AbilityTarget.allEnemies) {
      // Hit all allies
      final logs = <String>[];
      for (final ally in aliveAllies) {
        final damage = calculateDamage(enemy.attack, ability.damage, ally.totalDefense);
        ally.currentHp = max(0, ally.currentHp - damage);
        logs.add('${ally.name} takes $damage damage');
        if (!ally.isAlive) logs.add('${ally.name} falls!');
      }
      if (!ability.isBasicAttack) ability.isAvailable = false;
      return '${enemy.name} uses ${ability.name}! ${logs.join('. ')}';
    }

    // Single target
    final target = aliveAllies[_random.nextInt(aliveAllies.length)];
    final damage = calculateDamage(enemy.attack, ability.damage, target.totalDefense);
    target.currentHp = max(0, target.currentHp - damage);
    if (!ability.isBasicAttack) ability.isAvailable = false;
    final result = '${enemy.name} uses ${ability.name} on ${target.name} for $damage damage!';
    if (!target.isAlive) return '$result ${target.name} falls!';
    return result;
  }
}
