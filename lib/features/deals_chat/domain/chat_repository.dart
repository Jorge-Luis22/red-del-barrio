import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import 'chat.dart';

abstract interface class ChatRepository {
  Future<Result<void>> save(ChatMessage message);

  Future<Result<void>> updateStatus(String id, SyncStatus status);

  /// Mensajes de un trato, del más antiguo al más reciente.
  Stream<List<ChatMessage>> watchDeal(String dealId);

  /// Todos los mensajes (para mostrar el último de cada conversación).
  Stream<List<ChatMessage>> watchAll();
}
