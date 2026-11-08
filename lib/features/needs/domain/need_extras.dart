/// Información extra de un pedido: más detalle escrito y una foto (por ejemplo, la tubería rota).
/// Se guarda aparte del pedido, solo en este teléfono.
class NeedExtras {
  const NeedExtras({this.detail = '', this.imagePath});

  static const maxDetailLength = 500;

  final String detail;

  /// Ruta de la foto guardada en el teléfono; `null` si no hay foto.
  final String? imagePath;

  bool get isEmpty => detail.trim().isEmpty && imagePath == null;

  Map<String, Object?> toJson() => {
    'detail': detail.trim(),
    'imagePath': imagePath,
  };

  factory NeedExtras.fromJson(Map<String, Object?> json) => NeedExtras(
    detail: (json['detail'] as String?) ?? '',
    imagePath: json['imagePath'] as String?,
  );
}

abstract interface class NeedExtrasRepository {
  /// Devuelve los extras del pedido; vacíos si no tiene.
  Future<NeedExtras> get(String needId);

  Future<void> save(String needId, NeedExtras extras);
}
