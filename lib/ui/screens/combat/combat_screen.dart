import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/ability_icons.dart';
import '../../../data/class_data.dart';
import '../../widgets/idle_animated_sprite.dart';
import '../../../data/sprite_data.dart';
import '../../../models/ability.dart';
import '../../../models/character.dart';
import '../../../models/combat_state.dart';
import '../../../models/enemy.dart';
import '../../../models/enums.dart';
import '../../../models/summon_effect.dart';
import '../../../data/map_backgrounds.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../providers/help_mode_provider.dart';
import '../../../services/audio_service.dart';
import '../../../data/mutator_data.dart';
import '../../../services/combat_service.dart';
import '../../widgets/help_button.dart';
import '../../widgets/help_dialogs.dart';

// ---------------------------------------------------------------------------
// Attack line data
// ---------------------------------------------------------------------------
enum SpellType {
  normal,
  burningHands,
  fireball,
  iceStorm,
  chainLightning,
  meteor,
  summonWolf,
  summonGolem,
  summonFairy,
  summonShadow,
  skeletonAttack,
}

class _AttackLineData {
  final String attackerId;
  final String targetId;
  final int amount;
  final bool isHealing;
  final bool isSpell;
  final SpellType spellType;
  final int overkill;
  const _AttackLineData(
    this.attackerId,
    this.targetId,
    this.amount,
    this.isHealing,
    this.isSpell, {
    this.spellType = SpellType.normal,
    this.overkill = 0,
  });
}

