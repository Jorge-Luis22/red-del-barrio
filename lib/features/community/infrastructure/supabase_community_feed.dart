import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../core/result.dart';
import '../../needs/domain/need.dart';
import '../domain/community_need.dart';

/// Lee los pedidos abiertos del servidor. Solo trae zona aproximada: nunca la ubicación exacta.
class SupabaseCommunityFeed implements CommunityFeed {
  SupabaseCommunityFeed(this._client);

  final SupabaseClient _client;

  @override
  bool get isAvailable => true;

  @override
  Future<Result<List<CommunityNeed>>> openNeeds() async {
    try {
      if (_client.auth.currentSession == null) {
        await _client.auth.signInAnonymously();
      }
      final me = _client.auth.currentUser?.id;
      final rows = await _client
          .from('needs')
          .select('id, author_id, kind, body, urgency, created_at')
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .limit(50);
      final list = <CommunityNeed>[
        for (final r in rows)
          CommunityNeed(
            id: r['id'] as String,
            kind: NeedKind.values.firstWhere(
              (k) => k.name == r['kind'],
              orElse: () => NeedKind.help,
            ),
            text: r['body'] as String,
            urgency: Urgency.values.firstWhere(
              (u) => u.name == r['urgency'],
              orElse: () => Urgency.thisWeek,
            ),
            createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
            isMine: r['author_id'] == me,
          ),
      ];
      return Ok(list);
    } on SocketException {
      return const Err(NetworkFailure('Sin internet. Revisa tu conexión.'));
    } on TimeoutException {
      return const Err(NetworkFailure('Sin internet. Revisa tu conexión.'));
    } catch (e, st) {
      logError('supabase_community_feed.openNeeds', e, st);
      return const Err(
        UnknownFailure('No pudimos leer los pedidos del barrio ahora.'),
      );
    }
  }
}

/// Modo demostración: no hay servidor.
class DemoCommunityFeed implements CommunityFeed {
  const DemoCommunityFeed();

  @override
  bool get isAvailable => false;

  @override
  Future<Result<List<CommunityNeed>>> openNeeds() async => const Ok([]);
}
