import '../../../core/result.dart';
import 'interaction.dart';

abstract interface class ReputationRepository {
  Future<Result<void>> record(Interaction interaction);

  Future<List<Interaction>> forProvider(String providerId);

  Stream<List<Interaction>> watchAll();
}
