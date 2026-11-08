import 'dart:async';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import 'deal.dart';
import 'deal_repository.dart';

/// Máximo de contraofertas por TRATO (no por sesión). Se cuenta con lo guardado en el teléfono,
/// por eso no se reinicia al cerrar la app, reconectar o reabrir el trato.
const maxCounterOffers = 2;

enum PriceChangeStatus { pending, accepted, rejected }

/// Contraoferta presencial del prestador: cambia el precio SOLO si el cliente la acepta.
class PriceChange {
  const PriceChange({
    required this.id,
    required this.dealId,
    required this.previousPrice,
    required this.newPrice,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.author = 'provider',
  });

  final String id;
  final String dealId;
  final int previousPrice;
  final int newPrice;
  final String reason;
  final PriceChangeStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  /// Quién la hizo. Solo el prestador seleccionado puede iniciarlas.
  final String author;

  PriceChange resolved(PriceChangeStatus s, DateTime at) => PriceChange(
    id: id,
    dealId: dealId,
    previousPrice: previousPrice,
    newPrice: newPrice,
    reason: reason,
    status: s,
    createdAt: createdAt,
    resolvedAt: at,
    author: author,
  );
}

abstract interface class PriceChangeRepository {
  Future<Result<void>> save(PriceChange change);

  /// Guarda el trato con el nuevo precio y la contraoferta aceptada, todo o nada.
  Future<Result<void>> saveAccepted(Deal deal, PriceChange change);

  Future<List<PriceChange>> forDeal(String dealId);

  Stream<List<PriceChange>> watchAll();
}

/// Contraofertas presenciales. Reglas (aplicadas aquí, no en la pantalla):
///  · Solo después de validar el código de encuentro (trato «en curso»).
///  · Solo el prestador seleccionado las inicia; el cliente acepta o rechaza.
///  · Máximo 2 por trato, con nuevo monto y motivo obligatorios.
///  · No se envía otra mientras haya una pendiente.
///  · No se acepta una contraoferta obsoleta (distinta de la vigente).
///  · Solo en servicios con precio: favores, préstamos y donaciones no se negocian.
///  · Las peticiones del mismo trato se atienden de a una (sin carreras).
class CounterOfferService {
  CounterOfferService({
    required this.deals,
    required this.changes,
    required this.clock,
    required this.ids,
  });

  final DealRepository deals;
  final PriceChangeRepository changes;
  final Clock clock;
  final IdGenerator ids;

  final Map<String, Future<void>> _queues = {};

  /// Cola por trato: las peticiones se atienden de a una.
  Future<T> _serial<T>(String dealId, Future<T> Function() run) async {
    final previous = _queues[dealId] ?? Future<void>.value();
    final done = Completer<void>();
    final mine = previous.then((_) => done.future);
    _queues[dealId] = mine;
    await previous;
    try {
      return await run();
    } finally {
      done.complete();
      if (identical(_queues[dealId], mine)) _queues.remove(dealId)?.ignore();
    }
  }

  /// Cuántas contraofertas quedan en este trato.
  Future<int> remaining(String dealId) async =>
      maxCounterOffers - (await changes.forDeal(dealId)).length;

  Future<Result<PriceChange>> propose(
    String dealId, {
    required String by,
    required int newPrice,
    required String reason,
  }) => _serial(dealId, () async {
    final deal = await deals.byId(dealId);
    if (deal == null) {
      return const Err(ValidationFailure('No encontramos este trato.'));
    }
    if (by != deal.providerId) {
      return const Err(
        ValidationFailure(
          'Solo el prestador seleccionado puede hacer una contraoferta.',
        ),
      );
    }
    if (deal.status != DealStatus.inProgress) {
      return const Err(
        ValidationFailure(
          'La contraoferta se habilita solo después de validar el código de encuentro.',
        ),
      );
    }
    if (deal.priceSoles <= 0) {
      return const Err(
        ValidationFailure('Este trato no se negocia por precio.'),
      );
    }
    if (newPrice <= 0 || newPrice == deal.priceSoles) {
      return const Err(
        ValidationFailure(
          'Escribe un monto nuevo, mayor que cero y distinto al vigente.',
        ),
      );
    }
    if (reason.trim().length < 5) {
      return const Err(ValidationFailure('Cuenta el motivo del cambio.'));
    }
    final all = await changes.forDeal(dealId);
    if (all.any((c) => c.status == PriceChangeStatus.pending)) {
      return const Err(
        ValidationFailure(
          'Ya hay una contraoferta pendiente: espera la respuesta.',
        ),
      );
    }
    if (all.length >= maxCounterOffers) {
      return const Err(
        ValidationFailure('Ya se usaron las 2 contraofertas de este trato.'),
      );
    }
    final change = PriceChange(
      id: ids.newUuid(),
      dealId: dealId,
      previousPrice: deal.priceSoles,
      newPrice: newPrice,
      reason: reason.trim(),
      status: PriceChangeStatus.pending,
      createdAt: clock.now(),
    );
    final saved = await changes.save(change);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(change);
  });

  /// El cliente acepta o rechaza una contraoferta pendiente.
  Future<Result<Deal>> respond(
    String dealId,
    String changeId, {
    required bool accept,
  }) => _serial(dealId, () async {
    final deal = await deals.byId(dealId);
    if (deal == null) {
      return const Err(ValidationFailure('No encontramos este trato.'));
    }
    if (deal.status != DealStatus.inProgress) {
      return const Err(
        ValidationFailure('Este trato ya no admite cambios de precio.'),
      );
    }
    final all = await changes.forDeal(dealId);
    final change = all.where((c) => c.id == changeId).firstOrNull;
    final current = all
        .where((c) => c.status == PriceChangeStatus.pending)
        .firstOrNull;
    if (change == null ||
        current == null ||
        current.id != change.id ||
        change.previousPrice != deal.priceSoles) {
      return const Err(
        ValidationFailure('Esta contraoferta ya no está vigente.'),
      );
    }
    final now = clock.now();
    if (!accept) {
      final r = await changes.save(
        change.resolved(PriceChangeStatus.rejected, now),
      );
      if (r case Err(:final failure)) return Err(failure);
      return Ok(deal);
    }
    final updated = deal.copyWith(
      priceSoles: change.newPrice,
      priceLabel: 'S/ ${change.newPrice}',
    );
    final r = await changes.saveAccepted(
      updated,
      change.resolved(PriceChangeStatus.accepted, now),
    );
    if (r case Err(:final failure)) return Err(failure);
    return Ok(updated);
  });
}

/// Cancela un trato registrando el motivo. No hay multas ni se baja la reputación.
class CancelDeal {
  CancelDeal({required this.deals, required this.clock});

  final DealRepository deals;
  final Clock clock;

  Future<Result<Deal>> call(String dealId, {required String reason}) async {
    final deal = await deals.byId(dealId);
    if (deal == null) {
      return const Err(ValidationFailure('No encontramos este trato.'));
    }
    if (deal.status != DealStatus.accepted &&
        deal.status != DealStatus.inProgress) {
      return const Err(
        ValidationFailure('Este trato ya no se puede cancelar.'),
      );
    }
    if (reason.trim().length < 3) {
      return const Err(
        ValidationFailure('Cuenta el motivo de la cancelación.'),
      );
    }
    final updated = deal.copyWith(
      status: DealStatus.cancelled,
      cancelReason: reason.trim(),
      cancelledAt: clock.now(),
    );
    final saved = await deals.save(updated);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(updated);
  }
}
