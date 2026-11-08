/// Qué franja de estado de conexión se muestra.
enum ConnectionBanner {
  /// Todo normal: no se muestra nada.
  hidden,

  /// Sin conexión: la app sigue funcionando y guarda lo que se haga.
  offline,

  /// Con conexión, enviando lo pendiente.
  syncing,

  /// Se acaba de enviar todo (se muestra unos segundos).
  synced,
}

/// Decide la franja según el estado actual. Es una función pura para poder probarla.
ConnectionBanner deriveBanner({
  required bool online,
  required int pending,
  required bool syncing,
  required bool justSynced,
}) {
  if (!online) return ConnectionBanner.offline;
  if (syncing || pending > 0) return ConnectionBanner.syncing;
  if (justSynced) return ConnectionBanner.synced;
  return ConnectionBanner.hidden;
}
