import '../models/enums.dart';

/// Base gold cost per class tier for recruiting at taverns.
const Map<CharacterClass, int> recruitBaseCost = {
  // Starter tier — 40g base
  CharacterClass.fighter: 40,
  CharacterClass.rogue: 40,
  CharacterClass.cleric: 40,
  CharacterClass.wizard: 40,
  // Mid tier — 60g base
  CharacterClass.paladin: 60,
  CharacterClass.ranger: 60,
  CharacterClass.monk: 60,
  CharacterClass.barbarian: 60,
  CharacterClass.druid: 60,
  CharacterClass.spellsword: 60,
  // Advanced tier — 80g base
  CharacterClass.warlock: 80,
  CharacterClass.summoner: 80,
  CharacterClass.sorcerer: 80,
  CharacterClass.necromancer: 80,
  CharacterClass.artificer: 80,
  CharacterClass.templar: 80,
};

/// Total recruit cost = base + mapNumber * 20
int recruitCost(CharacterClass cls, int mapNumber) {
  return (recruitBaseCost[cls] ?? 60) + mapNumber * 20;
}
