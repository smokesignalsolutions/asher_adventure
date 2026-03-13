import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';

/// A compact audio control widget that shows a mute/unmute icon button.
/// Long-press or tap to toggle mute. Use [AudioControlsExpanded] for
/// a full volume slider.
class AudioMuteButton extends ConsumerWidget {
  const AudioMuteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);

    return IconButton(
      icon: Icon(
        audioState.isMuted ? Icons.volume_off : Icons.volume_up,
      ),
      tooltip: audioState.isMuted ? 'Unmute' : 'Mute',
      onPressed: () => ref.read(audioProvider.notifier).toggleMute(),
    );
  }
}

/// Expanded audio controls with a volume slider and mute toggle.
class AudioControlsExpanded extends ConsumerWidget {
  const AudioControlsExpanded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final notifier = ref.read(audioProvider.notifier);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            audioState.isMuted ? Icons.volume_off : Icons.volume_up,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => notifier.toggleMute(),
        ),
        SizedBox(
          width: 120,
          child: Slider(
            value: audioState.isMuted ? 0.0 : audioState.volume,
            onChanged: audioState.isMuted
                ? null
                : (value) => notifier.setVolume(value),
          ),
        ),
      ],
    );
  }
}
