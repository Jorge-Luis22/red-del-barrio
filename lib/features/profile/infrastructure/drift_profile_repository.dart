import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/result.dart';
import '../../../core/storage_guard.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db);

  final AppDatabase _db;

  static const _id = 'me';

  @override
  Stream<UserProfile?> watchProfile() => _db
      .select(_db.personProfile)
      .watchSingleOrNull()
      .map(
        (r) => r == null
            ? null
            : UserProfile(
                username: r.username,
                email: r.email,
                createdAt: r.createdAt,
              ),
      );

  @override
  Future<Result<void>> saveProfile(UserProfile p) =>
      guardStorage('No se pudo guardar tu perfil.', () async {
        await _db
            .into(_db.personProfile)
            .insertOnConflictUpdate(
              PersonProfileCompanion.insert(
                id: _id,
                username: p.username,
                email: Value(p.email),
                createdAt: p.createdAt,
              ),
            );
      });

  @override
  Stream<List<SavedAddress>> watchAddresses() {
    final q = _db.select(_db.personAddresses)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<SavedAddress>> addresses() async {
    final q = _db.select(_db.personAddresses)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return (await q.get()).map(_toDomain).toList();
  }

  @override
  Future<Result<void>> saveAddress(SavedAddress a) =>
      guardStorage('No se pudo guardar la dirección.', () async {
        await _db.transaction(() async {
          if (a.isActive) await _deactivateAll();
          await _db
              .into(_db.personAddresses)
              .insertOnConflictUpdate(
                PersonAddressesCompanion.insert(
                  id: a.id,
                  name: a.name,
                  reference: Value(a.reference),
                  lat: a.lat,
                  lng: a.lng,
                  createdAt: a.createdAt,
                  isActive: Value(a.isActive),
                ),
              );
        });
      });

  @override
  Future<Result<void>> setActive(String id) =>
      guardStorage('No se pudo actualizar la dirección.', () async {
        await _db.transaction(() async {
          await _deactivateAll();
          await (_db.update(_db.personAddresses)..where((t) => t.id.equals(id)))
              .write(const PersonAddressesCompanion(isActive: Value(true)));
        });
      });

  @override
  Future<Result<void>> deleteAddress(String id) =>
      guardStorage('No se pudo actualizar la dirección.', () async {
        await _db.transaction(() async {
          final all = await addresses();
          final wasActive = all.any((a) => a.id == id && a.isActive);
          await (_db.delete(
            _db.personAddresses,
          )..where((t) => t.id.equals(id))).go();
          if (!wasActive) return;
          final rest = all.where((a) => a.id != id).toList();
          if (rest.isEmpty) return;
          await (_db.update(_db.personAddresses)
                ..where((t) => t.id.equals(rest.first.id)))
              .write(const PersonAddressesCompanion(isActive: Value(true)));
        });
      });

  Future<void> _deactivateAll() => _db
      .update(_db.personAddresses)
      .write(const PersonAddressesCompanion(isActive: Value(false)));

  SavedAddress _toDomain(AddressRow r) => SavedAddress(
    id: r.id,
    name: r.name,
    reference: r.reference,
    lat: r.lat,
    lng: r.lng,
    createdAt: r.createdAt,
    isActive: r.isActive,
  );
}
