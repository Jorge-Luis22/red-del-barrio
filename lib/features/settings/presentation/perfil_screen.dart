import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../proposals/domain/deal.dart';
import '../domain/app_settings.dart';
import 'tutorial_sheet.dart';
import '../../../app/l10n.dart';

/// Evidencia de lo que la persona aportó, calculada de sus tratos cerrados.
/// Solo ella la ve. No hay puntos, puestos ni prioridad.
class HelpSummary {
  const HelpSummary({
    required this.confirmed,
    required this.people,
    required this.averageStars,
    required this.minutes,
  });

  final int confirmed;
  final int people;
  final double? averageStars;
  final int minutes;
}

final helpSummaryProvider = Provider<HelpSummary>((ref) {
  final deals = (ref.watch(dealsStreamProvider).value ?? const <Deal>[]).where(
    (d) => d.status == DealStatus.closed,
  );
  final interactions = ref.watch(interactionsStreamProvider).value ?? const [];
  final stars = interactions.map((i) => i.stars).toList();
  return HelpSummary(
    confirmed: deals.length,
    people: deals.map((d) => d.providerId).toSet().length,
    averageStars: stars.isEmpty
        ? null
        : stars.reduce((a, b) => a + b) / stars.length,
    minutes: deals.fold<int>(0, (sum, d) => sum + (d.duration?.inMinutes ?? 0)),
  );
});

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final help = ref.watch(helpSummaryProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BvSectionHeader(
            title: context.l.perfil,
            subtitle: context.l.tuAyudaAlBarrio,
            icon: Icons.person_rounded,
            background: context.tones.trust,
            foreground: context.cs.onTertiary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BvSectionTitle(
                  context.l.tuAyudaAlBarrio2,
                  subtitle: context.l.soloTuVesEste,
                ),
                const SizedBox(height: 12),
                _HelpGrid(help: help),
                const SizedBox(height: 8),
                Text(
                  context.l.esEvidenciaDeLo,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                const SizedBox(height: 28),
                BvSectionTitle(context.l.verYEscucharMejor),
                const SizedBox(height: 12),
                BvPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l.tamanoDelTexto,
                        style: context.tt.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      BvSegmented<double>(
                        options: [
                          (
                            value: 1.0,
                            label: context.l.normal,
                            icon: Icons.text_fields_rounded,
                          ),
                          (
                            value: 1.15,
                            label: context.l.grande,
                            icon: Icons.text_increase_rounded,
                          ),
                          (
                            value: 1.3,
                            label: context.l.muyGrande,
                            icon: Icons.format_size_rounded,
                          ),
                        ],
                        selected: s.textScale,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(textScale: v)),
                      ),
                      const SizedBox(height: 16),
                      Text(context.l.idioma, style: context.tt.titleSmall),
                      const SizedBox(height: 10),
                      BvSegmented<String>(
                        options:
                            [
                                  (
                                    '',
                                    context.l.sistema,
                                    Icons.language_rounded,
                                  ),
                                  ('es', 'Español', Icons.translate_rounded),
                                  ('en', 'English', Icons.translate_rounded),
                                ]
                                .map(
                                  (o) => (value: o.$1, label: o.$2, icon: o.$3),
                                )
                                .toList(),
                        selected: s.languageCode ?? '',
                        onChanged: (v) => repo.update(
                          (c) => v.isEmpty
                              ? c.copyWith(useSystemLanguage: true)
                              : c.copyWith(languageCode: v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(context.l.apariencia, style: context.tt.titleSmall),
                      const SizedBox(height: 10),
                      BvSegmented<ThemePreference>(
                        options: [
                          (
                            value: ThemePreference.system,
                            label: context.l.sistema,
                            icon: Icons.brightness_auto_rounded,
                          ),
                          (
                            value: ThemePreference.light,
                            label: context.l.claro,
                            icon: Icons.light_mode_rounded,
                          ),
                          (
                            value: ThemePreference.dark,
                            label: context.l.oscuro,
                            icon: Icons.dark_mode_rounded,
                          ),
                        ],
                        selected: s.theme,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(theme: v)),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.l.altoContraste,
                          style: context.tt.titleSmall,
                        ),
                        subtitle: Text(context.l.textosMasOscurosY),
                        value: s.highContrast,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(highContrast: v)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.l.vibracionAlConfirmar,
                          style: context.tt.titleSmall,
                        ),
                        subtitle: Text(context.l.unaVibracionCortaCuando),
                        value: s.vibration,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(vibration: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                BvSectionTitle(context.l.ayudaYDatos),
                const SizedBox(height: 12),
                BvRows(
                  children: [
                    _ActionRow(
                      icon: Icons.school_rounded,
                      title: context.l.verElTutorial,
                      subtitle: context.l.tresPantallasParaEmpezar,
                      onTap: () => showTutorial(context),
                    ),
                    _ActionRow(
                      icon: Icons.info_outline_rounded,
                      title: context.l.sobreEstePrototipo,
                      subtitle: context.l.queEsRealY,
                      onTap: () => _showAbout(context),
                    ),
                    _ActionRow(
                      icon: Icons.delete_forever_rounded,
                      title: context.l.borrarMisDatosDe,
                      subtitle: context.l.pedidosTratosMensajesY,
                      danger: true,
                      onTap: () => _confirmErase(context, ref),
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

class _HelpGrid extends StatelessWidget {
  const _HelpGrid({required this.help});

  final HelpSummary help;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.task_alt_rounded,
        '${help.confirmed}',
        context.l.tratosResueltos,
        BvTone.trust,
      ),
      (
        Icons.groups_rounded,
        '${help.people}',
        context.l.personasDistintas,
        BvTone.violet,
      ),
      (
        Icons.star_rounded,
        help.averageStars == null ? '—' : help.averageStars!.toStringAsFixed(1),
        context.l.calificacionQueDiste,
        BvTone.sun,
      ),
      (
        Icons.timer_rounded,
        context.l.min(help.minutes),
        context.l.tiempoEnTratos,
        BvTone.coral,
      ),
    ];
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        for (final (icon, value, label, tone) in items)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: toneColors(context, tone).bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: toneIconColor(context, tone)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: context.tt.headlineSmall),
                    Text(label, style: context.tt.bodySmall),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          BvIconBadge(icon, tone: danger ? BvTone.emergency : BvTone.violet),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.titleSmall?.copyWith(
                    color: danger ? context.tones.emergency : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.tones.muted),
        ],
      ),
    ),
  );
}

void _showAbout(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(context.l.sobreEstePrototipo),
    content: SingleChildScrollView(child: Text(context.l.esRealTusPedidos)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(context.l.entendido),
      ),
    ],
  ),
);

Future<void> _confirmErase(BuildContext context, WidgetRef ref) async {
  final first = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l.borrarTusDatos),
      content: Text(context.l.seBorraranTusPedidos),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.l.cancelar),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l.continuar),
        ),
      ],
    ),
  );
  if (first != true || !context.mounted) return;
  final second = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l.ultimaConfirmacion),
      content: Text(context.l.estoNoSePuede),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.l.noConservar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: context.tones.emergency,
            foregroundColor: context.cs.onError,
          ),
          child: Text(context.l.siBorrarTodo),
        ),
      ],
    ),
  );
  if (second != true) return;
  await ref.read(settingsRepositoryProvider).eraseAll();
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l.listoBorramosTusDatos)));
  }
}
