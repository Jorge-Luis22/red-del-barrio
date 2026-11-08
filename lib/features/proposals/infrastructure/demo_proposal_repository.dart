import '../../assistant/domain/request_assistant.dart';
import '../../directory/infrastructure/demo_seed.dart';
import '../../needs/domain/need.dart';
import '../domain/proposal.dart';
import '../domain/proposal_repository.dart';

/// Propuestas de DEMOSTRACIÓN (todas con `isExample: true`).
/// Para un servicio se muestran vecinos del oficio que se nombró en el pedido
/// (carpintería → carpinteros). Si no se reconoce ningún oficio, no se inventan propuestas.
/// En mobile-mejoras se reemplaza por propuestas reales de vecinos (Supabase + Realtime).
class DemoProposalRepository implements ProposalRepository {
  const DemoProposalRepository();

  static const _assistant = RequestAssistant();

  @override
  Future<List<Proposal>> forNeed(Need need) async {
    if (need.kind == NeedKind.service) {
      final trade = _assistant.detectTrade(need.text);
      if (trade == null) return const [];
      return demoServiceProposalsByTrade[trade] ?? const [];
    }
    return demoProposals[need.kind] ?? const [];
  }
}
