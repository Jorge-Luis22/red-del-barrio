import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import 'settings_panel.dart';

/// Ajustes en su propia pantalla: texto, idioma, apariencia, contraste, vibración y ubicación.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l.settingsTitle)),
    body: const SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: SettingsPanel(),
      ),
    ),
  );
}
