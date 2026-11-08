import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deals_chat/domain/chat.dart';
import '../../features/deals_chat/domain/chat_repository.dart';
import '../../features/deals_chat/domain/usecases/send_message.dart';
import '../../features/deals_chat/infrastructure/drift_chat_repository.dart';
import 'core_providers.dart';
import 'sync_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DriftChatRepository(ref.watch(appDatabaseProvider)),
);

final sendMessageProvider = Provider<SendMessage>(
  (ref) => SendMessage(
    chat: ref.watch(chatRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final chatMessagesStreamProvider = StreamProvider<List<ChatMessage>>(
  (ref) => ref.watch(chatRepositoryProvider).watchAll(),
);

final dealMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, dealId) => ref.watch(chatRepositoryProvider).watchDeal(dealId),
);
