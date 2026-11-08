import 'package:flutter/material.dart';

import '../../../app/ui/components.dart';
import '../domain/need.dart';

/// Textos e íconos de los tipos de necesidad (español claro y sencillo).
class NeedLabels {
  NeedLabels._();

  static String kind(NeedKind k) => switch (k) {
    NeedKind.service => 'Servicio',
    NeedKind.product => 'Producto',
    NeedKind.loan => 'Préstamo',
    NeedKind.help => 'Ayuda',
  };

  static String hint(NeedKind k) => switch (k) {
    NeedKind.service => 'Un oficio o profesional',
    NeedKind.product => 'Algo cerca de ti',
    NeedKind.loan => 'Prestar, alquilar o trueque',
    NeedKind.help => 'Un favor o tiempo de alguien',
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

  static String urgency(Urgency u) => switch (u) {
    Urgency.now => 'Ahora mismo',
    Urgency.today => 'Hoy',
    Urgency.tomorrow => 'Mañana',
    Urgency.thisWeek => 'Esta semana',
  };

  /// Frases listas: elegir una cuenta como escribir (menos teclado para quien lo necesite).
  static List<String> suggestions(NeedKind k) => switch (k) {
    NeedKind.service => [
      'Necesito un gasfitero para arreglar una fuga',
      'Necesito un electricista, se fue la luz en la cocina',
    ],
    NeedKind.product => [
      'Necesito 2 bidones de agua',
      'Necesito pan y leche, no puedo salir',
    ],
    NeedKind.loan => [
      'Necesito un taladro por una hora',
      'Necesito una escalera por hoy',
    ],
    NeedKind.help => [
      'Necesito ayuda para mover un mueble',
      'Necesito que alguien cuide a mi hijo 2 horas',
    ],
  };

  /// Atajos de Inicio (1 toque abre el formulario ya lleno; 2 toques con Publicar).
  static const quick = <({NeedKind kind, String text, String label})>[
    (
      kind: NeedKind.service,
      text: 'Necesito un gasfitero para arreglar una fuga',
      label: 'Gasfitero',
    ),
    (
      kind: NeedKind.service,
      text: 'Necesito un electricista, se fue la luz en la cocina',
      label: 'Electricista',
    ),
    (
      kind: NeedKind.product,
      text: 'Necesito 2 bidones de agua',
      label: '2 bidones de agua',
    ),
  ];
}

/// Rótulo del estado de envío. En mobile-ux el destino es de demostración: nunca decimos "servidor".
String syncLabel(SyncStatus s, {required bool isDemo}) => switch (s) {
  SyncStatus.pending =>
    'Guardada en tu teléfono · se enviará cuando haya internet',
  SyncStatus.sent => isDemo ? 'Enviada · barrio de ejemplo (demo)' : 'Enviada',
  SyncStatus.error => 'No se pudo enviar · toca para reintentar',
};

/// Versión corta del estado de envío para listas y etiquetas.
({String label, IconData icon, BvTone tone}) syncBadge(SyncStatus s) =>
    switch (s) {
      SyncStatus.pending => (
        label: 'Pendiente',
        icon: Icons.schedule_rounded,
        tone: BvTone.sun,
      ),
      SyncStatus.sent => (
        label: 'Enviada',
        icon: Icons.check_circle_rounded,
        tone: BvTone.trust,
      ),
      SyncStatus.error => (
        label: 'Reintentar',
        icon: Icons.error_rounded,
        tone: BvTone.emergency,
      ),
    };
