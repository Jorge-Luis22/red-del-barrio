import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../domain/connection_banner.dart';
import 'sync_controller.dart';

class LinkState {
  const LinkState({
    this.online = true,
    this.pending = 0,
    this.syncing = false,
    this.justSynced = false,
  });

  final bool online;
  final int pending;
  final bool syncing;
  final bool justSynced;

  ConnectionBanner get banner => deriveBanner(
    online: online,
    pending: pending,
    syncing: syncing,
    justSynced: justSynced,
  );

  LinkState copyWith({
    bool? online,
    int? pending,
    bool? syncing,
    bool? justSynced,
  }) => LinkState(
    online: online ?? this.online,
    pending: pending ?? this.pending,
    syncing: syncing ?? this.syncing,
    justSynced: justSynced ?? this.justSynced,
  );
}

/// Junta conexión, cola de pendientes y envío en curso en un solo estado para la interfaz.
class ConnectionController extends Notifier<LinkState> {
  Timer? _syncedTimer;

  @override
  LinkState build() {
    final connectivity = ref.read(connectivityProvider);

    connectivity.isOnline.then((v) => state = state.copyWith(online: v));
    final onlineSub = connectivity.onlineChanges.listen(
      (v) => state = state.copyWith(online: v),
    );

    final pendingSub = ref.read(outboxProvider).watchPendingCount().listen((
      count,
    ) {
      final drained = state.pending > 0 && count == 0 && state.online;
      state = state.copyWith(pending: count, justSynced: drained);
      if (drained) _showSyncedBriefly();
    });

    ref.listen(syncControllerProvider, (_, syncing) {
      state = state.copyWith(syncing: syncing);
    });

    ref.onDispose(() {
      onlineSub.cancel();
      pendingSub.cancel();
      _syncedTimer?.cancel();
    });
    return const LinkState();
  }

  void _showSyncedBriefly() {
    _syncedTimer?.cancel();
    _syncedTimer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(justSynced: false);
    });
  }
}

final connectionControllerProvider =
    NotifierProvider<ConnectionController, LinkState>(ConnectionController.new);
