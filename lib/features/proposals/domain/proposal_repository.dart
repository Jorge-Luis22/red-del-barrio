import '../../needs/domain/need.dart';
import 'proposal.dart';

/// Propuestas recibidas para una necesidad.
/// Local (mobile-ux): propuestas de ejemplo. Remoto (mobile-mejoras): Supabase + Realtime.
abstract interface class ProposalRepository {
  Future<List<Proposal>> forNeed(Need need);
}
