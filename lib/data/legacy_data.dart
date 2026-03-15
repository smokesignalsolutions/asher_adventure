// lib/data/legacy_data.dart

class PassiveBonusDefinition {
  final String id;
  final String name;
  final String description;
  final int costPerRank;
  final int maxRanks;

  const PassiveBonusDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.costPerRank,
    required this.maxRanks,
  });
}

class StartingPerkDefinition {
  final String id;
  final String name;
  final String description;
  final int cost;

  const StartingPerkDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });
}

const List<PassiveBonusDefinition> passiveBonuses = [
  PassiveBonusDefinition(id: 'hp', name: '+5 Max HP', description: 'All characters start with +5 max HP per rank', costPerRank: 25, maxRanks: 10),
  PassiveBonusDefinition(id: 'attack', name: '+1 Attack', description: 'All characters start with +1 attack per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'defense', name: '+1 Defense', description: 'All characters start with +1 defense per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'speed', name: '+1 Speed', description: 'All characters start with +1 speed per rank', costPerRank: 40, maxRanks: 3),
  PassiveBonusDefinition(id: 'magic', name: '+1 Magic', description: 'All characters start with +1 magic per rank', costPerRank: 30, maxRanks: 5),
  PassiveBonusDefinition(id: 'shop_discount', name: '+5% Shop Discount', description: 'Reduces purchase prices by 5% per rank', costPerRank: 20, maxRanks: 4),
  PassiveBonusDefinition(id: 'ability_refresh', name: '+10% Ability Refresh', description: 'Abilities have +10% refresh chance per rank (additive)', costPerRank: 50, maxRanks: 3),
  PassiveBonusDefinition(id: 'health_potion', name: '+1 Starting Potion', description: 'Start each run with +1 health potion per rank', costPerRank: 15, maxRanks: 3),
  PassiveBonusDefinition(id: 'army_delay', name: 'Army Delay', description: 'Army starts 1 column further back per rank', costPerRank: 75, maxRanks: 2),
];

const List<StartingPerkDefinition> startingPerks = [
  StartingPerkDefinition(id: 'scavenger', name: 'Scavenger', description: 'Start with a random common weapon', cost: 25),
  StartingPerkDefinition(id: 'merchant_purse', name: "Merchant's Purse", description: 'Start with 50 gold', cost: 20),
  StartingPerkDefinition(id: 'scout_eye', name: "Scout's Eye", description: 'All adjacent nodes start scouted on map 1', cost: 40),
  StartingPerkDefinition(id: 'veteran', name: 'Veteran', description: 'Start at level 2', cost: 60),
  StartingPerkDefinition(id: 'lucky', name: 'Lucky', description: '+10% treasure quality', cost: 45),
  StartingPerkDefinition(id: 'army_intel', name: 'Army Intel', description: 'Army moves 20% slower on map 1', cost: 35),
  StartingPerkDefinition(id: 'healer_blessing', name: "Healer's Blessing", description: 'Start with a shield equal to 20% max HP (absorbs damage first)', cost: 30),
];
