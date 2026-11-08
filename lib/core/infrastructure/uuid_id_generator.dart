import 'dart:math';

import 'package:uuid/uuid.dart';

import '../ids.dart';

class UuidIdGenerator implements IdGenerator {
  UuidIdGenerator() : _random = Random.secure();

  final Random _random;
  static const _uuid = Uuid();

  @override
  String newUuid() => _uuid.v4();

  @override
  String meetingCode() => (1000 + _random.nextInt(9000)).toString();
}
