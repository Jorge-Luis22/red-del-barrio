/// Puerto del reloj: permite probar plazos (ventana de gracia, no-show) sin esperar.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
