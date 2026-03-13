import 'dart:math';

class NameGenerator {
  static final _random = Random();

  static const _firstNames = [
    // Heroic / Fantasy names
    'Aldric', 'Brynn', 'Cedric', 'Dara', 'Elara', 'Finn', 'Gwyn',
    'Hadrian', 'Isolde', 'Jareth', 'Kira', 'Leoric', 'Mira', 'Nolan',
    'Ophelia', 'Percival', 'Quinn', 'Rowan', 'Sera', 'Theron',
    'Uma', 'Vex', 'Wren', 'Xander', 'Yara', 'Zephyr',
    'Ash', 'Bramble', 'Cleo', 'Drake', 'Ember', 'Flint',
    'Gareth', 'Hazel', 'Ivy', 'Jasper', 'Kellan', 'Luna',
    'Magnus', 'Nyx', 'Orion', 'Piper', 'Rook', 'Sable',
    'Thorn', 'Vale', 'Willow', 'Onyx', 'Sage', 'Basil',
  ];

  static final _usedNames = <String>{};

  static void reset() => _usedNames.clear();

  /// Generate a name like "Finn the Fighter"
  static String generate(String className) {
    String name;
    int attempts = 0;
    do {
      final first = _firstNames[_random.nextInt(_firstNames.length)];
      name = '$first the $className';
      attempts++;
      if (attempts > 100) {
        name = '$first the $className ${_random.nextInt(99)}';
        break;
      }
    } while (_usedNames.contains(name));

    _usedNames.add(name);
    return name;
  }
}
