import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../domain/emergency.dart';
import 'sos_labels.dart';

/// Servicios oficiales: siempre van primero en Emergencia. Cada llamada pide confirmar antes.
class OfficialContactsSection extends StatelessWidget {
  const OfficialContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(
          l.serviciosOficiales,
          subtitle: l.enPeligroLlamaAqui,
          trailing: BvPill(l.porVerificar, tone: BvTone.sun),
        ),
        const SizedBox(height: 12),
        BvRows(
          children: [
            for (final c in officialContacts) _OfficialRow(contact: c),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l.verificaEstosNumerosCon,
          style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
        ),
      ],
    );
  }
}

class _OfficialRow extends StatelessWidget {
  const _OfficialRow({required this.contact});

  final OfficialContact contact;

  Future<void> _call(BuildContext context) async {
    final l = context.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.llamarAl(contact.number)),
        content: Text(
          l.esteNumeroEstaPor(
            officialName(l, contact.id),
            officialUse(l, contact.id),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.llamar),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final launched = await launchUrl(Uri(scheme: 'tel', path: contact.number));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noPudimosAbrirEl(contact.number))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Semantics(
      button: true,
      label: l.llamarANumero(officialName(l, contact.id), contact.number),
      child: InkWell(
        onTap: () => _call(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      officialName(l, contact.id),
                      style: context.tt.titleSmall,
                    ),
                    Text(
                      officialUse(l, contact.id),
                      style: context.tt.bodySmall?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.call_rounded, color: context.tones.emergency),
            ],
          ),
        ),
      ),
    );
  }
}
