import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../needs/presentation/need_labels.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/emergency.dart';
import 'sos_sheet.dart';
import '../../../app/l10n.dart';
import 'sos_labels.dart';
import '../../../app/ui/failure_text.dart';

/// Emergencia. Orden fijo e intencional: 1) servicios oficiales, 2) pedir ayuda al barrio,
/// 3) mis avisos, 4) un barrio preparado. La institución oficial siempre va primero.
class EmergenciaScreen extends ConsumerWidget {
  const EmergenciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(emergencyPostsStreamProvider);
    final points =
        ref.watch(collectionPointsStreamProvider).value ??
        const <CollectionPoint>[];
    final settings = ref.watch(appSettingsProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: context.l.emergencia,
            subtitle: context.l.ayudaDelBarrioCuando,
            icon: Icons.crisis_alert_rounded,
            background: context.tones.emergency,
            foreground: context.cs.onError,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Oficiales primero.
                BvSectionTitle(
                  context.l.serviciosOficiales,
                  subtitle: context.l.enPeligroLlamaAqui,
                ),
                const SizedBox(height: 12),
                BvRows(
                  children: [
                    for (final c in officialContacts) _OfficialRow(contact: c),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l.verificaEstosNumerosCon,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                const SizedBox(height: 28),

                // 2) Pedir ayuda al barrio.
                BvSectionTitle(
                  context.l.ayudaDelBarrio,
                  subtitle: context.l.avisaATusVecinos,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showSosSheet(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.tones.emergency,
                      foregroundColor: context.cs.onError,
                      minimumSize: const Size(64, 60),
                    ),
                    icon: const Icon(Icons.campaign_rounded),
                    label: Text(context.l.necesitoAyuda),
                  ),
                ),
                const SizedBox(height: 16),

                // 3) Mis avisos.
                posts.when(
                  loading: () => const BvSkeletonRows(count: 1),
                  error: (_, _) => BvErrorState(
                    message: context.l.noPudimosLeerTus4,
                    onRetry: () => ref.invalidate(emergencyPostsStreamProvider),
                  ),
                  data: (list) => list.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BvSectionTitle(context.l.misAvisos),
                            const SizedBox(height: 12),
                            BvRows(
                              children: [
                                for (final p in list) _PostRow(post: p),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l.todaviaNoHayVecinos,
                              style: context.tt.bodySmall?.copyWith(
                                color: context.tones.muted,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 28),

                // 4) Barrio preparado.
                BvSectionTitle(
                  context.l.unBarrioPreparado,
                  subtitle: context.l.quePodriasOfrecerSi,
                ),
                const SizedBox(height: 12),
                BvPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final cap in emergencyCapabilities)
                            FilterChip(
                              label: Text(capabilityLabel(context.l, cap)),
                              selected: settings.capabilities.contains(cap),
                              showCheckmark: true,
                              onSelected: (on) => settingsRepo.update(
                                (s) => s.copyWith(
                                  capabilities: on
                                      ? {...s.capabilities, cap}
                                      : ({...s.capabilities}..remove(cap)),
                                ),
                              ),
                              labelStyle: context.tt.labelMedium?.copyWith(
                                color: settings.capabilities.contains(cap)
                                    ? context.cs.onPrimary
                                    : context.cs.onSurface,
                              ),
                              checkmarkColor: context.cs.onPrimary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.l.brigadistaVecinalVoluntario,
                          style: context.tt.titleSmall,
                        ),
                        subtitle: Text(context.l.sinVerificarSoloQueda),
                        value: settings.volunteer,
                        onChanged: (v) => settingsRepo.update(
                          (s) => s.copyWith(volunteer: v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BvSectionTitle(
                  context.l.puntosDeAcopio,
                  subtitle: context.l.lugaresParaReunirAyuda,
                  trailing: TextButton.icon(
                    onPressed: () => _showAcopioSheet(context),
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: Text(context.l.proponer),
                  ),
                ),
                const SizedBox(height: 12),
                if (points.isEmpty)
                  BvBanner(
                    icon: Icons.place_outlined,
                    tone: BvTone.violet,
                    message: context.l.aunNoHayPuntos,
                  )
                else
                  BvRows(
                    children: [for (final p in points) _AcopioRow(point: p)],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialRow extends StatelessWidget {
  const _OfficialRow({required this.contact});

  final OfficialContact contact;

  Future<void> _call(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l.llamarAl(contact.number)),
        content: Text(
          context.l.esteNumeroEstaPor(
            officialName(context.l, contact.id),
            officialUse(context.l, contact.id),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l.llamar),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final launched = await launchUrl(Uri(scheme: 'tel', path: contact.number));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l.noPudimosAbrirEl(contact.number))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l.llamarANumero(
      officialName(context.l, contact.id),
      contact.number,
    ),
    child: InkWell(
      onTap: () => _call(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.tones.emergencySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                contact.number,
                style: context.tt.titleLarge?.copyWith(
                  color: context.tones.emergency,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officialName(context.l, contact.id),
                    style: context.tt.titleSmall,
                  ),
                  Text(
                    officialUse(context.l, contact.id),
                    style: context.tt.bodySmall?.copyWith(
                      color: context.tones.muted,
                    ),
                  ),
                ],
              ),
            ),
            BvPill(context.l.porVerificar, tone: BvTone.sun),
            const SizedBox(width: 8),
            Icon(Icons.call_rounded, color: context.tones.emergency),
          ],
        ),
      ),
    ),
  );
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});

