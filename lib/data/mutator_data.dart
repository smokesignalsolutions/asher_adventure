class MutatorDefinition {
  final String id;
  final String name;
  final String description;
  final Map<String, double> effects;

  const MutatorDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.effects,
  });
}

const List<MutatorDefinition> runMutators = [
  MutatorDefinition(
    id: 'blood_moon',
    name: 'Blood Moon',
    description: 'Enemies deal +15% damage, but drop +25% more gold',
    effects: {'enemy_damage': 1.15, 'gold_drop': 1.25},
  ),
  MutatorDefinition(
    id: 'merchant_holiday',
    name: "Merchant's Holiday",
    description: 'Shops have double inventory, but rest nodes only heal 30%',
    effects: {'shop_stock': 2.0, 'rest_heal': 0.3},
  ),
  MutatorDefinition(
    id: 'fog_of_war',
    name: 'Fog of War',
    description: 'Scouting is disabled, but treasure gives double loot',
    effects: {'scouting_disabled': 1.0, 'treasure_gold': 2.0},
  ),
  MutatorDefinition(
    id: 'veteran_army',
    name: 'Veteran Army',
    description: 'Army moves 25% faster, but army fights give double legacy points',
    effects: {'army_speed': 1.25, 'army_lp': 2.0},
  ),
  MutatorDefinition(
    id: 'blessed_run',
    name: 'Blessed Run',
    description: 'Healing is +30% effective, but shops cost +20%',
    effects: {'healing': 1.3, 'shop_cost': 1.2},
  ),
];

/// Get a mutator effect value. Returns 1.0 (no effect) if mutator is null or effect not found.
double getMutatorEffect(String? mutatorId, String effectKey) {
  if (mutatorId == null) return 1.0;
  for (final m in runMutators) {
    if (m.id == mutatorId) {
      return m.effects[effectKey] ?? 1.0;
    }
  }
  return 1.0;
}

/// Find a mutator definition by ID.
MutatorDefinition? getMutatorById(String? id) {
  if (id == null) return null;
  for (final m in runMutators) {
    if (m.id == id) return m;
  }
  return null;
}
