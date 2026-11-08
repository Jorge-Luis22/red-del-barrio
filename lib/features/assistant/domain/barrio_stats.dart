import '../../needs/domain/need.dart';
import '../../proposals/domain/deal.dart';
import '../../reputation/domain/interaction.dart';
import '../../solidarity/domain/offer.dart';

/// Resumen anonimizado de lo que pasa en el barrio: sin nombres ni textos de personas.
class BarrioStats {
  const BarrioStats({
    required this.needs,
    required this.byKind,
    required this.urgentNeeds,
    required this.offers,
    required this.freeOffers,
    required this.deals,
    required this.closedDeals,
    required this.averageStars,
    required this.isExample,
  });

  final int needs;
  final Map<NeedKind, int> byKind;

  /// Pedidos que se necesitan ahora o hoy.
  final int urgentNeeds;
  final int offers;
  final int freeOffers;
  final int deals;
  final int closedDeals;
  final double? averageStars;

  /// `true` = datos de ejemplo para mostrar el tablero, no de personas reales.
  final bool isExample;

  /// Tipo de pedido más frecuente; `null` si no hay pedidos.
  NeedKind? get topKind {
    NeedKind? best;
    var bestCount = 0;
    for (final e in byKind.entries) {
      if (e.value > bestCount) {
        best = e.key;
        bestCount = e.value;
      }
    }
    return best;
  }

  /// Porcentaje (0–100) de pedidos urgentes; 0 si no hay pedidos.
  int get urgentPercent => needs == 0 ? 0 : (urgentNeeds * 100 / needs).round();

  /// Datos ficticios, siempre rotulados como ejemplo en pantalla.
  static const example = BarrioStats(
    needs: 24,
    byKind: {
      NeedKind.service: 11,
      NeedKind.help: 7,
      NeedKind.loan: 4,
      NeedKind.product: 2,
    },
    urgentNeeds: 9,
    offers: 15,
    freeOffers: 10,
    deals: 12,
    closedDeals: 8,
    averageStars: 4.6,
    isExample: true,
  );

  factory BarrioStats.fromData({
    required List<Need> needs,
    required List<Offer> offers,
    required List<Deal> deals,
    required List<Interaction> interactions,
  }) {
    final byKind = <NeedKind, int>{};
    var urgent = 0;
    for (final n in needs) {
      byKind[n.kind] = (byKind[n.kind] ?? 0) + 1;
      if (n.urgency == Urgency.now || n.urgency == Urgency.today) urgent++;
    }
    final stars = interactions
        .where((i) => !i.isClientRating)
        .map((i) => i.stars)
        .toList();
    return BarrioStats(
      needs: needs.length,
      byKind: byKind,
      urgentNeeds: urgent,
      offers: offers.length,
      freeOffers: offers.where((o) => o.modality == Modality.free).length,
      deals: deals.length,
      closedDeals: deals.where((d) => d.status == DealStatus.closed).length,
      averageStars: stars.isEmpty
          ? null
          : stars.reduce((a, b) => a + b) / stars.length,
      isExample: false,
    );
  }
}
