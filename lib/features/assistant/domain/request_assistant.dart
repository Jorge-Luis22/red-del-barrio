import '../../needs/domain/need.dart';
import 'text_norm.dart';

/// Lo que el asistente propone a partir de lo que la persona escribió.
/// Funciona con reglas locales, sin internet y sin enviar el texto a ningún lado.
class RequestSuggestion {
  const RequestSuggestion({
    required this.kind,
    required this.urgency,
    required this.trade,
    required this.cleanedText,
    required this.changesText,
  });

  /// Tipo de pedido que parece ser (siempre hay uno; por defecto, servicio).
  final NeedKind kind;

  /// Plazo detectado en el texto; `null` si no se dijo nada.
  final Urgency? urgency;

  /// Rubro detectado (por ejemplo "Gasfitería"); `null` si no aplica.
  final String? trade;

  /// Texto ordenado: mayúscula inicial, espacios limpios y "Necesito" si falta.
  final String cleanedText;

  /// `true` si [cleanedText] es distinto de lo escrito.
  final bool changesText;
}

class RequestAssistant {
  const RequestAssistant();

  static const _tradeWords = <String, List<String>>{
    'Gasfitería': [
      'cano',
      'fuga',
      'gotea',
      'goteo',
      'tuberia',
      'grifo',
      'desague',
      'inodoro',
      'gasfiter',
      'terma',
      'llave de agua',
      'no sale agua',
      'se inunda',
      'inundando',
    ],
    'Electricidad': [
      'foco',
      'enchufe',
      'cortocircuito',
      'tomacorriente',
      'electric',
      'apagon',
      'interruptor',
      'sin luz',
      'cable',
    ],
    'Carpintería': [
      'puerta',
      'ventana',
      'mueble',
      'madera',
      'carpinter',
      'ropero',
      'bisagra',
    ],
    'Cerrajería': [
      'cerradura',
      'candado',
      'chapa',
      'cerrajer',
      'me quede afuera',
      'me quede encerrad',
    ],
    'Costura': ['costur', 'dobladillo', 'ruedo', 'zurcir', 'coser', 'bastilla'],
    'Clases': [
      'clases',
      'reforzamiento',
      'ensenar',
      'profesor',
      'matematica',
      'aprender',
    ],
    'Mascotas': ['perro', 'gato', 'mascota', 'veterinari', 'pasear'],
  };

  static const _loanWords = [
    'prestar',
    'presta',
    'prestame',
    'prestado',
    'alguien tiene',
    'taladro',
    'escalera',
    'martillo',
    'herramienta',
  ];

  static const _productWords = [
    'comprar',
    'compra de',
    'bodega',
    'balon de gas',
    'pan ',
    'verdura',
    'leche',
    'panales',
    'medicina',
    'vender',
  ];

  static const _helpWords = [
    'acompan',
    'cargar',
    'mudanza',
    'adulto mayor',
    'abuelo',
    'abuela',
    'cuidar',
    'cuidado',
    'tramite',
    'hospital',
    'cocinar',
    'olla comun',
    'no puedo salir',
  ];

  static const _nowWords = [
    'ahora',
    'urgente',
    'ya mismo',
    'ahorita',
    'cuanto antes',
    'emergencia',
    'se inunda',
    'inundando',
  ];
  static const _todayWords = ['hoy', 'esta tarde', 'esta noche', 'mas tarde'];
  static const _tomorrowWords = ['manana'];
  static const _weekWords = [
    'esta semana',
    'fin de semana',
    'sabado',
    'domingo',
    'proxima semana',
  ];

  static const _starters = [
    'necesito',
    'busco',
    'alguien',
    'quien',
    'quiero',
    'quisiera',
    'requiero',
    'hola',
    'por favor',
    'tengo',
    'hay',
    'se',
    'me',
    'mi',
    'el',
    'la',
    'los',
    'las',
    'un',
    'una',
    'no',
    'estoy',
    'puede',
    'pueden',
    'ayuda',
    'urgente',
  ];

  /// Devuelve `null` si el texto es muy corto para opinar.
  RequestSuggestion? suggest(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length < 6) return null;
    final n = normalizeText(trimmed);

    String? trade;
    for (final entry in _tradeWords.entries) {
      if (containsAny(n, entry.value)) {
        trade = entry.key;
        break;
      }
    }

    final NeedKind kind;
    if (containsAny(n, _loanWords)) {
      kind = NeedKind.loan;
    } else if (trade != null) {
      kind = NeedKind.service;
    } else if (containsAny(n, _productWords)) {
      kind = NeedKind.product;
    } else if (containsAny(n, _helpWords)) {
      kind = NeedKind.help;
    } else {
      kind = NeedKind.service;
    }

    Urgency? urgency;
    if (containsAny(n, _nowWords)) {
      urgency = Urgency.now;
    } else if (containsAny(n, _todayWords)) {
      urgency = Urgency.today;
    } else if (containsAny(n, _tomorrowWords)) {
      urgency = Urgency.tomorrow;
    } else if (containsAny(n, _weekWords)) {
      urgency = Urgency.thisWeek;
    }

    final cleaned = _clean(trimmed);
    return RequestSuggestion(
      kind: kind,
      urgency: urgency,
      trade: trade,
      cleanedText: cleaned,
      changesText: cleaned != trimmed,
    );
  }

  String _clean(String text) {
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.isEmpty) return t;
    final firstWord = normalizeText(t.split(' ').first).replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );
    final isQuestion = t.startsWith('¿') || t.endsWith('?');
    if (!isQuestion && !_starters.contains(firstWord)) {
      t = 'Necesito ${t[0].toLowerCase()}${t.substring(1)}';
    }
    t = '${t[0].toUpperCase()}${t.substring(1)}';
    return t;
  }
}
