import '../../needs/domain/need.dart';

/// Tipos de emergencia (paridad con el PWA). La violencia es PRIVADA: no se comparte con el barrio.
enum SosSituation { earthquake, fire, medical, elderly, violence }

extension SosSituationInfo on SosSituation {
  bool get isPrivate => this == SosSituation.violence;
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

/// Persona de confianza a la que se avisa por SMS cuando se pide ayuda.
/// Vive solo en el teléfono: no se sube a ningún servidor.
class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Solo dígitos, con un `+` al inicio si trae código de país.
  final String phone;
  final DateTime createdAt;
}

/// Cuántos contactos de confianza se pueden guardar.
const maxTrustedContacts = 5;

/// Qué lleva la mochila de emergencia (identificadores; la interfaz pone el texto).
const backpackItems = [
  'water',
  'food',
  'flashlight',
  'radio',
  'firstAid',
  'meds',
  'docs',
  'cash',
  'charger',
  'whistle',
  'clothes',
];

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
  const OfficialContact({required this.id, required this.number});

  /// Identificador estable: la interfaz traduce su nombre y para qué sirve.
  final String id;
  final String number;
}

const officialContacts = [
  OfficialContact(id: 'police', number: '105'),
  OfficialContact(id: 'fire', number: '116'),
  OfficialContact(id: 'samu', number: '106'),
  OfficialContact(id: 'civil', number: '115'),
  OfficialContact(id: 'line100', number: '100'),
];
