import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../needs/domain/need.dart';
import '../../reputation/domain/calculate_reputation.dart';
import '../../reputation/domain/interaction.dart';
import '../../reputation/domain/visto_bueno.dart';
import '../domain/deal.dart';
import '../domain/proposal.dart';

final needByIdProvider = Provider.family<Need?, String>((ref, id) {
  final list = ref.watch(needsStreamProvider).value ?? const <Need>[];
  for (final n in list) {
    if (n.id == id) return n;
  }
  return null;
});

final dealByNeedProvider = Provider.family<Deal?, String>((ref, needId) {
  final list = ref.watch(dealsStreamProvider).value ?? const <Deal>[];
  for (final d in list) {
    if (d.needId == needId) return d;
  }
  return null;
});

/// Propuesta + reputación y Visto Bueno del proveedor.
class ProposalView {
  const ProposalView(this.proposal, this.reputation, this.vistoBueno);

  final Proposal proposal;
  final ReputationSnapshot reputation;
  final VistoBueno vistoBueno;
}

final proposalViewsProvider = FutureProvider.family<List<ProposalView>, String>((ref, needId) async {
  final need = ref.watch(needByIdProvider(needId));
  if (need == null) return const [];
  ref.watch(interactionsStreamProvider);
  final proposals = await ref.watch(listProposalsProvider)(need);
  final directory = ref.watch(directoryRepositoryProvider);
  final reputation = ref.watch(reputationRepositoryProvider);
  final out = <ProposalView>[];
  for (final p in proposals) {
    final profile = await directory.provider(p.providerId);
    if (profile == null) continue;
    final interactions = await reputation.forProvider(p.providerId);
    out.add(ProposalView(
      p,
      calculateReputation(profile, interactions),
      calculateVistoBueno(exampleCount: profile.exampleVistoBueno, interactions: interactions),
    ));
  }
  return out;
});

/// Resumen del trato cerrado: reputación antes → después de TU calificación.
class ClosedSummary {
  const ClosedSummary({
    required this.before,
    required this.after,
    required this.vistoBueno,
    required this.interaction,
  });

  final ReputationSnapshot before;
  final ReputationSnapshot after;
  final VistoBueno vistoBueno;
  final Interaction interaction;
}

final closedSummaryProvider = FutureProvider.family<ClosedSummary?, ({String dealId, String providerId})>((ref, key) async {
  final profile = await ref.watch(directoryRepositoryProvider).provider(key.providerId);
  if (profile == null) return null;
  final all = await ref.watch(reputationRepositoryProvider).forProvider(key.providerId);
  final mine = all.where((i) => i.dealId == key.dealId).toList();
  if (mine.isEmpty) return null;
  final others = all.where((i) => i.dealId != key.dealId).toList();
  return ClosedSummary(
    before: calculateReputation(profile, others),
    after: calculateReputation(profile, all),
    vistoBueno: calculateVistoBueno(exampleCount: profile.exampleVistoBueno, interactions: all),
    interaction: mine.first,
  );
});
