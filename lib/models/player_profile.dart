import 'enums.dart';

class PlayerProfile {
  int legacyPoints;
  int totalLegacyPointsEarned;
  int totalRuns;
  int totalVictories;
  int furthestMap;
  List<CharacterClass> unlockedClasses;
  Map<String, int> passiveBonuses;
  List<String> unlockedPerks;

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
    Map<String, int>? passiveBonuses,
    List<String>? unlockedPerks,
  }) : unlockedClasses = unlockedClasses ?? List.from(starterClasses),
       passiveBonuses = passiveBonuses ?? {},
       unlockedPerks = unlockedPerks ?? [];

  Map<String, dynamic> toJson() => {
    'legacyPoints': legacyPoints,
    'totalLegacyPointsEarned': totalLegacyPointsEarned,
    'totalRuns': totalRuns,
    'totalVictories': totalVictories,
    'furthestMap': furthestMap,
    'unlockedClasses': unlockedClasses.map((c) => c.index).toList(),
    'passiveBonuses': passiveBonuses,
    'unlockedPerks': unlockedPerks,
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
    passiveBonuses: json['passiveBonuses'] != null
        ? Map<String, int>.from(json['passiveBonuses'])
        : null,
    unlockedPerks: json['unlockedPerks'] != null
        ? List<String>.from(json['unlockedPerks'])
        : null,
  );
}
