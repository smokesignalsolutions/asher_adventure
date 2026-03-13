class GameConstants {
  static const int maxPartySize = 4;
  static const int totalMaps = 8;
  static const int columnsPerMap = 8;
  static const int minNodesPerColumn = 3;
  static const int maxNodesPerColumn = 5;
  static const int baseXpPerLevel = 100;
  static const double baseScoutChance = 0.30;
  static const double rangerScoutBonus = 0.15;
  static const double rogueScoutBonus = 0.10;

  // Army advancement: player moves per army column advance
  static const Map<String, double> armySpeed = {
    'easy': 3.0,
    'normal': 2.0,
    'hard': 1.5,
    'nightmare': 1.0,
  };

  // Initiative
  static const double minInitiativeRoll = 1.0;
  static const double maxInitiativeRoll = 20.0;
}
