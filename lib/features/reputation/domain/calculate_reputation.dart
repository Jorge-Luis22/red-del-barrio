import '../../directory/domain/provider_profile.dart';
import 'interaction.dart';

/// Reputación mostrada: mezcla la base de ejemplo con las calificaciones reales de este teléfono.
class ReputationSnapshot {
  const ReputationSnapshot({
    required this.average,
    required this.count,
    required this.realCount,
  });

  /// Promedio de 0 a 5 (0 si no hay calificaciones).
  final double average;

  /// Total de calificaciones (ejemplo + reales).
  final int count;

  /// Cuántas son reales (de tratos cerrados aquí).
  final int realCount;
}

ReputationSnapshot calculateReputation(
  ProviderProfile provider,
  List<Interaction> interactions,
) {
  final base = provider.exampleRatingCount;
  var sum = provider.exampleRating * base;
  for (final i in interactions) {
    sum += i.stars;
  }
  final total = base + interactions.length;
  return ReputationSnapshot(
    average: total == 0 ? 0 : sum / total,
    count: total,
    realCount: interactions.length,
  );
}