// ---------------------------------------------------------------------------
// Combat screen
// ---------------------------------------------------------------------------
class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({super.key});

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen>
    with TickerProviderStateMixin {
  CombatState? _combat;
  bool _waitingForInput = false;
  Ability? _selectedAbility;
  bool _potionMode = false;
  final _logController = ScrollController();

  // Attack line overlay
  List<_AttackLineData> _attackLines = [];
  late final AnimationController _lineAnimController;
  late final Animation<double> _lineProgress;

  // Army fight flag
  bool _isArmyFight = false;

  // Keyboard focus for number key shortcuts
  final _focusNode = FocusNode();

  // Boss fight flag
  bool _isBossFight = false;

  // Mutator multipliers
  double _enemyDamageMultiplier = 1.0;
  double _healingMultiplier = 1.0;

  // Background
  late String _backgroundPath;

  @override
  void initState() {
    super.initState();
    _lineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _lineProgress = CurvedAnimation(
      parent: _lineAnimController,
      curve: Curves.easeOutCubic,
    );
    _backgroundPath =
        'assets/sprites/backgrounds/meadow.png'; // default, set in _initCombat
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCombat());
  }

  void _initCombat() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    _backgroundPath = combatBackground(gameState.currentMapNumber);
    _enemyDamageMultiplier = getMutatorEffect(
      gameState.activeMutator,
      'enemy_damage',
    );
    _healingMultiplier = getMutatorEffect(gameState.activeMutator, 'healing');

    final notifier = ref.read(gameStateProvider.notifier);
    final currentNode = gameState.currentMap.currentNode;
    final List<Enemy> enemies;
    _isArmyFight = notifier.isArmyCatching;
    _isBossFight = currentNode.type == NodeType.boss;
    if (_isArmyFight) {
      enemies = notifier.generateArmyEnemies();
      ref.read(audioProvider.notifier).playMusic(MusicTrack.bossBattle);
    } else if (currentNode.type == NodeType.boss) {
      enemies = notifier.generateBoss();
      ref.read(audioProvider.notifier).playMusic(MusicTrack.bossBattle);
    } else {
      enemies = notifier.generateEnemies();
    }

    setState(() {
      _combat = CombatService.initCombat(gameState.party, enemies);
      _processNextTurn();
    });
  }

  // -- Turn processing ------------------------------------------------------
  void _processNextTurn() {
    if (_combat == null || _combat!.isComplete) return;

    if (_combat!.allEnemiesDead) {
      ref.read(audioProvider.notifier).playMusic(MusicTrack.victory);
      setState(() {
        _combat!.isComplete = true;
        _combat!.isVictory = true;
        _combat!.combatLog.add('Victory!');
      });
      return;
    }
    if (_combat!.allAlliesDead) {
      ref.read(audioProvider.notifier).playMusic(MusicTrack.gameOver);
      setState(() {
        _combat!.isComplete = true;
        _combat!.isVictory = false;
        _combat!.combatLog.add('Defeat...');
      });
      return;
    }

    final current = _combat!.currentCombatant;
    if (current.isAlly) {
      final char = _combat!.allies.firstWhere((c) => c.id == current.id);
      if (!char.isAlive) {
        _advanceTurn();
        return;
      }
      // Druid passive: Nature's Blessing — heal all alive allies for a small amount
      if (char.characterClass == CharacterClass.druid) {
        final heal = 3 + char.totalMagic ~/ 5;
        final aliveAllies = _combat!.allies.where((a) => a.isAlive && a.currentHp < a.totalMaxHp).toList();
        if (aliveAllies.isNotEmpty) {
          for (final ally in aliveAllies) {
            ally.currentHp = min(ally.totalMaxHp, ally.currentHp + heal);
          }
          setState(() {
            _combat!.combatLog.add('Nature\'s Blessing heals the party for $heal HP each!');
          });
          _scrollLog();
        }
      }

      // Artificer passive: Automatic Repair — heal 5% max HP at start of turn
      if (char.characterClass == CharacterClass.artificer &&
          char.currentHp < char.totalMaxHp) {
        final repair = max(1, (char.totalMaxHp * 0.05).round());
        char.currentHp = min(char.totalMaxHp, char.currentHp + repair);
        setState(() {
          _combat!.combatLog.add('Automatic Repair restores ${char.name} for $repair HP!');
        });
        _scrollLog();
      }

      // Summoner: process persistent summon effects at start of turn
      if (char.activeSummons.isNotEmpty) {
        final effects = CombatService.processSummonEffects(
          char,
          _combat!.enemies,
          _combat!.allies,
        );
        if (effects.isNotEmpty) {
          final lines = <_AttackLineData>[];
          for (final effect in effects) {
            switch (effect.type) {
              case SummonEffectType.wolfAttack:
                lines.add(_AttackLineData(
                  char.id, effect.targetId!, effect.amount, false, true,
                  spellType: SpellType.summonWolf,
                ));
              case SummonEffectType.golemShield:
                for (final allyId in effect.targetIds) {
                  lines.add(_AttackLineData(
                    char.id, allyId, 0, false, true,
                    spellType: SpellType.summonGolem,
                  ));
                }
              case SummonEffectType.fairyHeal:
                lines.add(_AttackLineData(
                  char.id, effect.targetId!, effect.amount, true, true,
                  spellType: SpellType.summonFairy,
                ));
              case SummonEffectType.shadowWeaken:
                for (final enemyId in effect.targetIds) {
                  lines.add(_AttackLineData(
                    char.id, enemyId, effect.amount, false, true,
                    spellType: SpellType.summonShadow,
                  ));
                }
            }
          }
          setState(() {
            _combat!.combatLog.addAll(effects.map((e) => e.logMessage));
            _attackLines = lines;
            _waitingForInput = false;
          });
          _scrollLog();
          _animateLines(holdMs: 400, onDone: () {
            if (mounted) {
              // Check if summons killed all enemies
              if (_combat!.allEnemiesDead) {
                _processNextTurn();
              } else {
                setState(() {
                  _waitingForInput = true;
                  _selectedAbility = null;
                });
              }
            }
          });
          return;
        }
      }
      // Necromancer: skeleton attacks at start of turn
      if (char.skeletonCount > 0) {
        final skelResults = CombatService.processSkeletonAttacks(
          char,
          _combat!.enemies,
        );
        if (skelResults.isNotEmpty) {
          final lines = skelResults.map((r) => _AttackLineData(
            char.id, r.targetId, r.damage, false, true,
            spellType: SpellType.skeletonAttack,
          )).toList();
          setState(() {
            _combat!.combatLog.addAll(skelResults.map((r) => r.log));
            _attackLines = lines;
            _waitingForInput = false;
          });
          _scrollLog();
          _animateLines(holdMs: 400, onDone: () {
            if (mounted) {
              if (_combat!.allEnemiesDead) {
                _processNextTurn();
              } else {
                setState(() {
                  _waitingForInput = true;
                  _selectedAbility = null;
                });
              }
            }
          });
          return;
        }
      }
      setState(() {
        _waitingForInput = true;
        _selectedAbility = null;
      });
    } else {
      final enemy = _combat!.enemies.firstWhere((e) => e.id == current.id);
      if (!enemy.isAlive) {
        _advanceTurn();
        return;
      }
      setState(() => _waitingForInput = false);

      // Snapshot HP before enemy acts
      final allyHpBefore = {for (final a in _combat!.allies) a.id: a.currentHp};
      final enemyHpBefore = enemy.currentHp;

      final log = CombatService.executeEnemyTurn(
        enemy,
        _combat!.allies,
        enemyDamageMultiplier: _enemyDamageMultiplier,
      );

      // Barbarian passive: taking damage grants +5% attack and +5% defense
      for (final a in _combat!.allies) {
        final diff = allyHpBefore[a.id]! - a.currentHp;
        if (diff > 0 && a.isAlive && a.characterClass == CharacterClass.barbarian) {
          a.combatAttackMultiplier += 0.05;
          a.combatDefenseMultiplier += 0.05;
        }
      }

      // Build attack lines from HP diffs
      final lines = <_AttackLineData>[];
      int hitCount = 0;
      for (final a in _combat!.allies) {
        final diff = allyHpBefore[a.id]! - a.currentHp;
        if (diff > 0) hitCount++;
      }
      final isAoE = hitCount > 1;
      for (final a in _combat!.allies) {
        final diff = allyHpBefore[a.id]! - a.currentHp;
        if (diff > 0) {
          lines.add(
            _AttackLineData(
              enemy.id,
              a.id,
              diff,
              false,
              isAoE || enemy.magic > enemy.attack,
            ),
          );
        }
      }
      if (enemy.currentHp > enemyHpBefore) {
        lines.add(
          _AttackLineData(
            enemy.id,
            enemy.id,
            enemy.currentHp - enemyHpBefore,
            true,
            true,
          ),
        );
      }

      setState(() {
        _combat!.combatLog.add(log);
        _attackLines = lines;
      });
      _scrollLog();
      _animateLines(holdMs: 400, onDone: _advanceTurn);
    }
  }

  /// Animate attack lines drawing in over 1s, hold, then clear.
  void _animateLines({required int holdMs, required VoidCallback onDone}) {
    _lineAnimController.reset();
    _lineAnimController.forward().then((_) {
      Future.delayed(Duration(milliseconds: holdMs), () {
        if (mounted) {
          setState(() => _attackLines = []);
          onDone();
        }
      });
    });
  }

  void _advanceTurn() {
    if (_combat == null) return;
    _combat!.currentTurnIndex++;
    if (_combat!.currentTurnIndex >= _combat!.turnOrder.length) {
      _combat!.currentTurnIndex = 0;
      _combat!.roundNumber++;
      _combat!.combatLog.add('--- Round ${_combat!.roundNumber} ---');

      // Boss enrage: after round 15, enemies get +10% attack per round
      if (_isBossFight && _combat!.roundNumber > 15) {
        for (final enemy in _combat!.enemies.where((e) => e.isAlive)) {
          enemy.attackMultiplier = (enemy.attackMultiplier * 1.10);
        }
        _combat!.combatLog.add('The enemy grows stronger! (Enrage!)');
      }

      for (final ally in _combat!.allies) {
        CombatService.refreshAbilities(ally.abilities);
      }
      for (final enemy in _combat!.enemies) {
        CombatService.refreshAbilities(enemy.abilities);
      }

      // Keep same group order, just remove dead combatants
      _combat!.turnOrder.removeWhere((entry) {
        if (entry.isAlly) {
          return !_combat!.allies.any((a) => a.id == entry.id && a.isAlive);
        } else {
          return !_combat!.enemies.any((e) => e.id == entry.id && e.isAlive);
        }
      });
    }
    _processNextTurn();
  }

  // -- Ally ability usage ---------------------------------------------------

  SpellType _getSpellType(Ability ability) {
    switch (ability.name.toLowerCase()) {
      case 'burning hands':
        return SpellType.burningHands;
      case 'fireball':
        return SpellType.fireball;
      case 'ice storm':
        return SpellType.iceStorm;
      case 'chain lightning':
        return SpellType.chainLightning;
      case 'meteor':
        return SpellType.meteor;
      default:
        return SpellType.normal;
    }
  }

  void _useAbility(Ability ability, dynamic target) {
    if (_combat == null) return;
    final current = _combat!.currentCombatant;
    final char = _combat!.allies.firstWhere((c) => c.id == current.id);

    // Snapshot HP before action
    final enemyHpBefore = {for (final e in _combat!.enemies) e.id: e.currentHp};
    final allyHpBefore = {for (final a in _combat!.allies) a.id: a.currentHp};

    // Spellsword: alternating physical/magic bonus (+30%)
    bool spellswordBoosted = false;
    if (char.characterClass == CharacterClass.spellsword &&
        ability.damage > 0) {
      final isPhysical = ability.isPhysicalAttack;
      if (char.lastAttackWasPhysical != null &&
          char.lastAttackWasPhysical != isPhysical) {
        char.combatAttackMultiplier += 0.30;
        spellswordBoosted = true;
      }
      char.lastAttackWasPhysical = isPhysical;
    }

    // Track raw damage per enemy for overkill display
    final rawDamageByEnemy = <String, int>{};

    String log;
    if (ability.darkPact) {
      // Dark Pact: special handling - sacrifice HP, damage all enemies
      if (!ability.isBasicAttack) ability.isAvailable = false;
      log = CombatService.executeDarkPact(
        char,
        _combat!.enemies.where((e) => e.isAlive).toList(),
      );
    } else if (ability.minTargets > 0) {
      // Multi-target: if alive <= minTargets, hit all; otherwise pick random unique targets
      final aliveEnemies = _combat!.enemies.where((e) => e.isAlive).toList();
      final List<Enemy> targets;
      if (aliveEnemies.length <= ability.minTargets) {
        targets = List.of(aliveEnemies);
      } else {
        final count =
            ability.minTargets +
            Random().nextInt(ability.maxTargets - ability.minTargets + 1);
        final shuffled = List.of(aliveEnemies)..shuffle();
        targets = shuffled.take(count.clamp(1, aliveEnemies.length)).toList();
      }
      final logs = <String>[];
      for (final enemy in targets) {
        if (!enemy.isAlive) continue;
        final result = CombatService.executeAllyTurn(
          char,
          ability,
          enemy,
          healingMultiplier: _healingMultiplier,
        );
        logs.add(result.$1);
        rawDamageByEnemy[enemy.id] = (rawDamageByEnemy[enemy.id] ?? 0) + result.$2;
      }
      log = logs.join(' ');
    } else if (ability.targetType == AbilityTarget.allEnemies) {
      final logs = <String>[];
      for (final enemy in _combat!.enemies.where((e) => e.isAlive)) {
        final result = CombatService.executeAllyTurn(
          char,
          ability,
          enemy,
          healingMultiplier: _healingMultiplier,
        );
        logs.add(result.$1);
        rawDamageByEnemy[enemy.id] = (rawDamageByEnemy[enemy.id] ?? 0) + result.$2;
      }
      log = logs.join(' ');
    } else if (ability.targetType == AbilityTarget.allAllies) {
      final logs = <String>[];
      for (final ally in _combat!.allies.where((a) => a.isAlive)) {
        logs.add(
          CombatService.executeAllyTurn(
            char,
            ability,
            ally,
            healingMultiplier: _healingMultiplier,
          ).$1,
        );
      }
      log = logs.join(' ');
    } else {
      final result = CombatService.executeAllyTurn(
        char,
        ability,
        target,
        healingMultiplier: _healingMultiplier,
      );
      log = result.$1;
      if (target is Enemy) {
        rawDamageByEnemy[target.id] = result.$2;
      }
    }

    // Revert spellsword boost
    if (spellswordBoosted) {
      char.combatAttackMultiplier -= 0.30;
    }

    // Rogue: 15% chance for dual strike
    String dualStrikeLog = '';
    String? dualStrikeTargetId;
    int dualStrikeDamage = 0;
    if (char.characterClass == CharacterClass.rogue &&
        ability.damage > 0 &&
        Random().nextInt(100) < 15) {
      final aliveEnemies = _combat!.enemies.where((e) => e.isAlive).toList();
      if (aliveEnemies.isNotEmpty) {
        final result = CombatService.executeRogueDualStrike(
          char,
          ability,
          target,
          aliveEnemies,
        );
        dualStrikeLog = result.log;
        dualStrikeTargetId = result.targetId;
        dualStrikeDamage = result.damage;
        log += ' ${dualStrikeLog}';
      }
    }

    // Chaotic bounce: 50% chance to hit another random enemy
    if (ability.chaotic) {
      final aliveEnemies = _combat!.enemies.where((e) => e.isAlive).toList();
      if (aliveEnemies.isNotEmpty && Random().nextInt(100) < 50) {
        final bounceTarget =
            aliveEnemies[Random().nextInt(aliveEnemies.length)];
        log +=
            ' ${CombatService.executeChaoticBounce(char, ability, bounceTarget)}';
      }
    }

    // Snapshot HP after main attack (before pierce) for line splitting
    final enemyHpAfterMain = {
      for (final e in _combat!.enemies) e.id: e.currentHp,
    };

    // Ranger pierce: 15% chance to hit another (or same) enemy
    String? pierceSourceId;
    String? pierceTargetId;
    int pierceDamage = 0;
    if (char.characterClass == CharacterClass.ranger && ability.damage > 0) {
      final aliveEnemies = _combat!.enemies.where((e) => e.isAlive).toList();
      if (aliveEnemies.isNotEmpty && Random().nextInt(100) < 15) {
        // Determine the "source" for the bounce line
        if (target is Enemy) {
          pierceSourceId = target.id;
        } else {
          // AOE — pick the first alive enemy as visual source
          pierceSourceId = aliveEnemies.first.id;
        }
        final result = CombatService.executePierce(char, ability, aliveEnemies);
        log += ' ${result.log}';
        pierceTargetId = result.targetId;
        pierceDamage = result.damage;
      }
    }

    // Templar: attack abilities heal most injured ally for 15% of damage dealt
    if (char.characterClass == CharacterClass.templar && ability.damage > 0) {
      int totalDmg = 0;
      for (final e in _combat!.enemies) {
        totalDmg += enemyHpBefore[e.id]! - e.currentHp;
      }
      if (totalDmg > 0) {
        final aliveAllies = _combat!.allies.where((a) => a.isAlive).toList();
        if (aliveAllies.isNotEmpty) {
          final injured = aliveAllies.reduce(
            (a, b) =>
                (a.currentHp / a.totalMaxHp) < (b.currentHp / b.totalMaxHp)
                ? a
                : b,
          );
          final healAmt = max(1, (totalDmg * 0.15).round());
          injured.currentHp = min(
            injured.totalMaxHp,
            injured.currentHp + healAmt,
          );
          log += ' ${injured.name} is healed for $healAmt by holy light!';
        }
      }
    }

    // Artificer: 35% chance to preserve ability (not consume refresh)
    if (char.characterClass == CharacterClass.artificer &&
        !ability.isBasicAttack &&
        !ability.isAvailable) {
      if (Random().nextInt(100) < 35) {
        ability.isAvailable = true;
        log += ' ${char.name}\'s ingenuity preserves ${ability.name}!';
      }
    }

    final SpellType attackSpellType =
        char.characterClass == CharacterClass.wizard && !ability.isBasicAttack
        ? _getSpellType(ability)
        : SpellType.normal;

    // Build attack lines from HP diffs (main attack only, using pre-pierce snapshot)
    final isSpell = !ability.isBasicAttack;
    final lines = <_AttackLineData>[];
    for (final e in _combat!.enemies) {
      final diff = enemyHpBefore[e.id]! - enemyHpAfterMain[e.id]!;
      if (diff > 0) {
        final raw = rawDamageByEnemy[e.id] ?? diff;
        final overkill = max(0, raw - diff);
        lines.add(
          _AttackLineData(
            char.id,
            e.id,
            diff,
            false,
            isSpell,
            spellType: attackSpellType,
            overkill: overkill,
          ),
        );
      }
    }

    // Add bounce line for pierce (from original target to pierce target)
    if (pierceTargetId != null && pierceDamage > 0) {
      lines.add(
        _AttackLineData(
          pierceSourceId!,
          pierceTargetId,
          pierceDamage,
          false,
          false,
        ),
      );
    }
    for (final a in _combat!.allies) {
      final diff = a.currentHp - allyHpBefore[a.id]!;
      if (diff > 0) lines.add(_AttackLineData(char.id, a.id, diff, true, true));
    }

    if (lines.isNotEmpty) {
      final isMagicUser = magicDamageClasses.contains(char.characterClass);
      ref
          .read(audioProvider.notifier)
          .playSfx(isMagicUser ? SfxType.spellCast : SfxType.meleeHit);
    }

    setState(() {
      _combat!.combatLog.add(log);
      _attackLines = lines;
      _waitingForInput = false;
      _selectedAbility = null;
    });
    _scrollLog();

    // Skeleton attacks immediately when summoned
    if (ability.summonId == 'skeleton') {
      _animateLines(holdMs: 300, onDone: () {
        if (!mounted || _combat == null) return;
        final skelResults = CombatService.processSkeletonAttacks(
          char,
          _combat!.enemies,
        );
        if (skelResults.isNotEmpty) {
          final skelLines = skelResults.map((r) => _AttackLineData(
            char.id, r.targetId, r.damage, false, true,
            spellType: SpellType.skeletonAttack,
          )).toList();
          setState(() {
            _combat!.combatLog.addAll(skelResults.map((r) => r.log));
            _attackLines = skelLines;
          });
          _scrollLog();
          _animateLines(holdMs: 300, onDone: () {
            if (mounted) {
              if (_combat!.allEnemiesDead) {
                _processNextTurn();
              } else {
                _advanceTurn();
              }
            }
          });
        } else {
          _advanceTurn();
        }
      });
    } else {
      _animateLines(holdMs: 300, onDone: _advanceTurn);
    }
  }

  void _usePotion(Character target) {
    if (_combat == null) return;
    final gameState = ref.read(gameStateProvider);
    if (gameState == null || gameState.healthPotions <= 0) return;

    final current = _combat!.currentCombatant;
    final char = _combat!.allies.firstWhere((c) => c.id == current.id);

    final healAmount = (target.totalMaxHp * 0.4).round();
    final before = target.currentHp;
    target.currentHp = min(target.totalMaxHp, target.currentHp + healAmount);
    final actualHeal = target.currentHp - before;

    ref.read(gameStateProvider.notifier).usePotion();

    final lines = <_AttackLineData>[];
    if (actualHeal > 0) {
      lines.add(_AttackLineData(char.id, target.id, actualHeal, true, false));
    }

    setState(() {
      _combat!.combatLog.add(
        '${char.name} uses a Health Potion on ${target.name}! (+$actualHeal HP)',
      );
      _attackLines = lines;
      _waitingForInput = false;
      _potionMode = false;
      _selectedAbility = null;
    });
    _scrollLog();
    _animateLines(holdMs: 300, onDone: _advanceTurn);
  }

  void _scrollLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onCombatEnd() {
    if (_combat == null) return;
    if (_combat!.isVictory) {
      final totalXp = _combat!.enemies.fold(0, (sum, e) => sum + e.xpReward);
      final totalGold = _combat!.enemies.fold(
        0,
        (sum, e) => sum + e.goldReward,
      );
      final notifier = ref.read(gameStateProvider.notifier);

      // Determine if this was a boss fight
      final gameState = ref.read(gameStateProvider);
      final isBoss =
          gameState != null &&
          gameState.currentMap.currentNode.type == NodeType.boss;

      // Track killed enemy types for LP calculation
      notifier.completeCombat(
        totalXp,
        totalGold,
        killedEnemyTypes: _combat!.enemies
            .where((e) => !e.isAlive)
            .map((e) => e.type)
            .toSet()
            .toList(),
        bossKilled: isBoss,
      );

      if (_isArmyFight) {
        notifier.defeatArmy();
      }

      // Re-read state after completeCombat updates it
      final updatedState = ref.read(gameStateProvider);
      if (isBoss) {
        if (updatedState != null && updatedState.currentMapNumber >= 8) {
          // Victory screen handles LP calculation and save cleanup
          context.go('/victory');
        } else {
          ref.read(gameStateProvider.notifier).advanceToNextMap();
          context.go('/map');
        }
      } else {
        context.go('/map');
      }
    } else {
      // DO NOT call gameOver() here — Game Over screen handles
      // the run-end lifecycle (LP calc -> profile update -> save delete)
      context.go('/game-over');
    }
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_combat == null) return;

    // Spacebar or C to continue after combat ends
    if (_combat!.isComplete) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyC) {
        _onCombatEnd();
      }
      return;
    }

    if (!_waitingForInput) return;

    final current = _combat!.currentCombatant;
    final char = _combat!.allies.firstWhere((c) => c.id == current.id);
    final abilities = char.abilities
        .where((a) => a.unlockedAtLevel <= char.level)
        .toList();

    int? index;
    if (event.logicalKey == LogicalKeyboardKey.digit1) index = 0;
    if (event.logicalKey == LogicalKeyboardKey.digit2) index = 1;
    if (event.logicalKey == LogicalKeyboardKey.digit3) index = 2;
    if (event.logicalKey == LogicalKeyboardKey.digit4) index = 3;
    if (event.logicalKey == LogicalKeyboardKey.digit5) index = 4;

    if (index == null || index >= abilities.length) return;
    final ability = abilities[index];
    if (!ability.isAvailable) return;

    // Same logic as the tap handler
    setState(() {
      _selectedAbility = ability;
      _potionMode = false;
    });
    if (ability.targetType == AbilityTarget.self) {
      _useAbility(ability, char);
    } else if (ability.targetType == AbilityTarget.allEnemies ||
        ability.targetType == AbilityTarget.allAllies) {
      _useAbility(ability, null);
    } else if (ability.minTargets > 0) {
      // Multi-target spells auto-fire (no target selection needed)
      _useAbility(ability, null);
    } else if (ability.targetType == AbilityTarget.singleEnemy) {
      final alive = _combat!.enemies.where((e) => e.isAlive).toList();
      if (alive.length == 1) _useAbility(ability, alive.first);
    } else if (ability.targetType == AbilityTarget.singleAlly) {
      final alive = _combat!.allies.where((a) => a.isAlive).toList();
      if (alive.length == 1) _useAbility(ability, alive.first);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _lineAnimController.dispose();
    _logController.dispose();
    super.dispose();
  }

  // -- Position helper for attack lines (returns sprite edge, not center) ---
  Offset _combatantEdge(String id, Size size) {
    final allyIdx = _combat!.allies.indexWhere((a) => a.id == id);
    if (allyIdx >= 0) {
      final n = _combat!.allies.length;
      final sprite = _spriteSize(n);
      final ally = _combat!.allies[allyIdx];
      final frontLineOffset = ally.isFrontLine ? 24.0 : 0.0;
      return Offset(
        size.width * 0.25 + sprite / 2 + 4 + frontLineOffset, // right edge of ally sprite
        size.height * (allyIdx + 1) / (n + 1),
      );
    }
    final enemyIdx = _combat!.enemies.indexWhere((e) => e.id == id);
    if (enemyIdx >= 0) {
      final enemies = _combat!.enemies;
      final totalCols = enemies.length <= 3
          ? 1
          : enemies.length <= 6
          ? 2
          : 3;
      final rowsPerCol = (enemies.length / totalCols).ceil();
      final gridCol = enemyIdx ~/ rowsPerCol;
      final gridRow = enemyIdx % rowsPerCol;
      final colEnemyCount = (gridCol < totalCols - 1)
          ? rowsPerCol
          : enemies.length - gridCol * rowsPerCol;

      // X: right half (0.5-1.0), spread across grid columns
      final colWidth = 0.5 / totalCols;
      final x = size.width * (0.5 + colWidth * gridCol + colWidth / 2);
      // Y: spread within column
      final y = size.height * (gridRow + 1) / (colEnemyCount + 1);
      return Offset(x, y);
    }
    return size.center(Offset.zero);
  }

  // =========================================================================
  // BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_combat == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCombatant = _combat!.isComplete
        ? null
        : _combat!.currentCombatant;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(theme, currentCombatant),
              Expanded(
                flex: 4,
                child: _buildBattlefield(theme, currentCombatant),
              ),
              const Divider(height: 1),
              Expanded(
                flex: 1,
                child: Container(
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: ListView.builder(
                    controller: _logController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: _combat!.combatLog.length,
                    itemBuilder: (context, index) {
                      final text = _combat!.combatLog[index];
                      final isRoundHeader = text.startsWith('---');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          text,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isRoundHeader ? FontWeight.bold : null,
                            color: isRoundHeader
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_waitingForInput && !_combat!.isComplete)
                _buildAbilityBar(theme)
              else if (_combat!.isComplete)
                _buildCombatEndBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  // -- Top bar --------------------------------------------------------------
  Widget _buildTopBar(ThemeData theme, CombatantEntry? currentCombatant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 40), // balance the HelpButton on the right
              Expanded(
                child: Text(
                  'Round ${_combat!.roundNumber}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 40, child: HelpButton()),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _combat!.turnOrder.map((entry) {
                final isCurrent = currentCombatant?.id == entry.id;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : entry.isAlly
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(
                            color: theme.colorScheme.onPrimary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    entry.name.split(' ').first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : entry.isAlly
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: isCurrent ? FontWeight.bold : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // -- Battlefield ----------------------------------------------------------
  Widget _buildBattlefield(ThemeData theme, CombatantEntry? currentCombatant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bfSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                _backgroundPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.surfaceContainerLow,
                        theme.colorScheme.surfaceContainer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Slight dim for readability
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),

            // Combatants row
            Positioned.fill(
              child: Row(
                children: [
                  // HEROES (left)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _combat!.allies.map((ally) {
                          final isCurrentTurn = currentCombatant?.id == ally.id;
                          final isHealTarget =
                              (_selectedAbility != null &&
                                  _selectedAbility!.damage < 0 &&
                                  _selectedAbility!.targetType ==
                                      AbilityTarget.singleAlly &&
                                  ally.isAlive) ||
                              (_potionMode && ally.isAlive);
                          // Front liners shift right (closer to enemies)
                          final frontLineOffset = ally.isFrontLine ? 24.0 : 0.0;
                          return Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: frontLineOffset),
                              child: GestureDetector(
                                onTap: isHealTarget || ref.read(helpModeProvider)
                                    ? () {
                                        if (ref.read(helpModeProvider)) {
                                          ref
                                                  .read(helpModeProvider.notifier)
                                                  .state =
                                              false;
                                          showCharacterHelp(context, ally);
                                          return;
                                        }
                                        if (_potionMode) {
                                          _usePotion(ally);
                                        } else {
                                          _useAbility(_selectedAbility!, ally);
                                        }
                                      }
                                    : null,
                                child: _buildAllyWidget(
                                  theme,
                                  ally,
                                  isCurrentTurn,
                                  isHealTarget,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // ENEMIES (right) — grid layout for many enemies
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: _buildEnemyGrid(theme),
                    ),
                  ),
                ],
              ),
            ),

            // Attack line overlay
            if (_attackLines.isNotEmpty)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _lineProgress,
                  builder: (context, _) => CustomPaint(
                    painter: _AttackLinePainter(
                      lines: _attackLines,
                      positionOf: (id) => _combatantEdge(id, bfSize),
                      progress: _lineProgress.value,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // -- Enemy grid (up to 3x3) ------------------------------------------------
  Widget _buildEnemyGrid(ThemeData theme) {
    final enemies = _combat!.enemies;
    final cols = enemies.length <= 3
        ? 1
        : enemies.length <= 6
        ? 2
        : 3;
    final rows = (enemies.length / cols).ceil();

    // Split enemies into grid columns
    final gridCols = <List<Enemy>>[];
    for (int c = 0; c < cols; c++) {
      final start = c * rows;
      final end = (start + rows).clamp(0, enemies.length);
      if (start < enemies.length) {
        gridCols.add(enemies.sublist(start, end));
      }
    }

    return Row(
      children: gridCols
          .map(
            (colEnemies) => Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colEnemies.map((enemy) {
                  final isTarget =
                      _selectedAbility != null &&
                      _selectedAbility!.damage > 0 &&
                      _selectedAbility!.targetType ==
                          AbilityTarget.singleEnemy &&
                      enemy.isAlive;
                  return Flexible(
                    child: GestureDetector(
                      onTap: isTarget || ref.read(helpModeProvider)
                          ? () {
                              if (ref.read(helpModeProvider)) {
                                ref.read(helpModeProvider.notifier).state =
                                    false;
                                showEnemyHelp(context, enemy);
                                return;
                              }
                              _useAbility(_selectedAbility!, enemy);
                            }
                          : null,
                      child: _buildEnemyWidget(theme, enemy, isTarget),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  // -- Ally widget (vertical: name, sprite, hp bar, hp text) ----------------
  Widget _buildAllyWidget(
    ThemeData theme,
    Character ally,
    bool isCurrentTurn,
    bool isHealTarget,
  ) {
    final spriteSize = _spriteSize(_combat!.allies.length);
    final spritePath = classSpritePath(ally.characterClass);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isCurrentTurn
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : isHealTarget
              ? Border.all(color: Colors.green, width: 2)
              : null,
          color: isCurrentTurn
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : isHealTarget
              ? Colors.green.withValues(alpha: 0.15)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ally.name.split(' ').first,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
                decoration: ally.isAlive ? null : TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: ally.isAlive ? 1.0 : 0.3,
                    child: IdleAnimatedSprite(
                      imagePath: spritePath,
                      size: spriteSize,
                      phaseOffset: ally.id.hashCode.toDouble(),
                      animate: ally.isAlive,
                    ),
                  ),
                  if (ally.activeSummons.isNotEmpty)
                    ...ally.activeSummons.map((id) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: CustomPaint(
                          size: Size(spriteSize, spriteSize),
                          painter: _SummonIconPainter(id),
                        ),
                      ),
                    ),
                  if (ally.skeletonCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: CustomPaint(
                        size: Size(spriteSize, spriteSize),
                        painter: _SkeletonPackPainter(ally.skeletonCount),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            if (ally.isAlive) ...[
              SizedBox(
                width: spriteSize,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ally.shieldHp > 0)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                        child: LinearProgressIndicator(
                          value: (ally.shieldHp / ally.totalMaxHp).clamp(
                            0.0,
                            1.0,
                          ),
                          minHeight: 4,
                          color: Colors.cyan.shade300,
                          backgroundColor: Colors.cyan.shade900.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ClipRRect(
                      borderRadius: ally.shieldHp > 0
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(3),
                            )
                          : BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ally.currentHp / ally.totalMaxHp,
                        minHeight: 5,
                        color: _hpColor(ally.currentHp / ally.totalMaxHp),
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                ally.shieldHp > 0
                    ? '${ally.currentHp}/${ally.totalMaxHp} +${ally.shieldHp}'
                    : '${ally.currentHp}/${ally.totalMaxHp}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: ally.shieldHp > 0
                      ? Colors.cyan.shade200
                      : Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
            ] else
              Text(
                'KO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -- Enemy widget (vertical layout, same as ally) -------------------------
  Widget _buildEnemyWidget(ThemeData theme, Enemy enemy, bool isTarget) {
    final spriteSize = _spriteSize(_combat!.enemies.length);
    final spritePath = enemySpritePathByName(enemy.name);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isTarget ? Border.all(color: Colors.red, width: 2) : null,
          color: isTarget
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.4)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              enemy.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
                decoration: enemy.isAlive ? null : TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Opacity(
                opacity: enemy.isAlive ? 1.0 : 0.3,
                child: IdleAnimatedSprite(
                  imagePath: spritePath,
                  size: spriteSize,
                  phaseOffset: enemy.id.hashCode.toDouble(),
                  animate: enemy.isAlive,
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (enemy.isAlive) ...[
              SizedBox(
                width: spriteSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: enemy.currentHp / enemy.maxHp,
                    minHeight: 5,
                    color: Colors.red,
                    backgroundColor: Colors.black45,
                  ),
                ),
              ),
              Text(
                '${enemy.currentHp}/${enemy.maxHp}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
            ] else
              Text(
                'Defeated',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Adaptive sprite size based on how many combatants in the column.
  double _spriteSize(int count) {
    if (count <= 4) return 96;
    if (count <= 6) return 72;
    if (count <= 8) return 56;
    return 48;
  }

  // -- Ability bar ----------------------------------------------------------
  Widget _buildAbilityBar(ThemeData theme) {
    final current = _combat!.currentCombatant;
    final char = _combat!.allies.firstWhere((c) => c.id == current.id);
    final abilities = char.abilities
        .where((a) => a.unlockedAtLevel <= char.level)
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                classSpritePath(char.characterClass),
                width: 24,
                height: 24,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _potionMode
                      ? '${char.name} - Choose potion target'
                      : _selectedAbility == null
                      ? '${char.name} - Choose ability'
                      : '${char.name} - Choose target',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Potion button
                if ((ref.read(gameStateProvider)?.healthPotions ?? 0) > 0)
                  _buildAbilityBox(
                    theme: theme,
                    label:
                        'Potion (${ref.read(gameStateProvider)!.healthPotions})',
                    iconWidget: Icon(
                      Icons.local_drink,
                      size: 96,
                      color: _potionMode
                          ? theme.colorScheme.onTertiary
                          : Colors.red.shade400,
                    ),
                    isSelected: _potionMode,
                    canUse: true,
                    selectedColor: theme.colorScheme.tertiary,
                    onTap: () {
                      setState(() {
                        _potionMode = !_potionMode;
                        _selectedAbility = null;
                      });
                      if (_potionMode) {
                        final alive = _combat!.allies
                            .where((a) => a.isAlive)
                            .toList();
                        if (alive.length == 1) {
                          _usePotion(alive.first);
                        }
                      }
                    },
                  ),
                // Ability boxes
                ...abilities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ability = entry.value;
                  final isSelected = _selectedAbility?.name == ability.name;
                  final canUse = ability.isAvailable;

                  return _buildAbilityBox(
                    theme: theme,
                    label: ability.name,
                    keyNumber: index < 5 ? index + 1 : null,
                    iconWidget: Image.asset(
                      abilityIconPath(ability.name),
                      width: 128,
                      height: 128,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        ability.damage < 0
                            ? Icons.favorite
                            : Icons.auto_awesome,
                        size: 28,
                      ),
                    ),
                    isSelected: isSelected,
                    canUse: canUse,
                    onTap: canUse
                        ? () {
                            if (ref.read(helpModeProvider)) {
                              ref.read(helpModeProvider.notifier).state = false;
                              showAbilityHelp(context, ability);
                              return;
                            }
                            setState(() {
                              _selectedAbility = ability;
                              _potionMode = false;
                            });
                            if (ability.targetType == AbilityTarget.self) {
                              _useAbility(ability, char);
                            } else if (ability.targetType ==
                                    AbilityTarget.allEnemies ||
                                ability.targetType == AbilityTarget.allAllies) {
                              _useAbility(ability, null);
                            } else if (ability.minTargets > 0) {
                              _useAbility(ability, null);
                            } else if (ability.targetType ==
                                AbilityTarget.singleEnemy) {
                              final alive = _combat!.enemies
                                  .where((e) => e.isAlive)
                                  .toList();
                              if (alive.length == 1) {
                                _useAbility(ability, alive.first);
                              }
                            } else if (ability.targetType ==
                                AbilityTarget.singleAlly) {
                              final alive = _combat!.allies
                                  .where((a) => a.isAlive)
                                  .toList();
                              if (alive.length == 1) {
                                _useAbility(ability, alive.first);
                              }
                            }
                          }
                        : null,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Ability box widget ---------------------------------------------------
  Widget _buildAbilityBox({
    required ThemeData theme,
    required String label,
    required Widget iconWidget,
    required bool isSelected,
    required bool canUse,
    int? keyNumber,
    Color? selectedColor,
    VoidCallback? onTap,
  }) {
    final bgColor = isSelected
        ? (selectedColor ?? theme.colorScheme.primary)
        : !canUse
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHigh;
    final fgColor = isSelected
        ? (selectedColor != null
              ? theme.colorScheme.onTertiary
              : theme.colorScheme.onPrimary)
        : !canUse
        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
        : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: canUse ? 1.0 : 0.5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 170,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(bgColor, Colors.white, 0.15)!,
                    bgColor,
                    Color.lerp(bgColor, Colors.black, 0.15)!,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (selectedColor ?? theme.colorScheme.primary)
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isSelected
                                ? (selectedColor ?? theme.colorScheme.primary)
                                : Colors.black)
                            .withValues(alpha: 0.4),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 3),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: (selectedColor ?? theme.colorScheme.primary)
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: fgColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 128,
                    height: 128,
                    child: FittedBox(fit: BoxFit.contain, child: iconWidget),
                  ),
                ],
              ),
            ),
            if (keyNumber != null)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$keyNumber',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -- Combat end bar -------------------------------------------------------
  Widget _buildCombatEndBar(ThemeData theme) {
    final isVictory = _combat!.isVictory;
    return Container(
      padding: const EdgeInsets.all(16),
      color: isVictory
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
      child: Column(
        children: [
          if (isVictory) ...[
            Text(
              'Victory!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '+${_combat!.enemies.fold(0, (sum, e) => sum + e.xpReward)} XP  '
              '+${_combat!.enemies.fold(0, (sum, e) => sum + e.goldReward)} Gold',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else
            Text(
              'Defeat...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _onCombatEnd,
              child: Text(isVictory ? 'Continue' : 'Game Over'),
            ),
          ),
        ],
      ),
    );
  }

  Color _hpColor(double ratio) {
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }
}

// ===========================================================================
// Attack line painter
// ===========================================================================
class _AttackLinePainter extends CustomPainter {
  final List<_AttackLineData> lines;
  final Offset Function(String id) positionOf;
  final double progress; // 0.0 → 1.0

  _AttackLinePainter({
    required this.lines,
    required this.positionOf,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final from = positionOf(line.attackerId);
      final to = positionOf(line.targetId);
      _paintLine(canvas, from, to, line);
    }
  }

  void _paintLine(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    if (line.isHealing && line.spellType == SpellType.summonFairy) {
      _paintSummonFairy(canvas, from, to, line);
    } else if (line.isHealing) {
      _paintHealBeam(canvas, from, to, line);
    } else if (line.spellType == SpellType.normal) {
      _paintStandardLine(canvas, from, to, line);
    } else {
      switch (line.spellType) {
        case SpellType.burningHands:
          _paintBurningHands(canvas, from, to, line);
          break;
        case SpellType.fireball:
          _paintFireball(canvas, from, to, line);
          break;
        case SpellType.iceStorm:
          _paintIceStorm(canvas, from, to, line);
          break;
        case SpellType.chainLightning:
          _paintChainLightning(canvas, from, to, line);
          break;
        case SpellType.meteor:
          _paintMeteor(canvas, from, to, line);
          break;
        case SpellType.summonWolf:
          _paintSummonWolf(canvas, from, to, line);
          break;
        case SpellType.summonGolem:
          _paintSummonGolem(canvas, from, to, line);
          break;
        case SpellType.summonFairy:
          _paintSummonFairy(canvas, from, to, line);
          break;
        case SpellType.summonShadow:
          _paintSummonShadow(canvas, from, to, line);
          break;
        case SpellType.skeletonAttack:
          _paintSkeletonAttack(canvas, from, to, line);
          break;
        case SpellType.normal:
          _paintStandardLine(canvas, from, to, line);
          break;
      }
    }
  }

  void _paintStandardLine(
    Canvas canvas,
    Offset from,
    Offset to,
    _AttackLineData line,
  ) {
    final Color color = line.isHealing
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF5722);
    final currentTo = Offset(
      from.dx + (to.dx - from.dx) * progress,
      from.dy + (to.dy - from.dy) * progress,
    );
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, currentTo, linePaint);
    if (progress < 1.0) {
      canvas.drawCircle(
        currentTo,
        5,
        Paint()..color = color.withValues(alpha: 0.7),
      );
    }
    if (progress > 0.5) {
      _drawDamageLabel(canvas, from, to, line.amount, line.isHealing, color,
          overkill: line.overkill);
    }
  }

  /// Heal glow: expanding glow on the target with yellow number.
  void _paintHealBeam(
    Canvas canvas,
    Offset from,
    Offset to,
    _AttackLineData line,
  ) {
    final gold = const Color(0xFFFFD700);
    final white = const Color(0xFFFFFDE7);
    final p = progress.clamp(0.0, 1.0);

    // Expanding glow rings on the target
    final glowAlpha = (1.0 - p * 0.6).clamp(0.0, 1.0);
    canvas.drawCircle(
      to,
      10 + p * 25,
      Paint()..color = gold.withValues(alpha: 0.25 * glowAlpha),
    );
    canvas.drawCircle(
      to,
      6 + p * 16,
      Paint()..color = white.withValues(alpha: 0.3 * glowAlpha),
    );
    // Inner bright pulse
    canvas.drawCircle(
      to,
      4 + p * 8,
      Paint()..color = gold.withValues(alpha: 0.4 * glowAlpha),
    );

    // Sparkle particles around the target
    if (p > 0.1) {
      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * pi * 2 + p * 4;
        final radius = 8.0 + p * 18;
        final sparkleAlpha = (0.7 - p * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(to.dx + cos(angle) * radius, to.dy + sin(angle) * radius),
          2.0,
          Paint()..color = gold.withValues(alpha: sparkleAlpha),
        );
      }
    }

    // Yellow heal number above the target
    if (p > 0.2 && line.amount > 0) {
      final labelOpacity = ((p - 0.2) * 2).clamp(0.0, 1.0);
      // Float upward as animation progresses
      final floatY = (p - 0.2) * 20;
      final label = '+${line.amount}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: gold.withValues(alpha: labelOpacity),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 3),
              Shadow(color: gold, blurRadius: 6),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(to.dx - tp.width / 2, to.dy - 35 - floatY),
      );
    }
  }


  void _drawDamageLabel(
    Canvas canvas,
    Offset from,
    Offset to,
    int amount,
    bool isHealing,
    Color color, {
    int overkill = 0,
  }) {
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final label = isHealing ? '+$amount' : '-$amount';
    final overkillText = (!isHealing && overkill > 0) ? ' ($overkill overkill)' : '';
    final labelOpacity = ((progress - 0.5) * 2).clamp(0.0, 1.0);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: labelOpacity),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: color, blurRadius: 4)],
            ),
          ),
          if (overkillText.isNotEmpty)
            TextSpan(
              text: overkillText,
              style: TextStyle(
                color: const Color(0xFFFFD700).withValues(alpha: labelOpacity),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: color, blurRadius: 4)],
              ),
            ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelW = tp.width + 14;
    final labelH = tp.height + 8;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: mid, width: labelW, height: labelH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      labelRect,
      Paint()..color = color.withValues(alpha: 0.9 * labelOpacity),
    );
    tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
  }

  void _paintBurningHands(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final amount = line.amount;
    final fireOrange = const Color(0xFFFF6600);
    final fireYellow = const Color(0xFFFFD700);
    final fireRed = const Color(0xFFCC2200);

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final dirX = dx / dist;
    final dirY = dy / dist;
    final perpX = -dirY;
    final perpY = dirX;

    final reach = progress.clamp(0.0, 1.0);
    final currentDist = dist * reach;
    final coneHalfWidth = 28.0;
    final streamCount = 9;

    for (int i = 0; i < streamCount; i++) {
      final spread = (i / (streamCount - 1)) * 2.0 - 1.0;
      final endX = from.dx + dirX * currentDist +
          perpX * spread * coneHalfWidth * reach;
      final endY = from.dy + dirY * currentDist +
          perpY * spread * coneHalfWidth * reach;

      // Wavy fire stream
      final path = Path()..moveTo(from.dx, from.dy);
      final segs = 8;
      for (int s = 1; s <= segs; s++) {
        final t = s / segs;
        final baseX = from.dx + (endX - from.dx) * t;
        final baseY = from.dy + (endY - from.dy) * t;
        final wave = sin(t * pi * 4 + progress * 10 + i * 1.3) * 3 * t;
        path.lineTo(baseX + perpX * wave, baseY + perpY * wave);
      }

      final colors = [fireRed, fireOrange, fireYellow];
      final color = colors[i % 3];
      final width = 2.0 + (1.0 - spread.abs()) * 2.5;
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..strokeWidth = width
          ..style = PaintingStyle.stroke,
      );

      // Fire particles along each stream
      if (reach > 0.3) {
        final particleT = 0.4 + (i % 4) * 0.15;
        if (particleT <= 1.0) {
          final px = from.dx + (endX - from.dx) * particleT;
          final py = from.dy + (endY - from.dy) * particleT;
          canvas.drawCircle(
            Offset(px, py),
            2.5 + (1.0 - spread.abs()) * 2.5,
            Paint()..color = fireYellow.withValues(alpha: 0.7),
          );
        }
      }
    }

    // Glow at wizard's hands
    canvas.drawCircle(
      from, 10,
      Paint()..color = fireOrange.withValues(alpha: 0.3 * reach),
    );
    canvas.drawCircle(
      from, 6,
      Paint()..color = fireYellow.withValues(alpha: 0.5 * reach),
    );

    if (progress > 0.5) {
      _drawDamageLabel(canvas, from, to, amount, false, fireOrange,
          overkill: line.overkill);
    }
  }

  void _paintFireball(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final amount = line.amount;
    final darkRed = const Color(0xFF8B0000);
    final red = const Color(0xFFD60000);
    final yellow = const Color(0xFFFFD700);
    final progressPct = progress.clamp(0.0, 1.0);
    final currentTo = Offset(
      from.dx + (to.dx - from.dx) * progressPct,
      from.dy + (to.dy - from.dy) * progressPct,
    );
    final ballRadius = 6.0 + (progressPct * 12.0);
    // Outer dark ring
    canvas.drawCircle(currentTo, ballRadius, Paint()..color = darkRed);
    // Mid red ball
    canvas.drawCircle(currentTo, ballRadius * 0.7, Paint()..color = red);
    // Inner yellow core
    canvas.drawCircle(currentTo, ballRadius * 0.4, Paint()..color = yellow);
    // Explosion at impact
    if (progress >= 0.92) {
      final expRadius = ballRadius * 2.2;
      canvas.drawCircle(
        currentTo,
        expRadius,
        Paint()..color = darkRed.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        currentTo,
        expRadius * 0.7,
        Paint()..color = red.withValues(alpha: 0.5),
      );
      final overkillText = line.overkill > 0 ? ' (${line.overkill} overkill)' : '';
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '-$amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: darkRed, blurRadius: 6)],
              ),
            ),
            if (overkillText.isNotEmpty)
              TextSpan(
                text: overkillText,
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: darkRed, blurRadius: 6)],
                ),
              ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: currentTo,
            width: tp.width + 14,
            height: tp.height + 8,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = darkRed.withValues(alpha: 0.7),
      );
      tp.paint(
        canvas,
        Offset(currentTo.dx - tp.width / 2, currentTo.dy - tp.height / 2 - 15),
      );
    }
  }

  void _paintIceStorm(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final amount = line.amount;
    final iceBlue = const Color(0xFF00BFFF);
    final iceCyan = const Color(0xFF00FFFF);
    final iceWhite = const Color(0xFFE0F0FF);

    // Ice chunks fall from the sky (above target) down to the target
    final skyY = to.dy - 180;
    final chunkCount = 9;

    for (int i = 0; i < chunkCount; i++) {
      // Stagger each chunk's start time
      final delay = i * 0.07;
      final chunkProgress = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (chunkProgress <= 0) continue;

      // Scatter horizontally around the target
      final scatterX = (i - chunkCount ~/ 2) * 16.0 + (i.isEven ? 4 : -4);
      final startX = to.dx + scatterX;
      final startY = skyY + (i % 3) * 20.0;

      // Fall straight down to target area
      final chunkX = startX;
      final chunkY = startY + (to.dy - startY) * chunkProgress;

      // Draw angular ice crystal (diamond shape)
      final size = 5.0 + (i % 3) * 3.0;
      final path = Path()
        ..moveTo(chunkX, chunkY - size)
        ..lineTo(chunkX + size * 0.6, chunkY)
        ..lineTo(chunkX, chunkY + size * 0.7)
        ..lineTo(chunkX - size * 0.6, chunkY)
        ..close();

      final colors = [iceBlue, iceCyan, iceWhite];
      canvas.drawPath(path, Paint()..color = colors[i % 3].withValues(alpha: 0.85));
      canvas.drawPath(
        path,
        Paint()
          ..color = iceWhite
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );

      // Small trail above each falling chunk
      if (chunkProgress < 0.9) {
        canvas.drawLine(
          Offset(chunkX, chunkY - size - 6),
          Offset(chunkX, chunkY - size),
          Paint()
            ..color = iceCyan.withValues(alpha: 0.4)
            ..strokeWidth = 1.5,
        );
      }
    }

    // Impact frost ring at target when chunks land
    if (progress > 0.7) {
      final impactProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        to,
        18 * impactProgress,
        Paint()
          ..color = iceBlue.withValues(alpha: 0.3 * (1.0 - impactProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    if (progress > 0.6) {
      _drawDamageLabel(canvas, from, to, amount, false, iceBlue,
          overkill: line.overkill);
    }
  }

  void _paintChainLightning(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final amount = line.amount;
    final yellow = const Color(0xFFFFEB3B);
    final black = Colors.black;
    final xDiff = to.dx - from.dx;
    final yDiff = to.dy - from.dy;
    final currentProgress = progress.clamp(0.0, 1.0);
    // Draw jagged lightning bolt
    final points = <Offset>[from];
    final segments = 5;
    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      final baseX = from.dx + xDiff * t;
      final baseY = from.dy + yDiff * t;
      final offset = (sin(currentProgress * 8.0 * pi + i) * 12 * (1 - t));
      points.add(Offset(baseX + offset, baseY));
    }
    points.add(to);
    // Black outline
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i],
        points[i + 1],
        Paint()
          ..color = black
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke,
      );
    }
    // Yellow core
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i],
        points[i + 1],
        Paint()
          ..color = yellow
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }
    if (progress > 0.5) {
      _drawDamageLabel(canvas, from, to, amount, false, yellow,
          overkill: line.overkill);
    }
  }

  void _paintMeteor(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final amount = line.amount;
    final darkRed = const Color(0xFF8B0000);
    final orangeRed = const Color(0xFFFF4500);
    final gold = const Color(0xFFFFD700);
    final currentTo = Offset(
      from.dx + (to.dx - from.dx) * progress,
      from.dy + (to.dy - from.dy) * progress,
    );
    final meteorSize = 8.0 + (progress * 18.0);
    // Dark outer ring
    canvas.drawCircle(currentTo, meteorSize, Paint()..color = darkRed);
    // Orange mid layer
    canvas.drawCircle(currentTo, meteorSize * 0.75, Paint()..color = orangeRed);
    // Gold core
    canvas.drawCircle(currentTo, meteorSize * 0.5, Paint()..color = gold);
    // Explosion at impact
    if (progress >= 0.95) {
      final expRadius = meteorSize * 2.5;
      canvas.drawCircle(
        currentTo,
        expRadius,
        Paint()..color = darkRed.withValues(alpha: 0.25),
      );
      canvas.drawCircle(
        currentTo,
        expRadius * 0.7,
        Paint()..color = orangeRed.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        currentTo,
        expRadius * 0.4,
        Paint()..color = gold.withValues(alpha: 0.6),
      );
      final overkillText = line.overkill > 0 ? ' (${line.overkill} overkill)' : '';
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '-$amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: darkRed, blurRadius: 8)],
              ),
            ),
            if (overkillText.isNotEmpty)
              TextSpan(
                text: overkillText,
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: darkRed, blurRadius: 8)],
                ),
              ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: currentTo,
            width: tp.width + 14,
            height: tp.height + 8,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = darkRed.withValues(alpha: 0.8),
      );
      tp.paint(
        canvas,
        Offset(currentTo.dx - tp.width / 2, currentTo.dy - tp.height / 2 - 20),
      );
    }
  }

  // -- Summon Wolf: gray wolf shape lunges from summoner to target ----------
  void _paintSummonWolf(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final gray = const Color(0xFF9E9E9E);
    final darkGray = const Color(0xFF616161);
    final p = progress.clamp(0.0, 1.0);

    // Wolf lunges along the line
    final currentPos = Offset(
      from.dx + (to.dx - from.dx) * p,
      from.dy + (to.dy - from.dy) * p,
    );

    // Draw wolf shape (simple triangle head + body)
    final wolfSize = 10.0;
    final dir = (to - from);
    final dist = dir.distance;
    if (dist == 0) return;
    final nx = dir.dx / dist;
    final ny = dir.dy / dist;

    // Body (oval)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(currentPos.dx - nx * 6, currentPos.dy - ny * 6),
        width: wolfSize * 1.4,
        height: wolfSize * 0.8,
      ),
      Paint()..color = gray,
    );
    // Head (triangle pointing forward)
    final headPath = Path()
      ..moveTo(currentPos.dx + nx * wolfSize, currentPos.dy + ny * wolfSize)
      ..lineTo(currentPos.dx + ny * 5, currentPos.dy - nx * 5)
      ..lineTo(currentPos.dx - ny * 5, currentPos.dy + nx * 5)
      ..close();
    canvas.drawPath(headPath, Paint()..color = darkGray);

    // Ears
    canvas.drawCircle(
      Offset(currentPos.dx + ny * 4 + nx * 4, currentPos.dy - nx * 4 + ny * 4),
      3, Paint()..color = gray,
    );
    canvas.drawCircle(
      Offset(currentPos.dx - ny * 4 + nx * 4, currentPos.dy + nx * 4 + ny * 4),
      3, Paint()..color = gray,
    );

    // Trail particles
    for (int i = 0; i < 4; i++) {
      final trailT = (p - i * 0.06).clamp(0.0, 1.0);
      final tx = from.dx + (to.dx - from.dx) * trailT;
      final ty = from.dy + (to.dy - from.dy) * trailT;
      canvas.drawCircle(
        Offset(tx, ty), 2.0 - i * 0.4,
        Paint()..color = gray.withValues(alpha: 0.4 - i * 0.08),
      );
    }

    // Impact claw slash at target
    if (p > 0.85) {
      final slashAlpha = ((p - 0.85) / 0.15).clamp(0.0, 1.0);
      final slashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * slashAlpha)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      // Three diagonal claw marks
      for (int i = -1; i <= 1; i++) {
        canvas.drawLine(
          Offset(to.dx - 8 + i * 5, to.dy - 10),
          Offset(to.dx + 4 + i * 5, to.dy + 10),
          slashPaint,
        );
      }
    }

    if (p > 0.5) {
      _drawDamageLabel(canvas, from, to, line.amount, false, gray,
          overkill: line.overkill);
    }
  }

  // -- Summon Golem: shield glow from summoner to allies --------------------
  void _paintSummonGolem(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final brown = const Color(0xFF8D6E63);
    final gold = const Color(0xFFFFD700);
    final p = progress.clamp(0.0, 1.0);

    // Expanding shield ring at golem (summoner) position
    if (p < 0.5) {
      final ringP = (p / 0.5).clamp(0.0, 1.0);
      canvas.drawCircle(
        from,
        10 + ringP * 20,
        Paint()
          ..color = brown.withValues(alpha: 0.4 * (1.0 - ringP))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }

    // Shield glow traveling to ally
    final glowPos = Offset(
      from.dx + (to.dx - from.dx) * p,
      from.dy + (to.dy - from.dy) * p,
    );
    canvas.drawCircle(glowPos, 5, Paint()..color = gold.withValues(alpha: 0.5 * (1.0 - p)));
    canvas.drawCircle(glowPos, 3, Paint()..color = brown.withValues(alpha: 0.7 * (1.0 - p)));

    // Shield icon at ally when glow arrives
    if (p > 0.6) {
      final shieldP = ((p - 0.6) / 0.4).clamp(0.0, 1.0);
      final shieldAlpha = (0.7 * (1.0 - (shieldP - 0.5).abs() * 2)).clamp(0.0, 1.0);
      // Shield shape (pointed bottom)
      final shieldPath = Path()
        ..moveTo(to.dx - 10, to.dy - 10)
        ..lineTo(to.dx + 10, to.dy - 10)
        ..lineTo(to.dx + 10, to.dy + 2)
        ..lineTo(to.dx, to.dy + 12)
        ..lineTo(to.dx - 10, to.dy + 2)
        ..close();
      canvas.drawPath(
        shieldPath,
        Paint()..color = brown.withValues(alpha: shieldAlpha * 0.6),
      );
      canvas.drawPath(
        shieldPath,
        Paint()
          ..color = gold.withValues(alpha: shieldAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  // -- Summon Fairy: sparkle dust raining on healed ally --------------------
  void _paintSummonFairy(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final pink = const Color(0xFFFF80AB);
    final green = const Color(0xFF69F0AE);
    final gold = const Color(0xFFFFD700);
    final p = progress.clamp(0.0, 1.0);

    // Green/pink glow on the target
    final glowAlpha = (1.0 - p * 0.6).clamp(0.0, 1.0);
    canvas.drawCircle(to, 10 + p * 25, Paint()..color = green.withValues(alpha: 0.2 * glowAlpha));
    canvas.drawCircle(to, 6 + p * 16, Paint()..color = pink.withValues(alpha: 0.2 * glowAlpha));

    // Fairy dust sparkles around target
    if (p > 0.1) {
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * pi * 2 + p * 4;
        final radius = 8.0 + p * 18;
        final sparkleAlpha = (0.7 - p * 0.5).clamp(0.0, 1.0);
        final colors = [pink, green, gold];
        canvas.drawCircle(
          Offset(to.dx + cos(angle) * radius, to.dy + sin(angle) * radius),
          2.0,
          Paint()..color = colors[i % 3].withValues(alpha: sparkleAlpha),
        );
      }
    }

    // Yellow heal number
    if (p > 0.2 && line.amount > 0) {
      final labelOpacity = ((p - 0.2) * 2).clamp(0.0, 1.0);
      final floatY = (p - 0.2) * 20;
      final label = '+${line.amount}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: gold.withValues(alpha: labelOpacity),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 3),
              Shadow(color: gold, blurRadius: 6),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(to.dx - tp.width / 2, to.dy - 35 - floatY));
    }
  }

  // -- Summon Shadow: dark clouds drifting to enemies -----------------------
  void _paintSummonShadow(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final darkPurple = const Color(0xFF4A148C);
    final black = const Color(0xFF1A1A2E);
    final p = progress.clamp(0.0, 1.0);

    // Dark cloud drifts from summoner to enemy
    final cloudPos = Offset(
      from.dx + (to.dx - from.dx) * p,
      from.dy + (to.dy - from.dy) * p + sin(p * pi * 4) * 8,
    );

    // Cloud shape (cluster of overlapping circles)
    for (int i = 0; i < 5; i++) {
      final ox = (i - 2) * 5.0 + sin(p * 10 + i) * 2;
      final oy = (i.isEven ? -2.0 : 2.0) + cos(p * 8 + i) * 2;
      canvas.drawCircle(
        Offset(cloudPos.dx + ox, cloudPos.dy + oy),
        5.0 + (i % 3),
        Paint()..color = black.withValues(alpha: 0.6),
      );
    }
    canvas.drawCircle(cloudPos, 4, Paint()..color = darkPurple.withValues(alpha: 0.5));

    // Smoke trail
    for (int i = 0; i < 3; i++) {
      final trailT = (p - i * 0.08).clamp(0.0, 1.0);
      final tx = from.dx + (to.dx - from.dx) * trailT;
      final ty = from.dy + (to.dy - from.dy) * trailT + sin(trailT * pi * 4) * 8;
      canvas.drawCircle(
        Offset(tx, ty), 3.0 - i * 0.5,
        Paint()..color = darkPurple.withValues(alpha: 0.2 - i * 0.05),
      );
    }

    // Dark cloud impact at enemy
    if (p > 0.7) {
      final impP = ((p - 0.7) / 0.3).clamp(0.0, 1.0);
      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * pi * 2 + p * 3;
        final radius = 8.0 + impP * 12;
        canvas.drawCircle(
          Offset(to.dx + cos(angle) * radius, to.dy + sin(angle) * radius),
          3.0 + (i % 2) * 2,
          Paint()..color = black.withValues(alpha: 0.5 * (1.0 - impP)),
        );
      }
    }

    if (p > 0.5 && line.amount > 0) {
      _drawDamageLabel(canvas, from, to, line.amount, false, darkPurple,
          overkill: line.overkill);
    }
  }

  // -- Skeleton attack: bone projectile from necromancer to enemy -----------
  void _paintSkeletonAttack(Canvas canvas, Offset from, Offset to, _AttackLineData line) {
    final bone = const Color(0xFFE0E0E0);
    final dark = const Color(0xFF9E9E9E);
    final p = progress.clamp(0.0, 1.0);

    final currentPos = Offset(
      from.dx + (to.dx - from.dx) * p,
      from.dy + (to.dy - from.dy) * p,
    );

    // Spinning bone projectile
    final angle = p * pi * 6;
    final boneLen = 8.0;
    canvas.drawLine(
      Offset(currentPos.dx + cos(angle) * boneLen, currentPos.dy + sin(angle) * boneLen),
      Offset(currentPos.dx - cos(angle) * boneLen, currentPos.dy - sin(angle) * boneLen),
      Paint()..color = bone..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
    // Knobs on ends
    canvas.drawCircle(
      Offset(currentPos.dx + cos(angle) * boneLen, currentPos.dy + sin(angle) * boneLen),
      2.5, Paint()..color = bone,
    );
    canvas.drawCircle(
      Offset(currentPos.dx - cos(angle) * boneLen, currentPos.dy - sin(angle) * boneLen),
      2.5, Paint()..color = bone,
    );

    // Trail
    for (int i = 0; i < 3; i++) {
      final trailT = (p - i * 0.05).clamp(0.0, 1.0);
      final tx = from.dx + (to.dx - from.dx) * trailT;
      final ty = from.dy + (to.dy - from.dy) * trailT;
      canvas.drawCircle(
        Offset(tx, ty), 2.0 - i * 0.5,
        Paint()..color = dark.withValues(alpha: 0.3 - i * 0.08),
      );
    }

    // Impact
    if (p > 0.85) {
      final impAlpha = ((p - 0.85) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(to, 12 * impAlpha,
        Paint()..color = bone.withValues(alpha: 0.3 * (1.0 - impAlpha)));
    }

    if (p > 0.5) {
      _drawDamageLabel(canvas, from, to, line.amount, false, dark,
          overkill: line.overkill);
    }
  }

  @override
  bool shouldRepaint(covariant _AttackLinePainter old) => true;
}

// ===========================================================================
// Summon icon painter (small icons under summoner sprite)
// ===========================================================================
class _SummonIconPainter extends CustomPainter {
  final String summonId;
  _SummonIconPainter(this.summonId);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 96; // scale factor (96 = default sprite size)

    switch (summonId) {
      case 'wolf':
        // Gray wolf — body, head, snout, ears, legs, tail
        final body = Paint()..color = const Color(0xFF9E9E9E);
        final dark = Paint()..color = const Color(0xFF616161);
        final eye = Paint()..color = const Color(0xFFFFEB3B);
        // Body
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 4 * s), width: 40 * s, height: 24 * s),
          body,
        );
        // Head
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 18 * s, cy - 6 * s), width: 22 * s, height: 18 * s),
          body,
        );
        // Snout
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 28 * s, cy - 4 * s), width: 12 * s, height: 8 * s),
          dark,
        );
        // Ears
        final earPath = Path()
          ..moveTo(cx + 14 * s, cy - 14 * s)
          ..lineTo(cx + 10 * s, cy - 26 * s)
          ..lineTo(cx + 20 * s, cy - 16 * s)
          ..close();
        canvas.drawPath(earPath, dark);
        final earPath2 = Path()
          ..moveTo(cx + 22 * s, cy - 14 * s)
          ..lineTo(cx + 20 * s, cy - 26 * s)
          ..lineTo(cx + 28 * s, cy - 16 * s)
          ..close();
        canvas.drawPath(earPath2, dark);
        // Eyes
        canvas.drawCircle(Offset(cx + 22 * s, cy - 10 * s), 3 * s, eye);
        canvas.drawCircle(Offset(cx + 22 * s, cy - 10 * s), 1.5 * s, Paint()..color = Colors.black);
        // Legs
        for (final lx in [-12.0, -4.0, 8.0, 16.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(cx + lx * s, cy + 14 * s, 6 * s, 16 * s),
              Radius.circular(2 * s),
            ),
            dark,
          );
        }
        // Tail
        final tailPath = Path()
          ..moveTo(cx - 20 * s, cy)
          ..quadraticBezierTo(cx - 32 * s, cy - 14 * s, cx - 26 * s, cy - 22 * s);
        canvas.drawPath(tailPath, Paint()
          ..color = const Color(0xFF9E9E9E)
          ..strokeWidth = 4 * s
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

      case 'golem':
        // Brown/gray rock golem — blocky humanoid
        final rock = Paint()..color = const Color(0xFF8D6E63);
        final darkRock = Paint()..color = const Color(0xFF6D4C41);
        final highlight = Paint()..color = const Color(0xFFA1887F);
        final eye = Paint()..color = const Color(0xFFFFD54F);
        // Body (large rectangle)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + 2 * s), width: 32 * s, height: 30 * s),
            Radius.circular(4 * s),
          ),
          rock,
        );
        // Head
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy - 18 * s), width: 22 * s, height: 18 * s),
            Radius.circular(3 * s),
          ),
          darkRock,
        );
        // Eyes (glowing)
        canvas.drawCircle(Offset(cx - 5 * s, cy - 20 * s), 3 * s, eye);
        canvas.drawCircle(Offset(cx + 5 * s, cy - 20 * s), 3 * s, eye);
        // Arms (thick rectangles)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 24 * s, cy - 8 * s, 10 * s, 24 * s),
            Radius.circular(3 * s),
          ),
          darkRock,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 14 * s, cy - 8 * s, 10 * s, 24 * s),
            Radius.circular(3 * s),
          ),
          darkRock,
        );
        // Legs
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 12 * s, cy + 16 * s, 10 * s, 16 * s),
            Radius.circular(2 * s),
          ),
          darkRock,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 2 * s, cy + 16 * s, 10 * s, 16 * s),
            Radius.circular(2 * s),
          ),
          darkRock,
        );
        // Rock texture lines
        canvas.drawLine(
          Offset(cx - 10 * s, cy - 4 * s), Offset(cx + 8 * s, cy),
          highlight..style = PaintingStyle.stroke..strokeWidth = 1.5 * s,
        );
        canvas.drawLine(
          Offset(cx - 6 * s, cy + 8 * s), Offset(cx + 12 * s, cy + 6 * s),
          highlight..style = PaintingStyle.stroke..strokeWidth = 1.5 * s,
        );

      case 'fairy':
        // Glowing fairy with wings
        final green = Paint()..color = const Color(0xFF69F0AE);
        final pink = const Color(0xFFFF80AB);
        final glow = Paint()..color = const Color(0xFFFFF9C4);
        // Outer glow
        canvas.drawCircle(Offset(cx, cy), 16 * s,
          Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.15));
        // Wings (large, translucent)
        final leftWing = Path()
          ..moveTo(cx, cy)
          ..quadraticBezierTo(cx - 28 * s, cy - 20 * s, cx - 16 * s, cy - 30 * s)
          ..quadraticBezierTo(cx - 6 * s, cy - 16 * s, cx, cy)
          ..close();
        final rightWing = Path()
          ..moveTo(cx, cy)
          ..quadraticBezierTo(cx + 28 * s, cy - 20 * s, cx + 16 * s, cy - 30 * s)
          ..quadraticBezierTo(cx + 6 * s, cy - 16 * s, cx, cy)
          ..close();
        final leftWingLow = Path()
          ..moveTo(cx, cy + 2 * s)
          ..quadraticBezierTo(cx - 22 * s, cy + 6 * s, cx - 14 * s, cy + 20 * s)
          ..quadraticBezierTo(cx - 4 * s, cy + 10 * s, cx, cy + 2 * s)
          ..close();
        final rightWingLow = Path()
          ..moveTo(cx, cy + 2 * s)
          ..quadraticBezierTo(cx + 22 * s, cy + 6 * s, cx + 14 * s, cy + 20 * s)
          ..quadraticBezierTo(cx + 4 * s, cy + 10 * s, cx, cy + 2 * s)
          ..close();
        final wingPaint = Paint()..color = pink.withValues(alpha: 0.5);
        canvas.drawPath(leftWing, wingPaint);
        canvas.drawPath(rightWing, wingPaint);
        canvas.drawPath(leftWingLow, wingPaint);
        canvas.drawPath(rightWingLow, wingPaint);
        // Wing outlines
        final wingStroke = Paint()
          ..color = pink.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s;
        canvas.drawPath(leftWing, wingStroke);
        canvas.drawPath(rightWing, wingStroke);
        // Body
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 10 * s, height: 16 * s),
          green,
        );
        // Head
        canvas.drawCircle(Offset(cx, cy - 10 * s), 6 * s, green);
        // Face glow
        canvas.drawCircle(Offset(cx, cy - 10 * s), 4 * s, glow);
        // Eyes
        canvas.drawCircle(Offset(cx - 2.5 * s, cy - 11 * s), 1.5 * s, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(cx + 2.5 * s, cy - 11 * s), 1.5 * s, Paint()..color = Colors.black);

      case 'shadow':
        // Dark ghost — wispy, translucent
        final darkPurple = const Color(0xFF4A148C);
        final ghostBody = Paint()..color = darkPurple.withValues(alpha: 0.7);
        final eyeColor = Paint()..color = const Color(0xFFCE93D8);
        // Main ghost shape
        final ghostPath = Path()
          ..moveTo(cx - 20 * s, cy + 20 * s)
          ..quadraticBezierTo(cx - 24 * s, cy - 10 * s, cx, cy - 28 * s)
          ..quadraticBezierTo(cx + 24 * s, cy - 10 * s, cx + 20 * s, cy + 20 * s)
          // Wavy bottom
          ..lineTo(cx + 14 * s, cy + 12 * s)
          ..lineTo(cx + 8 * s, cy + 20 * s)
          ..lineTo(cx + 2 * s, cy + 12 * s)
          ..lineTo(cx - 4 * s, cy + 20 * s)
          ..lineTo(cx - 10 * s, cy + 12 * s)
          ..lineTo(cx - 16 * s, cy + 20 * s)
          ..close();
        canvas.drawPath(ghostPath, ghostBody);
        // Darker inner shadow
        canvas.drawPath(ghostPath, Paint()
          ..color = Colors.black.withValues(alpha: 0.2));
        // Eyes (hollow, glowing)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 7 * s, cy - 8 * s), width: 10 * s, height: 12 * s),
          eyeColor,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 7 * s, cy - 8 * s), width: 10 * s, height: 12 * s),
          eyeColor,
        );
        // Dark pupils
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 7 * s, cy - 6 * s), width: 5 * s, height: 7 * s),
          Paint()..color = Colors.black,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 7 * s, cy - 6 * s), width: 5 * s, height: 7 * s),
          Paint()..color = Colors.black,
        );
        // Mouth
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 6 * s), width: 10 * s, height: 8 * s),
          Paint()..color = Colors.black.withValues(alpha: 0.6),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _SummonIconPainter old) => old.summonId != summonId;
}

