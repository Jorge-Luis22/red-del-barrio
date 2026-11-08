import 'failure.dart';

/// Resultado de una operación: correcto ([Ok]) o con error recuperable ([Err]).
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
