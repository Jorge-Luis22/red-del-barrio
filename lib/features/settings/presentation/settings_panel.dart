import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../location/presentation/location_controller.dart';
import '../domain/app_settings.dart';

/// Ajustes de la persona: tamaño de texto, idioma, apariencia, contraste, vibración y ubicación.
/// Todo se guarda en el teléfono y se aplica al instante.
class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final s = ref.watch(appSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final location = ref.read(locationControllerProvider.notifier);

    return BvPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.tamanoDelTexto, style: context.tt.titleSmall),
          const SizedBox(height: 10),
          BvSegmented<double>(
            options: [
              (value: 1.0, label: l.normal, icon: Icons.text_fields_rounded),
              (value: 1.15, label: l.grande, icon: Icons.text_increase_rounded),
              (value: 1.3, label: l.muyGrande, icon: Icons.format_size_rounded),
            ],
            selected: s.textScale,
            onChanged: (v) => repo.update((c) => c.copyWith(textScale: v)),
          ),
          const SizedBox(height: 16),
          Text(l.idioma, style: context.tt.titleSmall),
          const SizedBox(height: 10),
          BvSegmented<String>(
            options: [
              (value: '', label: l.sistema, icon: Icons.language_rounded),
              (value: 'es', label: 'Español', icon: Icons.translate_rounded),
              (value: 'en', label: 'English', icon: Icons.translate_rounded),
            ],
            selected: s.languageCode ?? '',
            onChanged: (v) => repo.update(
              (c) => v.isEmpty
                  ? c.copyWith(useSystemLanguage: true)
                  : c.copyWith(languageCode: v),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.apariencia, style: context.tt.titleSmall),
          const SizedBox(height: 10),
          BvSegmented<ThemePreference>(
            options: [
              (
                value: ThemePreference.system,
                label: l.sistema,
                icon: Icons.brightness_auto_rounded,
              ),
              (
                value: ThemePreference.light,
                label: l.claro,
                icon: Icons.light_mode_rounded,
              ),
              (
                value: ThemePreference.dark,
                label: l.oscuro,
                icon: Icons.dark_mode_rounded,
              ),
            ],
            selected: s.theme,
            onChanged: (v) => repo.update((c) => c.copyWith(theme: v)),
          ),
          const SizedBox(height: 8),
          _SwitchRow(
            title: l.altoContraste,
            subtitle: l.textosMasOscurosY,
            value: s.highContrast,
            onChanged: (v) => repo.update((c) => c.copyWith(highContrast: v)),
          ),
          _SwitchRow(
            title: l.vibracionAlConfirmar,
            subtitle: l.unaVibracionCortaCuando,
            value: s.vibration,
            onChanged: (v) => repo.update((c) => c.copyWith(vibration: v)),
          ),
          _SwitchRow(
            title: l.locSettingTitle,
            subtitle: l.locSettingHint,
            value: s.useLocation,
            onChanged: (v) => v ? location.request() : location.disable(),
          ),
          if (s.lastZoneLat != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final done = l.locForgotten;
                  await location.forgetZone();
                  messenger.showSnackBar(SnackBar(content: Text(done)));
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l.locForget),
              ),
            ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: context.tt.titleSmall),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
  );
}
