import '../../../core/result.dart';
import 'profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile?> watchProfile();

  Future<Result<void>> saveProfile(UserProfile profile);

  Stream<List<SavedAddress>> watchAddresses();

  Future<List<SavedAddress>> addresses();

  /// Guarda la dirección. Si viene activa, deja inactivas a las demás.
  Future<Result<void>> saveAddress(SavedAddress address);

  Future<Result<void>> setActive(String id);

  /// Elimina la dirección. Si era la activa, pasa a ser activa la primera que quede.
  Future<Result<void>> deleteAddress(String id);
}
