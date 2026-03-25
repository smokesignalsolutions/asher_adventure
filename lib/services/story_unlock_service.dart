import 'dart:math';
import '../data/event_data.dart';
import '../models/character.dart';
import '../models/enums.dart';

class StoryUnlockResult {
  final CharacterClass characterClass;
  final int chapter;
  final String className;

  const StoryUnlockResult({
    required this.characterClass,
    required this.chapter,
    required this.className,
  });

  /// True if this unlock triggers an art tier upgrade (chapters 4 and 8).
  bool get isArtUpgrade => chapter == 4 || chapter == 8;

  /// LP reward for unlocking this chapter.
  /// Base: 5 × chapter number. Milestone bonus: +10 at chapter 4, +15 at chapter 8.
  int get lpReward {
    final base = 5 * chapter;
    if (chapter == 4) return base + 10;
    if (chapter == 8) return base + 15;
    return base;
  }
}

/// Determines which class (if any) should get a story unlock from an event.
/// Returns null if no eligible class found.
StoryUnlockResult? determineStoryUnlock({
  required String eventTheme,
  required List<Character> party,
  required Map<String, int> classStoryProgress,
  required int currentMapNumber,
  Random? rng,
}) {
  rng ??= Random();

  final affinityClasses = themeClassAffinities[eventTheme];
  if (affinityClasses == null) return null;

  // Max chapter that can be unlocked on this map
  final maxChapter = currentMapNumber >= 8 ? 8 : 7;

  // Get party classes that match the theme affinity
  final partyClasses = party.map((c) => c.characterClass).toSet();

  // Find eligible classes: in party, in affinity list, and have chapters left
  final eligible = affinityClasses.where((cls) {
    if (!partyClasses.contains(cls)) return false;
    final progress = classStoryProgress[cls.name] ?? 0;
    return progress < maxChapter;
  }).toList();

  if (eligible.isEmpty) return null;

  final chosen = eligible[rng.nextInt(eligible.length)];
  final currentProgress = classStoryProgress[chosen.name] ?? 0;
  final nextChapter = currentProgress + 1;

  return StoryUnlockResult(
    characterClass: chosen,
    chapter: nextChapter,
    className: chosen.name,
  );
}
