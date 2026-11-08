enum DealStatus {
  /// Propuesta aceptada; falta encontrarse y validar el código.
  accepted,

  /// Código validado: el servicio está en curso.
  inProgress,

  /// Servicio hecho; falta calificar.
  awaitingRating,

  /// Calificado: cuenta para la reputación.
  closed,

  /// Cancelado con un motivo. No hay multas ni baja de reputación.
  cancelled,
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
    this.cancelReason,
    this.cancelledAt,
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
  final String? cancelReason;
  final DateTime? cancelledAt;

  /// Duración del servicio, si ya terminó.
  Duration? get duration => (startedAt != null && completedAt != null)
      ? completedAt!.difference(startedAt!)
      : null;

  Deal copyWith({
    DealStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? priceSoles,
    String? priceLabel,
    String? cancelReason,
    DateTime? cancelledAt,
  }) => Deal(
    id: id,
    needId: needId,
    providerId: providerId,
    providerName: providerName,
    priceSoles: priceSoles ?? this.priceSoles,
    priceLabel: priceLabel ?? this.priceLabel,
    code: code,
    status: status ?? this.status,
    acceptedAt: acceptedAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelReason: cancelReason ?? this.cancelReason,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );
}
