import 'package:flutter/widgets.dart';

/// Texto en español o inglés según el idioma de la app (sin tocar los archivos de traducción).
String tr(BuildContext context, String es, String en) =>
    Localizations.localeOf(context).languageCode == 'en' ? en : es;
