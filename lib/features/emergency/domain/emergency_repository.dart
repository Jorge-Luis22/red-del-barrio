import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import 'emergency.dart';

abstract interface class EmergencyRepository {
  Future<Result<void>> savePost(EmergencyPost post);

  Future<Result<void>> updatePostStatus(String id, SyncStatus status);

  Stream<List<EmergencyPost>> watchPosts();

  Future<Result<void>> saveCollectionPoint(CollectionPoint point);

  Stream<List<CollectionPoint>> watchCollectionPoints();
}
