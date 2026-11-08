import 'offer.dart';

/// DATOS DE DEMOSTRACIÓN del muro de vecinos (no son personas reales).
/// Siempre se rotulan "Ejemplo" en pantalla. En la etapa con servidor se reemplazan por datos reales.
const demoWall = <WallEntry>[
  WallEntry(
    id: 'w1',
    author: 'Inés Rojas',
    text: 'Necesito un taladro por una hora.',
    modality: Modality.free,
    isRequest: true,
    isExample: true,
    distanceMeters: 350,
  ),
  WallEntry(
    id: 'w2',
    author: 'Tomás Vega',
    text: 'Presto mi escalera de 3 metros. Pasa a recogerla.',
    modality: Modality.free,
    isRequest: false,
    isExample: true,
    distanceMeters: 500,
  ),
  WallEntry(
    id: 'w3',
    author: 'Nelly Flores',
    text: 'Cambio clases de tejido por ayuda con el celular.',
    modality: Modality.barter,
    isRequest: false,
    isExample: true,
    distanceMeters: 700,
  ),
  WallEntry(
    id: 'w4',
    author: 'Marco Rivas',
    text: 'Busco quien me ayude a mover un mueble el sábado.',
    modality: Modality.barter,
    isRequest: true,
    isExample: true,
    distanceMeters: 900,
  ),
  WallEntry(
    id: 'w5',
    author: 'Elena Castro',
    text: 'Alquilo una máquina de coser por día.',
    modality: Modality.rent,
    isRequest: false,
    isExample: true,
    distanceMeters: 1100,
  ),
  WallEntry(
    id: 'w6',
    author: 'Luis Paredes',
    text: 'Necesito una carretilla prestada para el fin de semana.',
    modality: Modality.free,
    isRequest: true,
    isExample: true,
    distanceMeters: 1300,
  ),
];
