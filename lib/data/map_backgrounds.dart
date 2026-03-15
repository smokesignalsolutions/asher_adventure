// Background themes per map number.
// Each map has a primary background (used on the map screen)
// and a list of combat variations (randomly picked for fights).

class MapTheme {
  final String primary;
  final List<String> combatVariations;

  const MapTheme(this.primary, this.combatVariations);
}

const _base = 'assets/sprites/backgrounds';

final Map<int, MapTheme> mapThemes = {
  1: MapTheme('$_base/meadow.png', ['$_base/meadow.png', '$_base/forest.png']),
  2: MapTheme('$_base/forest.png', ['$_base/forest.png', '$_base/swamp.png']),
  3: MapTheme('$_base/desert.png', ['$_base/desert.png', '$_base/ruins.png']),
  4: MapTheme('$_base/mountain.png', ['$_base/mountain.png', '$_base/cave.png']),
  5: MapTheme('$_base/swamp.png', ['$_base/swamp.png', '$_base/ruins.png']),
  6: MapTheme('$_base/snow.png', ['$_base/snow.png', '$_base/mountain.png']),
  7: MapTheme('$_base/ruins.png', ['$_base/ruins.png', '$_base/cave.png']),
  8: MapTheme('$_base/castle.png', ['$_base/castle.png', '$_base/cave.png']),
};

/// Get the map screen background for a given map number.
String mapBackground(int mapNumber) {
  return mapThemes[mapNumber]?.primary ?? '$_base/meadow.png';
}

/// Get a random combat background for a given map number.
String combatBackground(int mapNumber) {
  final variations = mapThemes[mapNumber]?.combatVariations ?? ['$_base/meadow.png'];
  return (variations.toList()..shuffle()).first;
}
