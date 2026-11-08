import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/needs/domain/need.dart';
import '../../features/needs/domain/need_repository.dart';
import '../../features/needs/domain/usecases/publish_need.dart';
import '../../features/needs/infrastructure/drift_need_repository.dart';
import 'core_providers.dart';
import 'sync_providers.dart';

final needRepositoryProvider = Provider<NeedRepository>(
  (ref) => DriftNeedRepository(ref.watch(appDatabaseProvider)),
);

final publishNeedProvider = Provider<PublishNeed>(
  (ref) => PublishNeed(
    needs: ref.watch(needRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final needsStreamProvider = StreamProvider<List<Need>>(
  (ref) => ref.watch(needRepositoryProvider).watchAll(),
);
