enum SummonEffectType { wolfAttack, golemShield, fairyHeal, shadowWeaken }

class SummonEffect {
  final SummonEffectType type;
  final String summonerId;
  final String? targetId; // wolf: enemy, fairy: ally
  final List<String> targetIds; // golem: allies, shadow: enemies
  final int amount; // damage or heal
  final String logMessage;

  const SummonEffect({
    required this.type,
    required this.summonerId,
    this.targetId,
    this.targetIds = const [],
    this.amount = 0,
    required this.logMessage,
  });
}
