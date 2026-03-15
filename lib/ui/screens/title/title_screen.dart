import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/game_state.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/game_state_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/save_service.dart';
import '../../widgets/audio_controls.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  bool _isLoading = true;
  List<GameState?> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    await SaveService.migrateOldSave();
    final slots = await SaveService.loadAllSlots();
    setState(() {
      _slots = slots;
      _isLoading = false;
    });
  }

  bool get _hasAnySave => _slots.any((s) => s != null);

  void _showLoadDialog() {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SlotPickerSheet(
        title: 'Load Game',
        slots: _slots,
        onSlotTap: (slot) {
          Navigator.pop(ctx);
          _loadSlot(slot);
        },
        emptySlotTappable: false,
      ),
    );
  }

  void _showNewGameDialog() {
    ref.read(audioProvider.notifier).playSfx(SfxType.menuSelect);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SlotPickerSheet(
        title: 'Select Save Slot',
        slots: _slots,
        onSlotTap: (slot) {
          Navigator.pop(ctx);
          if (_slots[slot] != null) {
            _confirmOverwrite(slot);
          } else {
            _startNewInSlot(slot);
          }
        },
        emptySlotTappable: true,
      ),
    );
  }

  void _confirmOverwrite(int slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Overwrite Save?'),
        content: Text(
          'Slot ${slot + 1} has an existing game '
          '(Map ${_slots[slot]!.currentMapNumber}, '
          '${_slots[slot]!.party.length} heroes). '
          'Start a new game here?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startNewInSlot(slot);
            },
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSlot(int slot) async {
    await ref.read(gameStateProvider.notifier).loadGame(slot);
    if (mounted) context.go('/map');
  }

  void _startNewInSlot(int slot) {
    // Store chosen slot, then go to party select
    ref.read(gameStateProvider.notifier).loadGame(slot);
    context.go('/party-select');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const AudioMuteButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Asher's Adventure",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Grand Quest Awaits',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 220,
                      child: FilledButton.icon(
                        onPressed: _showNewGameDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('New Game'),
                      ),
                    ),
                    if (_hasAnySave) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 220,
                        child: FilledButton.tonalIcon(
                          onPressed: _showLoadDialog,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Load Game'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(audioProvider.notifier)
                              .playSfx(SfxType.menuSelect);
                          context.go('/help');
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Guide'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slot picker bottom sheet
// ---------------------------------------------------------------------------
class _SlotPickerSheet extends StatelessWidget {
  final String title;
  final List<GameState?> slots;
  final void Function(int slot) onSlotTap;
  final bool emptySlotTappable;

  const _SlotPickerSheet({
    required this.title,
    required this.slots,
    required this.onSlotTap,
    required this.emptySlotTappable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < slots.length; i++) ...[
            _buildSlotCard(context, theme, i, slots[i]),
            if (i < slots.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSlotCard(
      BuildContext context, ThemeData theme, int index, GameState? save) {
    final hasData = save != null;
    final tappable = hasData || emptySlotTappable;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: tappable ? null : theme.colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: tappable ? () => onSlotTap(index) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: hasData
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasData
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: hasData
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Map ${save.currentMapNumber} of 8 '
                            '- ${save.difficulty.name.toUpperCase()}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${save.party.length} hero${save.party.length == 1 ? '' : 'es'}'
                            '  |  ${save.gold}g'
                            '  |  Lv ${save.party.isEmpty ? 1 : save.party.first.level}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            save.party.map((c) => c.name.split(' ').first).join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Text(
                        'Empty Slot',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
              ),
              if (tappable)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
