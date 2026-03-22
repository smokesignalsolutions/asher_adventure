import '../core/constants/game_constants.dart';
import '../data/class_data.dart';
import '../models/character.dart';

class ProgressionService {
  static int xpForLevel(int level) => level * GameConstants.baseXpPerLevel;

  static bool addXp(Character character, int amount) {
    character.xp += amount;
    bool leveled = false;
    while (character.xp >= xpForLevel(character.level)) {
      character.xp -= xpForLevel(character.level);
      levelUp(character);
      leveled = true;
    }
    return leveled;
  }

  static void levelUp(Character character) {
    final classDef = classDefinitions[character.characterClass];
    if (classDef == null) return;

    character.level++;
    character.maxHp += classDef.growthRates.hp;
    character.currentHp += classDef.growthRates.hp; // Heal the growth amount
    character.attack += classDef.growthRates.attack;
    character.defense += classDef.growthRates.defense;
    character.speed += classDef.growthRates.speed;
    character.magic += classDef.growthRates.magic;

    // Check for new abilities
    for (final ability in classDef.abilities) {
      if (ability.unlockedAtLevel == character.level) {
        final alreadyHas = character.abilities.any((a) => a.name == ability.name);
        if (!alreadyHas) {
          character.abilities.add(ability.copyWith());
        }
      }
    }
  }

  static int calculateCombatXp(int totalEnemyXp, int partySize) {
    // Everyone gets full XP
    return totalEnemyXp;
  }
}
