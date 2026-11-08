import '../../needs/domain/need.dart';

/// Qué se está ofertando.
/// - [sale]: algo que se vende (un producto). Gana la oferta MÁS ALTA.
/// - [request]: alguien pide ayuda o un servicio. Gana la propuesta MÁS BAJA
///   (0 = intercambio solidario).
enum BidKind { sale, request }

/// Aquello sobre lo que se puede ofertar (un producto del directorio o un pedido del muro).
class BidSubject {
  const BidSubject({
    required this.id,
    required this.kind,
    required this.title,
    required this.byline,
    this.referenceSoles,
    this.referenceText,
  });

  final String id;
  final BidKind kind;
  final String title;

  /// Quién vende o quién pide.
  final String byline;

  /// Precio de referencia en soles, si el anuncio trae uno (por ejemplo "Bidón S/ 12").
  final int? referenceSoles;
  final String? referenceText;
}

/// Una oferta o propuesta. Las [isExample] son de DEMOSTRACIÓN (no hay otros vecinos reales
/// todavía) y la interfaz las rotula "Ejemplo".
class Bid {
  const Bid({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.bidder,
    required this.amountSoles,
    required this.createdAt,
    this.message = '',
    this.whenText = '',
    this.isMine = false,
    this.isExample = false,
    this.demoSlot = 0,
    this.syncStatus,
  });

  final String id;
  final String subjectId;
  final BidKind kind;
  final String bidder;
  final int amountSoles;
  final String message;

  /// "Hoy 4:00 p. m.": cuándo puede cumplir quien oferta.
  final String whenText;
  final DateTime createdAt;
  final bool isMine;
  final bool isExample;

  /// En las ofertas de ejemplo, qué mensaje y horario de demostración se muestran (el texto
  /// sale de los archivos de traducción, así que el dominio solo guarda el número).
  final int demoSlot;

  /// Solo en las ofertas propias: Pendiente / Enviada / Error.
  final SyncStatus? syncStatus;
}

/// Ordena de mejor a peor: en una venta gana el precio más alto; en un pedido, el más bajo.
/// A igual precio gana quien ofertó primero.
List<Bid> rankBids(BidKind kind, Iterable<Bid> bids) {
  final list = bids.toList();
  list.sort((a, b) {
    final byPrice = kind == BidKind.sale
        ? b.amountSoles.compareTo(a.amountSoles)
        : a.amountSoles.compareTo(b.amountSoles);
    return byPrice != 0 ? byPrice : a.createdAt.compareTo(b.createdAt);
  });
  return list;
}

/// Saca el primer precio en soles de un texto ("Bidón de agua S/ 12" → 12).
int? parseReferenceSoles(String text) {
  final m = RegExp(r'S/\s*(\d{1,6})').firstMatch(text);
  return m == null ? null : int.parse(m.group(1)!);
}

/// Ofertas de ejemplo para que haya contra quién competir. Son siempre las mismas para un
/// mismo anuncio y quedan marcadas como ejemplo.
List<Bid> demoBidsFor(BidSubject subject, DateTime now) {
  const names = ['Tomás Vega', 'Nelly Flores', 'Elena Castro', 'Marco Rivas'];
  final seed = subject.id.codeUnits.fold<int>(0, (a, b) => a + b);
  final base =
      subject.referenceSoles ?? (subject.kind == BidKind.sale ? 20 : 40);
  final amounts = subject.kind == BidKind.sale
      ? [(base * 0.9).round(), (base * 1.15).round()]
      : [(base * 0.8).round(), (base * 1.1).round()];
  return [
    for (var i = 0; i < 2; i++)
      Bid(
        id: 'demo-${subject.id}-$i',
        subjectId: subject.id,
        kind: subject.kind,
        bidder: names[(seed + i) % names.length],
        amountSoles: amounts[i],
        createdAt: now.subtract(Duration(hours: 3 - i)),
        isExample: true,
        demoSlot: i,
      ),
  ];
}
