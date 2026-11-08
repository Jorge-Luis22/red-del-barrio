import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regla de dependencias: presentation → domain ← infrastructure.
/// Falla si el dominio importa paquetes de infraestructura o si la presentación
/// importa directamente un adaptador.
void main() {
  final forbiddenInDomain = RegExp(
    r'''import\s+['"](package:(flutter|flutter_riverpod|go_router|drift|drift_flutter|supabase|supabase_flutter|matrix|geolocator|connectivity_plus|image_picker|flutter_image_compress|path_provider|url_launcher|sqlite3)[/:][^'"]*|package:flutter/[^'"]*)['"]''',
  );
  final importLine = RegExp(r'''import\s+['"]([^'"]+)['"]''');

  List<File> dartFiles(String dir) {
    final d = Directory(dir);
    if (!d.existsSync()) return [];
    return d
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  String norm(String p) => p.replaceAll('\\', '/');

  test('domain/ no importa Flutter, Drift, Supabase, matrix ni geolocator', () {
    final domainFiles = [
      ...Directory('lib/features')
          .listSync()
          .whereType<Directory>()
          .expand((f) => dartFiles('${f.path}/domain')),
      ...dartFiles('lib/core/geo'),
      File('lib/core/result.dart'),
      File('lib/core/failure.dart'),
      File('lib/core/clock.dart'),
      File('lib/core/ids.dart'),
    ];
    expect(domainFiles, isNotEmpty);
    final violations = <String>[];
    for (final f in domainFiles) {
      for (final line in f.readAsLinesSync()) {
        if (forbiddenInDomain.hasMatch(line)) {
          violations.add('${norm(f.path)}: $line');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('domain/ no depende de infrastructure/ ni de presentation/', () {
    final violations = <String>[];
    for (final f
        in Directory('lib/features')
            .listSync()
            .whereType<Directory>()
            .expand((f) => dartFiles('${f.path}/domain'))) {
      for (final line in f.readAsLinesSync()) {
        final m = importLine.firstMatch(line);
        if (m == null) continue;
        final target = m.group(1)!;
        if (target.contains('/infrastructure/') ||
            target.contains('/presentation/')) {
          violations.add('${norm(f.path)}: $line');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation/ no importa adaptadores de infrastructure/', () {
    final violations = <String>[];
    for (final f
        in Directory('lib/features')
            .listSync()
            .whereType<Directory>()
            .expand((f) => dartFiles('${f.path}/presentation'))) {
      for (final line in f.readAsLinesSync()) {
        final m = importLine.firstMatch(line);
        if (m != null && m.group(1)!.contains('/infrastructure/')) {
          violations.add('${norm(f.path)}: $line');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
