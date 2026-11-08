import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/need_extras.dart';

/// Guarda los extras de los pedidos en un archivo JSON dentro del teléfono.
/// (Sin tocar la base de datos: así no cambia su esquema.)
class FileNeedExtrasRepository implements NeedExtrasRepository {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/detalles_pedidos.json');
  }

  Future<Map<String, Object?>> _readAll() async {
    try {
      final f = await _file();
      if (!await f.exists()) return {};
      final decoded = jsonDecode(await f.readAsString());
      return decoded is Map<String, Object?> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<NeedExtras> get(String needId) async {
    final all = await _readAll();
    final raw = all[needId];
    if (raw is Map<String, Object?>) return NeedExtras.fromJson(raw);
    return const NeedExtras();
  }

  @override
  Future<void> save(String needId, NeedExtras extras) async {
    final all = await _readAll();
    if (extras.isEmpty) {
      all.remove(needId);
    } else {
      all[needId] = extras.toJson();
    }
    final f = await _file();
    await f.writeAsString(jsonEncode(all));
  }
}
