import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/features/deals_chat/domain/photo_message.dart';
import 'package:red_barrio/features/needs/domain/need_extras.dart';

void main() {
  group('Mensaje de foto', () {
    test('se arma y se reconoce', () {
      final m = photoMessage('/data/foto_chat_1.jpg');
      expect(photoPathOf(m), '/data/foto_chat_1.jpg');
    });
    test('un mensaje común no es una foto', () {
      expect(photoPathOf('Hola, ¿a qué hora llegas?'), isNull);
      expect(photoPathOf('📷 Foto: '), isNull);
    });
  });

  group('NeedExtras', () {
    test('vacío cuando no hay detalle ni foto', () {
      expect(const NeedExtras().isEmpty, isTrue);
      expect(const NeedExtras(detail: '   ').isEmpty, isTrue);
    });
    test('con detalle o con foto no está vacío', () {
      expect(const NeedExtras(detail: 'Gotea el caño').isEmpty, isFalse);
      expect(const NeedExtras(imagePath: '/a.jpg').isEmpty, isFalse);
    });
    test('ida y vuelta por JSON', () {
      const e = NeedExtras(detail: ' Gotea ', imagePath: '/a.jpg');
      final back = NeedExtras.fromJson(e.toJson());
      expect(back.detail, 'Gotea');
      expect(back.imagePath, '/a.jpg');
    });
  });
}
