import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import 'bid.dart';

/// Las ofertas PROPIAS de la persona. Las de ejemplo no se guardan: se generan al mostrar.
abstract interface class BidRepository {
  Stream<List<Bid>> watchMine();

  /// Guarda la oferta de la persona para ese anuncio. Si ya tenía una, la reemplaza
  /// (solo hay una oferta propia por anuncio).
  Future<Result<void>> replaceMine(Bid bid);

  Future<Result<void>> updateStatus(String id, SyncStatus status);
}
