import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/help_mode_provider.dart';

class HelpButton extends ConsumerWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpMode = ref.watch(helpModeProvider);

    return IconButton(
      icon: Icon(
        helpMode ? Icons.help : Icons.help_outline,
        color: helpMode ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: helpMode ? 'Disable help mode' : 'Enable help mode',
      onPressed: () {
        ref.read(helpModeProvider.notifier).state = !helpMode;
      },
    );
  }
}
