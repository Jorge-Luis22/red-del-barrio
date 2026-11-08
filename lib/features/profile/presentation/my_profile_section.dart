import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../../assistant/presentation/tr.dart';
import '../domain/profile.dart';
import 'address_sheet.dart';
import 'profile_form.dart';

/// Cabecera de Perfil: quién es el vecino, su zona activa y el aviso de perfil local.
/// Va sobre el color de la sección (el mismo verde confianza de la barra).
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final profile = ref.watch(profileStreamProvider).value;
    final addresses = ref.watch(addressesStreamProvider).value ?? const [];
    final active = addresses.where((a) => a.isActive).firstOrNull;
    final fg = context.cs.onTertiary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 20,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: context.tones.trust,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PhotoAvatar(profile: profile),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          profile?.username ?? l.perfil,
                          maxLines: 1,
                          style: context.tt.headlineMedium?.copyWith(color: fg),
                        ),
                      ),
                    ),
                    if (profile?.email != null)
                      Text(
                        profile!.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.tt.bodyMedium?.copyWith(
                          color: fg.withValues(alpha: 0.92),
                        ),
                      ),
                  ],
                ),
              ),
              if (profile != null)
                IconButton.filled(
                  tooltip: l.profEdit,
                  onPressed: () => showEditProfileSheet(context, profile),
                  icon: const Icon(Icons.edit_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: fg.withValues(alpha: 0.18),
                    foregroundColor: fg,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (profile == null)
            FilledButton.icon(
              onPressed: () => context.push('/bienvenida'),
              style: FilledButton.styleFrom(
                backgroundColor: BarrioPalette.white,
                foregroundColor: context.tones.trustText,
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(l.profCreate),
            )
          else ...[
            _HeaderChip(
              icon: Icons.place_rounded,
              text: active == null
                  ? l.addrEmpty
                  : '${active.name} · ${tr(context, 'zona aprox. 1 km', 'approx. 1 km zone')}',
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  size: 18,
                  color: fg.withValues(alpha: 0.92),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr(
                      context,
                      'Perfil guardado solo en este teléfono. No sirve para entrar desde otro celular.',
                      'Profile saved only on this phone. It does not work to sign in from another phone.',
                    ),
                    style: context.tt.bodySmall?.copyWith(
                      color: fg.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar con la foto de la persona (o su inicial). Al tocarlo se puede cambiar la foto.
class _PhotoAvatar extends ConsumerWidget {
  const _PhotoAvatar({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = profile;
    final path = p?.photoPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file != null && file.existsSync();
    const size = 72.0;
    return Semantics(
      button: p != null,
      label: tr(context, 'Cambiar mi foto', 'Change my photo'),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: p == null ? null : () => _choosePhoto(context, ref, p, hasPhoto),
        child: SizedBox(
          width: size + 8,
          height: size + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: BarrioPalette.white,
                  shape: BoxShape.circle,
                ),
                child: hasPhoto
                    ? CircleAvatar(
                        radius: size / 2,
                        backgroundImage: FileImage(file),
                      )
                    : BvAvatar(
                        p?.username ?? '?',
                        size: size,
                        tone: BvTone.violet,
                      ),
              ),
              if (p != null)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: BarrioPalette.white, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 16,
                      color: context.cs.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _choosePhoto(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile,
  bool hasPhoto,
) async {
  final choice = await showBvSheet<String>(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              tr(context, 'Mi foto', 'My photo'),
              style: context.tt.headlineSmall,
            ),
          ),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.photo_camera_rounded),
            title: Text(tr(context, 'Tomar una foto', 'Take a photo')),
            onTap: () => Navigator.pop(ctx, 'camera'),
          ),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.photo_library_rounded),
            title: Text(
              tr(context, 'Elegir de la galería', 'Choose from gallery'),
            ),
            onTap: () => Navigator.pop(ctx, 'gallery'),
          ),
          if (hasPhoto)
            ListTile(
              minTileHeight: 56,
              leading: Icon(
                Icons.delete_outline_rounded,
                color: context.tones.emergency,
              ),
              title: Text(tr(context, 'Quitar mi foto', 'Remove my photo')),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
        ],
      ),
    ),
  );
  if (choice == null) return;
  final repo = ref.read(profileRepositoryProvider);
  if (choice == 'remove') {
    await repo.saveProfile(profile.withPhoto(null));
    return;
  }
  try {
    final picked = await ImagePicker().pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/foto_perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(picked.path).copy(dest.path);
    await repo.saveProfile(profile.withPhoto(dest.path));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              'No pudimos usar esa foto. Prueba con otra.',
              'We could not use that photo. Try another one.',
            ),
          ),
        ),
      );
    }
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final fg = context.cs.onTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: context.tt.labelMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mi zona": las direcciones que la persona marcó. Solo se guarda una zona aproximada.
class MyZoneSection extends ConsumerWidget {
  const MyZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final addresses = ref.watch(addressesStreamProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(
          tr(context, 'Mi zona', 'My zone'),
          subtitle: l.addrSubtitle,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final done = l.addrSaved;
              if (await showAddressSheet(context)) {
                messenger.showSnackBar(SnackBar(content: Text(done)));
              }
            },
            icon: const Icon(Icons.add_location_alt_rounded),
            label: Text(l.addrAdd),
          ),
        ),
        const SizedBox(height: 12),
        if (addresses.isEmpty)
          BvBanner(
            icon: Icons.place_outlined,
            tone: BvTone.violet,
            title: l.addrEmpty,
            message: l.addrEmptyHint,
          )
        else
          BvRows(
            children: [for (final a in addresses) _AddressRow(address: a)],
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: context.tones.muted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                tr(
                  context,
                  'Tu ubicación exacta no se muestra: los vecinos solo ven una zona de unos 1 km.',
                  'Your exact location is never shown: neighbors only see a zone of about 1 km.',
                ),
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showEditProfileSheet(BuildContext context, UserProfile profile) =>
    showBvSheet<void>(
      context,
      builder: (_) => _EditProfileSheet(profile: profile),
    );

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.profEdit, style: context.tt.headlineSmall),
            const SizedBox(height: 16),
            ProfileForm(
              initial: profile,
              askConsent: false,
              actionLabel: l.profSave,
              onSaved: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.profSaved)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends ConsumerWidget {
  const _AddressRow({required this.address});

  final SavedAddress address;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addrDeleteTitle(address.name)),
        content: Text(l.addrDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.tones.emergency,
              foregroundColor: context.cs.onError,
            ),
            child: Text(l.addrDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(profileRepositoryProvider).deleteAddress(address.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.addrDeleted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final a = address;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
      child: Row(
        children: [
          BvIconBadge(
            Icons.place_rounded,
            tone: a.isActive ? BvTone.trust : BvTone.violet,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(a.name, style: context.tt.titleSmall),
                    if (a.isActive)
                      BvPill(
                        l.addrActive,
                        icon: Icons.check_rounded,
                        tone: BvTone.trust,
                      ),
                  ],
                ),
                Text(
                  a.reference.isNotEmpty
                      ? a.reference
                      : tr(
                          context,
                          'Zona aproximada · 1 km',
                          'Approx. zone · 1 km',
                        ),
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
              ],
            ),
          ),
          if (!a.isActive)
            TextButton(
              onPressed: () =>
                  ref.read(profileRepositoryProvider).setActive(a.id),
              child: Text(l.addrUse),
            ),
          IconButton(
            tooltip: l.addrDelete,
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline_rounded),
            color: context.tones.emergency,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ],
      ),
    );
  }
}
