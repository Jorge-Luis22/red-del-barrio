import '../../needs/domain/need.dart';

/// Mensaje escrito por la persona en el chat de un trato.
/// No hay otra persona conectada todavía: nunca se inventan respuestas.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.dealId,
    required this.text,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final String dealId;
  final String text;
  final DateTime createdAt;
  final SyncStatus syncStatus;
}

/// Frases rápidas para quien escribe poco o con dificultad.
const quickPhrases = [
  'Ya voy en camino',
  'Estoy en la puerta',
  '¿A qué hora puede venir?',
  'Gracias, todo bien',
];
