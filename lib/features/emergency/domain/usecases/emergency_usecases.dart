import 'dart:convert';

import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../needs/domain/need.dart';
import '../../../sync/domain/outbox_queue.dart';
import '../emergency.dart';
import '../emergency_repository.dart';

/// Publica un aviso de ayuda. Sin internet queda guardado y se envía al volver la red.
/// NO inventa respuestas: si nadie ayuda todavía, la pantalla lo dice.
class PublishSos {
  PublishSos({
    required this.emergency,
    required this.outbox,
    required this.clock,
    required this.ids,
  });

  final EmergencyRepository emergency;
  final OutboxQueue outbox;
  final Clock clock;
  final IdGenerator ids;

  static const opType = 'publish_sos';

  Future<Result<EmergencyPost>> call({
    required SosSituation situation,
    required String text,
  }) async {
    final clean = text.trim().isEmpty ? situation.name : text.trim();
    final now = clock.now();
    final post = EmergencyPost(
      id: ids.newUuid(),
      situation: situation,
      text: clean,
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );
    final saved = await emergency.savePost(post);
    if (saved case Err(:final failure)) return Err(failure);
    final queued = await outbox.enqueue(
      OutboxOp(
        id: post.id,
        type: opType,
        payload: jsonEncode({
          'situation': situation.name,
          'text': clean,
          'private': situation.isPrivate,
        }),
        createdAt: now,
      ),
    );
    if (queued case Err(:final failure)) return Err(failure);
    return Ok(post);
  }
}

/// Propone un punto de acopio (queda "propuesto por ti, sin verificar").
class ProposeCollectionPoint {
  ProposeCollectionPoint({
    required this.emergency,
    required this.clock,
    required this.ids,
  });

  final EmergencyRepository emergency;
  final Clock clock;
  final IdGenerator ids;

  Future<Result<CollectionPoint>> call({
    required String name,
    required String reference,
  }) async {
    final n = name.trim();
    if (n.length < 3) {
      return const Err(ValidationFailure('Escribe el nombre del lugar.'));
    }
    final point = CollectionPoint(
      id: ids.newUuid(),
      name: n,
      reference: reference.trim(),
      createdAt: clock.now(),
    );
    final saved = await emergency.saveCollectionPoint(point);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(point);
  }
}

/// Agrega un contacto de confianza. Valida el nombre y el teléfono, evita repetidos
/// y limita la cantidad ([maxTrustedContacts]).
class AddContact {
  AddContact({required this.emergency, required this.clock, required this.ids});

  final EmergencyRepository emergency;
  final Clock clock;
  final IdGenerator ids;

  static const noName = 'Escribe el nombre del contacto.';
  static const badPhone = 'Escribe un teléfono válido (solo números).';
  static const duplicate = 'Ya tienes ese contacto.';
  static const tooMany = 'Puedes tener hasta 5 contactos.';

  /// Quita espacios, guiones y paréntesis. Devuelve `null` si no parece un teléfono
  /// (de 7 a 15 dígitos, con `+` opcional al inicio).
  static String? normalizePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\s\-().]'), '');
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned) ? cleaned : null;
  }

  Future<Result<TrustedContact>> call({
    required String name,
    required String phone,
  }) async {
    final cleanName = name.trim();
    if (cleanName.length < 2) return const Err(ValidationFailure(noName));
    final normalized = normalizePhone(phone);
    if (normalized == null) return const Err(ValidationFailure(badPhone));
    final current = await emergency.contacts();
    if (current.length >= maxTrustedContacts) {
      return const Err(ValidationFailure(tooMany));
    }
    if (current.any((c) => c.phone == normalized)) {
      return const Err(ValidationFailure(duplicate));
    }
    final contact = TrustedContact(
      id: ids.newUuid(),
      name: cleanName,
      phone: normalized,
      createdAt: clock.now(),
    );
    final saved = await emergency.saveContact(contact);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(contact);
  }
}
