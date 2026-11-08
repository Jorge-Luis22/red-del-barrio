import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/l10n/app_localizations_en.dart';
import 'package:red_barrio/l10n/app_localizations_es.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _textKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final es = _arb('app_es');
  final en = _arb('app_en');

  test('español e inglés tienen exactamente las mismas claves', () {
    final onlyEs = _textKeys(es).difference(_textKeys(en));
    final onlyEn = _textKeys(en).difference(_textKeys(es));
    expect(onlyEs, isEmpty, reason: 'Falta en inglés: $onlyEs');
    expect(onlyEn, isEmpty, reason: 'Falta en español: $onlyEn');
  });

  test('cada texto usa los mismos datos variables en los dos idiomas', () {
    final placeholder = RegExp(r'\{(\w+)[,}]');
    final problems = <String>[];
    for (final k in _textKeys(es)) {
      if (k == '@@locale') continue;
      final a = placeholder
          .allMatches(es[k] as String)
          .map((m) => m.group(1)!)
          .toSet();
      final b = placeholder
          .allMatches(en[k] as String)
          .map((m) => m.group(1)!)
          .toSet();
      if (a.length != b.length || !a.containsAll(b))
        problems.add('$k: $a vs $b');
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('ningún texto en inglés quedó igual al español por olvido', () {
    // Los nombres propios y palabras iguales en ambos idiomas se permiten.
    const same = {'minimarket', 'sistema', 'normal', 'min', 's', 'samu'};
    final copied = <String>[];
    for (final k in _textKeys(es)) {
      if (k == '@@locale') continue;
      final a = es[k] as String;
      final b = en[k] as String;
      if (a == b &&
          a.length > 12 &&
          !k.startsWith('duracion') &&
          !same.contains(a.toLowerCase()))
        copied.add(k);
    }
    expect(copied, isEmpty, reason: 'Sin traducir: $copied');
  });

  test('las clases generadas devuelven cada idioma', () {
    final l10nEs = AppLocalizationsEs();
    final l10nEn = AppLocalizationsEn();
    expect(l10nEs.misPedidos, 'Mis pedidos');
    expect(l10nEn.misPedidos, 'My requests');
    expect(l10nEn.todoAlDiaResueltos(1), 'All caught up · 1 resolved');
    expect(l10nEn.todoAlDiaResueltos(4), 'All caught up · 4 resolved');
    expect(l10nEs.todoAlDiaResueltos(4), 'Todo al día · 4 resueltos');
    expect(
      l10nEn.vecinosRecomiendanEjemploTuyas(14, 1),
      contains('1 of yours'),
    );
    expect(l10nEn.reputacionDe('Carlos'), 'Carlos’s reputation');
  });
}
