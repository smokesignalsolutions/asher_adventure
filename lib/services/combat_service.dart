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
    // Reset combat-only buffs
    for (final char in party) {
      char.combatAttackMultiplier = 1.0;
      char.combatDefenseMultiplier = 1.0;
      char.combatDefenseBonus = 0;
    }

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

  static int calculateDamage(int attackStat, int abilityDamage, int targetDefense, {bool targetVulnerable = false, bool chaotic = false, double damageMultiplier = 1.0}) {
    // Base damage = attack + ability damage - defense/2
    // Minimum 1 damage
    final raw = attackStat + abilityDamage - (targetDefense ~/ 2);
    // Chaotic: ±25% variance, Normal: ±20% variance
    final variance = chaotic
        ? 0.75 + _random.nextDouble() * 0.50
        : 0.8 + _random.nextDouble() * 0.4;
    var result = max(1, (raw * variance).round());
    // Vulnerable enemies take 5-15% extra damage
    if (targetVulnerable) {
      final bonus = 1.05 + _random.nextDouble() * 0.10;
      result = (result * bonus).round();
    }
    result = (result * damageMultiplier).round();
    return max(1, result);
  }

  static int calculateHealing(int magicStat, int abilityHeal, {double healingMultiplier = 1.0}) {
    // Heal amount = magic/2 + ability heal amount (stored as negative damage)
    final raw = (magicStat ~/ 2) + abilityHeal.abs();
    final variance = 0.9 + _random.nextDouble() * 0.2;
    return max(1, (raw * variance * healingMultiplier).round());
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

  /// Chaotic bounce: hit a random enemy with the same ability
  static String executeChaoticBounce(Character attacker, Ability ability, Enemy target) {
    final damage = calculateDamage(
      attacker.totalAttack, ability.damage, target.effectiveDefense,
      targetVulnerable: target.isVulnerable, chaotic: true,
    );
    target.currentHp = max(0, target.currentHp - damage);
    var result = 'Chaos Bolt bounces to ${target.name} for $damage damage!';
    if (!target.isAlive) result += ' ${target.name} is defeated!';
    return result;
  }

  /// Dark Pact: sacrifice 15-25% HP, deal 1.5x that to all enemies
  static String executeDarkPact(Character attacker, List<Enemy> aliveEnemies) {
    final sacrificePercent = 0.15 + _random.nextDouble() * 0.10;
    final hpCost = (attacker.totalMaxHp * sacrificePercent).round();
    attacker.currentHp = max(1, attacker.currentHp - hpCost);
    final damagePerEnemy = (hpCost * 1.5).round();

    final logs = <String>['${attacker.name} sacrifices $hpCost HP with Dark Pact!'];
    for (final enemy in aliveEnemies) {
      enemy.currentHp = max(0, enemy.currentHp - damagePerEnemy);
      logs.add('${enemy.name} takes $damagePerEnemy damage!');
      if (!enemy.isAlive) logs.add('${enemy.name} is defeated!');
    }
    return logs.join(' ');
  }

  /// Returns a log message describing what happened
  static String executeAllyTurn(
    Character attacker,
    Ability ability,
    dynamic target, { // Character or Enemy
    double healingMultiplier = 1.0,
  }) {
    if (!ability.isBasicAttack) {
      ability.isAvailable = false;
    }

    final logs = <String>[];

    if (ability.damage > 0) {
      // --- OFFENSIVE: damage + optional debuffs/drain/vulnerability ---
      final Enemy enemyTarget = target as Enemy;

      // ChainCast: AOE bonus, single-target penalty
      double chainCastMult = 1.0;
      if (attacker.equipment[EquipmentSlot.weapon]?.specialEffect == SpecialEffect.chainCast) {
        if (ability.targetType == AbilityTarget.allEnemies) {
          chainCastMult = 1.5;
        } else if (ability.targetType == AbilityTarget.singleEnemy) {
          chainCastMult = 0.7;
        }
      }

      final damage = calculateDamage(
        attacker.totalAttack, ability.damage, enemyTarget.effectiveDefense,
        targetVulnerable: enemyTarget.isVulnerable,
        chaotic: ability.chaotic,
        damageMultiplier: chainCastMult,
      );
      enemyTarget.currentHp = max(0, enemyTarget.currentHp - damage);
      logs.add('${attacker.name} uses ${ability.name} on ${enemyTarget.name} for $damage damage!');

      // Vampiric: heal for 25% of damage dealt
      if (attacker.equipment[EquipmentSlot.weapon]?.specialEffect == SpecialEffect.vampiric && damage > 0) {
        final vampHeal = (damage * 0.25).round();
        attacker.currentHp = min(attacker.totalMaxHp, attacker.currentHp + vampHeal);
        logs.add('Drains $vampHeal HP!');
      }

      if (ability.lifeDrain) {
        final healAmount = (damage * 0.5).round();
        attacker.currentHp = min(attacker.totalMaxHp, attacker.currentHp + healAmount);
        logs.add('Drains $healAmount HP!');
      }
      if (ability.appliesVulnerability && !enemyTarget.isVulnerable) {
        enemyTarget.isVulnerable = true;
        logs.add('${enemyTarget.name} is weakened!');
      }
      if (ability.enemyAttackDebuffPercent > 0) {
        enemyTarget.attackMultiplier *= (1 - ability.enemyAttackDebuffPercent / 100);
        logs.add('${enemyTarget.name} attack reduced by ${ability.enemyAttackDebuffPercent}%!');
      }
      if (ability.enemyDefenseDebuffPercent > 0) {
        enemyTarget.defenseMultiplier *= (1 - ability.enemyDefenseDebuffPercent / 100);
        logs.add('${enemyTarget.name} defense reduced by ${ability.enemyDefenseDebuffPercent}%!');
      }
      if (ability.stunChance > 0 && enemyTarget.isAlive && !enemyTarget.isStunned) {
        if (_random.nextInt(100) < ability.stunChance) {
          enemyTarget.isStunned = true;
          logs.add('${enemyTarget.name} is stunned!');
        }
      }
      if (ability.tempEnemyAttackDebuffPercent > 0) {
        enemyTarget.tempAttackMultiplier = 1 - ability.tempEnemyAttackDebuffPercent / 100;
        enemyTarget.tempAttackDebuffTurns = ability.debuffDuration;
        logs.add('${enemyTarget.name} attack reduced by ${ability.tempEnemyAttackDebuffPercent}% for ${ability.debuffDuration} turns!');
      }
      if (!enemyTarget.isAlive) {
        logs.add('${enemyTarget.name} is defeated!');
      }
    } else {
      // --- SUPPORTIVE: heal + optional buffs ---
      final Character charTarget = target as Character;

      // Heal
      if (ability.damage < 0) {
        final healStat = ability.healScalesWithDefense ? attacker.totalDefense : attacker.totalMagic;
        final healAmount = calculateHealing(healStat, ability.damage, healingMultiplier: healingMultiplier);
        charTarget.currentHp = min(charTarget.totalMaxHp, charTarget.currentHp + healAmount);
        logs.add('${attacker.name} uses ${ability.name} on ${charTarget.name} for $healAmount healing!');
      } else if (ability.healPercentMaxHp > 0) {
        final healAmount = (charTarget.totalMaxHp * ability.healPercentMaxHp / 100 * healingMultiplier).round();
        charTarget.currentHp = min(charTarget.totalMaxHp, charTarget.currentHp + healAmount);
        logs.add('${attacker.name} uses ${ability.name}! ${charTarget.name} heals $healAmount HP!');
      } else {
        logs.add('${attacker.name} uses ${ability.name}!');
      }

      // Buffs
      if (ability.defenseBuffPercent > 0) {
        charTarget.combatDefenseMultiplier += ability.defenseBuffPercent / 100;
        logs.add('${charTarget.name} defense +${ability.defenseBuffPercent}%!');
      }
      if (ability.attackBuffPercent > 0) {
        charTarget.combatAttackMultiplier += ability.attackBuffPercent / 100;
        logs.add('${charTarget.name} attack +${ability.attackBuffPercent}%!');
      }
      if (ability.grantCasterDefensePercent > 0) {
        final bonus = (attacker.totalDefense * ability.grantCasterDefensePercent / 100).round();
        charTarget.combatDefenseBonus += bonus;
        logs.add('${charTarget.name} defense +$bonus!');
      }
    }

    return logs.join(' ');
  }

  /// Enemy AI: pick a random alive ally to attack with basic attack
  static String executeEnemyTurn(Enemy enemy, List<Character> allies, {double enemyDamageMultiplier = 1.0}) {
    // Check stun
    if (enemy.isStunned) {
      enemy.isStunned = false;
      return '${enemy.name} is stunned and loses their turn!';
    }

    // Tick down temporary debuffs
    final logs = <String>[];
    if (enemy.tempAttackDebuffTurns > 0) {
      enemy.tempAttackDebuffTurns--;
      if (enemy.tempAttackDebuffTurns <= 0) {
        enemy.tempAttackMultiplier = 1.0;
        logs.add('${enemy.name}\'s attack returns to normal.');
      }
    }

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
      logs.add('${enemy.name} uses ${ability.name} and heals for $healAmount!');
      return logs.join(' ');
    }

    if (ability.targetType == AbilityTarget.allEnemies) {
      // Hit all allies
      for (final ally in aliveAllies) {
        final damage = calculateDamage(enemy.effectiveAttack, ability.damage, ally.totalDefense, damageMultiplier: enemyDamageMultiplier);
        ally.currentHp = max(0, ally.currentHp - damage);
        logs.add('${ally.name} takes $damage damage');

        // Thorns: reflect 15% damage back
        final allyOffhand = ally.equipment[EquipmentSlot.offhand];
        if (allyOffhand?.specialEffect == SpecialEffect.thorns && damage > 0) {
          final thornsDamage = (damage * 0.15).round();
          if (thornsDamage > 0) {
            enemy.currentHp -= thornsDamage;
            logs.add('Thorns reflect $thornsDamage!');
          }
        }

        if (!ally.isAlive) logs.add('${ally.name} falls!');
      }
      if (!ability.isBasicAttack) ability.isAvailable = false;
      return [if (logs.isNotEmpty) ...logs, '${enemy.name} uses ${ability.name}!'].join(' ');
    }

    // Single target
    final target = aliveAllies[_random.nextInt(aliveAllies.length)];
    final damage = calculateDamage(enemy.effectiveAttack, ability.damage, target.totalDefense, damageMultiplier: enemyDamageMultiplier);
    target.currentHp = max(0, target.currentHp - damage);
    if (!ability.isBasicAttack) ability.isAvailable = false;
    logs.add('${enemy.name} uses ${ability.name} on ${target.name} for $damage damage!');

    // Thorns: reflect 15% damage back
    final offhand = target.equipment[EquipmentSlot.offhand];
    if (offhand?.specialEffect == SpecialEffect.thorns && damage > 0) {
      final thornsDamage = (damage * 0.15).round();
      if (thornsDamage > 0) {
        enemy.currentHp -= thornsDamage;
        logs.add('Thorns reflect $thornsDamage!');
      }
    }

    if (!target.isAlive) logs.add('${target.name} falls!');
    return logs.join(' ');
  }
}
