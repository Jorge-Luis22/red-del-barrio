import '../../needs/domain/need.dart';

/// Tipos de emergencia (paridad con el PWA). La violencia es PRIVADA: no se comparte con el barrio.
enum SosSituation { earthquake, fire, medical, elderly, violence }

extension SosSituationInfo on SosSituation {
  bool get isPrivate => this == SosSituation.violence;

  String get label => switch (this) {
    SosSituation.earthquake => 'Sismo',
    SosSituation.fire => 'Incendio',
    SosSituation.medical => 'Médico',
    SosSituation.elderly => 'Persona mayor en riesgo',
    SosSituation.violence => 'Violencia',
  };

  /// Texto que se prellena para que enviar el aviso sea un solo toque (editar es opcional).
  String get template => switch (this) {
    SosSituation.earthquake => 'Hubo un sismo y necesito ayuda.',
    SosSituation.fire => 'Hay un incendio cerca y necesito ayuda.',
    SosSituation.medical => 'Necesito ayuda médica urgente.',
    SosSituation.elderly => 'Una persona mayor necesita ayuda ahora.',
    SosSituation.violence =>
      'Estoy en una situación de violencia y necesito ayuda.',
  };
}

/// Aviso de ayuda que la persona publicó.
class EmergencyPost {
  const EmergencyPost({
    required this.id,
    required this.situation,
    required this.text,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final SosSituation situation;
  final String text;
  final DateTime createdAt;
  final SyncStatus syncStatus;
}

/// Punto de acopio propuesto por la persona. Siempre "sin verificar".
class CollectionPoint {
  const CollectionPoint({
    required this.id,
    required this.name,
    required this.reference,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String reference;
  final DateTime createdAt;
}

/// Servicio oficial de emergencia. Los números están POR VERIFICAR con fuentes oficiales
/// (riesgo R10): la pantalla lo dice y pide confirmar antes de llamar.
class OfficialContact {
  const OfficialContact({
    required this.name,
    required this.number,
    required this.use,
  });

  final String name;
  final String number;
  final String use;
}

const officialContacts = [
  OfficialContact(
    name: 'Policía Nacional',
    number: '105',
    use: 'Delitos y peligro inmediato',
  ),
  OfficialContact(name: 'Bomberos', number: '116', use: 'Incendios y rescates'),
  OfficialContact(name: 'SAMU', number: '106', use: 'Emergencias médicas'),
  OfficialContact(
    name: 'Defensa Civil',
    number: '115',
    use: 'Sismos y desastres',
  ),
  OfficialContact(
    name: 'Línea 100',
    number: '100',
    use: 'Violencia familiar y sexual',
  ),
];
