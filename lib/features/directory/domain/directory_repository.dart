import '../../location/domain/zone.dart';
import 'listing.dart';
import 'provider_profile.dart';

/// Directorio de oficios y productos del barrio.
/// Local (mobile-ux): datos de ejemplo. Remoto (mobile-mejoras): Supabase + PostGIS.
abstract interface class DirectoryRepository {
  /// Publicaciones cercanas a [near]. Sin ubicación, devuelve distancias nominales de ejemplo.
  Future<List<Listing>> listings({ExactLocation? near});

  Future<ProviderProfile?> provider(String providerId);
}
