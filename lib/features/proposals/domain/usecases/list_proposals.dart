import '../../../needs/domain/need.dart';
import '../proposal.dart';
import '../proposal_repository.dart';

/// Solo una necesidad ya ENVIADA recibe propuestas.
/// Mientras esté Pendiente (sin conexión) no hay propuestas: nunca se finge lo contrario.
class ListProposals {
  ListProposals(this.repository);

  final ProposalRepository repository;

  Future<List<Proposal>> call(Need need) async {
    if (need.syncStatus != SyncStatus.sent) return const [];
    return repository.forNeed(need);
  }
}
