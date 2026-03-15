import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/ability_icons.dart';
import '../../widgets/idle_animated_sprite.dart';
import '../../../data/sprite_data.dart';
import '../../../models/ability.dart';
import '../../../models/character.dart';
import '../../../models/combat_state.dart';
import '../../../models/enemy.dart';
import '../../../models/enums.dart';
import '../../../data/map_backgrounds.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../services/audio_service.dart';
import '../../../data/mutator_data.dart';
import '../../../services/combat_service.dart';

// ---------------------------------------------------------------------------
// Attack line data
// ---------------------------------------------------------------------------
class _AttackLineData {
  final String attackerId;
  final String targetId;
  final int amount;
  final bool isHealing;
  final bool isSpell; // false = physical attack, true = magic/spell
  const _AttackLineData(this.attackerId, this.targetId, this.amount, this.isHealing, this.isSpell);
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
    _backgroundPath = 'assets/sprites/backgrounds/meadow.png'; // default, set in _initCombat
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCombat());
  }

  void _initCombat() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    _backgroundPath = combatBackground(gameState.currentMapNumber);
    _enemyDamageMultiplier = getMutatorEffect(gameState.activeMutator, 'enemy_damage');
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

      final log = CombatService.executeEnemyTurn(enemy, _combat!.allies, enemyDamageMultiplier: _enemyDamageMultiplier);

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
          lines.add(_AttackLineData(enemy.id, a.id, diff, false, isAoE || enemy.magic > enemy.attack));
        }
      }
      if (enemy.currentHp > enemyHpBefore) {
        lines.add(_AttackLineData(
            enemy.id, enemy.id, enemy.currentHp - enemyHpBefore, true, true));
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
  void _useAbility(Ability ability, dynamic target) {
    if (_combat == null) return;
    final current = _combat!.currentCombatant;
    final char = _combat!.allies.firstWhere((c) => c.id == current.id);

    // Snapshot HP before action
    final enemyHpBefore = {
      for (final e in _combat!.enemies) e.id: e.currentHp
    };
    final allyHpBefore = {
      for (final a in _combat!.allies) a.id: a.currentHp
    };

    String log;
    if (ability.darkPact) {
      // Dark Pact: special handling - sacrifice HP, damage all enemies
      if (!ability.isBasicAttack) ability.isAvailable = false;
      log = CombatService.executeDarkPact(
        char, _combat!.enemies.where((e) => e.isAlive).toList(),
      );
    } else if (ability.targetType == AbilityTarget.allEnemies) {
      final logs = <String>[];
      for (final enemy in _combat!.enemies.where((e) => e.isAlive)) {
        logs.add(CombatService.executeAllyTurn(char, ability, enemy, healingMultiplier: _healingMultiplier));
      }
      log = logs.join(' ');
    } else if (ability.targetType == AbilityTarget.allAllies) {
      final logs = <String>[];
      for (final ally in _combat!.allies.where((a) => a.isAlive)) {
        logs.add(CombatService.executeAllyTurn(char, ability, ally, healingMultiplier: _healingMultiplier));
      }
      log = logs.join(' ');
    } else {
      log = CombatService.executeAllyTurn(char, ability, target, healingMultiplier: _healingMultiplier);
    }

    // Chaotic bounce: 50% chance to hit another random enemy
    if (ability.chaotic) {
      final aliveEnemies = _combat!.enemies.where((e) => e.isAlive).toList();
      if (aliveEnemies.isNotEmpty && Random().nextInt(100) < 50) {
        final bounceTarget = aliveEnemies[Random().nextInt(aliveEnemies.length)];
        log += ' ${CombatService.executeChaoticBounce(char, ability, bounceTarget)}';
      }
    }

    // Build attack lines from HP diffs
    final isSpell = !ability.isBasicAttack;
    final lines = <_AttackLineData>[];
    for (final e in _combat!.enemies) {
      final diff = enemyHpBefore[e.id]! - e.currentHp;
      if (diff > 0) lines.add(_AttackLineData(char.id, e.id, diff, false, isSpell));
    }
    for (final a in _combat!.allies) {
      final diff = a.currentHp - allyHpBefore[a.id]!;
      if (diff > 0) lines.add(_AttackLineData(char.id, a.id, diff, true, true));
    }

    if (lines.isNotEmpty) {
      ref.read(audioProvider.notifier).playSfx(SfxType.attackHit);
    }

    setState(() {
      _combat!.combatLog.add(log);
      _attackLines = lines;
      _waitingForInput = false;
      _selectedAbility = null;
    });
    _scrollLog();
    _animateLines(holdMs: 300, onDone: _advanceTurn);
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
          '${char.name} uses a Health Potion on ${target.name}! (+$actualHeal HP)');
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
      final totalXp =
          _combat!.enemies.fold(0, (sum, e) => sum + e.xpReward);
      final totalGold =
          _combat!.enemies.fold(0, (sum, e) => sum + e.goldReward);
      final notifier = ref.read(gameStateProvider.notifier);

      // Determine if this was a boss fight
      final gameState = ref.read(gameStateProvider);
      final isBoss = gameState != null &&
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

  @override
  void dispose() {
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
      return Offset(
        size.width * 0.25 + sprite / 2 + 4, // right edge of ally sprite
        size.height * (allyIdx + 1) / (n + 1),
      );
    }
    final enemyIdx = _combat!.enemies.indexWhere((e) => e.id == id);
    if (enemyIdx >= 0) {
      final n = _combat!.enemies.length;
      final sprite = _spriteSize(n);
      return Offset(
        size.width * 0.75 - sprite / 2 - 4, // left edge of enemy sprite
        size.height * (enemyIdx + 1) / (n + 1),
      );
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
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final currentCombatant =
        _combat!.isComplete ? null : _combat!.currentCombatant;

    return Scaffold(
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
                      horizontal: 12, vertical: 4),
                  itemCount: _combat!.combatLog.length,
                  itemBuilder: (context, index) {
                    final text = _combat!.combatLog[index];
                    final isRoundHeader = text.startsWith('---');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isRoundHeader ? FontWeight.bold : null,
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
    );
  }

  // -- Top bar --------------------------------------------------------------
  Widget _buildTopBar(ThemeData theme, CombatantEntry? currentCombatant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          Text(
            'Round ${_combat!.roundNumber}',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
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
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : entry.isAlly
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(
                            color: theme.colorScheme.onPrimary, width: 2)
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
  Widget _buildBattlefield(
      ThemeData theme, CombatantEntry? currentCombatant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bfSize =
            Size(constraints.maxWidth, constraints.maxHeight);

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
              child: Container(
                  color: Colors.black.withValues(alpha: 0.15)),
            ),

            // Combatants row
            Positioned.fill(
              child: Row(
                children: [
                  // HEROES (left)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _combat!.allies.map((ally) {
                          final isCurrentTurn =
                              currentCombatant?.id == ally.id;
                          final isHealTarget = (_selectedAbility != null &&
                              _selectedAbility!.damage < 0 &&
                              _selectedAbility!.targetType ==
                                  AbilityTarget.singleAlly &&
                              ally.isAlive) ||
                              (_potionMode && ally.isAlive);
                          return Flexible(
                            child: GestureDetector(
                              onTap: isHealTarget
                                  ? () {
                                      if (_potionMode) {
                                        _usePotion(ally);
                                      } else {
                                        _useAbility(_selectedAbility!, ally);
                                      }
                                    }
                                  : null,
                              child: _buildAllyWidget(
                                  theme, ally, isCurrentTurn, isHealTarget),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // ENEMIES (right)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _combat!.enemies.map((enemy) {
                          final isTarget = _selectedAbility != null &&
                              _selectedAbility!.damage > 0 &&
                              _selectedAbility!.targetType ==
                                  AbilityTarget.singleEnemy &&
                              enemy.isAlive;
                          return Flexible(
                            child: GestureDetector(
                              onTap: isTarget
                                  ? () =>
                                      _useAbility(_selectedAbility!, enemy)
                                  : null,
                              child: _buildEnemyWidget(
                                  theme, enemy, isTarget),
                            ),
                          );
                        }).toList(),
                      ),
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

  // -- Ally widget (vertical: name, sprite, hp bar, hp text) ----------------
  Widget _buildAllyWidget(ThemeData theme, Character ally,
      bool isCurrentTurn, bool isHealTarget) {
    final spriteSize = _spriteSize(_combat!.allies.length);
    final spritePath = classSpritePath(ally.characterClass);

    return AnimatedContainer(
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
              decoration:
                  ally.isAlive ? null : TextDecoration.lineThrough,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Opacity(
              opacity: ally.isAlive ? 1.0 : 0.3,
              child: IdleAnimatedSprite(
                imagePath: spritePath,
                size: spriteSize,
                phaseOffset: ally.id.hashCode.toDouble(),
                animate: ally.isAlive,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (ally.isAlive) ...[
            SizedBox(
              width: spriteSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ally.currentHp / ally.totalMaxHp,
                  minHeight: 5,
                  color: _hpColor(ally.currentHp / ally.totalMaxHp),
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
            Text(
              '${ally.currentHp}/${ally.totalMaxHp}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2)
                ],
              ),
            ),
          ] else
            Text(
              'KO',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2)
                ],
              ),
            ),
        ],
      ),
    );
  }

  // -- Enemy widget (vertical layout, same as ally) -------------------------
  Widget _buildEnemyWidget(
      ThemeData theme, Enemy enemy, bool isTarget) {
    final spriteSize = _spriteSize(_combat!.enemies.length);
    final spritePath = enemySpritePathByName(enemy.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isTarget
            ? Border.all(color: Colors.red, width: 2)
            : null,
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
              decoration:
                  enemy.isAlive ? null : TextDecoration.lineThrough,
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
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2)
                ],
              ),
            ),
          ] else
            Text(
              'Defeated',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2)
                ],
              ),
            ),
        ],
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
    final abilities =
        char.abilities.where((a) => a.unlockedAtLevel <= char.level).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(
            top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3))),
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
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
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
                    label: 'Potion (${ref.read(gameStateProvider)!.healthPotions})',
                    iconWidget: Icon(
                      Icons.local_drink,
                      size: 80,
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
                ...abilities.map((ability) {
                  final isSelected =
                      _selectedAbility?.name == ability.name;
                  final canUse = ability.isAvailable;

                  return _buildAbilityBox(
                    theme: theme,
                    label: ability.name,
                    iconWidget: Image.asset(
                      abilityIconPath(ability.name),
                      width: 96,
                      height: 96,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(
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
                            setState(() {
                              _selectedAbility = ability;
                              _potionMode = false;
                            });
                            if (ability.targetType ==
                                AbilityTarget.self) {
                              _useAbility(ability, char);
                            } else if (ability.targetType ==
                                    AbilityTarget.allEnemies ||
                                ability.targetType ==
                                    AbilityTarget.allAllies) {
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
        child: Container(
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
                color: (isSelected
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
                width: 120,
                height: 120,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: iconWidget,
                ),
              ),
            ],
          ),
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
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
      _paintLine(canvas, from, to, line.amount, line.isHealing, line.isSpell);
    }
  }

  void _paintLine(
      Canvas canvas, Offset from, Offset to, int amount, bool isHealing, bool isSpell) {
    final Color color;
    if (isHealing) {
      color = const Color(0xFF4CAF50);
    } else if (isSpell) {
      color = const Color(0xFF7C4DFF);
    } else {
      color = const Color(0xFFFF5722);
    }

    // Current end point based on progress
    final currentTo = Offset(
      from.dx + (to.dx - from.dx) * progress,
      from.dy + (to.dy - from.dy) * progress,
    );

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw the line up to current progress
    canvas.drawLine(from, currentTo, linePaint);

    // Glowing tip at the leading edge
    if (progress < 1.0) {
      canvas.drawCircle(
        currentTo,
        5,
        Paint()..color = color.withValues(alpha: 0.7),
      );
    }

    // Show damage label once line is past halfway
    if (progress > 0.5) {
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final label = isHealing ? '+$amount' : '-$amount';
      final labelOpacity = ((progress - 0.5) * 2).clamp(0.0, 1.0);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: labelOpacity),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: color, blurRadius: 4)],
          ),
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
          labelRect, Paint()..color = color.withValues(alpha: 0.9 * labelOpacity));
      tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _AttackLinePainter old) => true;
}
