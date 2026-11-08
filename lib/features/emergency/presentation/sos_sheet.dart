import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/emergency.dart';
import '../../../app/l10n.dart';
import '../../location/presentation/location_controller.dart';
import '../../location/domain/zone.dart';
import 'alert_sms.dart';
import 'sos_labels.dart';
import '../../../app/ui/failure_text.dart';

/// "Necesito ayuda": situación → (texto ya escrito) → Enviar aviso. Tres toques.
Future<void> showSosSheet(BuildContext context) =>
    showBvSheet<void>(context, builder: (_) => const _SosSheet());

IconData sosIcon(SosSituation s) => switch (s) {
  SosSituation.earthquake => Icons.vibration_rounded,
  SosSituation.fire => Icons.local_fire_department_rounded,
  SosSituation.medical => Icons.medical_services_rounded,
  SosSituation.elderly => Icons.elderly_rounded,
  SosSituation.violence => Icons.shield_rounded,
};

class _SosSheet extends ConsumerStatefulWidget {
  const _SosSheet();

  @override
  ConsumerState<_SosSheet> createState() => _SosSheetState();
}

class _SosSheetState extends ConsumerState<_SosSheet> {
  SosSituation _situation = SosSituation.medical;
  final TextEditingController _text = TextEditingController();
  bool _textReady = false;
  bool _busy = false;
  bool _notifyContacts = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El texto inicial depende del idioma: se prepara una sola vez, ya con el contexto listo.
    if (!_textReady) {
      _textReady = true;
      _text.text = sosTemplate(context.l, _situation);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _pick(SosSituation s) {
    // Si la persona no tocó el texto, la plantilla acompaña a la situación.
    final l = context.l;
    final untouched = SosSituation.values.any(
      (x) => sosTemplate(l, x) == _text.text,
    );
    setState(() {
      _situation = s;
      if (untouched) _text.text = sosTemplate(l, s);
    });
  }

  /// SMS con el aviso para todos los contactos de confianza (`null` si no hay ninguno).
  /// Solo lleva la zona de ~1 km: la dirección activa, el GPS o la última zona guardada.
  Future<Uri?> _smsToContacts(AppLocalizations l) async {
    final contacts = await ref.read(emergencyRepositoryProvider).contacts();
    if (contacts.isEmpty) return null;
    final active = ref.read(activeAddressProvider);
    final settings = ref.read(appSettingsProvider);
    final saved = (settings.lastZoneLat == null || settings.lastZoneLng == null)
        ? null
        : Zone(settings.lastZoneLat!, settings.lastZoneLng!);
    final zone =
        active?.zone ??
        ref.read(locationControllerProvider).location?.zone ??
        saved;
    final body = buildAlertSms(
      l,
      situation: _situation,
      text: _text.text,
      zone: zone,
      reference: active?.reference,
    );
    return buildSmsUri([for (final c in contacts) c.phone], body);
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(publishSosProvider)(
      situation: _situation,
      text: _text.text,
    );
    if (!mounted) return;
    final l = context.l;
    switch (r) {
      case Ok():
        final messenger = ScaffoldMessenger.of(context);
        final sms = _notifyContacts ? await _smsToContacts(l) : null;
        if (!mounted) return;
        Navigator.of(context).pop();
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        if (sms != null && !await launchUrl(sms)) {
          messenger.showSnackBar(SnackBar(content: Text(l.sosSmsFailed)));
        }
        await ref.read(syncControllerProvider.notifier).flushNow();
        messenger.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 8),
            content: Text(l.tuAvisoQuedoGuardado),
          ),
        );
      case Err(:final failure):
        // El error va dentro de la hoja: un aviso flotante quedaría tapado por ella.
        setState(() {
          _busy = false;
          _error = failureText(context.l, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: context.l.necesitoAyuda,
    subtitle: context.l.eligeQuePasaEl,
    actionLabel: context.l.enviarAviso,
    actionIcon: Icons.campaign_rounded,
    danger: true,
    busy: _busy,
    onAction: _send,
    children: [
      if (_error != null) ...[
        BvBanner(
          icon: Icons.error_rounded,
          tone: BvTone.emergency,
          title: context.l.noSePudoGuardar,
          message: context.l.siEsUrgenteLlama(_error!),
        ),
        const SizedBox(height: 16),
      ],
      BvBanner(
        icon: Icons.phone_in_talk_rounded,
        tone: BvTone.emergency,
        title: context.l.primeroLosServiciosOficiales,
        message: context.l.siHayPeligroAhora,
      ),
      const SizedBox(height: 16),
      _NotifyContactsRow(
        value: _notifyContacts,
        onChanged: (v) => setState(() => _notifyContacts = v),
      ),
      const SizedBox(height: 20),
      Text(context.l.quePasa, style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final s in SosSituation.values)
            Semantics(
              button: true,
              selected: _situation == s,
              label: sosLabel(context.l, s),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pick(s),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _situation == s
                        ? context.tones.emergencySoft
                        : context.cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _situation == s
                          ? context.tones.emergency
                          : context.tones.control,
                      width: _situation == s ? 2 : 1.5,
                    ),
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sosIcon(s),
                          size: 22,
                          color: context.tones.emergency,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sosLabel(context.l, s),
                          style: context.tt.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      if (_situation.isPrivate) ...[
        const SizedBox(height: 12),
        BvBanner(
          icon: Icons.lock_rounded,
          tone: BvTone.violet,
          message: context.l.esteAvisoEsPrivado,
        ),
      ],
      const SizedBox(height: 16),
      TextField(
        controller: _text,
        minLines: 2,
        maxLines: 4,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.quePasoPuedesCambiarlo,
        ),
      ),
      Text(
        context.l.tuUbicacionExactaNo,
        style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
      ),
    ],
  );
}

/// Interruptor "Avisar también a mis contactos". Sin contactos explica cómo agregarlos.
class _NotifyContactsRow extends ConsumerWidget {
  const _NotifyContactsRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final contacts = ref.watch(contactsStreamProvider).value ?? const [];
    if (contacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: BvBanner(
          icon: Icons.sms_outlined,
          tone: BvTone.violet,
          message: l.sosNoContacts,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BvPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const BvIconBadge(Icons.sms_rounded, tone: BvTone.coral),
          title: Text(l.sosNotifyTitle, style: context.tt.titleSmall),
          subtitle: Text(l.sosNotifySub),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
