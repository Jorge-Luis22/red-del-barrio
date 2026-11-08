import '../../directory/infrastructure/demo_seed.dart';
import '../../needs/domain/need.dart';
import '../domain/proposal.dart';
import '../domain/proposal_repository.dart';

/// Propuestas de DEMOSTRACIÓN (todas con `isExample: true`).
/// En mobile-mejoras se reemplaza por propuestas reales de vecinos (Supabase + Realtime).
class DemoProposalRepository implements ProposalRepository {
  const DemoProposalRepository();

  @override
  Future<List<Proposal>> forNeed(Need need) async =>
      demoProposals[need.kind] ?? const [];
}
