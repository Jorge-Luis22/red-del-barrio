import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../solidarity/domain/wall_demo.dart';
import '../domain/bid.dart';

/// Clave de un anuncio: qué tipo es y su identificador.
typedef BidSubjectKey = ({BidKind kind, String id});

/// Busca el anuncio sobre el que se oferta: un producto del directorio (venta) o un pedido
/// de un vecino del muro (pedido). `null` si ya no existe.
final bidSubjectProvider = FutureProvider.family<BidSubject?, BidSubjectKey>((
  ref,
  key,
) async {
  switch (key.kind) {
    case BidKind.sale:
      final directory = ref.read(directoryRepositoryProvider);
      final listings = await directory.listings();
      for (final l in listings) {
        if (l.id != key.id) continue;
        final provider = await directory.provider(l.providerId);
        return BidSubject(
          id: l.id,
          kind: BidKind.sale,
          title: l.title,
          byline: provider?.name ?? '',
          referenceSoles: parseReferenceSoles(l.reference),
          referenceText: l.reference,
        );
      }
      return null;
    case BidKind.request:
      for (final e in demoWall) {
        if (e.id != key.id || !e.isRequest) continue;
        return BidSubject(
          id: e.id,
          kind: BidKind.request,
          title: e.text,
          byline: e.author,
        );
      }
      return null;
  }
});
