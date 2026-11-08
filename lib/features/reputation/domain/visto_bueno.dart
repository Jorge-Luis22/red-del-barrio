import 'interaction.dart';

/// Visto Bueno Vecinal con la regla anti-inflado (decisión Q-3):
///
/// > Una recomendación cuenta solo si nace de una interacción confirmada con ese
/// > proveedor, y cuenta una vez por persona distinta.
///
/// [confirmed] es lo único que cuenta de verdad. [example] es la cifra de demostración
/// y debe mostrarse aparte, rotulada "ejemplo".
class VistoBueno {
  const VistoBueno({required this.confirmed, required this.example});

  final int confirmed;
  final int example;

  int get total => confirmed + example;
  bool get isEmpty => total == 0;
}

VistoBueno calculateVistoBueno({
  required int exampleCount,
  required List<Interaction> interactions,
}) {
  final people = <String>{
    for (final i in interactions)
      if (i.recommended) i.raterId,
  };
  return VistoBueno(confirmed: people.length, example: exampleCount);
}
