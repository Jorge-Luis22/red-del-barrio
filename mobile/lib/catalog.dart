/// Publicar en 3 toques: Necesito/Ofrezco → qué (botón grande) → Publicar.
/// Es el mismo catálogo que la web (app/src/lib/publish.ts) para que los dos se entiendan.

class Tile {
  const Tile({
    required this.key,
    required this.icon,
    required this.label,
    required this.category,
    required this.type,
    required this.quick,
    required this.trade,
  });

  final String key;
  final String icon;

  /// Lo que lee el vecino en el botón y en el título.
  final String label;

  /// Oficio o rubro que se guarda (coincide con los oficios del Directorio).
  final String category;
  final String type;

  /// Botones rápidos de "¿Qué pasó?" (opcionales).
  final List<String> quick;

  /// Se puede ofrecer como servicio en el Directorio.
  final bool trade;
}

const List<Tile> tiles = <Tile>[
  Tile(key: 'gasfiteria', icon: '🔧', label: 'Gasfitería', category: 'Gasfitería', type: 'servicio', trade: true,
      quick: <String>['Fuga de agua', 'Caño tapado', 'Instalar grifo o ducha', 'Cambiar tubería']),
  Tile(key: 'electricidad', icon: '⚡', label: 'Electricidad', category: 'Electricidad', type: 'servicio', trade: true,
      quick: <String>['Sin luz en casa', 'Cambiar enchufe o interruptor', 'Instalar lámpara', 'Revisar el tablero']),
  Tile(key: 'cerrajeria', icon: '🔑', label: 'Cerrajería', category: 'Cerrajería', type: 'servicio', trade: true,
      quick: <String>['Me quedé afuera', 'Cambiar chapa', 'Copiar llaves', 'Puerta trabada']),
  Tile(key: 'carpinteria', icon: '🔨', label: 'Carpintería', category: 'Carpintería', type: 'servicio', trade: true,
      quick: <String>['Arreglar puerta', 'Reparar mueble', 'Mueble a medida', 'Ventana o closet']),
  Tile(key: 'limpieza', icon: '🧹', label: 'Limpieza y jardín', category: 'Limpieza y jardinería', type: 'servicio', trade: true,
      quick: <String>['Limpieza de casa', 'Lavar tanque de agua', 'Podar el jardín', 'Limpiar terraza']),
  Tile(key: 'cuidado', icon: '👶', label: 'Cuidado de personas', category: 'Cuidado de niños y adultos mayores', type: 'servicio', trade: true,
      quick: <String>['Cuidar niños un rato', 'Acompañar a un adulto mayor', 'Recoger del colegio']),
  Tile(key: 'comida', icon: '🍲', label: 'Comida', category: 'Cocina y repostería', type: 'producto', trade: true,
      quick: <String>['Almuerzos del día', 'Torta o postres', 'Menú para un evento']),
  Tile(key: 'transporte', icon: '🚗', label: 'Transporte', category: 'Transporte', type: 'servicio', trade: true,
      quick: <String>['Llevar a la posta', 'Mudanza pequeña', 'Ir al mercado', 'Flete']),
  Tile(key: 'costura', icon: '🧵', label: 'Costura y arreglos', category: 'Costura y arreglos', type: 'servicio', trade: true,
      quick: <String>['Arreglar ropa', 'Bastas', 'Uniforme escolar', 'Cortinas']),
  Tile(key: 'clases', icon: '📚', label: 'Clases', category: 'Clases y refuerzo escolar', type: 'servicio', trade: true,
      quick: <String>['Matemática', 'Inglés', 'Primaria', 'Ayuda con tareas']),
  Tile(key: 'herramientas', icon: '🧰', label: 'Herramientas', category: 'Herramientas', type: 'prestamo', trade: false,
      quick: <String>['Escalera', 'Taladro', 'Carretilla', 'Cables de batería']),
];

/// Oficios menos frecuentes: salen en "Otra cosa".
const List<Tile> moreTiles = <Tile>[
  Tile(key: 'enfermeria', icon: '💉', label: 'Enfermería', category: 'Enfermería', type: 'servicio', trade: true,
      quick: <String>['Inyectable', 'Curaciones', 'Control de presión']),
  Tile(key: 'aguagas', icon: '💧', label: 'Agua y gas', category: 'Agua y gas', type: 'producto', trade: true,
      quick: <String>['Balón de gas', 'Bidón de agua', 'Cisterna']),
  Tile(key: 'mascotas', icon: '🐕', label: 'Mascotas', category: 'Paseo de mascotas', type: 'servicio', trade: true,
      quick: <String>['Pasear perro', 'Cuidarlo unos días']),
  Tile(key: 'electro', icon: '📺', label: 'Electrodomésticos', category: 'Reparación de electrodomésticos', type: 'servicio', trade: true,
      quick: <String>['Refrigeradora', 'Lavadora', 'Cocina', 'Televisor']),
];

