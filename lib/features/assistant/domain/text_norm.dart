/// Minúsculas y sin tildes, para comparar texto escrito de cualquier manera.
String normalizeText(String input) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  final buf = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buf.write(i >= 0 ? to[i] : ch);
  }
  return buf.toString();
}

/// `true` si [text] (ya normalizado) contiene alguna de las [needles] (ya normalizadas).
bool containsAny(String text, List<String> needles) {
  for (final n in needles) {
    if (text.contains(n)) return true;
  }
  return false;
}
