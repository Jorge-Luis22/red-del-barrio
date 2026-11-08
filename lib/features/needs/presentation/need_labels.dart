import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../domain/need.dart';

/// Textos e íconos de los tipos de necesidad. Los textos salen de los archivos de traducción.
class NeedLabels {
  NeedLabels._();

  static String kind(AppLocalizations l, NeedKind k) => switch (k) {
    NeedKind.service => l.kindService,
    NeedKind.product => l.kindProduct,
    NeedKind.loan => l.kindLoan,
    NeedKind.help => l.kindHelp,
  };

  static String hint(AppLocalizations l, NeedKind k) => switch (k) {
    NeedKind.service => l.hintService,
    NeedKind.product => l.hintProduct,
    NeedKind.loan => l.hintLoan,
    NeedKind.help => l.hintHelp,
  };

  static IconData icon(NeedKind k) => switch (k) {
    NeedKind.service => Icons.handyman_rounded,
    NeedKind.product => Icons.shopping_basket_rounded,
    NeedKind.loan => Icons.swap_horiz_rounded,
    NeedKind.help => Icons.volunteer_activism_rounded,
  };

  /// Cada tipo de pedido tiene su color de la paleta.
  static BvTone tone(NeedKind k) => switch (k) {
    NeedKind.service => BvTone.violet,
    NeedKind.product => BvTone.coral,
    NeedKind.loan => BvTone.trust,
    NeedKind.help => BvTone.sun,
  };

  static String urgency(AppLocalizations l, Urgency u) => switch (u) {
    Urgency.now => l.urgencyNow,
    Urgency.today => l.urgencyToday,
    Urgency.tomorrow => l.urgencyTomorrow,
    Urgency.thisWeek => l.urgencyThisWeek,
  };

  /// Frases listas: elegir una cuenta como escribir (menos teclado para quien lo necesite).
  static List<String> suggestions(AppLocalizations l, NeedKind k) =>
      switch (k) {
        NeedKind.service => [l.suggService1, l.suggService2],
        NeedKind.product => [l.suggProduct1, l.suggProduct2],
        NeedKind.loan => [l.suggLoan1, l.suggLoan2],
        NeedKind.help => [l.suggHelp1, l.suggHelp2],
      };

  /// Atajos de Inicio (1 toque abre el formulario ya lleno; 2 toques con Publicar).
  static List<({NeedKind kind, String text, String label})> quick(
    AppLocalizations l,
  ) => [
    (kind: NeedKind.service, text: l.suggService1, label: l.quickPlumber),
    (kind: NeedKind.service, text: l.suggService2, label: l.quickElectrician),
    (kind: NeedKind.product, text: l.suggProduct1, label: l.quickWater),
  ];
}

/// Rótulo del estado de envío. El destino es de demostración: nunca decimos "servidor".
String syncLabel(AppLocalizations l, SyncStatus s, {required bool isDemo}) =>
    switch (s) {
      SyncStatus.pending => l.syncPending,
      SyncStatus.sent => isDemo ? l.syncSentDemo : l.syncSent,
      SyncStatus.error => l.syncError,
    };

/// Versión corta del estado de envío para listas y etiquetas.
({String label, IconData icon, BvTone tone}) syncBadge(
  AppLocalizations l,
  SyncStatus s,
) => switch (s) {
  SyncStatus.pending => (
    label: l.badgePending,
    icon: Icons.schedule_rounded,
    tone: BvTone.sun,
  ),
  SyncStatus.sent => (
    label: l.badgeSent,
    icon: Icons.check_circle_rounded,
    tone: BvTone.trust,
  ),
  SyncStatus.error => (
    label: l.badgeRetry,
    icon: Icons.error_rounded,
    tone: BvTone.emergency,
  ),
};
