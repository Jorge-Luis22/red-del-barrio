/// Una frase en español y su equivalente en quechua.
class QuechuaPhrase {
  const QuechuaPhrase(this.es, this.qu, {this.en = ''});

  final String es;
  final String qu;

  /// Significado en inglés, para quien use la app en inglés.
  final String en;
}

/// Frases muy comunes del quechua sureño (Cusco-Collao).
///
/// REFERENCIAL: es una lista corta escrita por el equipo, NO es un traductor.
/// El quechua tiene variedades y escrituras distintas según la región; antes de
/// usarla con vecinos debe revisarla un hablante nativo.
const quechuaPhrases = <QuechuaPhrase>[
  QuechuaPhrase('Hola (saludo respetuoso)', 'Rimaykullayki', en: 'Hello (respectful)'),
  QuechuaPhrase('¿Cómo estás?', 'Allillanchu?', en: 'How are you?'),
  QuechuaPhrase('Estoy bien', 'Allillanmi', en: 'I am well'),
  QuechuaPhrase('Gracias', 'Sulpayki', en: 'Thank you'),
  QuechuaPhrase('Ayúdame', 'Yanapaway', en: 'Help me'),
  QuechuaPhrase('Sí', 'Arí', en: 'Yes'),
  QuechuaPhrase('No', 'Mana', en: 'No'),
  QuechuaPhrase('Ahora', 'Kunan', en: 'Now'),
  QuechuaPhrase('Mañana', 'Paqarin', en: 'Tomorrow'),
  QuechuaPhrase('Casa', 'Wasi', en: 'House'),
  QuechuaPhrase('Agua', 'Yaku', en: 'Water'),
  QuechuaPhrase('Hasta luego', 'Tupananchiskama', en: 'See you later'),
];
