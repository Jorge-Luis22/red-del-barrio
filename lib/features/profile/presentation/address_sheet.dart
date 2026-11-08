import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/failure_text.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../location/domain/usecases/get_location.dart';
import '../../location/domain/zone.dart';

/// Marca dónde está la persona con el GPS, le pone nombre y la guarda.
/// Devuelve `true` si se guardó una dirección.
Future<bool> showAddressSheet(BuildContext context) async =>
    await showBvSheet<bool>(context, builder: (_) => const _AddressSheet()) ??
    false;

class _AddressSheet extends ConsumerStatefulWidget {
  const _AddressSheet();

  @override
  ConsumerState<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends ConsumerState<_AddressSheet> {
  final _name = TextEditingController();
  final _reference = TextEditingController();
  ExactLocation? _location;
  bool _locating = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final r = await ref.read(getLocationProvider)(askPermission: true);
    if (!mounted) return;
    final l = context.l;
    switch (r) {
      // Una zona guardada es solo aproximada: no sirve para marcar una dirección.
      case Ok(:final value) when value.source != LocationSource.savedZone:
        setState(() {
          _locating = false;
          _location = value.location;
        });
      case Ok(:final value):
        setState(() {
          _locating = false;
          _error = value.reason == null
              ? l.failLocation
              : failureText(l, value.reason!);
        });
      case Err(:final failure):
        setState(() {
          _locating = false;
          _error = failureText(l, failure);
        });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ref.read(addAddressProvider)(
      name: _name.text,
      reference: _reference.text,
      location: _location,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failureText(context.l, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final loc = _location;
    final suggestions = [l.addrHome, l.addrWork, l.addrOther];
    return BvSheetScaffold(
      title: l.addrAdd,
      subtitle: l.addrPrivacy,
      actionLabel: l.addrSave,
      actionIcon: Icons.place_rounded,
      busy: _saving,
      onAction: (loc != null && _name.text.trim().length >= 2) ? _save : null,
      disabledHint: l.hintAddr,
      children: [
        if (_error != null) ...[
          BvBanner(
            icon: Icons.location_off_rounded,
            tone: BvTone.sun,
            message: _error!,
          ),
          const SizedBox(height: 16),
        ],
        if (loc == null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _locating ? null : _locate,
              icon: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(_locating ? l.buscando : l.addrGetLocation),
            ),
          )
        else
          BvBanner(
            icon: Icons.check_circle_rounded,
            tone: BvTone.trust,
            message: l.addrGot(
              l.zonaAprox1Km(
                loc.zone.lat.toStringAsFixed(2),
                loc.zone.lng.toStringAsFixed(2),
              ),
            ),
            action: TextButton.icon(
              onPressed: _locating ? null : _locate,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.addrRelocate),
            ),
          ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in suggestions)
              ActionChip(
                label: Text(s),
                onPressed: () => setState(() => _name.text = s),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l.addrNameLabel),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _reference,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l.addrRef,
            helperText: l.addrRefHelp,
          ),
        ),
      ],
    );
  }
}
