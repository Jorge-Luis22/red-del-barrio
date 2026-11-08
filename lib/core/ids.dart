/// Puerto de identificadores: UUID de cliente (idempotencia de la cola)
/// y código de encuentro de 4 dígitos. Inyectable para pruebas deterministas.
abstract interface class IdGenerator {
  String newUuid();
  String meetingCode();
}
