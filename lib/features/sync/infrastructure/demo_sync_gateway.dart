import '../../../core/result.dart';
import '../domain/outbox_queue.dart';
import '../domain/sync_gateway.dart';

/// Destino de DEMOSTRACIÓN (mobile-ux no tiene servidor).
/// Acepta la operación pero [isDemo] es `true`: la interfaz debe rotularla
/// "Enviada · barrio de ejemplo (demo)" y nunca "enviada al servidor".
/// En mobile-mejoras se sustituye por el gateway de Supabase.
class DemoSyncGateway implements SyncGateway {
  const DemoSyncGateway();

  @override
  bool get isDemo => true;

  @override
  Future<Result<void>> send(OutboxOp op) async => const Ok(null);
}
