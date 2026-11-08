import '../../../core/geo/geo_math.dart';
import '../../directory/domain/directory_repository.dart';
import '../../directory/domain/listing.dart';
import '../../directory/domain/provider_profile.dart';
import '../../location/domain/zone.dart';
import '../../reputation/domain/interaction.dart';
import '../../reputation/domain/reputation_repository.dart';
import '../../reputation/domain/visto_bueno.dart';

enum ExploreSort { recommended, nearest }

class ExploreItem {
  const ExploreItem({
    required this.listing,
    required this.provider,
    required this.distanceMeters,
    required this.distanceIsReal,
    required this.vistoBueno,
    required this.recommendedByMe,
  });

  final Listing listing;
  final ProviderProfile provider;

  /// Metros hasta el usuario. Si [distanceIsReal] es falso, es una cifra aproximada de ejemplo.
  final double? distanceMeters;
  final bool distanceIsReal;
  final VistoBueno vistoBueno;
  final bool recommendedByMe;
}

/// Lista servicios o productos cercanos con su Visto Bueno.
class ExploreNearby {
  ExploreNearby({required this.directory, required this.reputation});

  final DirectoryRepository directory;
  final ReputationRepository reputation;

  Future<List<ExploreItem>> call({
    required ListingKind kind,
    String? trade,
    ExploreSort sort = ExploreSort.recommended,
    ExactLocation? near,
    String raterId = 'me',
  }) async {
    final all = await directory.listings(near: near);
    final out = <ExploreItem>[];
    for (final l in all) {
      if (l.kind != kind) continue;
      if (trade != null && trade != 'Todos' && l.trade != trade) continue;
      final provider = await directory.provider(l.providerId);
      if (provider == null) continue;
      final interactions = await reputation.forProvider(l.providerId);
      final hasPosition =
          near != null && l.latitude != null && l.longitude != null;
      final double? distance = hasPosition
          ? haversineMeters(near.lat, near.lng, l.latitude!, l.longitude!)
          : l.nominalMeters;
      out.add(
        ExploreItem(
          listing: l,
          provider: provider,
          distanceMeters: distance,
          distanceIsReal: hasPosition,
          vistoBueno: calculateVistoBueno(
            exampleCount: provider.exampleVistoBueno,
            interactions: interactions,
          ),
          recommendedByMe: _recommended(interactions, raterId),
        ),
      );
    }
    out.sort((a, b) {
      final da = a.distanceMeters ?? 99999;
      final db = b.distanceMeters ?? 99999;
      if (sort == ExploreSort.nearest) return da.compareTo(db);
      final byVb = b.vistoBueno.total.compareTo(a.vistoBueno.total);
      return byVb != 0 ? byVb : da.compareTo(db);
    });
    return out;
  }

  bool _recommended(List<Interaction> list, String raterId) =>
      list.any((i) => i.raterId == raterId && i.recommended);
}
