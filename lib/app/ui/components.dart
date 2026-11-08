import 'package:flutter/material.dart';

import '../theme/brand.dart';
import 'illustrations.dart';
import '../l10n.dart';

/// Intención de color de un componente. Cada tono sale de la paleta Barrio Vivo.
enum BvTone { violet, coral, trust, sun, emergency, neutral }

({Color bg, Color fg}) toneColors(BuildContext context, BvTone tone) {
  final t = context.tones;
  final cs = context.cs;
  return switch (tone) {
    BvTone.violet => (bg: t.violetSoft, fg: cs.primary),
    BvTone.coral => (bg: t.coralSoft, fg: cs.onSurface),
    BvTone.trust => (bg: t.trustSoft, fg: t.trustText),
    BvTone.sun => (bg: t.sunSoft, fg: cs.onSurface),
    BvTone.emergency => (bg: t.emergencySoft, fg: t.emergency),
    BvTone.neutral => (bg: t.hairline, fg: t.muted),
  };
}

/// Color del icono sobre fondo suave (el coral y el sol se leen mejor oscuros).
Color toneIconColor(BuildContext context, BvTone tone) => switch (tone) {
  BvTone.coral => context.tones.coral,
  BvTone.sun => context.cs.onSurface,
  _ => toneColors(context, tone).fg,
};

/// Etiqueta corta (estado, "Ejemplo", recomendaciones).
class BvPill extends StatelessWidget {
  const BvPill(this.label, {super.key, this.icon, this.tone = BvTone.neutral});

  final String label;
  final IconData? icon;
  final BvTone tone;

  @override
  Widget build(BuildContext context) {
    final c = toneColors(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: c.fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: context.tt.labelSmall?.copyWith(color: c.fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo con icono (tipo de pedido, rubro…).
class BvIconBadge extends StatelessWidget {
  const BvIconBadge(
    this.icon, {
    super.key,
    this.tone = BvTone.violet,
    this.size = 48,
  });

  final IconData icon;
  final BvTone tone;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: toneColors(context, tone).bg,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: size * 0.5, color: toneIconColor(context, tone)),
  );
}

/// Avatar con iniciales.
class BvAvatar extends StatelessWidget {
  const BvAvatar(
    this.name, {
    super.key,
    this.size = 48,
    this.tone = BvTone.violet,
  });

  final String name;
  final double size;
  final BvTone tone;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
    final c = toneColors(context, tone);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
      child: Text(
        initials,
        style: context.tt.titleSmall?.copyWith(color: c.fg),
      ),
    );
  }
}

/// Título de sección con subtítulo opcional y acción a la derecha.
class BvSectionTitle extends StatelessWidget {
  const BvSectionTitle(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: context.tt.titleLarge),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
            ],
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

/// Superficie blanca redondeada, sin borde, para agrupar filas relacionadas.
class BvPanel extends StatelessWidget {
  const BvPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.cs.surface,
      borderRadius: BorderRadius.circular(22),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

/// Panel con filas separadas por líneas finas.
class BvRows extends StatelessWidget {
  const BvRows({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => BvPanel(
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(indent: 16, endIndent: 16, color: context.tones.hairline),
          children[i],
        ],
      ],
    ),
  );
}

/// Aviso con icono: ubicación, sincronización, errores.
class BvBanner extends StatelessWidget {
  const BvBanner({
    super.key,
    required this.icon,
    required this.message,
    this.tone = BvTone.violet,
    this.title,
    this.action,
  });

  final IconData icon;
  final String? title;
  final String message;
  final BvTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = toneColors(context, tone);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: toneIconColor(context, tone), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: context.tt.titleSmall),
                Text(message, style: context.tt.bodyMedium),
                if (action != null) ...[const SizedBox(height: 12), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de dos o tres opciones tipo "pestañas", más claro que SegmentedButton.
class BvSegmented<T> extends StatelessWidget {
  const BvSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<({T value, String label, IconData icon})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.tones.violetSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: o.value == selected,
                label: o.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onChanged(o.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 48,
                    decoration: BoxDecoration(
                      color: o.value == selected
                          ? cs.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ExcludeSemantics(
                      // FittedBox: con texto grande o 3 opciones, el contenido se
                      // reduce un poco en vez de desbordarse.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                o.icon,
                                size: 20,
                                color: o.value == selected
                                    ? cs.onPrimary
                                    : cs.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                o.label,
                                style: context.tt.labelLarge?.copyWith(
                                  color: o.value == selected
                                      ? cs.onPrimary
                                      : cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Estrellas de solo lectura o para elegir.
class BvStars extends StatelessWidget {
  const BvStars({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 26,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var s = 1; s <= 5; s++)
        onChanged == null
            ? Icon(
                value >= s ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: context.tones.sun,
              )
            : IconButton(
                iconSize: size,
                tooltip: '$s ${s == 1 ? 'estrella' : 'estrellas'}',
                onPressed: () => onChanged!(s),
                icon: Icon(
                  value >= s ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: context.tones.sun,
                ),
              ),
    ],
  );
}

/// Estado vacío o sección todavía no disponible: ilustración, título, texto y acción opcional.
class BvEmptyState extends StatelessWidget {
  const BvEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.accent,
  });

  final String title;
  final String message;
  final Widget? action;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BarrioHouse(size: 132, accent: accent),
        const SizedBox(height: 16),
        Text(title, style: context.tt.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          message,
          style: context.tt.bodyMedium?.copyWith(color: context.tones.muted),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

/// Error con salida: nunca un texto suelto.
class BvErrorState extends StatelessWidget {
  const BvErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => BvBanner(
    icon: Icons.cloud_off_rounded,
    tone: BvTone.emergency,
    title: context.l.algoNoSalioBien,
    message: message,
    action: onRetry == null
        ? null
        : OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l.intentarOtraVez),
          ),
  );
}

/// Carga: bloques con la forma del contenido (sin animaciones decorativas).
class BvSkeletonRows extends StatelessWidget {
  const BvSkeletonRows({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: context.tones.hairline,
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Semantics(
      label: context.l.cargando,
      child: BvRows(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.tones.hairline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(160, 14),
                      const SizedBox(height: 8),
                      bar(110, 12),
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
