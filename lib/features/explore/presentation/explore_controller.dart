import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../directory/domain/listing.dart';
import '../../location/presentation/location_controller.dart';
import '../../profile/domain/profile.dart';
import '../domain/explore_nearby.dart';

class ExploreFilters {
  const ExploreFilters({
    this.kind = ListingKind.service,
    this.trade = 'Todos',
    this.sort = ExploreSort.recommended,
  });

  final ListingKind kind;
  final String trade;
  final ExploreSort sort;

  ExploreFilters copyWith({
    ListingKind? kind,
    String? trade,
    ExploreSort? sort,
  }) => ExploreFilters(
    kind: kind ?? this.kind,
    trade: trade ?? this.trade,
    sort: sort ?? this.sort,
  );
}

class ExploreFiltersController extends Notifier<ExploreFilters> {
  @override
  ExploreFilters build() => const ExploreFilters();

  void setKind(ListingKind k) =>
      state = ExploreFilters(kind: k, sort: state.sort);
  void setTrade(String t) => state = state.copyWith(trade: t);
  void setSort(ExploreSort s) => state = state.copyWith(sort: s);
}

final exploreFiltersProvider =
    NotifierProvider<ExploreFiltersController, ExploreFilters>(
      ExploreFiltersController.new,
    );

/// Se recalcula al cambiar filtros, ubicación o interacciones (Visto Bueno).
final exploreItemsProvider = FutureProvider<List<ExploreItem>>((ref) async {
  final filters = ref.watch(exploreFiltersProvider);
  // Las distancias se miden desde la dirección activa; sin ella, desde el GPS.
  final location = pickOrigin(
    active: ref.watch(activeAddressProvider),
    gps: ref.watch(locationControllerProvider).location,
  );
  ref.watch(interactionsStreamProvider);
  return ref.watch(exploreNearbyProvider)(
    kind: filters.kind,
    trade: filters.trade,
    sort: filters.sort,
    near: location,
  );
});
