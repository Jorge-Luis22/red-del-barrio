import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/illustrations.dart';
import 'address_sheet.dart';
import 'profile_form.dart';

/// Primer arranque: paso 1 crear el perfil, paso 2 marcar dónde está. Se puede saltar.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _step = 0;
  bool _located = false;

  /// Sea cual sea la salida (terminar, saltar o volver), no se vuelve a insistir.
  Future<void> _markDone() => ref
      .read(settingsRepositoryProvider)
      .update((s) => s.copyWith(welcomeDone: true));

  Future<void> _close() async {
    await _markDone();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _mark() async {
    final saved = await showAddressSheet(context);
    if (saved && mounted) setState(() => _located = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _markDone();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.cs.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.only(top: 12),
                child: const BarrioSkyline(height: 84),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    20 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l.welcomeTitle,
                          style: context.tt.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _step == 0 ? l.welcomeStep1 : l.welcomeStep2,
                        style: context.tt.titleSmall?.copyWith(
                          color: context.cs.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_step == 0) ...[
                        ProfileForm(
                          actionLabel: l.continuar,
                          onSaved: () => setState(() => _step = 1),
                        ),
                        const SizedBox(height: 12),
                        BvBanner(
                          icon: Icons.info_outline_rounded,
                          tone: BvTone.sun,
                          message: l.profLocalNote,
                        ),
                      ] else ...[
                        Text(l.welcomeWhere, style: context.tt.bodyLarge),
                        const SizedBox(height: 12),
                        BvBanner(
                          icon: Icons.lock_outline_rounded,
                          tone: BvTone.violet,
                          message: l.addrPrivacy,
                        ),
                        const SizedBox(height: 20),
                        if (_located) ...[
                          BvBanner(
                            icon: Icons.check_circle_rounded,
                            tone: BvTone.trust,
                            message: l.welcomeDone,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _close,
                              icon: const Icon(Icons.check_rounded),
                              label: Text(l.welcomeFinish),
                            ),
                          ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _mark,
                              icon: const Icon(Icons.my_location_rounded),
                              label: Text(l.welcomeMark),
                            ),
                          ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: _close,
                          child: Text(l.welcomeSkip),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
