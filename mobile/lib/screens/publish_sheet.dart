import 'package:flutter/material.dart';

import '../catalog.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';

/// Abre la hoja de publicar. Devuelve el mensaje de éxito si se publicó, o null si se cerró sin publicar.
/// [dir] es 'necesito' u 'ofrezco'. Si ya se conoce el oficio ([category]) se salta al último paso.
Future<String?> showPublishSheet(BuildContext context, {required String dir, String? category}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: paper,
    builder: (BuildContext sheetContext) => PublishSheet(dir: dir, category: category),
  );
}

enum _Step { cat, otro, confirm }

/// Publicar sin escribir: Necesito/Ofrezco → qué (botón grande) → Publicar.
/// Todo lo demás es opcional, y siempre se puede escribir con palabras propias.
class PublishSheet extends StatefulWidget {
  const PublishSheet({super.key, required this.dir, this.category});

  final String dir;
  final String? category;

  @override
  State<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<PublishSheet> {
  late _Step _step;
  Tile? _tile;
  final TextEditingController _other = TextEditingController();
  final TextEditingController _detail = TextEditingController();
  String _otherType = 'servicio';
  String? _what;
  String? _when;
  String? _schedule;
  bool _availableNow = false;
  bool _urgent = true;
  bool _busy = false;
  String _error = '';

  bool get _offer => widget.dir == 'ofrezco';

  @override
  void initState() {
    super.initState();
    final String? cat = widget.category;
    _step = cat != null ? _Step.confirm : _Step.cat;
    _tile = cat != null ? tileFor(cat) : null;
  }

  @override
  void dispose() {
    _other.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _pick(Tile tile) {
    setState(() {
      _tile = tile;
      _what = null;
      _step = _Step.confirm;
    });
  }

  void _back() {
    setState(() {
      if (_step == _Step.confirm) {
        final Tile? t = _tile;
        final bool fromOther = t != null && (t.key == 'custom' || moreTiles.any((Tile m) => m.key == t.key));
        _step = fromOther ? _Step.otro : _Step.cat;
      } else if (_step == _Step.otro) {
        _step = _Step.cat;
      }
    });
  }

  void _useOther() {
    final String text = _other.text.trim();
    if (text.length < 3) return;
    _pick(Tile(
      key: 'custom',
      icon: '✏️',
      label: text,
      // Al ofrecer, lo escrito es el oficio; al pedir, queda en el título y el rubro es "Otros".
      category: _offer ? text : 'Otros',
      type: _otherType,
      quick: const <String>[],
      trade: true,
    ));
  }

  Future<void> _publish() async {
    final Tile? tile = _tile;
    if (tile == null || _busy) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final String detail = _detail.text.trim();
      if (_offer) {
        await store.saveService(
          trade: tile.category,
          description: detail.length > maxDetail ? detail.substring(0, maxDetail) : detail,
          urgent: _urgent,
          availableNow: _availableNow,
          schedule: _schedule ?? '',
        );
        if (!mounted) return;
        Navigator.of(context).pop('Listo: ya apareces en el Directorio de vecinos como ${tile.label.toLowerCase()}.');
      } else {
        await store.createNeed(
          type: tile.type,
          title: needTitle(tile, _what, detail),
          description: needDescription(_when, detail),
          category: tile.category,
        );
        if (!mounted) return;
        Navigator.of(context).pop('Listo: tu pedido ya está publicado en el muro del barrio.');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'No se pudo publicar. Inténtalo otra vez.';
        });
      }
    }
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
      );

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(color: muted, fontSize: 14)),
      );

  /// Botones grandes en dos columnas que bajan de línea si el texto del teléfono es grande.
  Widget _tileGrid(List<Tile> list) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = (box.maxWidth - 10) / 2;
        final List<Widget> items = <Widget>[];
        for (final Tile t in list) {
          items.add(SizedBox(width: w, child: _bigButton('${t.icon}  ${t.label}', () => _pick(t))));
        }
        items.add(
          SizedBox(width: w, child: _bigButton('✏️  Otra cosa (escribir)', () => setState(() => _step = _Step.otro))),
        );
        return Wrap(spacing: 10, runSpacing: 10, children: items);
      },
    );
  }

  Widget _bigButton(String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
        ),
      ),
    );
  }

  Widget _chips(List<Widget> children) => Wrap(spacing: 8, runSpacing: 8, children: children);

  Widget _stepCat() {
    final List<Tile> list = _offer ? tiles.where((Tile t) => t.trade).toList() : tiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(_offer ? '¿Qué sabes hacer?' : '¿Qué necesitas?'),
        _hint('Toca una opción.'),
        _tileGrid(list),
        if (_offer)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '¿Quieres prestar, regalar o ayudar sin dinero? Eso se publica desde la versión web por ahora.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _stepOtro() {
    final List<Tile> more = _offer ? moreTiles.where((Tile t) => t.trade).toList() : moreTiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(_offer ? '¿Qué sabes hacer?' : '¿Qué necesitas?'),
        _hint('Elige uno de estos o escribe en pocas palabras.'),
        _chips(<Widget>[
          for (final Tile t in more) ChoiceChipBtn(label: '${t.icon} ${t.label}', on: false, onTap: () => _pick(t)),
        ]),
        const SectionLabel('Escríbelo aquí'),
        TextField(
          controller: _other,
          maxLength: 50,
          textInputAction: TextInputAction.done,
          onChanged: (String _) => setState(() {}),
          onSubmitted: (String _) => _useOther(),
          decoration: InputDecoration(
            hintText: _offer ? 'Ej. Pintura de paredes' : 'Ej. Pintar una pared',
            counterText: '',
          ),
        ),
        if (!_offer) ...<Widget>[
          const SizedBox(height: 12),
          _chips(<Widget>[
            for (final List<String> o in otherTypes)
              ChoiceChipBtn(label: o[1], on: _otherType == o[0], onTap: () => setState(() => _otherType = o[0])),
          ]),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _other.text.trim().length < 3 ? null : _useOther,
            child: const Text('Seguir'),
          ),
        ),
      ],
    );
  }

  Widget _stepConfirm(Tile tile) {
    final String verb = _offer ? 'Ofrezco' : 'Necesito';
    final String zone = sv(store.meUser, 'zone');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title('$verb: ${tile.icon} ${tile.label}'),
        if (!_offer && tile.quick.isNotEmpty) ...<Widget>[
          const SectionLabel('¿Qué pasó?', hint: '(opcional)'),
          _chips(<Widget>[
            for (final String q in tile.quick)
              ChoiceChipBtn(label: q, on: _what == q, onTap: () => setState(() => _what = _what == q ? null : q)),
          ]),
        ],
        if (!_offer) ...<Widget>[
          const SectionLabel('¿Para cuándo?', hint: '(opcional)'),
          _chips(<Widget>[
            for (final List<String> w in whenOptions)
              ChoiceChipBtn(
                label: w[1],
                on: _when == w[0],
                onTap: () => setState(() => _when = _when == w[0] ? null : w[0]),
              ),
          ]),
        ],
        if (_offer) ...<Widget>[
          const SectionLabel('¿Cuándo atiendes?', hint: '(opcional)'),
          _chips(<Widget>[
            ChoiceChipBtn(
              label: '🟢 Disponible ahora',
              on: _availableNow,
              onTap: () => setState(() => _availableNow = !_availableNow),
            ),
            for (final String s in schedules)
              ChoiceChipBtn(label: s, on: _schedule == s, onTap: () => setState(() => _schedule = _schedule == s ? null : s)),
          ]),
          const SizedBox(height: 8),
          _chips(<Widget>[
            ChoiceChipBtn(
              label: '🛠️ Atiendo urgencias',
              on: _urgent,
              onTap: () => setState(() => _urgent = !_urgent),
            ),
          ]),
        ],
        SectionLabel(_offer ? 'Cuéntalo con tus palabras' : '¿Otra cosa? Cuéntalo con tus palabras', hint: '(opcional)'),
        TextField(
          controller: _detail,
          minLines: 3,
          maxLines: 5,
          maxLength: maxDetail,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: _offer
                ? 'Ej. Hago instalaciones y reparaciones, con 10 años de experiencia'
                : 'Ej. Se me quemó el tablero y no tengo luz en la cocina',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            '📍 ${zone.isEmpty ? 'Tu zona' : zone}. Se muestra solo una zona aproximada, nunca tu ubicación exacta.',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error, style: const TextStyle(color: danger, fontWeight: FontWeight.w600)),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _publish,
            child: Text(_busy ? 'Publicando…' : (_offer ? 'Publicar mi servicio' : 'Publicar')),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Tile? tile = _tile;
    final bool showBack = _step != _Step.cat && !(_step == _Step.confirm && widget.category != null);
    Widget body;
    if (_step == _Step.cat) {
      body = _stepCat();
    } else if (_step == _Step.otro) {
      body = _stepOtro();
    } else if (tile != null) {
      body = _stepConfirm(tile);
    } else {
      body = _stepCat();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (showBack)
                  TextButton(onPressed: _back, child: const Text('‹ Atrás'))
                else
                  Text(
                    'Paso ${_step == _Step.confirm ? 2 : 1} de 2',
                    style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body,
          ],
        ),
      ),
    );
  }
}
