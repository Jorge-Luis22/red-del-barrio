import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/result.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/needs/domain/usecases/publish_need.dart';
import 'package:red_barrio/features/sync/domain/usecases/flush_outbox.dart';

import '../fakes/fakes.dart';

void main() {
  late FakeNeeds needs;
  late FakeOutbox outbox;
  late FakeConnectivity net;
  late FakeGateway gateway;
  late PublishNeed publish;
  late FlushOutbox flush;

  setUp(() {
    needs = FakeNeeds();
    outbox = FakeOutbox();
    net = FakeConnectivity();
    gateway = FakeGateway();
    publish = PublishNeed(
      needs: needs,
      outbox: outbox,
      clock: FakeClock(DateTime(2026, 11, 8)),
      ids: FakeIds(),
    );
    flush = FlushOutbox(outbox: outbox, gateway: gateway, connectivity: net, needs: needs);
  });

  test('rechaza textos de menos de 3 letras y no guarda nada', () async {
    final r = await publish(kind: NeedKind.service, text: ' a ');
    expect(r, isA<Err<Need>>());
    expect(needs.store, isEmpty);
    expect(outbox.ops, isEmpty);
  });

  test('publicar guarda la necesidad como Pendiente y la encola', () async {
    final r = await publish(kind: NeedKind.service, text: 'Necesito un gasfitero');
    expect(r.isOk, isTrue);
    expect(needs.store.values.single.syncStatus, SyncStatus.pending);
    expect(outbox.ops.length, 1);
  });

  test('sin conexión no se envía nada y sigue Pendiente', () async {
    net.online = false;
    await publish(kind: NeedKind.product, text: '2 bidones de agua');
    final r = await flush();
    expect((r as Ok<int>).value, 0);
    expect(gateway.received, isEmpty);
    expect(needs.store.values.single.syncStatus, SyncStatus.pending);
  });

  test('al volver la conexión se envía una vez y queda Enviada', () async {
    await publish(kind: NeedKind.product, text: '2 bidones de agua');
    await flush();
    expect(gateway.received.length, 1);
    expect(needs.store.values.single.syncStatus, SyncStatus.sent);
    expect(outbox.ops, isEmpty);
    await flush(); // segundo vaciado: no reenvía
    expect(gateway.received.length, 1);
  });

  test('si el envío falla queda en Error y el reintento no duplica', () async {
    await publish(kind: NeedKind.help, text: 'Ayuda con una mudanza');
    gateway.failNext = true;
    await flush();
    expect(needs.store.values.single.syncStatus, SyncStatus.error);
    expect(outbox.ops.values.single.attempts, 1);
    gateway.failNext = false;
    await flush();
    expect(needs.store.values.single.syncStatus, SyncStatus.sent);
    expect(gateway.received.length, 1);
  });

  test('encolar el mismo UUID dos veces no crea duplicados', () async {
    await publish(kind: NeedKind.loan, text: 'Un taladro por una hora');
    final op = outbox.ops.values.single;
    await outbox.enqueue(op);
    expect(outbox.ops.length, 1);
  });
}
