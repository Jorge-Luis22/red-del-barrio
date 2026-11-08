import '../../../core/result.dart';
import 'need.dart';

abstract interface class NeedRepository {
  /// Guarda o reemplaza por id (idempotente).
  Future<Result<void>> save(Need need);

  Future<Result<void>> updateStatus(String id, SyncStatus status);

  Stream<List<Need>> watchAll();
}
