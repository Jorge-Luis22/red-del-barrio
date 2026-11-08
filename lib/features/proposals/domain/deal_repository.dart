import '../../../core/result.dart';
import 'deal.dart';

abstract interface class DealRepository {
  Future<Result<void>> save(Deal deal);

  Future<Deal?> byId(String id);

  Future<Deal?> byNeed(String needId);

  Stream<List<Deal>> watchAll();
}
