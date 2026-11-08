import 'package:flutter_test/flutter_test.dart';
import 'package:red_barrio/features/assistant/domain/barrio_stats.dart';
import 'package:red_barrio/features/assistant/domain/request_assistant.dart';
import 'package:red_barrio/features/assistant/domain/safety_guard.dart';
import 'package:red_barrio/features/needs/domain/need.dart';

void main() {
  const assistant = RequestAssistant();
  const guard = SafetyGuard();

  group('RequestAssistant', () {
    test('textos muy cortos no generan sugerencia', () {
      expect(assistant.suggest('hola'), isNull);
    });

    test('detecta gasfitería, servicio y urgencia', () {
      final s = assistant.suggest('se rompio el caño de la cocina, urgente')!;
      expect(s.kind, NeedKind.service);
      expect(s.trade, 'Gasfitería');
      expect(s.urgency, Urgency.now);
    });

    test('detecta préstamo de herramientas', () {
      final s = assistant.suggest('alguien me presta un taladro mañana')!;
      expect(s.kind, NeedKind.loan);
      expect(s.urgency, Urgency.tomorrow);
    });

    test('detecta ayuda para acompañar', () {
      final s = assistant.suggest('busco quien acompañe a mi abuela al hospital')!;
      expect(s.kind, NeedKind.help);
    });

    test('ordena el texto y es idempotente', () {
      final s = assistant.suggest('gasfitero para arreglar fuga hoy')!;
      expect(s.cleanedText, 'Necesito gasfitero para arreglar fuga hoy');
      final again = assistant.suggest(s.cleanedText)!;
      expect(again.changesText, isFalse);
    });
  });

  group('SafetyGuard', () {
    test('un pedido normal no genera avisos', () {
      expect(guard.scan('Necesito un gasfitero para una fuga'), isEmpty);
    });

    test('detecta teléfono', () {
      expect(guard.scan('llámame al 987 654 321'), contains(SafetyFlag.phone));
    });

    test('detecta DNI de 8 dígitos', () {
      expect(guard.scan('mi dni es 12345678'), contains(SafetyFlag.idNumber));
    });

    test('detecta dirección exacta', () {
      expect(
        guard.scan('vivo en Jr. Los Pinos 123'),
        contains(SafetyFlag.exactAddress),
      );
    });

    test('detecta pago por adelantado y enlaces', () {
      final f = guard.scan('haz un adelanto por yape y mira www.promo.com');
      expect(f, contains(SafetyFlag.advancePayment));
      expect(f, contains(SafetyFlag.externalLink));
    });

    test('detecta pedido de códigos', () {
      expect(
        guard.scan('pásame tu código por favor'),
        contains(SafetyFlag.secretCode),
      );
    });
  });

  group('BarrioStats', () {
    test('sin datos: todo en cero y sin tipo más frecuente', () {
      final s = BarrioStats.fromData(
        needs: const [],
        offers: const [],
        deals: const [],
        interactions: const [],
      );
      expect(s.needs, 0);
      expect(s.topKind, isNull);
      expect(s.urgentPercent, 0);
      expect(s.isExample, isFalse);
    });

    test('los datos de ejemplo están rotulados como ejemplo', () {
      expect(BarrioStats.example.isExample, isTrue);
      expect(BarrioStats.example.topKind, NeedKind.service);
    });
  });
}
