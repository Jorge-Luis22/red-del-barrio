import 'package:flutter/material.dart';

import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../domain/quechua_phrasebook.dart';
import 'tr.dart';

/// Hoja con frases en quechua. Devuelve el texto elegido ("Yanapaway (Ayúdame)") o `null`.
Future<String?> showQuechuaSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _QuechuaSheet(),
    );

class _QuechuaSheet extends StatelessWidget {
  const _QuechuaSheet();

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            tr(context, 'Frases en quechua', 'Quechua phrases'),
            style: context.tt.headlineSmall,
          ),
          const SizedBox(height: 8),
          BvBanner(
            icon: Icons.info_outline_rounded,
            tone: BvTone.sun,
            message: tr(
              context,
              'Es una lista corta y referencial (quechua sureño), no un traductor. '
                  'Las variedades cambian según la región: conviene que un hablante la revise.',
              'A short, reference-only list (Southern Quechua), not a translator. '
                  'Varieties change by region: a native speaker should review it.',
            ),
          ),
          const SizedBox(height: 12),
          for (final p in quechuaPhrases)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final short = (isEn && p.en.isNotEmpty ? p.en : p.es)
                      .split(' (')
                      .first;
                  Navigator.pop(context, '${p.qu} ($short)');
                },
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.tones.hairline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.qu, style: context.tt.titleMedium),
                            Text(
                              isEn && p.en.isNotEmpty ? p.en : p.es,
                              style: context.tt.bodySmall?.copyWith(
                                color: context.tones.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: context.tones.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
