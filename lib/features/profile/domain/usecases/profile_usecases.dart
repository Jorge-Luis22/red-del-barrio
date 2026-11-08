import '../../../../core/clock.dart';
import '../../../../core/failure.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../location/domain/zone.dart';
import '../profile.dart';
import '../profile_repository.dart';

final _usernameRule = RegExp(r'^[\p{L}0-9_.]{3,20}$', unicode: true);
final _emailRule = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Crea o actualiza el perfil. Usuario obligatorio; correo opcional y sin verificar.
class SaveProfile {
  SaveProfile({required this.profiles, required this.clock});

  final ProfileRepository profiles;
  final Clock clock;

  static const badUsername =
      'El usuario debe tener de 3 a 20 letras, números, punto o guion bajo.';
  static const badEmail = 'Escribe un correo válido o déjalo vacío.';

  Future<Result<UserProfile>> call({
    required String username,
    String? email,
    UserProfile? current,
  }) async {
    final name = username.trim();
    if (!_usernameRule.hasMatch(name)) {
      return const Err(ValidationFailure(badUsername));
    }
    final mail = email?.trim() ?? '';
    if (mail.isNotEmpty && !_emailRule.hasMatch(mail)) {
      return const Err(ValidationFailure(badEmail));
    }
    final profile = UserProfile(
      username: name,
      email: mail.isEmpty ? null : mail,
      createdAt: current?.createdAt ?? clock.now(),
    );
    final saved = await profiles.saveProfile(profile);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(profile);
  }
}

/// Guarda una dirección marcada con el GPS. La primera que se guarda queda activa.
class AddAddress {
  AddAddress({required this.profiles, required this.clock, required this.ids});

  final ProfileRepository profiles;
  final Clock clock;
  final IdGenerator ids;

  static const noName = 'Ponle un nombre a la dirección.';
  static const noLocation = 'Primero marca tu ubicación.';

  Future<Result<SavedAddress>> call({
    required String name,
    required ExactLocation? location,
    String reference = '',
  }) async {
    final clean = name.trim();
    if (clean.length < 2) return const Err(ValidationFailure(noName));
    if (location == null) return const Err(ValidationFailure(noLocation));
    final isFirst = (await profiles.addresses()).isEmpty;
    final address = SavedAddress(
      id: ids.newUuid(),
      name: clean,
      reference: reference.trim(),
      lat: location.lat,
      lng: location.lng,
      createdAt: clock.now(),
      isActive: isFirst,
    );
    final saved = await profiles.saveAddress(address);
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(address);
  }
}
