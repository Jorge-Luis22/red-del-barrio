import 'package:flutter/material.dart';

import '../catalog.dart';
import '../config.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';
import 'legal.dart';
import 'publish_sheet.dart';

/// Perfil: tu nivel, tus servicios, a quién bloqueaste y tus datos.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _zone;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: sv(store.meUser, 'display_name'));
    _zone = TextEditingController(text: sv(store.meUser, 'zone', Config.defaultZone));
  }

  @override
  void dispose() {
    _name.dispose();
    _zone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.length < 2) {
      toast(context, 'Escribe tu nombre o apodo.');
      return;
    }
    await store.saveProfile(name, _zone.text);
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) toast(context, 'Perfil guardado.');
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    await store.sync();
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _offer() async {
    final String? message = await showPublishSheet(context, dir: 'ofrezco');
    if (message != null && mounted) toast(context, message);
  }

  Future<void> _deleteAccount() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('¿Borrar mi cuenta?'),
        content: const Text(
          'Se borrarán tu perfil, tus pedidos, tus servicios, tus mensajes y tus calificaciones del servidor. '
          'No se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 44), backgroundColor: danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, borrar todo'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await store.deleteAccount();
    } catch (_) {
      if (mounted) toast(context, 'No se pudo borrar ahora. Revisa tu conexión e inténtalo otra vez.');
    }
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: brand)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _service(Rec o) {
    final String id = sv(o, 'id');
    final String trade = sv(o, 'trade');
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${tileFor(trade).icon} $trade',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink),
                ),
              ),
              IconButton(
                tooltip: 'Quitar este servicio',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => store.removeService(id),
              ),
            ],
          ),
          if (sv(o, 'description').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(sv(o, 'description'), style: const TextStyle(color: muted)),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Disponible ahora'),
            value: iv(o, 'available_now') == 1,
            onChanged: (bool v) => store.updateService(id, availableNow: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Atiendo urgencias'),
            value: iv(o, 'urgent') == 1,
            onChanged: (bool v) => store.updateService(id, urgent: v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, Widget? child) {
        final String my = store.meId ?? '';
        final Stats stats = store.statsOf(my);
        final LevelInfo level = store.levelOf(my);
        final List<Rec> services = store.myServices();
        final List<Map<String, String>> blocked = store.blockedList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
            Row(
              children: <Widget>[
                Avatar(name: store.nameOf(my), color: store.colorOf(my), size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(store.nameOf(my), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: <Widget>[
                          Pill(level.name),
                          if (level.capped) const Pill('Nivel limitado por calificaciones', bg: warmSoft, fg: warm),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (level.next != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Te faltan ${level.missing} ${level.missing == 1 ? 'punto' : 'puntos'} para ser ${level.next}. '
                  'Cada ayuda completada suma 2 y cada recomendación suma 1.',
                  style: const TextStyle(color: muted, fontSize: 13, height: 1.3),
                ),
              ),
            const SizedBox(height: 14),
            Panel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _stat('${stats.helps}', stats.helps == 1 ? 'ayuda\ncompletada' : 'ayudas\ncompletadas'),
                  _stat('${stats.people}', 'personas\nayudadas'),
                  _stat(stats.avgStars == null ? '—' : stats.avgStars!.toStringAsFixed(1), 'calificación\npromedio'),
                  _stat('${stats.recommendations}', stats.recommendations == 1 ? 'vez\nrecomendado' : 'veces\nrecomendado'),
                ],
              ),
            ),
            const SectionLabel('Mis datos'),
            TextField(
              controller: _name,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre o apodo', counterText: ''),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _zone,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Zona (aproximada)', counterText: ''),
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _save, child: const Text('Guardar cambios'))),
            const SectionLabel('Lo que ofrezco'),
            if (services.isEmpty)
              const Panel(
                child: Text(
                  'Todavía no ofreces nada. Anótate para que tus vecinos te encuentren en la pestaña Vecinos.',
                  style: TextStyle(color: muted),
                ),
              )
            else
              for (final Rec o in services) _service(o),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _offer,
                icon: const Icon(Icons.add),
                label: const Text('Ofrezco un servicio'),
              ),
            ),
            if (blocked.isNotEmpty) ...<Widget>[
              const SectionLabel('Bloqueados'),
              for (final Map<String, String> b in blocked)
                Panel(
                  padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(b['name'] ?? 'Vecino', style: const TextStyle(fontWeight: FontWeight.w600))),
                      TextButton(
                        onPressed: () => store.unblockUser(b['id'] ?? ''),
                        child: const Text('Desbloquear'),
                      ),
                    ],
                  ),
                ),
            ],
            const SectionLabel('Conexión'),
            Panel(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      store.syncState == 'ok'
                          ? 'Conectado con el barrio${store.lastOk == null ? '' : ' · ${timeAgo(store.lastOk!.toUtc().toIso8601String())}'}'
                          : (store.syncState == 'sin_conexion' ? 'Sin conexión' : 'Error: ${store.syncDetail}'),
                      style: TextStyle(
                        color: store.syncState == 'ok' ? brand : danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(onPressed: _syncing ? null : _syncNow, child: Text(_syncing ? 'Sincronizando…' : 'Sincronizar')),
                ],
              ),
            ),
            const SectionLabel('Tus datos'),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (BuildContext _) => const LegalScreen()),
              ),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Qué datos se guardan y tus derechos'),
            ),
            const SizedBox(height: 8),
            Text('Dudas o reportes: ${Config.contactEmail}', style: const TextStyle(color: muted, fontSize: 13)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: danger, side: const BorderSide(color: danger)),
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Borrar mi cuenta y mis datos'),
            ),
          ],
        );
      },
    );
  }
}
