import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';

/// Tutorial de 3 pantallas: pedir, elegir y encontrarse, confiar. Se ve la primera vez
/// y se puede repetir desde Perfil.
Future<void> showTutorial(BuildContext context) =>
    showBvSheet<void>(context, builder: (_) => const _Tutorial());

class _Step {
  const _Step(this.icon, this.tone, this.title, this.text);

  final IconData icon;
  final BvTone tone;
  final String title;
  final String text;
}

const _steps = [
  _Step(
    Icons.edit_note_rounded,
    BvTone.violet,
    'Cuenta qué necesitas',
    'Toca "Pedir algo" y elige una frase, o escribe con tus palabras. Con un atajo, son solo dos toques.',
  ),
  _Step(
    Icons.handshake_rounded,
    BvTone.coral,
    'Elige a quién y encuéntrense',
    'Tu barrio te propone cómo resolverlo y cada persona pone su precio. Al encontrarse, se dicen un código de 4 dígitos.',
  ),
  _Step(
    Icons.verified_rounded,
    BvTone.trust,
    'Califica y construye confianza',
    'Al terminar, calificas. Así el barrio sabe en quién confiar. También funciona sin internet: tus pedidos se envían después.',
  ),
];

class _Tutorial extends ConsumerStatefulWidget {
  const _Tutorial();

  @override
  ConsumerState<_Tutorial> createState() => _TutorialState();
}

class _TutorialState extends ConsumerState<_Tutorial> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(tutorialSeen: true));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _steps.length - 1;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref
              .read(settingsRepositoryProvider)
              .update((s) => s.copyWith(tutorialSeen: true));
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: PageView(
                  controller: _page,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    for (final s in _steps)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BvIconBadge(s.icon, tone: s.tone, size: 96),
                          const SizedBox(height: 24),
                          Text(
                            s.title,
                            style: context.tt.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.text,
                            style: context.tt.bodyLarge?.copyWith(
                              color: context.tones.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    Container(
                      width: i == _index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? context.cs.primary
                            : context.tones.hairline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (!last) ...[
                    TextButton(onPressed: _finish, child: const Text('Saltar')),
                  ],
                  const Spacer(),
                  FilledButton(
                    onPressed: last
                        ? _finish
                        : () => _page.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                    child: Text(last ? 'Empezar' : 'Siguiente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
