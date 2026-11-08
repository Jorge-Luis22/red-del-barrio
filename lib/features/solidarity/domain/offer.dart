import '../../needs/domain/need.dart';

/// Cómo se ofrece algo entre vecinos.
enum Modality { free, barter, rent }

/// Algo que la persona ofrece al barrio (una herramienta, tiempo, una habilidad…).
class Offer {
  const Offer({
    required this.id,
    required this.modality,
    required this.text,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final Modality modality;
  final String text;
  final DateTime createdAt;
  final SyncStatus syncStatus;
}

/// Una fila del muro de vecinos. Las de [isExample] son de DEMOSTRACIÓN (no hay vecinos reales
/// todavía) y la interfaz debe rotularlas "Ejemplo".
class WallEntry {
  const WallEntry({
    required this.id,
    required this.author,
    required this.text,
    required this.isRequest,
    required this.isExample,
    this.modality,
    this.tag,
    this.distanceMeters,
    this.syncStatus,
  });

  final String id;
  final String author;
  final String text;

  /// Modalidad elegida; las entradas propias que vienen de un pedido no la tienen.
  final Modality? modality;

  /// Etiqueta cuando no hay modalidad (por ejemplo "Préstamo" o "Ayuda").
  final String? tag;

  /// `true` = alguien pide; `false` = alguien ofrece.
  final bool isRequest;
  final bool isExample;
  final double? distanceMeters;

  /// Solo en las entradas propias.
  final SyncStatus? syncStatus;
}
