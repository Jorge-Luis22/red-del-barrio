import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../store.dart';
import '../theme.dart';
import 'legal.dart';

String joinMessage(String code) {
  switch (code) {
    case 'bad_code':
      return 'Ese código no es válido. Revisa que esté completo (por ejemplo 5TTM-GW4A-L6AZ).';
    case 'too_many_attempts':
      return 'Demasiados intentos. Espera unos minutos y vuelve a probar.';
    case 'banned':
      return 'Esta cuenta no puede entrar al piloto. Escríbenos si crees que es un error.';
    case 'not_configured':
      return 'El piloto todavía no está abierto. Avísale a quien te dio el código.';
    case 'bad_name':
      return 'Escribe tu nombre (o un apodo) para que tus vecinos sepan quién eres.';
    case 'offline':
      return 'No hay conexión con internet. Revisa tu señal y vuelve a intentar.';
    case 'disabled':
      return 'El servidor todavía no admite cuentas automáticas. Avísale a quien organiza el piloto.';
    default:
      return 'No se pudo entrar. Inténtalo otra vez en un momento.';
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _zone = TextEditingController(text: Config.defaultZone);
  bool _accepted = false;
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _zone.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    if (_busy) return;
    final String code = _code.text.trim();
    final String name = _name.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Escribe el código que te dieron.');
      return;
    }
    if (name.length < 2) {
      setState(() => _error = joinMessage('bad_name'));
      return;
    }
    if (!_accepted) {
      setState(() => _error = 'Marca la casilla para continuar.');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      await store.join(code, name, _zone.text);
    } on JoinFailed catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = joinMessage(e.code);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = joinMessage('server');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? notice = store.notice;
    String? noticeText;
    if (notice == 'session_lost') {
      noticeText = 'Tu sesión en este teléfono venció. Vuelve a entrar con el código del piloto.';
    } else if (notice == 'not_member') {
      noticeText = 'Tu cuenta ya no está en el piloto. Si fue un error, vuelve a entrar con el código.';
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('🏘️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              const Text(
                'Red del barrio',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: brand),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vecinos que se ayudan: pide lo que necesitas, ofrece lo que sabes hacer y encuentra a alguien de confianza cerca de ti.',
                style: TextStyle(fontSize: 16, color: muted, height: 1.4),
              ),
              if (noticeText != null) ...<Widget>[
                const SizedBox(height: 14),
                Panel(
                  padding: const EdgeInsets.all(12),
                  child: Text(noticeText, style: const TextStyle(color: warm, fontWeight: FontWeight.w600)),
                ),
              ],
              const SizedBox(height: 22),
              const Text('Código del piloto', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'XXXX-XXXX-XXXX'),
              ),
              const SizedBox(height: 14),
              const Text('Tu nombre o apodo', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Ej. Rosa M.', counterText: ''),
              ),
              const SizedBox(height: 14),
              const Text('Tu zona', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _zone,
                maxLength: 60,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Ej. Los Olivos, Lima', counterText: ''),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    value: _accepted,
                    onChanged: (bool? v) => setState(() => _accepted = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(height: 1.35),
                          children: <InlineSpan>[
                            const TextSpan(
                              text:
                                  'Entiendo que mi nombre, mi zona y lo que publique lo verán los vecinos del piloto. ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (BuildContext _) => const LegalScreen()),
                                ),
                                child: const Text(
                                  'Ver qué datos se guardan',
                                  style: TextStyle(color: brand, decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_error.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(_error, style: const TextStyle(color: danger, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _enter,
                  child: Text(_busy ? 'Entrando…' : 'Entrar al barrio'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Piloto cerrado: solo entran vecinos con código. Dudas: ${Config.contactEmail}',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
