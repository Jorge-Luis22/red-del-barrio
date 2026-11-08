import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brand.dart';
import '../l10n.dart';

/// Abre una hoja inferior sobre toda la app (también sobre la barra de pestañas),
/// respetando el área segura y el teclado.
Future<T?> showBvSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  showDragHandle: true,
  builder: builder,
);

/// Estructura común de las hojas: título, contenido que se desplaza y un botón de acción
/// fijo abajo que nunca queda tapado por el teclado.
class BvSheetScaffold extends StatelessWidget {
  const BvSheetScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.busy = false,
    this.danger = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String actionLabel;
  final IconData actionIcon;

  /// `null` deja el botón desactivado.
  final VoidCallback? onAction;
  final bool busy;

  /// Acción delicada (por ejemplo, avisar una emergencia): botón en rojo de emergencia.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: context.tt.headlineSmall),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: context.tt.bodyMedium?.copyWith(
                        color: context.tones.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ...children,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.tones.cream,
              border: Border(top: BorderSide(color: context.tones.hairline)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : onAction,
                  style: danger
                      ? FilledButton.styleFrom(
                          backgroundColor: context.tones.emergency,
                          foregroundColor: context.cs.onError,
                        )
                      : null,
                  icon: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Icon(actionIcon),
                  label: Text(busy ? context.l.unMomento : actionLabel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vibración corta de confirmación, solo si la persona la dejó activada.
void confirmHaptic({required bool enabled}) {
  if (enabled) HapticFeedback.mediumImpact();
}
