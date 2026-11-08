/// Una foto enviada por el chat se guarda como un mensaje normal: "📷 Foto: <ruta>".
/// (Así no cambia la base de datos.) La foto vive solo en este teléfono.
const _prefix = '📷 Foto: ';

String photoMessage(String path) => '$_prefix$path';

/// Ruta de la foto si [text] es un mensaje de foto; `null` si es un mensaje común.
String? photoPathOf(String text) {
  final t = text.trim();
  if (!t.startsWith(_prefix)) return null;
  final path = t.substring(_prefix.length).trim();
  return path.isEmpty ? null : path;
}
