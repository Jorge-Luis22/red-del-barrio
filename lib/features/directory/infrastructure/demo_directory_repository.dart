import '../../../core/geo/geo_math.dart';
import '../../location/domain/zone.dart';
import '../domain/directory_repository.dart';
import '../domain/listing.dart';
import '../domain/provider_profile.dart';
import 'demo_seed.dart';

/// Directorio de DEMOSTRACIÓN. Ubica cada publicación alrededor de la posición del usuario
/// (a la distancia y rumbo del seed) para que las distancias sean coherentes y calculables.
class DemoDirectoryRepository implements DirectoryRepository {
  const DemoDirectoryRepository();

  @override
  Future<List<Listing>> listings({ExactLocation? near}) async {
    return [
      for (final d in demoListings)
        if (near == null)
          d.listing
        else
          _placed(d, near),
    ];
  }

  Listing _placed(DemoListing d, ExactLocation origin) {
    final p = destinationPoint(origin.lat, origin.lng, d.meters, d.bearing);
    final l = d.listing;
    return Listing(
      id: l.id,
      providerId: l.providerId,
      title: l.title,
      trade: l.trade,
      kind: l.kind,
      availability: l.availability,
      reference: l.reference,
      requestText: l.requestText,
      latitude: p.lat,
      longitude: p.lng,
      nominalMeters: l.nominalMeters,
    );
  }

  @override
  Future<ProviderProfile?> provider(String providerId) async => demoProviders[providerId];
}
