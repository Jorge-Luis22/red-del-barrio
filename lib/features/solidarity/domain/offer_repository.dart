import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import 'offer.dart';

abstract interface class OfferRepository {
  Future<Result<void>> save(Offer offer);

  Future<Result<void>> updateStatus(String id, SyncStatus status);

  Stream<List<Offer>> watchAll();
}
