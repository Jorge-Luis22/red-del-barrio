import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';

/// Qué datos se guardan y qué derechos tiene cada vecino (lenguaje simple).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  Widget _block(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(height: 1.4, color: ink)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tus datos y el piloto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _block(
            'Qué es',
            'Red del barrio es un piloto cerrado entre vecinos. No es una tienda ni cobra comisiones: '
                'cada trato (y el pago, si lo hay) se hace entre las dos personas, en persona.',
          ),
          _block(
            'Qué datos se guardan',
            'Tu nombre o apodo, tu zona aproximada, lo que publiques (pedidos, servicios, propuestas), '
                'tus mensajes con la otra persona del trato y tus calificaciones. No se guarda tu ubicación exacta, '
                'ni tu número, ni tu correo.',
          ),
          _block(
            'Quién lo ve',
            'Pedidos, servicios y tu perfil: los vecinos del piloto. Los mensajes de un trato: solo las dos personas '
                'que lo acordaron. El código de encuentro: solo quien pidió.',
          ),
          _block(
            'Tus derechos',
            'Puedes borrar tu cuenta y todo lo que publicaste desde Perfil → "Borrar mi cuenta". '
                'También puedes pedir acceso o corrección de tus datos escribiendo a ${Config.contactEmail}. '
                'Aplica la Ley 29733 de Protección de Datos Personales del Perú.',
          ),
          _block(
            'Seguridad entre vecinos',
            'Reúnete en lugares públicos o con alguien más presente, no compartas claves ni códigos de tus cuentas '
                'y usa "Reportar" si alguien te incomoda. En una emergencia real llama al 105 (Policía), 116 (Bomberos) o 106 (SAMU).',
          ),
          const Text(
            'Esto es un resumen del piloto; la versión legal completa está pendiente de revisión.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
