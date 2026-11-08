// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NeedsTable extends Needs with TableInfo<$NeedsTable, NeedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
    'urgency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    body,
    urgency,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'needs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NeedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    } else if (isInserting) {
      context.missing(_urgencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NeedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NeedRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $NeedsTable createAlias(String alias) {
    return $NeedsTable(attachedDatabase, alias);
  }
}

class NeedRow extends DataClass implements Insertable<NeedRow> {
  final String id;
  final String kind;
  final String body;
  final String urgency;
  final DateTime createdAt;
  final String syncStatus;
  const NeedRow({
    required this.id,
    required this.kind,
    required this.body,
    required this.urgency,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['body'] = Variable<String>(body);
    map['urgency'] = Variable<String>(urgency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  NeedsCompanion toCompanion(bool nullToAbsent) {
    return NeedsCompanion(
      id: Value(id),
      kind: Value(kind),
      body: Value(body),
      urgency: Value(urgency),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory NeedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NeedRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String>(json['body']),
      urgency: serializer.fromJson<String>(json['urgency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String>(body),
      'urgency': serializer.toJson<String>(urgency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  NeedRow copyWith({
    String? id,
    String? kind,
    String? body,
    String? urgency,
    DateTime? createdAt,
    String? syncStatus,
  }) => NeedRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    body: body ?? this.body,
    urgency: urgency ?? this.urgency,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  NeedRow copyWithCompanion(NeedsCompanion data) {
    return NeedRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NeedRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('urgency: $urgency, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, body, urgency, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NeedRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.urgency == this.urgency &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class NeedsCompanion extends UpdateCompanion<NeedRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> body;
  final Value<String> urgency;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const NeedsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.urgency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NeedsCompanion.insert({
    required String id,
    required String kind,
    required String body,
    required String urgency,
    required DateTime createdAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       body = Value(body),
       urgency = Value(urgency),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<NeedRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? urgency,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (urgency != null) 'urgency': urgency,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? body,
    Value<String>? urgency,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return NeedsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NeedsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('urgency: $urgency, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opType,
    payload,
    attempts,
    createdAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String id;
  final String opType;
  final String payload;
  final int attempts;
  final DateTime createdAt;
  final String? lastError;
  const OutboxRow({
    required this.id,
    required this.opType,
    required this.payload,
    required this.attempts,
    required this.createdAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['op_type'] = Variable<String>(opType);
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      id: Value(id),
      opType: Value(opType),
      payload: Value(payload),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<String>(json['id']),
      opType: serializer.fromJson<String>(json['opType']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'opType': serializer.toJson<String>(opType),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxRow copyWith({
    String? id,
    String? opType,
    String? payload,
    int? attempts,
    DateTime? createdAt,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxRow(
    id: id ?? this.id,
    opType: opType ?? this.opType,
    payload: payload ?? this.payload,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      opType: data.opType.present ? data.opType.value : this.opType,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, opType, payload, attempts, createdAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.opType == this.opType &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.lastError == this.lastError);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> id;
  final Value<String> opType;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxOpsCompanion({
    this.id = const Value.absent(),
    this.opType = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    required String id,
    required String opType,
    required String payload,
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       opType = Value(opType),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? id,
    Expression<String>? opType,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opType != null) 'op_type': opType,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<String>? id,
    Value<String>? opType,
    Value<String>? payload,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxOpsCompanion(
      id: id ?? this.id,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealsTable extends Deals with TableInfo<$DealsTable, DealRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needIdMeta = const VerificationMeta('needId');
  @override
  late final GeneratedColumn<String> needId = GeneratedColumn<String>(
    'need_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceSolesMeta = const VerificationMeta(
    'priceSoles',
  );
  @override
  late final GeneratedColumn<int> priceSoles = GeneratedColumn<int>(
    'price_soles',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceLabelMeta = const VerificationMeta(
    'priceLabel',
  );
  @override
  late final GeneratedColumn<String> priceLabel = GeneratedColumn<String>(
    'price_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    needId,
    providerId,
    providerName,
    priceSoles,
    priceLabel,
    code,
    status,
    acceptedAt,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('need_id')) {
      context.handle(
        _needIdMeta,
        needId.isAcceptableOrUnknown(data['need_id']!, _needIdMeta),
      );
    } else if (isInserting) {
      context.missing(_needIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('price_soles')) {
      context.handle(
        _priceSolesMeta,
        priceSoles.isAcceptableOrUnknown(data['price_soles']!, _priceSolesMeta),
      );
    } else if (isInserting) {
      context.missing(_priceSolesMeta);
    }
    if (data.containsKey('price_label')) {
      context.handle(
        _priceLabelMeta,
        priceLabel.isAcceptableOrUnknown(data['price_label']!, _priceLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_priceLabelMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acceptedAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DealRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      needId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}need_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      )!,
      priceSoles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_soles'],
      )!,
      priceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_label'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DealsTable createAlias(String alias) {
    return $DealsTable(attachedDatabase, alias);
  }
}

class DealRow extends DataClass implements Insertable<DealRow> {
  final String id;
  final String needId;
  final String providerId;
  final String providerName;
  final int priceSoles;
  final String priceLabel;
  final String code;
  final String status;
  final DateTime acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const DealRow({
    required this.id,
    required this.needId,
    required this.providerId,
    required this.providerName,
    required this.priceSoles,
    required this.priceLabel,
    required this.code,
    required this.status,
    required this.acceptedAt,
    this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['need_id'] = Variable<String>(needId);
    map['provider_id'] = Variable<String>(providerId);
    map['provider_name'] = Variable<String>(providerName);
    map['price_soles'] = Variable<int>(priceSoles);
    map['price_label'] = Variable<String>(priceLabel);
    map['code'] = Variable<String>(code);
    map['status'] = Variable<String>(status);
    map['accepted_at'] = Variable<DateTime>(acceptedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DealsCompanion toCompanion(bool nullToAbsent) {
    return DealsCompanion(
      id: Value(id),
      needId: Value(needId),
      providerId: Value(providerId),
      providerName: Value(providerName),
      priceSoles: Value(priceSoles),
      priceLabel: Value(priceLabel),
      code: Value(code),
      status: Value(status),
      acceptedAt: Value(acceptedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DealRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealRow(
      id: serializer.fromJson<String>(json['id']),
      needId: serializer.fromJson<String>(json['needId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      providerName: serializer.fromJson<String>(json['providerName']),
      priceSoles: serializer.fromJson<int>(json['priceSoles']),
      priceLabel: serializer.fromJson<String>(json['priceLabel']),
      code: serializer.fromJson<String>(json['code']),
      status: serializer.fromJson<String>(json['status']),
      acceptedAt: serializer.fromJson<DateTime>(json['acceptedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'needId': serializer.toJson<String>(needId),
      'providerId': serializer.toJson<String>(providerId),
      'providerName': serializer.toJson<String>(providerName),
      'priceSoles': serializer.toJson<int>(priceSoles),
      'priceLabel': serializer.toJson<String>(priceLabel),
      'code': serializer.toJson<String>(code),
      'status': serializer.toJson<String>(status),
      'acceptedAt': serializer.toJson<DateTime>(acceptedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DealRow copyWith({
    String? id,
    String? needId,
    String? providerId,
    String? providerName,
    int? priceSoles,
    String? priceLabel,
    String? code,
    String? status,
    DateTime? acceptedAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DealRow(
    id: id ?? this.id,
    needId: needId ?? this.needId,
    providerId: providerId ?? this.providerId,
    providerName: providerName ?? this.providerName,
    priceSoles: priceSoles ?? this.priceSoles,
    priceLabel: priceLabel ?? this.priceLabel,
    code: code ?? this.code,
    status: status ?? this.status,
    acceptedAt: acceptedAt ?? this.acceptedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DealRow copyWithCompanion(DealsCompanion data) {
    return DealRow(
      id: data.id.present ? data.id.value : this.id,
      needId: data.needId.present ? data.needId.value : this.needId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      priceSoles: data.priceSoles.present
          ? data.priceSoles.value
          : this.priceSoles,
      priceLabel: data.priceLabel.present
          ? data.priceLabel.value
          : this.priceLabel,
      code: data.code.present ? data.code.value : this.code,
      status: data.status.present ? data.status.value : this.status,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealRow(')
          ..write('id: $id, ')
          ..write('needId: $needId, ')
          ..write('providerId: $providerId, ')
          ..write('providerName: $providerName, ')
          ..write('priceSoles: $priceSoles, ')
          ..write('priceLabel: $priceLabel, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    needId,
    providerId,
    providerName,
    priceSoles,
    priceLabel,
    code,
    status,
    acceptedAt,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealRow &&
          other.id == this.id &&
          other.needId == this.needId &&
          other.providerId == this.providerId &&
          other.providerName == this.providerName &&
          other.priceSoles == this.priceSoles &&
          other.priceLabel == this.priceLabel &&
          other.code == this.code &&
          other.status == this.status &&
          other.acceptedAt == this.acceptedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class DealsCompanion extends UpdateCompanion<DealRow> {
  final Value<String> id;
  final Value<String> needId;
  final Value<String> providerId;
  final Value<String> providerName;
  final Value<int> priceSoles;
  final Value<String> priceLabel;
  final Value<String> code;
  final Value<String> status;
  final Value<DateTime> acceptedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const DealsCompanion({
    this.id = const Value.absent(),
    this.needId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.priceSoles = const Value.absent(),
    this.priceLabel = const Value.absent(),
    this.code = const Value.absent(),
    this.status = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealsCompanion.insert({
    required String id,
    required String needId,
    required String providerId,
    required String providerName,
    required int priceSoles,
    required String priceLabel,
    required String code,
    required String status,
    required DateTime acceptedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       needId = Value(needId),
       providerId = Value(providerId),
       providerName = Value(providerName),
       priceSoles = Value(priceSoles),
       priceLabel = Value(priceLabel),
       code = Value(code),
       status = Value(status),
       acceptedAt = Value(acceptedAt);
  static Insertable<DealRow> custom({
    Expression<String>? id,
    Expression<String>? needId,
    Expression<String>? providerId,
    Expression<String>? providerName,
    Expression<int>? priceSoles,
    Expression<String>? priceLabel,
    Expression<String>? code,
    Expression<String>? status,
    Expression<DateTime>? acceptedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (needId != null) 'need_id': needId,
      if (providerId != null) 'provider_id': providerId,
      if (providerName != null) 'provider_name': providerName,
      if (priceSoles != null) 'price_soles': priceSoles,
      if (priceLabel != null) 'price_label': priceLabel,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealsCompanion copyWith({
    Value<String>? id,
    Value<String>? needId,
    Value<String>? providerId,
    Value<String>? providerName,
    Value<int>? priceSoles,
    Value<String>? priceLabel,
    Value<String>? code,
    Value<String>? status,
    Value<DateTime>? acceptedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return DealsCompanion(
      id: id ?? this.id,
      needId: needId ?? this.needId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      priceSoles: priceSoles ?? this.priceSoles,
      priceLabel: priceLabel ?? this.priceLabel,
      code: code ?? this.code,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (needId.present) {
      map['need_id'] = Variable<String>(needId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (priceSoles.present) {
      map['price_soles'] = Variable<int>(priceSoles.value);
    }
    if (priceLabel.present) {
      map['price_label'] = Variable<String>(priceLabel.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealsCompanion(')
          ..write('id: $id, ')
          ..write('needId: $needId, ')
          ..write('providerId: $providerId, ')
          ..write('providerName: $providerName, ')
          ..write('priceSoles: $priceSoles, ')
          ..write('priceLabel: $priceLabel, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionsTable extends Interactions
    with TableInfo<$InteractionsTable, InteractionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _raterIdMeta = const VerificationMeta(
    'raterId',
  );
  @override
  late final GeneratedColumn<String> raterId = GeneratedColumn<String>(
    'rater_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedMeta = const VerificationMeta(
    'recommended',
  );
  @override
  late final GeneratedColumn<bool> recommended = GeneratedColumn<bool>(
    'recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recommended" IN (0, 1))',
    ),
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dealId,
    providerId,
    raterId,
    stars,
    recommended,
    closedAt,
    comment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InteractionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('rater_id')) {
      context.handle(
        _raterIdMeta,
        raterId.isAcceptableOrUnknown(data['rater_id']!, _raterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_raterIdMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('recommended')) {
      context.handle(
        _recommendedMeta,
        recommended.isAcceptableOrUnknown(
          data['recommended']!,
          _recommendedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_closedAtMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InteractionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InteractionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      raterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rater_id'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      recommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recommended'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
    );
  }

  @override
  $InteractionsTable createAlias(String alias) {
    return $InteractionsTable(attachedDatabase, alias);
  }
}

class InteractionRow extends DataClass implements Insertable<InteractionRow> {
  final String id;
  final String dealId;
  final String providerId;
  final String raterId;
  final int stars;
  final bool recommended;
  final DateTime closedAt;
  final String comment;
  const InteractionRow({
    required this.id,
    required this.dealId,
    required this.providerId,
    required this.raterId,
    required this.stars,
    required this.recommended,
    required this.closedAt,
    required this.comment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deal_id'] = Variable<String>(dealId);
    map['provider_id'] = Variable<String>(providerId);
    map['rater_id'] = Variable<String>(raterId);
    map['stars'] = Variable<int>(stars);
    map['recommended'] = Variable<bool>(recommended);
    map['closed_at'] = Variable<DateTime>(closedAt);
    map['comment'] = Variable<String>(comment);
    return map;
  }

  InteractionsCompanion toCompanion(bool nullToAbsent) {
    return InteractionsCompanion(
      id: Value(id),
      dealId: Value(dealId),
      providerId: Value(providerId),
      raterId: Value(raterId),
      stars: Value(stars),
      recommended: Value(recommended),
      closedAt: Value(closedAt),
      comment: Value(comment),
    );
  }

  factory InteractionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InteractionRow(
      id: serializer.fromJson<String>(json['id']),
      dealId: serializer.fromJson<String>(json['dealId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      raterId: serializer.fromJson<String>(json['raterId']),
      stars: serializer.fromJson<int>(json['stars']),
      recommended: serializer.fromJson<bool>(json['recommended']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      comment: serializer.fromJson<String>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dealId': serializer.toJson<String>(dealId),
      'providerId': serializer.toJson<String>(providerId),
      'raterId': serializer.toJson<String>(raterId),
      'stars': serializer.toJson<int>(stars),
      'recommended': serializer.toJson<bool>(recommended),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'comment': serializer.toJson<String>(comment),
    };
  }

  InteractionRow copyWith({
    String? id,
    String? dealId,
    String? providerId,
    String? raterId,
    int? stars,
    bool? recommended,
    DateTime? closedAt,
    String? comment,
  }) => InteractionRow(
    id: id ?? this.id,
    dealId: dealId ?? this.dealId,
    providerId: providerId ?? this.providerId,
    raterId: raterId ?? this.raterId,
    stars: stars ?? this.stars,
    recommended: recommended ?? this.recommended,
    closedAt: closedAt ?? this.closedAt,
    comment: comment ?? this.comment,
  );
  InteractionRow copyWithCompanion(InteractionsCompanion data) {
    return InteractionRow(
      id: data.id.present ? data.id.value : this.id,
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      raterId: data.raterId.present ? data.raterId.value : this.raterId,
      stars: data.stars.present ? data.stars.value : this.stars,
      recommended: data.recommended.present
          ? data.recommended.value
          : this.recommended,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InteractionRow(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('providerId: $providerId, ')
          ..write('raterId: $raterId, ')
          ..write('stars: $stars, ')
          ..write('recommended: $recommended, ')
          ..write('closedAt: $closedAt, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dealId,
    providerId,
    raterId,
    stars,
    recommended,
    closedAt,
    comment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractionRow &&
          other.id == this.id &&
          other.dealId == this.dealId &&
          other.providerId == this.providerId &&
          other.raterId == this.raterId &&
          other.stars == this.stars &&
          other.recommended == this.recommended &&
          other.closedAt == this.closedAt &&
          other.comment == this.comment);
}

class InteractionsCompanion extends UpdateCompanion<InteractionRow> {
  final Value<String> id;
  final Value<String> dealId;
  final Value<String> providerId;
  final Value<String> raterId;
  final Value<int> stars;
  final Value<bool> recommended;
  final Value<DateTime> closedAt;
  final Value<String> comment;
  final Value<int> rowid;
  const InteractionsCompanion({
    this.id = const Value.absent(),
    this.dealId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.raterId = const Value.absent(),
    this.stars = const Value.absent(),
    this.recommended = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InteractionsCompanion.insert({
    required String id,
    required String dealId,
    required String providerId,
    required String raterId,
    required int stars,
    required bool recommended,
    required DateTime closedAt,
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dealId = Value(dealId),
       providerId = Value(providerId),
       raterId = Value(raterId),
       stars = Value(stars),
       recommended = Value(recommended),
       closedAt = Value(closedAt);
  static Insertable<InteractionRow> custom({
    Expression<String>? id,
    Expression<String>? dealId,
    Expression<String>? providerId,
    Expression<String>? raterId,
    Expression<int>? stars,
    Expression<bool>? recommended,
    Expression<DateTime>? closedAt,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dealId != null) 'deal_id': dealId,
      if (providerId != null) 'provider_id': providerId,
      if (raterId != null) 'rater_id': raterId,
      if (stars != null) 'stars': stars,
      if (recommended != null) 'recommended': recommended,
      if (closedAt != null) 'closed_at': closedAt,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InteractionsCompanion copyWith({
    Value<String>? id,
    Value<String>? dealId,
    Value<String>? providerId,
    Value<String>? raterId,
    Value<int>? stars,
    Value<bool>? recommended,
    Value<DateTime>? closedAt,
    Value<String>? comment,
    Value<int>? rowid,
  }) {
    return InteractionsCompanion(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      providerId: providerId ?? this.providerId,
      raterId: raterId ?? this.raterId,
      stars: stars ?? this.stars,
      recommended: recommended ?? this.recommended,
      closedAt: closedAt ?? this.closedAt,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (raterId.present) {
      map['rater_id'] = Variable<String>(raterId.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (recommended.present) {
      map['recommended'] = Variable<bool>(recommended.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionsCompanion(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('providerId: $providerId, ')
          ..write('raterId: $raterId, ')
          ..write('stars: $stars, ')
          ..write('recommended: $recommended, ')
          ..write('closedAt: $closedAt, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OffersTable extends Offers with TableInfo<$OffersTable, OfferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OffersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modalityMeta = const VerificationMeta(
    'modality',
  );
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
    'modality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modality,
    body,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'neighbor_offers';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('modality')) {
      context.handle(
        _modalityMeta,
        modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta),
      );
    } else if (isInserting) {
      context.missing(_modalityMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfferRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $OffersTable createAlias(String alias) {
    return $OffersTable(attachedDatabase, alias);
  }
}

class OfferRow extends DataClass implements Insertable<OfferRow> {
  final String id;
  final String modality;
  final String body;
  final DateTime createdAt;
  final String syncStatus;
  const OfferRow({
    required this.id,
    required this.modality,
    required this.body,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modality'] = Variable<String>(modality);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  OffersCompanion toCompanion(bool nullToAbsent) {
    return OffersCompanion(
      id: Value(id),
      modality: Value(modality),
      body: Value(body),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory OfferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfferRow(
      id: serializer.fromJson<String>(json['id']),
      modality: serializer.fromJson<String>(json['modality']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modality': serializer.toJson<String>(modality),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  OfferRow copyWith({
    String? id,
    String? modality,
    String? body,
    DateTime? createdAt,
    String? syncStatus,
  }) => OfferRow(
    id: id ?? this.id,
    modality: modality ?? this.modality,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  OfferRow copyWithCompanion(OffersCompanion data) {
    return OfferRow(
      id: data.id.present ? data.id.value : this.id,
      modality: data.modality.present ? data.modality.value : this.modality,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfferRow(')
          ..write('id: $id, ')
          ..write('modality: $modality, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, modality, body, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfferRow &&
          other.id == this.id &&
          other.modality == this.modality &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class OffersCompanion extends UpdateCompanion<OfferRow> {
  final Value<String> id;
  final Value<String> modality;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const OffersCompanion({
    this.id = const Value.absent(),
    this.modality = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OffersCompanion.insert({
    required String id,
    required String modality,
    required String body,
    required DateTime createdAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modality = Value(modality),
       body = Value(body),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<OfferRow> custom({
    Expression<String>? id,
    Expression<String>? modality,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modality != null) 'modality': modality,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OffersCompanion copyWith({
    Value<String>? id,
    Value<String>? modality,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return OffersCompanion(
      id: id ?? this.id,
      modality: modality ?? this.modality,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OffersCompanion(')
          ..write('id: $id, ')
          ..write('modality: $modality, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dealIdMeta = const VerificationMeta('dealId');
  @override
  late final GeneratedColumn<String> dealId = GeneratedColumn<String>(
    'deal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dealId,
    body,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deal_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deal_id')) {
      context.handle(
        _dealIdMeta,
        dealId.isAcceptableOrUnknown(data['deal_id']!, _dealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dealIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  final String id;
  final String dealId;
  final String body;
  final DateTime createdAt;
  final String syncStatus;
  const ChatMessageRow({
    required this.id,
    required this.dealId,
    required this.body,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deal_id'] = Variable<String>(dealId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      dealId: Value(dealId),
      body: Value(body),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ChatMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      dealId: serializer.fromJson<String>(json['dealId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dealId': serializer.toJson<String>(dealId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ChatMessageRow copyWith({
    String? id,
    String? dealId,
    String? body,
    DateTime? createdAt,
    String? syncStatus,
  }) => ChatMessageRow(
    id: id ?? this.id,
    dealId: dealId ?? this.dealId,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      dealId: data.dealId.present ? data.dealId.value : this.dealId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dealId, body, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.dealId == this.dealId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<String> id;
  final Value<String> dealId;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.dealId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String dealId,
    required String body,
    required DateTime createdAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dealId = Value(dealId),
       body = Value(body),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<ChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? dealId,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dealId != null) 'deal_id': dealId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? dealId,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dealId.present) {
      map['deal_id'] = Variable<String>(dealId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('dealId: $dealId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmergencyPostsTable extends EmergencyPosts
    with TableInfo<$EmergencyPostsTable, EmergencyPostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmergencyPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _situationMeta = const VerificationMeta(
    'situation',
  );
  @override
  late final GeneratedColumn<String> situation = GeneratedColumn<String>(
    'situation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    situation,
    body,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sos_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmergencyPostRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('situation')) {
      context.handle(
        _situationMeta,
        situation.isAcceptableOrUnknown(data['situation']!, _situationMeta),
      );
    } else if (isInserting) {
      context.missing(_situationMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmergencyPostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmergencyPostRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      situation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}situation'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $EmergencyPostsTable createAlias(String alias) {
    return $EmergencyPostsTable(attachedDatabase, alias);
  }
}

class EmergencyPostRow extends DataClass
    implements Insertable<EmergencyPostRow> {
  final String id;
  final String situation;
  final String body;
  final DateTime createdAt;
  final String syncStatus;
  const EmergencyPostRow({
    required this.id,
    required this.situation,
    required this.body,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['situation'] = Variable<String>(situation);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  EmergencyPostsCompanion toCompanion(bool nullToAbsent) {
    return EmergencyPostsCompanion(
      id: Value(id),
      situation: Value(situation),
      body: Value(body),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory EmergencyPostRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmergencyPostRow(
      id: serializer.fromJson<String>(json['id']),
      situation: serializer.fromJson<String>(json['situation']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'situation': serializer.toJson<String>(situation),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  EmergencyPostRow copyWith({
    String? id,
    String? situation,
    String? body,
    DateTime? createdAt,
    String? syncStatus,
  }) => EmergencyPostRow(
    id: id ?? this.id,
    situation: situation ?? this.situation,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  EmergencyPostRow copyWithCompanion(EmergencyPostsCompanion data) {
    return EmergencyPostRow(
      id: data.id.present ? data.id.value : this.id,
      situation: data.situation.present ? data.situation.value : this.situation,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyPostRow(')
          ..write('id: $id, ')
          ..write('situation: $situation, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, situation, body, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyPostRow &&
          other.id == this.id &&
          other.situation == this.situation &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class EmergencyPostsCompanion extends UpdateCompanion<EmergencyPostRow> {
  final Value<String> id;
  final Value<String> situation;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const EmergencyPostsCompanion({
    this.id = const Value.absent(),
    this.situation = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmergencyPostsCompanion.insert({
    required String id,
    required String situation,
    required String body,
    required DateTime createdAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       situation = Value(situation),
       body = Value(body),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<EmergencyPostRow> custom({
    Expression<String>? id,
    Expression<String>? situation,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (situation != null) 'situation': situation,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmergencyPostsCompanion copyWith({
    Value<String>? id,
    Value<String>? situation,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return EmergencyPostsCompanion(
      id: id ?? this.id,
      situation: situation ?? this.situation,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (situation.present) {
      map['situation'] = Variable<String>(situation.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyPostsCompanion(')
          ..write('id: $id, ')
          ..write('situation: $situation, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionPointsTable extends CollectionPoints
    with TableInfo<$CollectionPointsTable, CollectionPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, reference, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'acopio_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CollectionPointsTable createAlias(String alias) {
    return $CollectionPointsTable(attachedDatabase, alias);
  }
}

class CollectionPointRow extends DataClass
    implements Insertable<CollectionPointRow> {
  final String id;
  final String name;
  final String reference;
  final DateTime createdAt;
  const CollectionPointRow({
    required this.id,
    required this.name,
    required this.reference,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['reference'] = Variable<String>(reference);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CollectionPointsCompanion toCompanion(bool nullToAbsent) {
    return CollectionPointsCompanion(
      id: Value(id),
      name: Value(name),
      reference: Value(reference),
      createdAt: Value(createdAt),
    );
  }

  factory CollectionPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionPointRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      reference: serializer.fromJson<String>(json['reference']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'reference': serializer.toJson<String>(reference),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CollectionPointRow copyWith({
    String? id,
    String? name,
    String? reference,
    DateTime? createdAt,
  }) => CollectionPointRow(
    id: id ?? this.id,
    name: name ?? this.name,
    reference: reference ?? this.reference,
    createdAt: createdAt ?? this.createdAt,
  );
  CollectionPointRow copyWithCompanion(CollectionPointsCompanion data) {
    return CollectionPointRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      reference: data.reference.present ? data.reference.value : this.reference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionPointRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, reference, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionPointRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.reference == this.reference &&
          other.createdAt == this.createdAt);
}

class CollectionPointsCompanion extends UpdateCompanion<CollectionPointRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> reference;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CollectionPointsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionPointsCompanion.insert({
    required String id,
    required String name,
    required String reference,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       reference = Value(reference),
       createdAt = Value(createdAt);
  static Insertable<CollectionPointRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? reference,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? reference,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CollectionPointsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionPointsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsKvTable extends AppSettingsKv
    with TableInfo<$AppSettingsKvTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsKvTable createAlias(String alias) {
    return $AppSettingsKvTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsKvCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsKvCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsKvCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsKvCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsKvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsKvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsKvCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsKvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsKvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonProfileTable extends PersonProfile
    with TableInfo<$PersonProfileTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonProfileTable createAlias(String alias) {
    return $PersonProfileTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final String username;
  final String? email;
  final DateTime createdAt;
  const ProfileRow({
    required this.id,
    required this.username,
    this.email,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonProfileCompanion toCompanion(bool nullToAbsent) {
    return PersonProfileCompanion(
      id: Value(id),
      username: Value(username),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String?>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String?>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProfileRow copyWith({
    String? id,
    String? username,
    Value<String?> email = const Value.absent(),
    DateTime? createdAt,
  }) => ProfileRow(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email.present ? email.value : this.email,
    createdAt: createdAt ?? this.createdAt,
  );
  ProfileRow copyWithCompanion(PersonProfileCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class PersonProfileCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<String> username;
  final Value<String?> email;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PersonProfileCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonProfileCompanion.insert({
    required String id,
    required String username,
    this.email = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       createdAt = Value(createdAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String?>? email,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PersonProfileCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonProfileCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonAddressesTable extends PersonAddresses
    with TableInfo<$PersonAddressesTable, AddressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    reference,
    lat,
    lng,
    createdAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AddressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AddressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AddressRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $PersonAddressesTable createAlias(String alias) {
    return $PersonAddressesTable(attachedDatabase, alias);
  }
}

class AddressRow extends DataClass implements Insertable<AddressRow> {
  final String id;
  final String name;
  final String reference;
  final double lat;
  final double lng;
  final DateTime createdAt;
  final bool isActive;
  const AddressRow({
    required this.id,
    required this.name,
    required this.reference,
    required this.lat,
    required this.lng,
    required this.createdAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['reference'] = Variable<String>(reference);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  PersonAddressesCompanion toCompanion(bool nullToAbsent) {
    return PersonAddressesCompanion(
      id: Value(id),
      name: Value(name),
      reference: Value(reference),
      lat: Value(lat),
      lng: Value(lng),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
    );
  }

  factory AddressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AddressRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      reference: serializer.fromJson<String>(json['reference']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'reference': serializer.toJson<String>(reference),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AddressRow copyWith({
    String? id,
    String? name,
    String? reference,
    double? lat,
    double? lng,
    DateTime? createdAt,
    bool? isActive,
  }) => AddressRow(
    id: id ?? this.id,
    name: name ?? this.name,
    reference: reference ?? this.reference,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
  );
  AddressRow copyWithCompanion(PersonAddressesCompanion data) {
    return AddressRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      reference: data.reference.present ? data.reference.value : this.reference,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AddressRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, reference, lat, lng, createdAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddressRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.reference == this.reference &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive);
}

class PersonAddressesCompanion extends UpdateCompanion<AddressRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> reference;
  final Value<double> lat;
  final Value<double> lng;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const PersonAddressesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.reference = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonAddressesCompanion.insert({
    required String id,
    required String name,
    this.reference = const Value.absent(),
    required double lat,
    required double lng,
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       lat = Value(lat),
       lng = Value(lng),
       createdAt = Value(createdAt);
  static Insertable<AddressRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? reference,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (reference != null) 'reference': reference,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonAddressesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? reference,
    Value<double>? lat,
    Value<double>? lng,
    Value<DateTime>? createdAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return PersonAddressesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonAddressesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NeedsTable needs = $NeedsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $DealsTable deals = $DealsTable(this);
  late final $InteractionsTable interactions = $InteractionsTable(this);
  late final $OffersTable offers = $OffersTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $EmergencyPostsTable emergencyPosts = $EmergencyPostsTable(this);
  late final $CollectionPointsTable collectionPoints = $CollectionPointsTable(
    this,
  );
  late final $AppSettingsKvTable appSettingsKv = $AppSettingsKvTable(this);
  late final $PersonProfileTable personProfile = $PersonProfileTable(this);
  late final $PersonAddressesTable personAddresses = $PersonAddressesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    needs,
    outboxOps,
    deals,
    interactions,
    offers,
    chatMessages,
    emergencyPosts,
    collectionPoints,
    appSettingsKv,
    personProfile,
    personAddresses,
  ];
}

typedef $$NeedsTableCreateCompanionBuilder = NeedsCompanion Function({
  required String id,
  required String kind,
  required String body,
  required String urgency,
  required DateTime createdAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$NeedsTableUpdateCompanionBuilder = NeedsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> body,
  Value<String> urgency,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$NeedsTableFilterComposer extends Composer<_$AppDatabase, $NeedsTable> {
  $$NeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $NeedsTable> {
  $$NeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NeedsTable> {
  $$NeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$NeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NeedsTable,
          NeedRow,
          $$NeedsTableFilterComposer,
          $$NeedsTableOrderingComposer,
          $$NeedsTableAnnotationComposer,
          $$NeedsTableCreateCompanionBuilder,
          $$NeedsTableUpdateCompanionBuilder,
          (NeedRow, BaseReferences<_$AppDatabase, $NeedsTable, NeedRow>),
          NeedRow,
          PrefetchHooks Function()
        > {
  $$NeedsTableTableManager(_$AppDatabase db, $NeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> urgency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NeedsCompanion(
                id: id,
                kind: kind,
                body: body,
                urgency: urgency,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String body,
                required String urgency,
                required DateTime createdAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => NeedsCompanion.insert(
                id: id,
                kind: kind,
                body: body,
                urgency: urgency,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NeedsTable, NeedRow>(table),
                  BaseReferences<_$AppDatabase, $NeedsTable, NeedRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NeedsTable,
      NeedRow,
      $$NeedsTableFilterComposer,
      $$NeedsTableOrderingComposer,
      $$NeedsTableAnnotationComposer,
      $$NeedsTableCreateCompanionBuilder,
      $$NeedsTableUpdateCompanionBuilder,
      (NeedRow, BaseReferences<_$AppDatabase, $NeedsTable, NeedRow>),
      NeedRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  required String id,
  required String opType,
  required String payload,
  Value<int> attempts,
  required DateTime createdAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<String> id,
  Value<String> opType,
  Value<String> payload,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$OutboxOpsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion(
                id: id,
                opType: opType,
                payload: payload,
                attempts: attempts,
                createdAt: createdAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String opType,
                required String payload,
                Value<int> attempts = const Value.absent(),
                required DateTime createdAt,
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion.insert(
                id: id,
                opType: opType,
                payload: payload,
                attempts: attempts,
                createdAt: createdAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$DealsTableCreateCompanionBuilder = DealsCompanion Function({
  required String id,
  required String needId,
  required String providerId,
  required String providerName,
  required int priceSoles,
  required String priceLabel,
  required String code,
  required String status,
  required DateTime acceptedAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$DealsTableUpdateCompanionBuilder = DealsCompanion Function({
  Value<String> id,
  Value<String> needId,
  Value<String> providerId,
  Value<String> providerName,
  Value<int> priceSoles,
  Value<String> priceLabel,
  Value<String> code,
  Value<String> status,
  Value<DateTime> acceptedAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$DealsTableFilterComposer extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get needId => $composableBuilder(
    column: $table.needId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceSoles => $composableBuilder(
    column: $table.priceSoles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceLabel => $composableBuilder(
    column: $table.priceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get needId => $composableBuilder(
    column: $table.needId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceSoles => $composableBuilder(
    column: $table.priceSoles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceLabel => $composableBuilder(
    column: $table.priceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get needId =>
      $composableBuilder(column: $table.needId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceSoles => $composableBuilder(
    column: $table.priceSoles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priceLabel => $composableBuilder(
    column: $table.priceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealsTable,
          DealRow,
          $$DealsTableFilterComposer,
          $$DealsTableOrderingComposer,
          $$DealsTableAnnotationComposer,
          $$DealsTableCreateCompanionBuilder,
          $$DealsTableUpdateCompanionBuilder,
          (DealRow, BaseReferences<_$AppDatabase, $DealsTable, DealRow>),
          DealRow,
          PrefetchHooks Function()
        > {
  $$DealsTableTableManager(_$AppDatabase db, $DealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> needId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> providerName = const Value.absent(),
                Value<int> priceSoles = const Value.absent(),
                Value<String> priceLabel = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> acceptedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion(
                id: id,
                needId: needId,
                providerId: providerId,
                providerName: providerName,
                priceSoles: priceSoles,
                priceLabel: priceLabel,
                code: code,
                status: status,
                acceptedAt: acceptedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String needId,
                required String providerId,
                required String providerName,
                required int priceSoles,
                required String priceLabel,
                required String code,
                required String status,
                required DateTime acceptedAt,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion.insert(
                id: id,
                needId: needId,
                providerId: providerId,
                providerName: providerName,
                priceSoles: priceSoles,
                priceLabel: priceLabel,
                code: code,
                status: status,
                acceptedAt: acceptedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DealsTable, DealRow>(table),
                  BaseReferences<_$AppDatabase, $DealsTable, DealRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealsTable,
      DealRow,
      $$DealsTableFilterComposer,
      $$DealsTableOrderingComposer,
      $$DealsTableAnnotationComposer,
      $$DealsTableCreateCompanionBuilder,
      $$DealsTableUpdateCompanionBuilder,
      (DealRow, BaseReferences<_$AppDatabase, $DealsTable, DealRow>),
      DealRow,
      PrefetchHooks Function()
    >;
typedef $$InteractionsTableCreateCompanionBuilder =
    InteractionsCompanion Function({
      required String id,
      required String dealId,
      required String providerId,
      required String raterId,
      required int stars,
      required bool recommended,
      required DateTime closedAt,
      Value<String> comment,
      Value<int> rowid,
    });
typedef $$InteractionsTableUpdateCompanionBuilder =
    InteractionsCompanion Function({
      Value<String> id,
      Value<String> dealId,
      Value<String> providerId,
      Value<String> raterId,
      Value<int> stars,
      Value<bool> recommended,
      Value<DateTime> closedAt,
      Value<String> comment,
      Value<int> rowid,
    });

class $$InteractionsTableFilterComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raterId => $composableBuilder(
    column: $table.raterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InteractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raterId => $composableBuilder(
    column: $table.raterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InteractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get raterId =>
      $composableBuilder(column: $table.raterId, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<bool> get recommended => $composableBuilder(
    column: $table.recommended,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$InteractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InteractionsTable,
          InteractionRow,
          $$InteractionsTableFilterComposer,
          $$InteractionsTableOrderingComposer,
          $$InteractionsTableAnnotationComposer,
          $$InteractionsTableCreateCompanionBuilder,
          $$InteractionsTableUpdateCompanionBuilder,
          (
            InteractionRow,
            BaseReferences<_$AppDatabase, $InteractionsTable, InteractionRow>,
          ),
          InteractionRow,
          PrefetchHooks Function()
        > {
  $$InteractionsTableTableManager(_$AppDatabase db, $InteractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dealId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> raterId = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<bool> recommended = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion(
                id: id,
                dealId: dealId,
                providerId: providerId,
                raterId: raterId,
                stars: stars,
                recommended: recommended,
                closedAt: closedAt,
                comment: comment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dealId,
                required String providerId,
                required String raterId,
                required int stars,
                required bool recommended,
                required DateTime closedAt,
                Value<String> comment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion.insert(
                id: id,
                dealId: dealId,
                providerId: providerId,
                raterId: raterId,
                stars: stars,
                recommended: recommended,
                closedAt: closedAt,
                comment: comment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InteractionsTable, InteractionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InteractionsTable,
                    InteractionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InteractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InteractionsTable,
      InteractionRow,
      $$InteractionsTableFilterComposer,
      $$InteractionsTableOrderingComposer,
      $$InteractionsTableAnnotationComposer,
      $$InteractionsTableCreateCompanionBuilder,
      $$InteractionsTableUpdateCompanionBuilder,
      (
        InteractionRow,
        BaseReferences<_$AppDatabase, $InteractionsTable, InteractionRow>,
      ),
      InteractionRow,
      PrefetchHooks Function()
    >;
typedef $$OffersTableCreateCompanionBuilder = OffersCompanion Function({
  required String id,
  required String modality,
  required String body,
  required DateTime createdAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$OffersTableUpdateCompanionBuilder = OffersCompanion Function({
  Value<String> id,
  Value<String> modality,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$OffersTableFilterComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OffersTableOrderingComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OffersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$OffersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OffersTable,
          OfferRow,
          $$OffersTableFilterComposer,
          $$OffersTableOrderingComposer,
          $$OffersTableAnnotationComposer,
          $$OffersTableCreateCompanionBuilder,
          $$OffersTableUpdateCompanionBuilder,
          (OfferRow, BaseReferences<_$AppDatabase, $OffersTable, OfferRow>),
          OfferRow,
          PrefetchHooks Function()
        > {
  $$OffersTableTableManager(_$AppDatabase db, $OffersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OffersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OffersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OffersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modality = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OffersCompanion(
                id: id,
                modality: modality,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modality,
                required String body,
                required DateTime createdAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => OffersCompanion.insert(
                id: id,
                modality: modality,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OffersTable, OfferRow>(table),
                  BaseReferences<_$AppDatabase, $OffersTable, OfferRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OffersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OffersTable,
      OfferRow,
      $$OffersTableFilterComposer,
      $$OffersTableOrderingComposer,
      $$OffersTableAnnotationComposer,
      $$OffersTableCreateCompanionBuilder,
      $$OffersTableUpdateCompanionBuilder,
      (OfferRow, BaseReferences<_$AppDatabase, $OffersTable, OfferRow>),
      OfferRow,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String dealId,
      required String body,
      required DateTime createdAt,
      required String syncStatus,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> dealId,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dealId => $composableBuilder(
    column: $table.dealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dealId =>
      $composableBuilder(column: $table.dealId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessageRow,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessageRow,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>,
          ),
          ChatMessageRow,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dealId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                dealId: dealId,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dealId,
                required String body,
                required DateTime createdAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                dealId: dealId,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatMessagesTable, ChatMessageRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChatMessagesTable,
                    ChatMessageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessageRow,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessageRow,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>,
      ),
      ChatMessageRow,
      PrefetchHooks Function()
    >;
typedef $$EmergencyPostsTableCreateCompanionBuilder =
    EmergencyPostsCompanion Function({
      required String id,
      required String situation,
      required String body,
      required DateTime createdAt,
      required String syncStatus,
      Value<int> rowid,
    });
typedef $$EmergencyPostsTableUpdateCompanionBuilder =
    EmergencyPostsCompanion Function({
      Value<String> id,
      Value<String> situation,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$EmergencyPostsTableFilterComposer
    extends Composer<_$AppDatabase, $EmergencyPostsTable> {
  $$EmergencyPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get situation => $composableBuilder(
    column: $table.situation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmergencyPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmergencyPostsTable> {
  $$EmergencyPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get situation => $composableBuilder(
    column: $table.situation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmergencyPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmergencyPostsTable> {
  $$EmergencyPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get situation =>
      $composableBuilder(column: $table.situation, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$EmergencyPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmergencyPostsTable,
          EmergencyPostRow,
          $$EmergencyPostsTableFilterComposer,
          $$EmergencyPostsTableOrderingComposer,
          $$EmergencyPostsTableAnnotationComposer,
          $$EmergencyPostsTableCreateCompanionBuilder,
          $$EmergencyPostsTableUpdateCompanionBuilder,
          (
            EmergencyPostRow,
            BaseReferences<
              _$AppDatabase,
              $EmergencyPostsTable,
              EmergencyPostRow
            >,
          ),
          EmergencyPostRow,
          PrefetchHooks Function()
        > {
  $$EmergencyPostsTableTableManager(
    _$AppDatabase db,
    $EmergencyPostsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmergencyPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmergencyPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmergencyPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> situation = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmergencyPostsCompanion(
                id: id,
                situation: situation,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String situation,
                required String body,
                required DateTime createdAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => EmergencyPostsCompanion.insert(
                id: id,
                situation: situation,
                body: body,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmergencyPostsTable, EmergencyPostRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EmergencyPostsTable,
                    EmergencyPostRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmergencyPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmergencyPostsTable,
      EmergencyPostRow,
      $$EmergencyPostsTableFilterComposer,
      $$EmergencyPostsTableOrderingComposer,
      $$EmergencyPostsTableAnnotationComposer,
      $$EmergencyPostsTableCreateCompanionBuilder,
      $$EmergencyPostsTableUpdateCompanionBuilder,
      (
        EmergencyPostRow,
        BaseReferences<_$AppDatabase, $EmergencyPostsTable, EmergencyPostRow>,
      ),
      EmergencyPostRow,
      PrefetchHooks Function()
    >;
typedef $$CollectionPointsTableCreateCompanionBuilder =
    CollectionPointsCompanion Function({
      required String id,
      required String name,
      required String reference,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CollectionPointsTableUpdateCompanionBuilder =
    CollectionPointsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> reference,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CollectionPointsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionPointsTable> {
  $$CollectionPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionPointsTable> {
  $$CollectionPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionPointsTable> {
  $$CollectionPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CollectionPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionPointsTable,
          CollectionPointRow,
          $$CollectionPointsTableFilterComposer,
          $$CollectionPointsTableOrderingComposer,
          $$CollectionPointsTableAnnotationComposer,
          $$CollectionPointsTableCreateCompanionBuilder,
          $$CollectionPointsTableUpdateCompanionBuilder,
          (
            CollectionPointRow,
            BaseReferences<
              _$AppDatabase,
              $CollectionPointsTable,
              CollectionPointRow
            >,
          ),
          CollectionPointRow,
          PrefetchHooks Function()
        > {
  $$CollectionPointsTableTableManager(
    _$AppDatabase db,
    $CollectionPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionPointsCompanion(
                id: id,
                name: name,
                reference: reference,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String reference,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionPointsCompanion.insert(
                id: id,
                name: name,
                reference: reference,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionPointsTable, CollectionPointRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectionPointsTable,
                    CollectionPointRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionPointsTable,
      CollectionPointRow,
      $$CollectionPointsTableFilterComposer,
      $$CollectionPointsTableOrderingComposer,
      $$CollectionPointsTableAnnotationComposer,
      $$CollectionPointsTableCreateCompanionBuilder,
      $$CollectionPointsTableUpdateCompanionBuilder,
      (
        CollectionPointRow,
        BaseReferences<
          _$AppDatabase,
          $CollectionPointsTable,
          CollectionPointRow
        >,
      ),
      CollectionPointRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsKvTableCreateCompanionBuilder =
    AppSettingsKvCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsKvTableUpdateCompanionBuilder =
    AppSettingsKvCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsKvTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsKvTable> {
  $$AppSettingsKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsKvTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsKvTable> {
  $$AppSettingsKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsKvTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsKvTable> {
  $$AppSettingsKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsKvTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsKvTable,
          SettingRow,
          $$AppSettingsKvTableFilterComposer,
          $$AppSettingsKvTableOrderingComposer,
          $$AppSettingsKvTableAnnotationComposer,
          $$AppSettingsKvTableCreateCompanionBuilder,
          $$AppSettingsKvTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsKvTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsKvTableTableManager(_$AppDatabase db, $AppSettingsKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsKvCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsKvCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsKvTable, SettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsKvTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsKvTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsKvTable,
      SettingRow,
      $$AppSettingsKvTableFilterComposer,
      $$AppSettingsKvTableOrderingComposer,
      $$AppSettingsKvTableAnnotationComposer,
      $$AppSettingsKvTableCreateCompanionBuilder,
      $$AppSettingsKvTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsKvTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$PersonProfileTableCreateCompanionBuilder =
    PersonProfileCompanion Function({
      required String id,
      required String username,
      Value<String?> email,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PersonProfileTableUpdateCompanionBuilder =
    PersonProfileCompanion Function({
      Value<String> id,
      Value<String> username,
      Value<String?> email,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PersonProfileTableFilterComposer
    extends Composer<_$AppDatabase, $PersonProfileTable> {
  $$PersonProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonProfileTable> {
  $$PersonProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonProfileTable> {
  $$PersonProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PersonProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonProfileTable,
          ProfileRow,
          $$PersonProfileTableFilterComposer,
          $$PersonProfileTableOrderingComposer,
          $$PersonProfileTableAnnotationComposer,
          $$PersonProfileTableCreateCompanionBuilder,
          $$PersonProfileTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $PersonProfileTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$PersonProfileTableTableManager(_$AppDatabase db, $PersonProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonProfileCompanion(
                id: id,
                username: username,
                email: email,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                Value<String?> email = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonProfileCompanion.insert(
                id: id,
                username: username,
                email: email,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonProfileTable, ProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PersonProfileTable,
                    ProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonProfileTable,
      ProfileRow,
      $$PersonProfileTableFilterComposer,
      $$PersonProfileTableOrderingComposer,
      $$PersonProfileTableAnnotationComposer,
      $$PersonProfileTableCreateCompanionBuilder,
      $$PersonProfileTableUpdateCompanionBuilder,
      (
        ProfileRow,
        BaseReferences<_$AppDatabase, $PersonProfileTable, ProfileRow>,
      ),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$PersonAddressesTableCreateCompanionBuilder =
    PersonAddressesCompanion Function({
      required String id,
      required String name,
      Value<String> reference,
      required double lat,
      required double lng,
      required DateTime createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$PersonAddressesTableUpdateCompanionBuilder =
    PersonAddressesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> reference,
      Value<double> lat,
      Value<double> lng,
      Value<DateTime> createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$PersonAddressesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonAddressesTable> {
  $$PersonAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonAddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonAddressesTable> {
  $$PersonAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonAddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonAddressesTable> {
  $$PersonAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$PersonAddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonAddressesTable,
          AddressRow,
          $$PersonAddressesTableFilterComposer,
          $$PersonAddressesTableOrderingComposer,
          $$PersonAddressesTableAnnotationComposer,
          $$PersonAddressesTableCreateCompanionBuilder,
          $$PersonAddressesTableUpdateCompanionBuilder,
          (
            AddressRow,
            BaseReferences<_$AppDatabase, $PersonAddressesTable, AddressRow>,
          ),
          AddressRow,
          PrefetchHooks Function()
        > {
  $$PersonAddressesTableTableManager(
    _$AppDatabase db,
    $PersonAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonAddressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonAddressesCompanion(
                id: id,
                name: name,
                reference: reference,
                lat: lat,
                lng: lng,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> reference = const Value.absent(),
                required double lat,
                required double lng,
                required DateTime createdAt,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonAddressesCompanion.insert(
                id: id,
                name: name,
                reference: reference,
                lat: lat,
                lng: lng,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonAddressesTable, AddressRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PersonAddressesTable,
                    AddressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonAddressesTable,
      AddressRow,
      $$PersonAddressesTableFilterComposer,
      $$PersonAddressesTableOrderingComposer,
      $$PersonAddressesTableAnnotationComposer,
      $$PersonAddressesTableCreateCompanionBuilder,
      $$PersonAddressesTableUpdateCompanionBuilder,
      (
        AddressRow,
        BaseReferences<_$AppDatabase, $PersonAddressesTable, AddressRow>,
      ),
      AddressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NeedsTableTableManager get needs =>
      $$NeedsTableTableManager(_db, _db.needs);
  $$OutboxOpsTableTableManager get outboxOps =>
      $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$DealsTableTableManager get deals =>
      $$DealsTableTableManager(_db, _db.deals);
  $$InteractionsTableTableManager get interactions =>
      $$InteractionsTableTableManager(_db, _db.interactions);
  $$OffersTableTableManager get offers =>
      $$OffersTableTableManager(_db, _db.offers);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$EmergencyPostsTableTableManager get emergencyPosts =>
      $$EmergencyPostsTableTableManager(_db, _db.emergencyPosts);
  $$CollectionPointsTableTableManager get collectionPoints =>
      $$CollectionPointsTableTableManager(_db, _db.collectionPoints);
  $$AppSettingsKvTableTableManager get appSettingsKv =>
      $$AppSettingsKvTableTableManager(_db, _db.appSettingsKv);
  $$PersonProfileTableTableManager get personProfile =>
      $$PersonProfileTableTableManager(_db, _db.personProfile);
  $$PersonAddressesTableTableManager get personAddresses =>
      $$PersonAddressesTableTableManager(_db, _db.personAddresses);
}
