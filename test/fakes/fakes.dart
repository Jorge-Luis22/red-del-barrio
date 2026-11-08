import 'dart:async';

import 'package:red_barrio/core/clock.dart';
import 'package:red_barrio/core/failure.dart';
import 'package:red_barrio/core/ids.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/needs/domain/need_repository.dart';
import 'package:red_barrio/features/sync/domain/connectivity_monitor.dart';
import 'package:red_barrio/features/sync/domain/outbox_queue.dart';
import 'package:red_barrio/features/sync/domain/sync_gateway.dart';
import 'package:red_barrio/features/proposals/domain/deal.dart';
import 'package:red_barrio/features/proposals/domain/deal_repository.dart';
import 'package:red_barrio/features/reputation/domain/interaction.dart';
import 'package:red_barrio/features/reputation/domain/reputation_repository.dart';

class FakeClock implements Clock {
  FakeClock(this.current);
  DateTime current;
  @override
  DateTime now() => current;
}

class FakeIds implements IdGenerator {
  int _n = 0;
  @override
  String newUuid() => 'uuid-${++_n}';
  @override
  String meetingCode() => '1234';
}

class FakeNeeds implements NeedRepository {
  final Map<String, Need> store = {};
  bool failSave = false;

  @override
  Future<Result<void>> save(Need need) async {
    if (failSave) return const Err(StorageFailure('sin espacio'));
    store[need.id] = need;
    return const Ok(null);
  }

  @override
  Future<Result<void>> updateStatus(String id, SyncStatus status) async {
    final n = store[id];
    if (n != null) store[id] = n.copyWith(syncStatus: status);
    return const Ok(null);
  }

  @override
  Stream<List<Need>> watchAll() => Stream.value(store.values.toList());
}

class FakeOutbox implements OutboxQueue {
  final Map<String, OutboxOp> ops = {};

  @override
  Future<Result<void>> enqueue(OutboxOp op) async {
    ops.putIfAbsent(op.id, () => op); // idempotente por UUID
    return const Ok(null);
  }

  @override
  Future<List<OutboxOp>> pending() async => ops.values.toList();

  @override
  Future<Result<void>> remove(String id) async {
    ops.remove(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> markFailed(String id, String error) async {
    final o = ops[id];
    if (o != null) {
      ops[id] = OutboxOp(
        id: o.id,
        type: o.type,
        payload: o.payload,
        createdAt: o.createdAt,
        attempts: o.attempts + 1,
        lastError: error,
      );
    }
    return const Ok(null);
  }
}

class FakeConnectivity implements ConnectivityMonitor {
  FakeConnectivity({this.online = true});
  bool online;
  @override
  Future<bool> get isOnline async => online;
  @override
  Stream<bool> get onlineChanges => const Stream.empty();
}

class FakeGateway implements SyncGateway {
  bool failNext = false;
  final List<String> received = [];
  @override
  bool get isDemo => true;

  @override
  Future<Result<void>> send(OutboxOp op) async {
    if (failNext) return const Err(NetworkFailure('sin respuesta'));
    received.add(op.id);
    return const Ok(null);
  }
}

class FakeDeals implements DealRepository {
  final Map<String, Deal> store = {};

  @override
  Future<Result<void>> save(Deal deal) async {
    store[deal.id] = deal;
    return const Ok(null);
  }

  @override
  Future<Deal?> byId(String id) async => store[id];

  @override
  Future<Deal?> byNeed(String needId) async {
    for (final d in store.values) {
      if (d.needId == needId) return d;
    }
    return null;
  }

  @override
  Stream<List<Deal>> watchAll() => Stream.value(store.values.toList());
}

class FakeReputation implements ReputationRepository {
  final List<Interaction> store = [];

  @override
  Future<Result<void>> record(Interaction interaction) async {
    store.add(interaction);
    return const Ok(null);
  }

  @override
  Future<List<Interaction>> forProvider(String providerId) async =>
      store.where((i) => i.providerId == providerId).toList();

  @override
  Stream<List<Interaction>> watchAll() => Stream.value(List.of(store));
}
