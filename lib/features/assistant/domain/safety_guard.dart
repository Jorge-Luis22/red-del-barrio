import 'text_norm.dart';

/// Riesgos que el cuidado de seguridad avisa antes de publicar o enviar un texto.
enum SafetyFlag {
  phone,
  idNumber,
  email,
  exactAddress,
  advancePayment,
  secretCode,
  externalLink,
}

/// Revisa un texto con reglas locales (sin internet). Avisa, no bloquea:
/// la persona decide. Puede equivocarse (falsos positivos y falsos negativos).
class SafetyGuard {
  const SafetyGuard();

  static final _phone = RegExp(
    r'(?<!\d)(\+?51[\s-]?)?9\d{2}[\s-]?\d{3}[\s-]?\d{3}(?!\d)',
  );
  static final _idNumber = RegExp(r'(?<!\d)\d{8}(?!\d)');
  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+');
  static final _address = RegExp(
    r'\b(jr|jiron|av|avenida|calle|psje|pasaje|mz|manzana|lt|lote|urb|nro)\b\.?\s*([a-z0-9]+\s+){0,4}?\d{1,5}\b',
  );
  static final _payShort = RegExp(r'\b(cci|plin)\b');
  static final _link = RegExp(r'(https?://|www\.|bit\.ly)');

  static const _payWords = [
    'adelanto',
    'por adelantado',
    'deposito',
    'transfer',
    'yapeame',
    'yapea',
    'paga antes',
    'pagame antes',
    'numero de cuenta',
    'cuenta bancaria',
  ];
  static const _secretWords = [
    'codigo',
    'clave',
    'contrasena',
    'cvv',
    'token',
  ];

  List<SafetyFlag> scan(String raw) {
    final n = normalizeText(raw);
    final flags = <SafetyFlag>[];
    if (_phone.hasMatch(n)) flags.add(SafetyFlag.phone);
    if (_idNumber.hasMatch(n)) flags.add(SafetyFlag.idNumber);
    if (_email.hasMatch(n)) flags.add(SafetyFlag.email);
    if (_address.hasMatch(n)) flags.add(SafetyFlag.exactAddress);
    if (containsAny(n, _payWords) || _payShort.hasMatch(n)) {
      flags.add(SafetyFlag.advancePayment);
    }
    if (containsAny(n, _secretWords)) flags.add(SafetyFlag.secretCode);
    if (_link.hasMatch(n)) flags.add(SafetyFlag.externalLink);
    return flags;
  }
}
