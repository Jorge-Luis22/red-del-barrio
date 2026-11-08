import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../domain/connection_banner.dart';
import 'connection_controller.dart';

/// Franja fina sobre la barra de pestañas: dice si hay conexión y cuántos envíos esperan.
/// Se oculta cuando todo está normal. Un lector de pantalla anuncia cada cambio.
class ConnectionBannerBar extends ConsumerWidget {
  const ConnectionBannerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(connectionControllerProvider);
    final l = context.l;
    final banner = link.banner;

    final (String text, IconData icon, BvTone tone) = switch (banner) {
      ConnectionBanner.offline => (
        link.pending > 0 ? l.connOfflinePending(link.pending) : l.connOffline,
        Icons.cloud_off_rounded,
        BvTone.sun,
      ),
      ConnectionBanner.syncing => (
        l.connSyncing(link.pending < 1 ? 1 : link.pending),
        Icons.sync_rounded,
        BvTone.violet,
      ),
      ConnectionBanner.synced => (
        l.connSynced,
        Icons.cloud_done_rounded,
        BvTone.trust,
      ),
      ConnectionBanner.hidden => ('', Icons.circle, BvTone.neutral),
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      alignment: Alignment.bottomCenter,
      child: banner == ConnectionBanner.hidden
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              label: text,
              child: ExcludeSemantics(
                child: Container(
                  width: double.infinity,
                  color: toneColors(context, tone).bg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: toneIconColor(context, tone)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(text, style: context.tt.labelMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
