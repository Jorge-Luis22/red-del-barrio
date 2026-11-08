/// Punto de encuentro que dos personas acuerdan en el chat de un trato.
///
/// Se guarda como un mensaje de texto normal ("📍 Punto de encuentro: Parque (lat, lng)"),
/// así no hace falta cambiar la base de datos. Es un lugar elegido a mano en el mapa:
/// NO es la ubicación del teléfono.
class MeetingPoint {
  const MeetingPoint({
    required this.label,
    required this.lat,
    required this.lng,
  });

  final String label;
  final double lat;
  final double lng;

  static const _prefix = '📍 Punto de encuentro: ';
  static final _tail = RegExp(r'^(.*) \((-?\d+\.\d+), (-?\d+\.\d+)\)$');

  /// Texto que se guarda y se envía en el chat.
  String toMessage() {
    var clean = label.replaceAll(RegExp(r'[()\n\r]'), ' ').trim();
    if (clean.isEmpty) clean = 'Lugar público';
    if (clean.length > 40) clean = clean.substring(0, 40);
    return '$_prefix$clean (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})';
  }

  /// Devuelve el punto si [text] es un mensaje de punto de encuentro; si no, `null`.
  static MeetingPoint? tryParse(String text) {
    if (!text.startsWith(_prefix)) return null;
    final m = _tail.firstMatch(text.substring(_prefix.length));
    if (m == null) return null;
    final lat = double.tryParse(m.group(2)!);
    final lng = double.tryParse(m.group(3)!);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return MeetingPoint(label: m.group(1)!.trim(), lat: lat, lng: lng);
  }
}
