import '../../core/failure.dart';
import '../l10n.dart';

/// Texto traducido de un error. El dominio guarda un mensaje en español estable; aquí se
/// convierte al idioma elegido. Si el mensaje no está en la lista, se muestra tal cual.
String failureText(AppLocalizations l, Failure failure) =>
    messageText(l, failure.message);

/// Igual que [failureText] pero a partir del mensaje guardado (por ejemplo, en un estado).
String messageText(AppLocalizations l, String message) => switch (message) {
  "Escribe un mensaje." => l.failWriteMessage,
  "No se pudo guardar tu mensaje." => l.failSaveMessage,
  "No se pudo actualizar el mensaje." => l.failUpdateMessage,
  "Escribe el nombre del lugar." => l.failPlaceName,
  "No se pudo guardar tu aviso." => l.failSaveAlert,
  "No se pudo actualizar el aviso." => l.failUpdateAlert,
  "No se pudo guardar el punto de acopio." => l.failSavePoint,
  "No pudimos obtener tu ubicación. Inténtalo otra vez." => l.failLocation,
  "Cuéntanos qué necesitas (al menos 3 letras)." => l.failNeedShort,
  "No se pudo guardar en tu teléfono." => l.failSavePhone,
  "No se pudo actualizar el estado." => l.failUpdateStatus,
  "Este pedido ya tiene una propuesta aceptada." => l.failAlreadyAccepted,
  "No encontramos este trato." => l.failDealNotFound,
  "El código de este trato ya fue validado." => l.failCodeValidated,
  "Primero hay que validar el código de encuentro." => l.failValidateCodeFirst,
  "Elige de 1 a 5 estrellas." => l.failStars,
  "Primero marca el servicio como hecho." => l.failMarkDoneFirst,
  "No encontramos a esta persona." => l.failPersonNotFound,
  "No se pudo guardar el trato en tu teléfono." => l.failSaveDeal,
  "No se pudo guardar tu calificación." => l.failSaveRating,
  "Cuéntanos qué ofreces (al menos 3 letras)." => l.failOfferShort,
  "No se pudo guardar el envío pendiente." => l.failSavePending,
  "No se pudo actualizar la cola." => l.failUpdateQueue,
  'Activa la ubicación del teléfono para ver lo que hay cerca.' =>
    l.failLocationOff,
  'El permiso de ubicación está bloqueado. Actívalo en los ajustes del teléfono.' =>
    l.failLocationBlocked,
  'Sin permiso de ubicación. Puedes elegir tu zona a mano.' =>
    l.failLocationPermission,
  'El usuario debe tener de 3 a 20 letras, números, punto o guion bajo.' =>
    l.failUsername,
  'Escribe un correo válido o déjalo vacío.' => l.failEmail,
  'Ponle un nombre a la dirección.' => l.failAddressName,
  'Primero marca tu ubicación.' => l.failAddressNoLocation,
  'No se pudo guardar tu perfil.' => l.failSaveProfile,
  'No se pudo guardar la dirección.' => l.failSaveAddress,
  'No se pudo actualizar la dirección.' => l.failUpdateAddress,
  _ => message,
};
