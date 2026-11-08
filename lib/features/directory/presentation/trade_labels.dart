import '../../../app/l10n.dart';

/// Nombre traducido de un rubro. La clave en español se conserva para filtrar los datos;
/// si el rubro no está en la lista se muestra tal cual.
String tradeLabel(AppLocalizations l, String key) => switch (key) {
  'Todos' => l.trAll,
  'Gasfitería' => l.trPlumbing,
  'Electricidad' => l.trElectrical,
  'Carpintería' => l.trCarpentry,
  'Cerrajería' => l.trLocksmith,
  'Costura' => l.trSewing,
  'Clases' => l.trLessons,
  'Mascotas' => l.trPets,
  'Bodega' => l.trGrocery,
  'Minimarket' => l.trMinimarket,
  'De un vecino' => l.trNeighbor,
  _ => key,
};

/// Nombre traducido de un oficio o tipo de proveedor de los datos de ejemplo.
String roleLabel(AppLocalizations l, String role) => switch (role) {
  'Gasfitero' || 'Gasfitera' => l.roPlumber,
  'Electricista' => l.roElectrician,
  'Carpintero' => l.roCarpenter,
  'Cerrajero' => l.roLocksmith,
  'Costurera' => l.roSeamstress,
  'Profesora de clases particulares' => l.roTutor,
  'Paseadora de mascotas' => l.roPetWalker,
  'Bodega' => l.trGrocery,
  'Minimarket' => l.trMinimarket,
  'Vecino' || 'Vecina' => l.roNeighbor,
  _ => role,
};