String _simple(String input) {
  const String from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const String to = 'aeiouunaeiouun';
  final StringBuffer out = StringBuffer();
  for (final int rune in input.trim().runes) {
    final String ch = String.fromCharCode(rune);
    final int at = from.indexOf(ch);
    out.write(at >= 0 ? to[at] : ch.toLowerCase());
  }
  return out.toString();
}

/// Botón de un oficio; si no existe (oficio escrito a mano) se arma uno genérico.
Tile tileFor(String category) {
  final String wanted = _simple(category);
  for (final Tile t in <Tile>[...tiles, ...moreTiles]) {
    if (_simple(t.category) == wanted) return t;
  }
  return Tile(
    key: 'custom',
    icon: '🛠️',
    label: category,
    category: category,
    type: 'servicio',
    quick: const <String>[],
    trade: true,
  );
}

/// Tipo que se puede elegir en "Otra cosa".
const List<List<String>> otherTypes = <List<String>>[
  <String>['servicio', 'Un servicio'],
  <String>['producto', 'Un producto'],
  <String>['prestamo', 'Un préstamo'],
  <String>['ayuda', 'Una ayuda'],
];

/// ¿Para cuándo? (opcional).
const List<List<String>> whenOptions = <List<String>>[
  <String>['hoy', 'Hoy'],
  <String>['manana', 'Mañana'],
  <String>['semana', 'Esta semana'],
  <String>['sinapuro', 'Sin apuro'],
];

/// ¿Cuándo atiendes? (opcional, al ofrecer un servicio).
const List<String> schedules = <String>['Mañanas', 'Tardes', 'Todo el día', 'Fines de semana'];

const int maxDetail = 200;

const Map<String, String> needLabel = <String, String>{
  'servicio': 'Servicio',
  'producto': 'Producto',
  'prestamo': 'Préstamo',
  'ayuda': 'Ayuda',
};

/* ---------- Dirección: "Necesito: …" / "Ofrezco: …" ---------- */

const String prefixNecesito = 'Necesito: ';
const String prefixOfrezco = 'Ofrezco: ';

/// 'necesito', 'ofrezco' o null si el título no empieza con ninguno.
String? directionOf(String title) {
  if (title.startsWith(prefixOfrezco)) return 'ofrezco';
  if (title.startsWith(prefixNecesito)) return 'necesito';
  return null;
}

/// Favores "sin dinero" y recursos de emergencia: no llevan precio (los publica la web).
const List<String> solidaryCategories = <String>[
  'Préstamo de herramientas',
  'Ayuda temporal',
  'Donación de materiales',
  'Intercambio de habilidades',
  'Movilidad solidaria',
];
const String resourcePrefix = 'Recurso · ';

bool isFreeCategory(String category) =>
    solidaryCategories.contains(category) || category.startsWith(resourcePrefix);

/// Recorta lo escrito a una frase corta para el título, sin cortar palabras a la mitad.
String shortPhrase(String text, [int max = 45]) {
  final String clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (clean.length <= max) return clean;
  final String cut = clean.substring(0, max);
  final int lastSpace = cut.lastIndexOf(' ');
  final String base = lastSpace > 20 ? cut.substring(0, lastSpace) : cut;
  return '${base.trim()}…';
}

/// Título del pedido: "Necesito: Gasfitería · Fuga de agua".
/// Si tocó un botón rápido se usa ese; si prefirió escribir con sus palabras, se usa lo escrito.
String needTitle(Tile tile, String? what, String written) {
  final String? extra = what ?? (written.trim().isNotEmpty ? shortPhrase(written) : null);
  final String base = extra != null ? '${tile.label} · $extra' : tile.label;
  final String full = '$prefixNecesito$base';
  return full.length > 80 ? full.substring(0, 80) : full;
}

/// Descripción del pedido: lo que eligió en los botones más el detalle escrito (si lo hay).
String needDescription(String? whenKey, String detail) {
  String? whenLabel;
  for (final List<String> w in whenOptions) {
    if (w[0] == whenKey) whenLabel = w[1];
  }
  final String text = detail.trim();
  final String cut = text.length > maxDetail ? text.substring(0, maxDetail) : text;
  final List<String> parts = <String>[];
  if (whenLabel != null) parts.add('Para: $whenLabel.');
  if (cut.isNotEmpty) parts.add(cut);
  return parts.join(' ');
}
