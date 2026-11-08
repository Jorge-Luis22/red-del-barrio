import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/section_header.dart';
import '../../proposals/domain/deal.dart';
import '../domain/app_settings.dart';
import 'tutorial_sheet.dart';

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
            title: 'Perfil',
            subtitle: 'Tu ayuda al barrio y tus ajustes.',
            icon: Icons.person_rounded,
            background: context.tones.trust,
            foreground: context.cs.onTertiary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BvSectionTitle(
                  'Tu ayuda al barrio',
                  subtitle: 'Solo tú ves este resumen.',
                ),
                const SizedBox(height: 12),
                _HelpGrid(help: help),
                const SizedBox(height: 8),
                Text(
                  'Es evidencia de lo que hiciste, no puntos: no da prioridad ni ventaja.',
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                const SizedBox(height: 28),
                const BvSectionTitle('Ver y escuchar mejor'),
                const SizedBox(height: 12),
                BvPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tamaño del texto', style: context.tt.titleSmall),
                      const SizedBox(height: 10),
                      BvSegmented<double>(
                        options: const [
                          (
                            value: 1.0,
                            label: 'Normal',
                            icon: Icons.text_fields_rounded,
                          ),
                          (
                            value: 1.15,
                            label: 'Grande',
                            icon: Icons.text_increase_rounded,
                          ),
                          (
                            value: 1.3,
                            label: 'Muy grande',
                            icon: Icons.format_size_rounded,
                          ),
                        ],
                        selected: s.textScale,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(textScale: v)),
                      ),
                      const SizedBox(height: 16),
                      Text('Apariencia', style: context.tt.titleSmall),
                      const SizedBox(height: 10),
                      BvSegmented<ThemePreference>(
                        options: const [
                          (
                            value: ThemePreference.system,
                            label: 'Sistema',
                            icon: Icons.brightness_auto_rounded,
                          ),
                          (
                            value: ThemePreference.light,
                            label: 'Claro',
                            icon: Icons.light_mode_rounded,
                          ),
                          (
                            value: ThemePreference.dark,
                            label: 'Oscuro',
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
                          'Alto contraste',
                          style: context.tt.titleSmall,
                        ),
                        subtitle: const Text(
                          'Textos más oscuros y bordes más marcados.',
                        ),
                        value: s.highContrast,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(highContrast: v)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Vibración al confirmar',
                          style: context.tt.titleSmall,
                        ),
                        subtitle: const Text(
                          'Una vibración corta cuando envías algo.',
                        ),
                        value: s.vibration,
                        onChanged: (v) =>
                            repo.update((c) => c.copyWith(vibration: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const BvSectionTitle('Ayuda y datos'),
                const SizedBox(height: 12),
                BvRows(
                  children: [
                    _ActionRow(
                      icon: Icons.school_rounded,
                      title: 'Ver el tutorial',
                      subtitle: 'Tres pantallas para empezar.',
                      onTap: () => showTutorial(context),
                    ),
                    _ActionRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Sobre este prototipo',
                      subtitle: 'Qué es real y qué es de ejemplo.',
                      onTap: () => _showAbout(context),
                    ),
                    _ActionRow(
                      icon: Icons.delete_forever_rounded,
                      title: 'Borrar mis datos de este teléfono',
                      subtitle: 'Pedidos, tratos, mensajes y ajustes.',
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
        'Tratos resueltos',
        BvTone.trust,
      ),
      (
        Icons.groups_rounded,
        '${help.people}',
        'Personas distintas',
        BvTone.violet,
      ),
      (
        Icons.star_rounded,
        help.averageStars == null ? '—' : help.averageStars!.toStringAsFixed(1),
        'Calificación que diste',
        BvTone.sun,
      ),
      (
        Icons.timer_rounded,
        '${help.minutes} min',
        'Tiempo en tratos',
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
    title: const Text('Sobre este prototipo'),
    content: const SingleChildScrollView(
      child: Text(
        'Es real: tus pedidos, tratos, mensajes y ajustes se guardan en tu teléfono, '
        'funciona sin internet y la cola envía lo pendiente al volver la señal.\n\n'
        'Es de ejemplo: los vecinos, negocios, propuestas y precios que ves, y el '
        '"enviado", porque todavía no hay servidor ni cuentas.\n\n'
        'Por verificar: los números de emergencia deben confirmarse con fuentes oficiales.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Entendido'),
      ),
    ],
  ),
);

Future<void> _confirmErase(BuildContext context, WidgetRef ref) async {
  final first = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Borrar tus datos?'),
      content: const Text(
        'Se borrarán tus pedidos, tratos, calificaciones, mensajes, avisos y ajustes de este teléfono.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Continuar'),
        ),
      ],
    ),
  );
  if (first != true || !context.mounted) return;
  final second = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Última confirmación'),
      content: const Text(
        'Esto no se puede deshacer. ¿Seguro que quieres borrar todo?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No, conservar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: context.tones.emergency,
            foregroundColor: context.cs.onError,
          ),
          child: const Text('Sí, borrar todo'),
        ),
      ],
    ),
  );
  if (second != true) return;
  await ref.read(settingsRepositoryProvider).eraseAll();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listo: borramos tus datos de este teléfono.'),
      ),
    );
  }
}
