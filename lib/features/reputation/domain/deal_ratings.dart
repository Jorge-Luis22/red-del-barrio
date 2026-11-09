import 'interaction.dart';

/// Las dos calificaciones de un trato: la que el cliente dio a quien prestó el servicio
/// y la que quien prestó el servicio dio al cliente. Cada una puede faltar todavía.
class DealRatings {
  const DealRatings({this.ofProvider, this.ofClient});

  /// Lo que el cliente calificó a quien prestó el servicio.
  final Interaction? ofProvider;

  /// Lo que quien prestó el servicio calificó al cliente.
  final Interaction? ofClient;

  /// Separa, entre todas las calificaciones guardadas, las que son de este trato.
  factory DealRatings.of(String dealId, Iterable<Interaction> all) {
    Interaction? ofProvider;
    Interaction? ofClient;
    for (final i in all) {
      if (i.dealId != dealId) continue;
      if (i.isClientRating) {
        ofClient = i;
      } else {
        ofProvider = i;
      }
    }
    return DealRatings(ofProvider: ofProvider, ofClient: ofClient);
  }
}
