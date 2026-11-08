import 'package:flutter/material.dart';

import 'util.dart';

const Color brand = Color(0xFF0A6B66);
const Color brandSoft = Color(0xFFD9ECEA);
const Color warm = Color(0xFFB5651D);
const Color warmSoft = Color(0xFFF6E7D6);
const Color paper = Color(0xFFF7F5F0);
const Color ink = Color(0xFF1B2B2A);
const Color muted = Color(0xFF5B6B69);
const Color line = Color(0xFFDAD6CC);
const Color danger = Color(0xFFB3261E);

ThemeData buildTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(seedColor: brand).copyWith(primary: brand);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: line),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

void toast(BuildContext context, String message) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Tarjeta blanca con borde suave.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final Widget body = Padding(padding: padding, child: child);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: onTap == null
          ? body
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: body),
            ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, required this.color, this.size = 40});
  final String name;
  final String color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colorFromHex(color), shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.44),
      ),
    );
  }
}

/// Etiqueta pequeña (tipo, estado, nivel).
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.bg = brandSoft, this.fg = brand});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

/// Botón-etiqueta que se enciende al tocarlo (como los "chips" de la web).
class ChoiceChipBtn extends StatelessWidget {
  const ChoiceChipBtn({super.key, required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? brand : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: on ? brand : line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Text(
            label,
            style: TextStyle(
              color: on ? Colors.white : ink,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.hint});
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
            if (hint != null) TextSpan(text: '  $hint', style: const TextStyle(color: muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.text = ''});
  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: ink),
          ),
          if (text.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: muted)),
          ],
        ],
      ),
    );
  }
}
