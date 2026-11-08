/// Errores de negocio y de borde que la interfaz puede mostrar.
/// Ninguna excepción de infraestructura debe llegar a la UI: se traduce a un [Failure].
sealed class Failure {
  const Failure(this.message);

  /// Mensaje en español claro y sencillo (regla inviolable 6).
  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
