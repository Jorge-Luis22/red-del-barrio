enum DealStatus {
  /// Propuesta aceptada; falta encontrarse y validar el código.
  accepted,

  /// Código validado: el servicio está en curso.
  inProgress,

  /// Servicio hecho; falta calificar.
  awaitingRating,

  /// Calificado: cuenta para la reputación.
  closed,
}

/// Trato: una propuesta aceptada con su código de encuentro, etapas y cierre.
class Deal {
  const Deal({
    required this.id,
    required this.needId,
    required this.providerId,
    required this.providerName,
    required this.priceSoles,
    required this.priceLabel,
    required this.code,
    required this.status,
    required this.acceptedAt,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final String needId;
  final String providerId;
  final String providerName;
  final int priceSoles;
  final String priceLabel;

  /// Código de 4 dígitos que confirma que las dos personas se encontraron.
  final String code;
  final DealStatus status;
  final DateTime acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Duración del servicio, si ya terminó.
  Duration? get duration =>
      (startedAt != null && completedAt != null) ? completedAt!.difference(startedAt!) : null;

  Deal copyWith({DealStatus? status, DateTime? startedAt, DateTime? completedAt}) => Deal(
        id: id,
        needId: needId,
        providerId: providerId,
        providerName: providerName,
        priceSoles: priceSoles,
        priceLabel: priceLabel,
        code: code,
        status: status ?? this.status,
        acceptedAt: acceptedAt,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
