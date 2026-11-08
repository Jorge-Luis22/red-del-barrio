import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/ui/components.dart';
import '../../proposals/domain/deal.dart';
import '../domain/need.dart';

/// En qué punto está un pedido, mezclando su envío y su trato.
enum NeedPhase { sending, error, waiting, active, rate, done }

class MyNeed {
  const MyNeed(this.need, this.deal);

  final Need need;
  final Deal? deal;

  NeedPhase get phase {
    final d = deal;
    if (d != null) {
      return switch (d.status) {
        DealStatus.accepted || DealStatus.inProgress => NeedPhase.active,
        DealStatus.awaitingRating => NeedPhase.rate,
        DealStatus.closed => NeedPhase.done,
      };
    }
    return switch (need.syncStatus) {
      SyncStatus.pending => NeedPhase.sending,
      SyncStatus.error => NeedPhase.error,
      SyncStatus.sent => NeedPhase.waiting,
    };
  }

  bool get isDone => phase == NeedPhase.done;

  /// Lo que pide una acción de la persona va primero.
  int get priority => switch (phase) {
    NeedPhase.rate => 0,
    NeedPhase.error => 1,
    NeedPhase.active => 2,
    NeedPhase.waiting => 3,
    NeedPhase.sending => 4,
    NeedPhase.done => 5,
  };

  ({String label, IconData icon, BvTone tone}) get badge => switch (phase) {
    NeedPhase.sending => (
      label: 'Pendiente de envío',
      icon: Icons.schedule_rounded,
      tone: BvTone.sun,
    ),
    NeedPhase.error => (
      label: 'No se envió · reintentar',
      icon: Icons.error_rounded,
      tone: BvTone.emergency,
    ),
    NeedPhase.waiting => (
      label: 'Con propuestas',
      icon: Icons.groups_rounded,
      tone: BvTone.violet,
    ),
    NeedPhase.active => (
      label: 'En curso',
      icon: Icons.handshake_rounded,
      tone: BvTone.trust,
    ),
    NeedPhase.rate => (
      label: 'Falta calificar',
      icon: Icons.star_rounded,
      tone: BvTone.coral,
    ),
    NeedPhase.done => (
      label: 'Resuelta',
      icon: Icons.check_circle_rounded,
      tone: BvTone.trust,
    ),
  };
}

/// Pedidos de la persona con su trato, ordenados: primero lo que necesita atención,
/// después lo más reciente.
final myNeedsProvider = Provider<AsyncValue<List<MyNeed>>>((ref) {
  final needs = ref.watch(needsStreamProvider);
  final deals = ref.watch(dealsStreamProvider).value ?? const <Deal>[];
  return needs.whenData((list) {
    final byNeed = {for (final d in deals) d.needId: d};
    final out = [for (final n in list) MyNeed(n, byNeed[n.id])];
    out.sort((a, b) {
      final p = a.priority.compareTo(b.priority);
      return p != 0 ? p : b.need.createdAt.compareTo(a.need.createdAt);
    });
    return out;
  });
});
