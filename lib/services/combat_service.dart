import 'dart:math';
import '../data/class_data.dart';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/combat_state.dart';
import '../models/enemy.dart';
import '../models/enums.dart';

class CombatService {
  static final _random = Random();

  static double rollInitiative(double classModifier, double speed) {
    // Roll 1.00 to 20.00 + class modifier + speed/4
    final roll = (_random.nextDouble() * 19.0 + 1.0);
    final rounded = (roll * 100).roundToDouble() / 100;
    return rounded + classModifier + speed / 4;
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
          initiative: rollInitiative(
            classDefinitions[char.characterClass]?.initiativeModifier ?? 0.0,
            char.totalSpeed.toDouble(),
          ),
        ));
      }
    }

    for (final enemy in enemies) {
      if (enemy.isAlive) {
        enemyEntries.add(CombatantEntry(
          id: enemy.id,
          name: enemy.name,
          isAlly: false,
          initiative: rollInitiative(0.0, enemy.speed.toDouble()),
        ));
        // Bosses act twice per round
        if (enemy.type == 'boss') {
          enemyEntries.add(CombatantEntry(
            id: enemy.id,
            name: enemy.name,
            isAlly: false,
            initiative: rollInitiative(0.0, enemy.speed.toDouble() * 0.5),
          ));
        }
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

  /// Returns true if this roll is a critical hit. 5% base + speed/2 %.
  static bool rollCrit(int speed) {
    final critChance = 5 + speed ~/ 2;
    return _random.nextInt(100) < critChance;
  }

  static (int damage, bool isCrit) calculateDamage(int attackStat, int abilityDamage, int targetDefense, {bool targetVulnerable = false, bool chaotic = false, double damageMultiplier = 1.0, int attackerSpeed = 0}) {
    final raw = attackStat + abilityDamage - (targetDefense ~/ 2);
    final variance = chaotic
        ? 0.75 + _random.nextDouble() * 0.50
        : 0.8 + _random.nextDouble() * 0.4;
    var result = max(1, (raw * variance).round());
    if (targetVulnerable) {
      final bonus = 1.05 + _random.nextDouble() * 0.10;
      result = (result * bonus).round();
    }
    result = (result * damageMultiplier).round();
    final isCrit = rollCrit(attackerSpeed);
    if (isCrit) result = (result * 1.5).round();
    return (max(1, result), isCrit);
  }

  static (int healing, bool isCrit) calculateHealing(int magicStat, int abilityHeal, {double healingMultiplier = 1.0, int casterSpeed = 0}) {
    final raw = (magicStat ~/ 2) + abilityHeal.abs();
    final variance = 0.9 + _random.nextDouble() * 0.2;
    var result = max(1, (raw * variance * healingMultiplier).round());
    final isCrit = rollCrit(casterSpeed);
    if (isCrit) result = (result * 1.5).round();
    return (result, isCrit);
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
    final useMagic = magicDamageClasses.contains(attacker.characterClass);
    final offensiveStat = useMagic ? attacker.totalMagic : attacker.totalAttack;
    final (damage, isCrit) = calculateDamage(
      offensiveStat, ability.damage, target.effectiveDefense,
      targetVulnerable: target.isVulnerable, chaotic: true,
      attackerSpeed: attacker.totalSpeed,
    );
    target.currentHp = max(0, target.currentHp - damage);
    var result = 'Chaos Bolt bounces to ${target.name} for $damage damage!';
    if (isCrit) result += ' CRIT!';
    if (!target.isAlive) result += ' ${target.name} is defeated!';
    return result;
  }

  /// Dark Pact: sacrifice 15-25% HP, deal 1.5x that to all enemies
  static String executeDarkPact(Character attacker, List<Enemy> aliveEnemies) {
    final sacrificePercent = 0.15 + _random.nextDouble() * 0.10;
    final hpCost = (attacker.totalMaxHp * sacrificePercent).round();
    attacker.currentHp = max(1, attacker.currentHp - hpCost);
    // Scales with HP sacrificed + magic stat, 2.5x multiplier
    final damagePerEnemy = ((hpCost + attacker.totalMagic) * 2.5).round();

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

    if (ability.damage > 0 || target is Enemy) {
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

      final useMagic = magicDamageClasses.contains(attacker.characterClass);
      final offensiveStat = useMagic ? attacker.totalMagic : attacker.totalAttack;
      final (damage, isCrit) = calculateDamage(
        offensiveStat, ability.damage, enemyTarget.effectiveDefense,
        targetVulnerable: enemyTarget.isVulnerable,
        chaotic: ability.chaotic,
        damageMultiplier: chainCastMult,
        attackerSpeed: attacker.totalSpeed,
      );
      enemyTarget.currentHp = max(0, enemyTarget.currentHp - damage);
      logs.add('${attacker.name} uses ${ability.name} on ${enemyTarget.name} for $damage damage!${isCrit ? ' CRIT!' : ''}');

      // Vampiric: heal for 25% of damage dealt
      if (attacker.equipment[EquipmentSlot.weapon]?.specialEffect == SpecialEffect.vampiric && damage > 0) {
        final vampHeal = (damage * 0.25).round();
        attacker.currentHp = min(attacker.totalMaxHp, attacker.currentHp + vampHeal);
        logs.add('Drains $vampHeal HP!');
      }

      if (ability.lifeDrain) {
        final healAmount = damage;
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
        final (healAmount, healCrit) = calculateHealing(healStat, ability.damage, healingMultiplier: healingMultiplier, casterSpeed: attacker.totalSpeed);
        charTarget.currentHp = min(charTarget.totalMaxHp, charTarget.currentHp + healAmount);
        logs.add('${attacker.name} uses ${ability.name} on ${charTarget.name} for $healAmount healing!${healCrit ? ' CRIT!' : ''}');
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
      final (healAmount, _) = calculateHealing(enemy.magic, ability.damage, casterSpeed: enemy.speed);
      enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healAmount);
      if (!ability.isBasicAttack) ability.isAvailable = false;
      logs.add('${enemy.name} uses ${ability.name} and heals for $healAmount!');
      return logs.join(' ');
    }

    if (ability.targetType == AbilityTarget.allEnemies) {
      // Hit all allies
      for (final ally in aliveAllies) {
        var (damage, isCrit) = calculateDamage(enemy.effectiveAttack, ability.damage, ally.totalDefense, damageMultiplier: enemyDamageMultiplier, attackerSpeed: enemy.speed);
        var log = '${ally.name} takes $damage damage${isCrit ? ' (CRIT!)' : ''}';
        // Shield absorbs damage first
        if (ally.shieldHp > 0) {
          final shieldAbsorb = min(damage, ally.shieldHp);
          ally.shieldHp -= shieldAbsorb;
          damage -= shieldAbsorb;
          if (shieldAbsorb > 0) log += ' (Shield -$shieldAbsorb)';
        }
        ally.currentHp = max(0, ally.currentHp - damage);
        logs.add(log);

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
    var (damage, isCrit) = calculateDamage(enemy.effectiveAttack, ability.damage, target.totalDefense, damageMultiplier: enemyDamageMultiplier, attackerSpeed: enemy.speed);
    if (!ability.isBasicAttack) ability.isAvailable = false;
    var log = '${enemy.name} uses ${ability.name} on ${target.name} for $damage damage!${isCrit ? ' CRIT!' : ''}';
    // Shield absorbs damage first
    if (target.shieldHp > 0) {
      final shieldAbsorb = min(damage, target.shieldHp);
      target.shieldHp -= shieldAbsorb;
      damage -= shieldAbsorb;
      if (shieldAbsorb > 0) log += ' (Shield -$shieldAbsorb)';
    }
    target.currentHp = max(0, target.currentHp - damage);
    logs.add(log);

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
