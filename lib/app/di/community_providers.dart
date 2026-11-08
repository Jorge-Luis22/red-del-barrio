import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result.dart';
import '../../features/community/domain/community_need.dart';
import '../../features/community/infrastructure/supabase_community_feed.dart';
import '../config.dart';

final communityFeedProvider = Provider<CommunityFeed>(
  (_) => AppConfig.supabaseReady
      ? SupabaseCommunityFeed(Supabase.instance.client)
      : const DemoCommunityFeed(),
);

/// Pedidos abiertos del barrio (se vuelve a leer con `ref.invalidate`).
final communityNeedsProvider = FutureProvider.autoDispose<List<CommunityNeed>>((
  ref,
) async {
  final r = await ref.watch(communityFeedProvider).openNeeds();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw Exception(failure.message),
  };
});