  final EmergencyPost post;

  @override
  Widget build(BuildContext context) {
    final badge = syncBadge(context.l, post.syncStatus);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.tones.emergencySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              sosIcon(post.situation),
              color: context.tones.emergency,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sosLabel(context.l, post.situation),
                  style: context.tt.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(post.text, style: context.tt.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    BvPill(badge.label, icon: badge.icon, tone: badge.tone),
                    if (post.situation.isPrivate)
                      BvPill(
                        context.l.privado,
                        icon: Icons.lock_rounded,
                        tone: BvTone.violet,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcopioRow extends StatelessWidget {
  const _AcopioRow({required this.point});

  final CollectionPoint point;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BvIconBadge(Icons.inventory_2_rounded, tone: BvTone.trust),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point.name, style: context.tt.titleSmall),
              if (point.reference.isNotEmpty)
                Text(
                  point.reference,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              const SizedBox(height: 8),
              BvPill(
                context.l.propuestoPorTiSin,
                icon: Icons.help_outline_rounded,
                tone: BvTone.sun,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _showAcopioSheet(BuildContext context) =>
    showBvSheet<void>(context, builder: (_) => const _AcopioSheet());

class _AcopioSheet extends ConsumerStatefulWidget {
  const _AcopioSheet();

  @override
  ConsumerState<_AcopioSheet> createState() => _AcopioSheetState();
}

class _AcopioSheetState extends ConsumerState<_AcopioSheet> {
  final _name = TextEditingController();
  final _ref = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _ref.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final r = await ref.read(proposeCollectionPointProvider)(
      name: _name.text,
      reference: _ref.text,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        Navigator.of(context).pop();
      case Err(:final failure):
        setState(() => _error = failureText(context.l, failure));
    }
  }

  @override
  Widget build(BuildContext context) => BvSheetScaffold(
    title: context.l.proponerUnPuntoDe,
    subtitle: context.l.unLugarDelBarrio,
    actionLabel: context.l.guardarPunto,
    actionIcon: Icons.add_location_alt_rounded,
    onAction: _name.text.trim().length >= 3 ? _save : null,
    children: [
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.nombreDelLugar,
          errorText: _error,
        ),
        onChanged: (_) => setState(() => _error = null),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _ref,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l.referenciaOpcional,
          helperText: context.l.porEjemploFrenteAl,
        ),
      ),
    ],
  );
}