// ===========================================================================
// Skeleton pack painter (overlapping skeletons with count)
// ===========================================================================
class _SkeletonPackPainter extends CustomPainter {
  final int count;
  _SkeletonPackPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 96;

    final bone = const Color(0xFFE0E0E0);
    final darkBone = const Color(0xFFBDBDBD);
    final eyeColor = const Color(0xFF1B5E20);

    // Draw overlapping skulls (up to 3 visible, offset)
    final visible = count.clamp(1, 3);
    for (int i = visible - 1; i >= 0; i--) {
      final ox = i * 8.0 * s;
      final oy = i * -4.0 * s;
      final alpha = i == 0 ? 1.0 : 0.6 - i * 0.15;

      // Rib cage / body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx + ox, cy + 10 * s + oy), width: 20 * s, height: 24 * s),
          Radius.circular(4 * s),
        ),
        Paint()..color = darkBone.withValues(alpha: alpha * 0.7),
      );
      // Ribs
      for (int r = 0; r < 3; r++) {
        canvas.drawLine(
          Offset(cx + ox - 8 * s, cy + (2 + r * 6) * s + oy),
          Offset(cx + ox + 8 * s, cy + (2 + r * 6) * s + oy),
          Paint()
            ..color = bone.withValues(alpha: alpha * 0.5)
            ..strokeWidth = 1.5 * s
            ..style = PaintingStyle.stroke,
        );
      }

      // Skull
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + ox, cy - 14 * s + oy), width: 22 * s, height: 20 * s),
        Paint()..color = bone.withValues(alpha: alpha),
      );
      // Eye sockets
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + ox - 5 * s, cy - 16 * s + oy), width: 7 * s, height: 8 * s),
        Paint()..color = eyeColor.withValues(alpha: alpha),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + ox + 5 * s, cy - 16 * s + oy), width: 7 * s, height: 8 * s),
        Paint()..color = eyeColor.withValues(alpha: alpha),
      );
      // Nose
      canvas.drawPath(
        Path()
          ..moveTo(cx + ox - 2 * s, cy - 10 * s + oy)
          ..lineTo(cx + ox + 2 * s, cy - 10 * s + oy)
          ..lineTo(cx + ox, cy - 7 * s + oy)
          ..close(),
        Paint()..color = Colors.black.withValues(alpha: alpha * 0.6),
      );
      // Jaw
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + ox, cy - 6 * s + oy), width: 14 * s, height: 8 * s),
        0, pi,
        false,
        Paint()
          ..color = darkBone.withValues(alpha: alpha)
          ..strokeWidth = 2 * s
          ..style = PaintingStyle.stroke,
      );

      // Arms (bone sticks)
      canvas.drawLine(
        Offset(cx + ox - 10 * s, cy + 4 * s + oy),
        Offset(cx + ox - 18 * s, cy + 18 * s + oy),
        Paint()..color = bone.withValues(alpha: alpha)..strokeWidth = 2.5 * s..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(cx + ox + 10 * s, cy + 4 * s + oy),
        Offset(cx + ox + 18 * s, cy + 18 * s + oy),
        Paint()..color = bone.withValues(alpha: alpha)..strokeWidth = 2.5 * s..strokeCap = StrokeCap.round,
      );

      // Legs
      canvas.drawLine(
        Offset(cx + ox - 4 * s, cy + 22 * s + oy),
        Offset(cx + ox - 6 * s, cy + 34 * s + oy),
        Paint()..color = bone.withValues(alpha: alpha)..strokeWidth = 2.5 * s..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(cx + ox + 4 * s, cy + 22 * s + oy),
        Offset(cx + ox + 6 * s, cy + 34 * s + oy),
        Paint()..color = bone.withValues(alpha: alpha)..strokeWidth = 2.5 * s..strokeCap = StrokeCap.round,
      );
    }

    // Count badge
    if (count > 0) {
      final badgeCenter = Offset(cx + 16 * s, cy - 26 * s);
      canvas.drawCircle(badgeCenter, 10 * s, Paint()..color = Colors.black.withValues(alpha: 0.7));
      canvas.drawCircle(badgeCenter, 10 * s, Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s);
      final tp = TextPainter(
        text: TextSpan(
          text: '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * s,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(badgeCenter.dx - tp.width / 2, badgeCenter.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPackPainter old) => old.count != count;
}
