import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/core/db/app_database.dart';
import 'package:red_barrio/features/needs/domain/need.dart';
import 'package:red_barrio/features/needs/infrastructure/drift_need_repository.dart';
import 'package:red_barrio/features/proposals/domain/deal.dart';
import 'package:red_barrio/features/proposals/infrastructure/drift_deal_repository.dart';
import 'package:red_barrio/features/reputation/domain/interaction.dart';
import 'package:red_barrio/features/reputation/infrastructure/drift_reputation_repository.dart';
import 'package:red_barrio/features/sync/domain/outbox_queue.dart';
import 'package:red_barrio/features/sync/infrastructure/drift_outbox.dart';

void main() {
  test('persistencia: necesidad, cola, trato e interacción sobreviven y la cola no duplica', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final needs = DriftNeedRepository(db);
    final outbox = DriftOutbox(db);
    final deals = DriftDealRepository(db);
    final rep = DriftReputationRepository(db);
    final t = DateTime(2026, 11, 8);

    await needs.save(
      Need(
        id: 'n1',
        kind: NeedKind.help,
        text: 'Ayuda',
        urgency: Urgency.now,
        createdAt: t,
        syncStatus: SyncStatus.pending,
      ),
    );
    await needs.updateStatus('n1', SyncStatus.sent);
    expect((await needs.watchAll().first).single.syncStatus, SyncStatus.sent);

    final op = OutboxOp(
      id: 'n1',
      type: 'publish_need',
      payload: '{}',
      createdAt: t,
    );
    await outbox.enqueue(op);
    await outbox.enqueue(op);
    expect((await outbox.pending()).length, 1);
    await outbox.markFailed('n1', 'sin red');
    expect((await outbox.pending()).single.attempts, 1);

    await deals.save(
      Deal(
        id: 'd1',
        needId: 'n1',
        providerId: 'carlos',
        providerName: 'Carlos',
        priceSoles: 35,
        priceLabel: 'S/ 35',
        code: '1234',
        status: DealStatus.accepted,
        acceptedAt: t,
      ),
    );
    expect((await deals.byNeed('n1'))!.code, '1234');

    await rep.record(
      Interaction(
        id: 'i1',
        dealId: 'd1',
        providerId: 'carlos',
        raterId: 'me',
        stars: 5,
        recommended: true,
        closedAt: t,
      ),
    );
    expect((await rep.forProvider('carlos')).single.recommended, isTrue);
  });

  test('migración 1 → 2: una base del esquema 1 conserva sus datos y gana las tablas nuevas', () async {
    // Base "vieja": solo las tablas del esquema 1 y user_version = 1.
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute(
          'CREATE TABLE needs (id TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL, body TEXT NOT NULL, urgency TEXT NOT NULL, created_at INTEGER NOT NULL, sync_status TEXT NOT NULL)',
        );
        raw.execute(
          'CREATE TABLE outbox_ops (id TEXT NOT NULL PRIMARY KEY, op_type TEXT NOT NULL, payload TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, last_error TEXT)',
        );
        raw.execute(
          "INSERT INTO needs VALUES ('viejo','service','Necesito un gasfitero','today',1700000000,'sent')",
        );
        raw.execute('PRAGMA user_version = 1');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final needs = await DriftNeedRepository(db).watchAll().first;
    expect(needs.single.id, 'viejo'); // no se perdió nada
    // las tablas nuevas existen y funcionan
    expect(await db.select(db.deals).get(), isEmpty);
    expect(await db.select(db.interactions).get(), isEmpty);
    await db
        .into(db.interactions)
        .insert(
          InteractionsCompanion.insert(
            id: 'i',
            dealId: 'd',
            providerId: 'p',
            raterId: 'me',
            stars: 4,
            recommended: false,
            closedAt: DateTime(2026),
          ),
        );
    expect((await db.select(db.interactions).get()).length, 1);
  });
}
