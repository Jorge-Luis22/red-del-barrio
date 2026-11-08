import 'dart:convert';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/outbox_queue.dart';
import '../domain/sync_gateway.dart';
import 'remote_store.dart';

/// Envía las operaciones pendientes al servidor real (Supabase), idempotente por UUID.
///
/// Reglas que respeta:
///  · Regla 3: NO envía ubicación. El servidor solo guarda lo que aquí se manda (hoy, nada).
///  · Regla 5: los casos sensibles (violencia) nunca llegan aquí: `PublishSos` no los encola.
///  · Nunca devuelve `Ok` si el servidor no confirmó: así la pantalla no dice «Enviada» en falso.
class SupabaseSyncGateway implements SyncGateway {
  const SupabaseSyncGateway(this._store);

  final RemoteStore _store;

  /// Límites que el servidor también exige (`char_length` en las tablas).
  static const maxBody = 200;
  static const maxDetails = 600;

  @override
  bool get isDemo => false;

  @override
  Future<Result<void>> send(OutboxOp op) async {
    final mapped = _map(op);
    if (mapped case Err(:final failure)) return Err(failure);
    if (mapped is! Ok<(String, Map<String, Object?>)>) {
      return const Err(UnknownFailure('No se pudo preparar el envío.'));
    }
    final (table, row) = mapped.value;

    final session = await _store.ensureSession();
    if (session case Err(:final failure)) return Err(failure);
    return _store.insert(table, row);
  }

  Result<(String, Map<String, Object?>)> _map(OutboxOp op) {
    final Object? decoded;
    try {
      decoded = jsonDecode(op.payload);
    } on FormatException {
      return const Err(ValidationFailure('Este envío está dañado.'));
    }
    if (decoded is! Map<String, dynamic>) {
      return const Err(ValidationFailure('Este envío está dañado.'));
    }
    switch (op.type) {
      case 'publish_need':
        final text = decoded['text'] as String? ?? '';
        final details = decoded['details'] as String?;
        if (text.length > maxBody || (details?.length ?? 0) > maxDetails) {
          return const Err(ValidationFailure('El texto es demasiado largo.'));
        }
        return Ok((
          'needs',
          {
            'id': op.id,
            'kind': decoded['kind'],
            'body': text,
            'urgency': decoded['urgency'],
            'details': ?details,
            'category_id': ?decoded['category'],
          },
        ));
      case 'sos':
        final why = decoded['why'] as String? ?? '';
        if (why.length > maxBody) {
          return const Err(ValidationFailure('El texto es demasiado largo.'));
        }
        return Ok((
          'emergency_posts',
          {
            'id': op.id,
            'type': decoded['type'],
            'why': why,
            'needs': decoded['needs'] ?? const <String>[],
          },
        ));
      default:
        return Err(ValidationFailure('Envío desconocido (${op.type}).'));
    }
  }
}
