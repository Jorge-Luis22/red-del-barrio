import '../../../core/result.dart';
import '../../needs/domain/need.dart';

/// Un pedido abierto del barrio, publicado desde cualquier celular.
class CommunityNeed {
  const CommunityNeed({
    required this.id,
    required this.kind,
    required this.text,
    required this.urgency,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final NeedKind kind;
  final String text;
  final Urgency urgency;
  final DateTime createdAt;
  final bool isMine;
}

/// Pedidos abiertos que están en el servidor. Sin servidor, la implementación dice "no disponible".
abstract interface class CommunityFeed {
  /// `false` en modo demostración (sin claves del servidor).
  bool get isAvailable;

  Future<Result<List<CommunityNeed>>> openNeeds();
}
