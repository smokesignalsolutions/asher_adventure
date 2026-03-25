import 'dart:math';
import '../data/class_data.dart';
import '../data/map_data.dart';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/combat_state.dart';
import '../models/enemy.dart';
import '../models/enums.dart';
import '../models/summon_effect.dart';

class CombatService {
  static final _random = Random();

  static double rollInitiative(double classModifier, double speed) {
    // Roll 1.00 to 20.00 + class modifier + speed/4
    final roll = (_random.nextDouble() * 19.0 + 1.0);
    final rounded = (roll * 100).roundToDouble() / 100;
    return rounded + classModifier + speed / 4;
  }

  static CombatState initCombat(List<Character> party, List<Enemy> enemies, {int? mapDefinitionId}) {
    // Reset combat-only buffs & auto-assign front/back line by class
    for (final char in party) {
      char.combatAttackMultiplier = 1.0;
      char.combatDefenseMultiplier = 1.0;
      char.combatSpeedMultiplier = 1.0;
      char.combatMagicMultiplier = 1.0;
      char.combatDefenseBonus = 0;
      char.activeSummons = [];
      char.lastAttackWasPhysical = null;
      char.isFrontLine = !magicDamageClasses.contains(char.characterClass);
      char.skeletonCount = 0;
    }

    // Apply map-specific class modifiers
    if (mapDefinitionId != null) {
      final mapDef = getMapDefinition(mapDefinitionId);
      for (final char in party) {
        final mod = mapDef.classModifiers[char.characterClass];
        if (mod != null) {
          char.combatAttackMultiplier += mod.atkPercent / 100;
          char.combatDefenseMultiplier += mod.defPercent / 100;
          char.combatSpeedMultiplier += mod.spdPercent / 100;
          char.combatMagicMultiplier += mod.magPercent / 100;
        }
      }
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
    List<Character> party,
    List<Enemy> enemies,
  ) {
    final allyEntries = <CombatantEntry>[];
    final enemyEntries = <CombatantEntry>[];

    for (final char in party) {
      if (char.isAlive) {
        allyEntries.add(
          CombatantEntry(
            id: char.id,
            name: char.name,
            isAlly: true,
            initiative: rollInitiative(
              classDefinitions[char.characterClass]?.initiativeModifier ?? 0.0,
              char.totalSpeed.toDouble(),
            ),
          ),
        );
      }
    }

    for (final enemy in enemies) {
      if (enemy.isAlive) {
        enemyEntries.add(
          CombatantEntry(
            id: enemy.id,
            name: enemy.name,
            isAlly: false,
            initiative: rollInitiative(0.0, enemy.speed.toDouble()),
          ),
        );
        // Bosses act twice per round
        if (enemy.type == 'boss') {
          enemyEntries.add(
            CombatantEntry(
              id: enemy.id,
              name: enemy.name,
              isAlly: false,
              initiative: rollInitiative(0.0, enemy.speed.toDouble() * 0.5),
            ),
          );
        }
      }
    }

    // Sort within each group by initiative (highest first)
    allyEntries.sort((a, b) => b.initiative.compareTo(a.initiative));
    enemyEntries.sort((a, b) => b.initiative.compareTo(a.initiative));

    // Best roll from each side decides which group goes first
    final bestAlly = allyEntries.isEmpty ? 0.0 : allyEntries.first.initiative;
    final bestEnemy = enemyEntries.isEmpty
        ? 0.0
        : enemyEntries.first.initiative;

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

  static (int damage, bool isCrit) calculateDamage(
    int attackStat,
    int abilityDamage,
    int targetDefense, {
    bool targetVulnerable = false,
    bool chaotic = false,
    double damageMultiplier = 1.0,
    int attackerSpeed = 0,
  }) {
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

  static (int healing, bool isCrit) calculateHealing(
    int magicStat,
    int abilityHeal, {
    double healingMultiplier = 1.0,
    int casterSpeed = 0,
  }) {
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
  static String executeChaoticBounce(
    Character attacker,
    Ability ability,
    Enemy target,
  ) {
    final useMagic = magicDamageClasses.contains(attacker.characterClass);
    final offensiveStat = useMagic ? attacker.totalMagic : attacker.totalAttack;
    final (damage, isCrit) = calculateDamage(
      offensiveStat,
      ability.damage,
      target.effectiveDefense,
      targetVulnerable: target.isVulnerable,
      chaotic: true,
      attackerSpeed: attacker.totalSpeed,
    );
    target.currentHp = max(0, target.currentHp - damage);
    var result = 'Chaos Bolt bounces to ${target.name} for $damage damage!';
    if (isCrit) result += ' CRIT!';
    if (!target.isAlive) result += ' ${target.name} is defeated!';
    return result;
  }

  /// Ranger pierce: re-roll damage against another (or same) enemy.
  /// Returns (log message, pierce target ID, damage dealt).
  static ({String log, String targetId, int damage}) executePierce(
    Character attacker,
    Ability ability,
    List<Enemy> aliveEnemies,
  ) {
    if (aliveEnemies.isEmpty) return (log: '', targetId: '', damage: 0);
    final pierceTarget = aliveEnemies[_random.nextInt(aliveEnemies.length)];
    final offensiveStat = attacker.totalAttack;
    final (dmg, isCrit) = calculateDamage(
      offensiveStat,
      ability.damage,
      pierceTarget.effectiveDefense,
      targetVulnerable: pierceTarget.isVulnerable,
      attackerSpeed: attacker.totalSpeed,
    );
    pierceTarget.currentHp = max(0, pierceTarget.currentHp - dmg);
    var result = 'Arrow pierces to ${pierceTarget.name} for $dmg damage!';
    if (isCrit) result += ' CRIT!';
    if (!pierceTarget.isAlive) result += ' ${pierceTarget.name} is defeated!';
    return (log: result, targetId: pierceTarget.id, damage: dmg);
  }

  /// Rogue dual strike: 15% chance to execute ability a second time on a (possibly new) target
  /// Returns (log message, target ID, damage dealt). For single-target abilities, if the
  /// original target dies, a new random target is chosen for the second strike.
  static ({String log, String targetId, int damage}) executeRogueDualStrike(
    Character attacker,
    Ability ability,
    dynamic originalTarget,
    List<Enemy> aliveEnemies,
  ) {
    if (aliveEnemies.isEmpty) return (log: '', targetId: '', damage: 0);

    Enemy secondStrikeTarget;
    if (originalTarget is Enemy) {
      // Single-target ability: if original target still alive, hit it again
      // Otherwise, pick a new random target
      if (originalTarget.isAlive) {
        secondStrikeTarget = originalTarget;
      } else {
        secondStrikeTarget = aliveEnemies[_random.nextInt(aliveEnemies.length)];
      }
    } else {
      // AOE ability: hit a random enemy
      secondStrikeTarget = aliveEnemies[_random.nextInt(aliveEnemies.length)];
    }

    final useMagic = magicDamageClasses.contains(attacker.characterClass);
    final offensiveStat = useMagic ? attacker.totalMagic : attacker.totalAttack;
    final (dmg, isCrit) = calculateDamage(
      offensiveStat,
      ability.damage,
      secondStrikeTarget.effectiveDefense,
      targetVulnerable: secondStrikeTarget.isVulnerable,
      attackerSpeed: attacker.totalSpeed,
    );
    secondStrikeTarget.currentHp = max(0, secondStrikeTarget.currentHp - dmg);

    var result = 'Dual Strike: ${secondStrikeTarget.name} takes $dmg damage!';
    if (isCrit) result += ' CRIT!';
    if (!secondStrikeTarget.isAlive)
      result += ' ${secondStrikeTarget.name} is defeated!';

    return (log: result, targetId: secondStrikeTarget.id, damage: dmg);
  }

  /// Dark Pact: sacrifice 15-25% HP, deal 1.5x that to all enemies
  static String executeDarkPact(Character attacker, List<Enemy> aliveEnemies) {
    final sacrificePercent = 0.15 + _random.nextDouble() * 0.10;
    final hpCost = (attacker.totalMaxHp * sacrificePercent).round();
    attacker.currentHp = max(1, attacker.currentHp - hpCost);
    // Scales with HP sacrificed + magic stat, 2.5x multiplier
    final damagePerEnemy = ((hpCost + attacker.totalMagic) * 2.5).round();

    final logs = <String>[
      '${attacker.name} sacrifices $hpCost HP with Dark Pact!',
    ];
    for (final enemy in aliveEnemies) {
      enemy.currentHp = max(0, enemy.currentHp - damagePerEnemy);
      logs.add('${enemy.name} takes $damagePerEnemy damage!');
      if (!enemy.isAlive) logs.add('${enemy.name} is defeated!');
    }
    return logs.join(' ');
  }

  /// Returns a log message describing what happened
  static (String, int) executeAllyTurn(
    Character attacker,
    Ability ability,
    dynamic target, { // Character or Enemy
    double healingMultiplier = 1.0,
  }) {
    if (!ability.isBasicAttack) {
      ability.isAvailable = false;
    }

    final logs = <String>[];
    int rawDamageDealt = 0;

    if (ability.damage > 0 || target is Enemy) {
      // --- OFFENSIVE: damage + optional debuffs/drain/vulnerability ---
      final Enemy enemyTarget = target as Enemy;

      // ChainCast: AOE bonus, single-target penalty
      double chainCastMult = 1.0;
      if (attacker.equipment[EquipmentSlot.weapon]?.specialEffect ==
          SpecialEffect.chainCast) {
        if (ability.targetType == AbilityTarget.allEnemies) {
          chainCastMult = 1.5;
        } else if (ability.targetType == AbilityTarget.singleEnemy) {
          chainCastMult = 0.7;
        }
      }

      final useMagic = magicDamageClasses.contains(attacker.characterClass);
      final int offensiveStat;
      if (attacker.characterClass == CharacterClass.artificer) {
        // Artificer uses whichever is higher
        offensiveStat = max(attacker.totalAttack, attacker.totalMagic);
      } else {
        offensiveStat = useMagic ? attacker.totalMagic : attacker.totalAttack;
      }

      // Multi-hit: each hit rolls damage separately
      final hits = ability.hitCount;
      for (int hit = 0; hit < hits; hit++) {
        if (!enemyTarget.isAlive) break;
        final (damage, isCrit) = calculateDamage(
          offensiveStat,
          ability.damage,
          enemyTarget.effectiveDefense,
          targetVulnerable: enemyTarget.isVulnerable,
          chaotic: ability.chaotic,
          damageMultiplier: chainCastMult,
          attackerSpeed: attacker.totalSpeed,
        );
        rawDamageDealt += damage;
        enemyTarget.currentHp = max(0, enemyTarget.currentHp - damage);
        if (hits > 1) {
          logs.add(
            '${attacker.name}\'s ${ability.name} hit ${hit + 1}: $damage damage!${isCrit ? ' CRIT!' : ''}',
          );
        } else {
          logs.add(
            '${attacker.name} uses ${ability.name} on ${enemyTarget.name} for $damage damage!${isCrit ? ' CRIT!' : ''}',
          );
        }

        // Vampiric: heal for 25% of damage dealt (per hit)
        if (attacker.equipment[EquipmentSlot.weapon]?.specialEffect ==
                SpecialEffect.vampiric &&
            damage > 0) {
          final vampHeal = (damage * 0.25).round();
          attacker.currentHp = min(
            attacker.totalMaxHp,
            attacker.currentHp + vampHeal,
          );
          logs.add('Drains $vampHeal HP!');
        }

        if (ability.lifeDrain) {
          final healAmount = damage;
          attacker.currentHp = min(
            attacker.totalMaxHp,
            attacker.currentHp + healAmount,
          );
          logs.add('Drains $healAmount HP!');
        }

        // Templar passive: heal for 35% of damage dealt
        if (attacker.characterClass == CharacterClass.templar && damage > 0) {
          final templarHeal = (damage * 0.35).round();
          if (templarHeal > 0) {
            attacker.currentHp = min(
              attacker.totalMaxHp,
              attacker.currentHp + templarHeal,
            );
            logs.add('Holy fervor heals ${attacker.name} for $templarHeal!');
          }
        }

        // Warlock passive: drain 25% of damage dealt as HP
        if (attacker.characterClass == CharacterClass.warlock && damage > 0) {
          final drainHeal = (damage * 0.25).round();
          if (drainHeal > 0) {
            attacker.currentHp = min(
              attacker.totalMaxHp,
              attacker.currentHp + drainHeal,
            );
            logs.add('Dark siphon drains $drainHeal HP!');
          }
        }
      }

      // Debuffs apply once (not per hit)
      if (ability.appliesVulnerability && !enemyTarget.isVulnerable) {
        enemyTarget.isVulnerable = true;
        logs.add('${enemyTarget.name} is weakened!');
      }
      if (ability.enemyAttackDebuffPercent > 0) {
        enemyTarget.attackMultiplier *=
            (1 - ability.enemyAttackDebuffPercent / 100);
        logs.add(
          '${enemyTarget.name} attack reduced by ${ability.enemyAttackDebuffPercent}%!',
        );
      }
      if (ability.enemyDefenseDebuffPercent > 0) {
        enemyTarget.defenseMultiplier *=
            (1 - ability.enemyDefenseDebuffPercent / 100);
        logs.add(
          '${enemyTarget.name} defense reduced by ${ability.enemyDefenseDebuffPercent}%!',
        );
      }
      if (ability.stunChance > 0 &&
          enemyTarget.isAlive &&
          !enemyTarget.isStunned) {
        if (_random.nextInt(100) < ability.stunChance) {
          enemyTarget.isStunned = true;
          logs.add('${enemyTarget.name} is stunned!');
        }
      }
      if (ability.tempEnemyAttackDebuffPercent > 0) {
        enemyTarget.tempAttackMultiplier =
            1 - ability.tempEnemyAttackDebuffPercent / 100;
        enemyTarget.tempAttackDebuffTurns = ability.debuffDuration;
        logs.add(
          '${enemyTarget.name} attack reduced by ${ability.tempEnemyAttackDebuffPercent}% for ${ability.debuffDuration} turns!',
        );
      }
      if (!enemyTarget.isAlive) {
        logs.add('${enemyTarget.name} is defeated!');
      }
    } else {
      // --- SUPPORTIVE: heal + optional buffs ---
      final Character charTarget = target as Character;

      // Summon handling
      if (ability.summonId.isNotEmpty) {
        if (ability.summonId == 'skeleton') {
          // Necromancer: skeletons stack
          attacker.skeletonCount++;
          logs.add('${attacker.name} raises a skeleton! (${attacker.skeletonCount} active)');
        } else if (!attacker.activeSummons.contains(ability.summonId)) {
          attacker.activeSummons.add(ability.summonId);
          logs.add('${attacker.name} summons a ${ability.summonId}!');
        }
      }

      // Heal
      if (ability.damage < 0) {
        final healStat = ability.healScalesWithDefense
            ? attacker.totalDefense
            : attacker.totalMagic;
        final (healAmount, healCrit) = calculateHealing(
          healStat,
          ability.damage,
          healingMultiplier: healingMultiplier,
          casterSpeed: attacker.totalSpeed,
        );
        final hpBefore = charTarget.currentHp;
        charTarget.currentHp = min(
          charTarget.totalMaxHp,
          charTarget.currentHp + healAmount,
        );
        logs.add(
          '${attacker.name} uses ${ability.name} on ${charTarget.name} for $healAmount healing!${healCrit ? ' CRIT!' : ''}',
        );

        // Cleric overheal → shield (excess becomes shield, max 50% of target maxHp)
        if (attacker.characterClass == CharacterClass.cleric) {
          final actualHealed = charTarget.currentHp - hpBefore;
          final overheal = healAmount - actualHealed;
          if (overheal > 0) {
            final shieldCap = charTarget.totalMaxHp ~/ 2;
            final shieldGain = min(overheal, shieldCap - charTarget.shieldHp);
            if (shieldGain > 0) {
              charTarget.shieldHp += shieldGain;
              logs.add(
                '${charTarget.name} gains $shieldGain shield from overheal!',
              );
            }
          }
        }
      } else if (ability.healPercentMaxHp > 0) {
        final healAmount =
            (charTarget.totalMaxHp *
                    ability.healPercentMaxHp /
                    100 *
                    healingMultiplier)
                .round();
        charTarget.currentHp = min(
          charTarget.totalMaxHp,
          charTarget.currentHp + healAmount,
        );
        logs.add(
          '${attacker.name} uses ${ability.name}! ${charTarget.name} heals $healAmount HP!',
        );
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
        final bonus =
            (attacker.totalDefense * ability.grantCasterDefensePercent / 100)
                .round();
        charTarget.combatDefenseBonus += bonus;
        logs.add('${charTarget.name} defense +$bonus!');
      }
    }

    return (logs.join(' '), rawDamageDealt);
  }

  /// Check if any ally has an active golem summon (15% party damage reduction)
  static bool _hasGolemSummon(List<Character> allies) {
    return allies.any((a) => a.isAlive && a.activeSummons.contains('golem'));
  }

  /// Apply Paladin DR and Golem summon DR to incoming damage
  static (int, List<String>) _applyDefensivePassives(
    int damage,
    Character ally,
    List<Character> allAllies,
  ) {
    final logs = <String>[];
    // Golem summon: party takes 15% less damage
    if (_hasGolemSummon(allAllies)) {
      damage = (damage * 0.85).round();
    }
    // Paladin: 25% DR when below 50% HP
    if (ally.characterClass == CharacterClass.paladin &&
        ally.currentHp < ally.totalMaxHp / 2) {
      damage = (damage * 0.75).round();
      logs.add('${ally.name}\'s divine resolve reduces damage!');
    }
    return (max(1, damage), logs);
  }

  /// Fighter counter-attack: 15% chance when hit
  static List<String> _tryFighterCounter(Character ally, Enemy enemy) {
    if (ally.characterClass != CharacterClass.fighter || !ally.isAlive)
      return [];
    if (_random.nextInt(100) >= 15) return [];
    final basicAbility = ally.abilities.firstWhere(
      (a) => a.isBasicAttack,
      orElse: () => ally.abilities.first,
    );
    final (counterDmg, counterCrit) = calculateDamage(
      ally.totalAttack,
      basicAbility.damage,
      enemy.effectiveDefense,
      attackerSpeed: ally.totalSpeed,
    );
    enemy.currentHp = max(0, enemy.currentHp - counterDmg);
    var log =
        '${ally.name} counter-attacks for $counterDmg damage!${counterCrit ? ' CRIT!' : ''}';
    if (!enemy.isAlive) log += ' ${enemy.name} is defeated!';
    return [log];
  }

  /// Summoner: process persistent summon effects at start of turn
  static List<SummonEffect> processSummonEffects(
    Character summoner,
    List<Enemy> enemies,
    List<Character> allies,
  ) {
    final effects = <SummonEffect>[];
    final aliveEnemies = enemies.where((e) => e.isAlive).toList();
    final aliveAllies = allies.where((a) => a.isAlive).toList();

    for (final summon in summoner.activeSummons) {
      switch (summon) {
        case 'wolf':
          if (aliveEnemies.isNotEmpty) {
            final target = aliveEnemies[_random.nextInt(aliveEnemies.length)];
            final dmg = 8 + summoner.totalMagic ~/ 3;
            target.currentHp = max(0, target.currentHp - dmg);
            var log = 'Wolf spirit attacks ${target.name} for $dmg damage!';
            if (!target.isAlive) log += ' ${target.name} is defeated!';
            effects.add(SummonEffect(
              type: SummonEffectType.wolfAttack,
              summonerId: summoner.id,
              targetId: target.id,
              amount: dmg,
              logMessage: log,
            ));
          }
        case 'golem':
          if (aliveAllies.isNotEmpty) {
            effects.add(SummonEffect(
              type: SummonEffectType.golemShield,
              summonerId: summoner.id,
              targetIds: aliveAllies.map((a) => a.id).toList(),
              logMessage: 'Golem raises a protective barrier!',
            ));
          }
        case 'fairy':
          if (aliveAllies.isNotEmpty) {
            final injured = aliveAllies.reduce(
              (a, b) =>
                  (a.currentHp / a.totalMaxHp) < (b.currentHp / b.totalMaxHp)
                  ? a
                  : b,
            );
            if (injured.currentHp < injured.totalMaxHp) {
              final heal = 5 + summoner.totalMagic ~/ 4;
              injured.currentHp = min(
                injured.totalMaxHp,
                injured.currentHp + heal,
              );
              effects.add(SummonEffect(
                type: SummonEffectType.fairyHeal,
                summonerId: summoner.id,
                targetId: injured.id,
                amount: heal,
                logMessage: 'Fairy heals ${injured.name} for $heal HP!',
              ));
            }
          }
        case 'shadow':
          if (aliveEnemies.isNotEmpty) {
            final dmg = 2 + summoner.totalMagic ~/ 6;
            for (final e in aliveEnemies) {
              e.attackMultiplier = max(0.5, e.attackMultiplier - 0.10);
              e.currentHp = max(0, e.currentHp - dmg);
            }
            final defeated = aliveEnemies.where((e) => !e.isAlive).toList();
            var log = 'Shadow weakens enemies and deals $dmg damage!';
            for (final e in defeated) {
              log += ' ${e.name} is defeated!';
            }
            effects.add(SummonEffect(
              type: SummonEffectType.shadowWeaken,
              summonerId: summoner.id,
              targetIds: aliveEnemies.map((e) => e.id).toList(),
              amount: dmg,
              logMessage: log,
            ));
          }
        // 'golem' DR is also handled in _applyDefensivePassives
      }
    }
    return effects;
  }

  /// Necromancer skeletons: each skeleton attacks a random enemy.
  /// Returns list of (targetId, damage, log) for animation.
  static List<({String targetId, int damage, String log})> processSkeletonAttacks(
    Character necromancer,
    List<Enemy> enemies,
  ) {
    final results = <({String targetId, int damage, String log})>[];
    final aliveEnemies = enemies.where((e) => e.isAlive).toList();
    if (aliveEnemies.isEmpty || necromancer.skeletonCount <= 0) return results;

    final baseDmg = 8;
    for (int i = 0; i < necromancer.skeletonCount; i++) {
      final alive = enemies.where((e) => e.isAlive).toList();
      if (alive.isEmpty) break;
      final target = alive[_random.nextInt(alive.length)];
      final dmg = baseDmg + necromancer.totalMagic ~/ 3;
      target.currentHp = max(0, target.currentHp - dmg);
      var log = 'Skeleton attacks ${target.name} for $dmg damage!';
      if (!target.isAlive) log += ' ${target.name} is defeated!';
      results.add((targetId: target.id, damage: dmg, log: log));
    }
    return results;
  }

  /// Enemy AI: pick a random alive ally to attack with basic attack
  static String executeEnemyTurn(
    Enemy enemy,
    List<Character> allies, {
    double enemyDamageMultiplier = 1.0,
  }) {
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
    final availableAbilities = enemy.abilities
        .where((a) => a.isAvailable)
        .toList();
    final ability =
        availableAbilities[_random.nextInt(availableAbilities.length)];

    if (ability.damage < 0) {
      // Self heal
      final (healAmount, _) = calculateHealing(
        enemy.magic,
        ability.damage,
        casterSpeed: enemy.speed,
      );
      enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healAmount);
      if (!ability.isBasicAttack) ability.isAvailable = false;
      logs.add('${enemy.name} uses ${ability.name} and heals for $healAmount!');
      return logs.join(' ');
    }

    if (ability.targetType == AbilityTarget.allEnemies) {
      // Hit all allies
      for (final ally in aliveAllies) {
        // Necromancer skeleton shield: 50% chance a skeleton absorbs AoE hit
        if (ally.characterClass == CharacterClass.necromancer &&
            ally.skeletonCount > 0 &&
            _random.nextInt(100) < 50) {
          ally.skeletonCount--;
          logs.add('A skeleton shields ${ally.name} from the blast and crumbles! (${ally.skeletonCount} remaining)');
          continue;
        }
        var (damage, isCrit) = calculateDamage(
          enemy.effectiveAttack,
          ability.damage,
          ally.totalDefense,
          damageMultiplier: enemyDamageMultiplier,
          attackerSpeed: enemy.speed,
        );
        // Defensive passives (Paladin DR, Golem summon)
        final (reducedDmg, drLogs) = _applyDefensivePassives(
          damage,
          ally,
          allies,
        );
        damage = reducedDmg;
        logs.addAll(drLogs);
        var log =
            '${ally.name} takes $damage damage${isCrit ? ' (CRIT!)' : ''}';
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
        // Fighter counter-attack
        if (ally.isAlive && enemy.isAlive)
          logs.addAll(_tryFighterCounter(ally, enemy));
      }
      if (!ability.isBasicAttack) ability.isAvailable = false;
      return [
        if (logs.isNotEmpty) ...logs,
        '${enemy.name} uses ${ability.name}!',
      ].join(' ');
    }

    // Single target — front line bias (65% front, 35% back)
    final frontLiners = aliveAllies.where((a) => a.isFrontLine).toList();
    final backLiners = aliveAllies.where((a) => !a.isFrontLine).toList();
    final Character target;
    if (frontLiners.isEmpty) {
      target = backLiners[_random.nextInt(backLiners.length)];
    } else if (backLiners.isEmpty) {
      target = frontLiners[_random.nextInt(frontLiners.length)];
    } else {
      final roll = _random.nextInt(100);
      if (roll < 65) {
        target = frontLiners[_random.nextInt(frontLiners.length)];
      } else {
        target = backLiners[_random.nextInt(backLiners.length)];
      }
    }
    // Necromancer skeleton shield: 50% chance a skeleton absorbs the hit
    if (target.characterClass == CharacterClass.necromancer &&
        target.skeletonCount > 0 &&
        _random.nextInt(100) < 50) {
      target.skeletonCount--;
      if (!ability.isBasicAttack) ability.isAvailable = false;
      logs.add(
        '${enemy.name} attacks ${target.name}, but a skeleton blocks the blow and crumbles! (${target.skeletonCount} remaining)',
      );
      return logs.join(' ');
    }

    var (damage, isCrit) = calculateDamage(
      enemy.effectiveAttack,
      ability.damage,
      target.totalDefense,
      damageMultiplier: enemyDamageMultiplier,
      attackerSpeed: enemy.speed,
    );
    if (!ability.isBasicAttack) ability.isAvailable = false;
    // Defensive passives (Paladin DR, Golem summon)
    final (reducedDmg, drLogs) = _applyDefensivePassives(
      damage,
      target,
      allies,
    );
    damage = reducedDmg;
    logs.addAll(drLogs);
    var log =
        '${enemy.name} uses ${ability.name} on ${target.name} for $damage damage!${isCrit ? ' CRIT!' : ''}';
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
    // Fighter counter-attack
    if (target.isAlive && enemy.isAlive)
      logs.addAll(_tryFighterCounter(target, enemy));
    return logs.join(' ');
  }
}
