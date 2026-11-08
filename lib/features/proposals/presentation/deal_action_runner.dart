import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/ui/failure_text.dart';
import '../../../core/result.dart';

/// Ejecuta una acción del trato: bloquea el botón mientras trabaja y avisa el resultado
/// (éxito o el error traducido). Lo comparten todas las tarjetas de etapa del trato.
mixin DealActionRunner<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;

  void toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: const Duration(seconds: 6), content: Text(message)),
  );

  Future<void> run(
    Future<Result<Object?>> Function() action, {
    String? ok,
  }) async {
    setState(() => busy = true);
    final r = await action();
    if (!mounted) return;
    setState(() => busy = false);
    switch (r) {
      case Ok():
        if (ok != null) toast(ok);
      case Err(:final failure):
        toast(failureText(context.l, failure));
    }
  }
}
