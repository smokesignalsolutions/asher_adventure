import 'enums.dart';

class PlayerProfile {
  int legacyPoints;
  int totalLegacyPointsEarned;
  int totalRuns;
  int totalVictories;
  int furthestMap;
  List<CharacterClass> unlockedClasses;

  static const List<CharacterClass> starterClasses = [
    CharacterClass.fighter,
    CharacterClass.rogue,
    CharacterClass.cleric,
    CharacterClass.wizard,
  ];

  PlayerProfile({
    this.legacyPoints = 0,
    this.totalLegacyPointsEarned = 0,
    this.totalRuns = 0,
    this.totalVictories = 0,
    this.furthestMap = 0,
    List<CharacterClass>? unlockedClasses,
  }) : unlockedClasses = unlockedClasses ?? List.from(starterClasses);

  Map<String, dynamic> toJson() => {
    'legacyPoints': legacyPoints,
    'totalLegacyPointsEarned': totalLegacyPointsEarned,
    'totalRuns': totalRuns,
    'totalVictories': totalVictories,
    'furthestMap': furthestMap,
    'unlockedClasses': unlockedClasses.map((c) => c.index).toList(),
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    legacyPoints: json['legacyPoints'] ?? 0,
    totalLegacyPointsEarned: json['totalLegacyPointsEarned'] ?? 0,
    totalRuns: json['totalRuns'] ?? 0,
    totalVictories: json['totalVictories'] ?? 0,
    furthestMap: json['furthestMap'] ?? 0,
    unlockedClasses: json['unlockedClasses'] != null
        ? (json['unlockedClasses'] as List)
            .map((i) => CharacterClass.values[i])
            .toList()
        : null,
  );
}
