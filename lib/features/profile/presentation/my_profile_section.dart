import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/sheet.dart';
import '../domain/profile.dart';
import 'address_sheet.dart';
import 'profile_form.dart';

/// "Mi perfil" y "Mis direcciones": usuario, correo y los lugares que la persona marcó.
class MyProfileSection extends ConsumerWidget {
  const MyProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final profile = ref.watch(profileStreamProvider).value;
    final addresses = ref.watch(addressesStreamProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(l.profTitle),
        const SizedBox(height: 12),
        profile == null
            ? BvPanel(
                child: BvEmptyState(
                  title: l.profNone,
                  message: l.profNoneHint,
                  action: FilledButton.icon(
                    onPressed: () => context.push('/bienvenida'),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(l.profCreate),
                  ),
                ),
              )
            : _ProfileCard(profile: profile),
        const SizedBox(height: 28),
        BvSectionTitle(
          l.addrTitle,
          subtitle: l.addrSubtitle,
          trailing: TextButton.icon(
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
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BvPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BvAvatar(profile.username, size: 56, tone: BvTone.trust),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.username, style: context.tt.titleMedium),
                    if (profile.email != null)
                      Text(
                        profile.email!,
                        style: context.tt.bodySmall?.copyWith(
                          color: context.tones.muted,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l.profEdit,
                onPressed: () => showBvSheet<void>(
                  context,
                  builder: (_) => _EditProfileSheet(profile: profile),
                ),
                icon: const Icon(Icons.edit_rounded),
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.profLocalNote,
            style: context.tt.bodySmall?.copyWith(color: context.tones.muted),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BvIconBadge(
            Icons.place_rounded,
            tone: a.isActive ? BvTone.trust : BvTone.violet,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(a.name, style: context.tt.titleSmall)),
                    if (a.isActive) ...[
                      const SizedBox(width: 8),
                      BvPill(
                        l.addrActive,
                        icon: Icons.check_rounded,
                        tone: BvTone.trust,
                      ),
                    ],
                  ],
                ),
                Text(
                  l.zonaAprox1Km(
                    a.zone.lat.toStringAsFixed(2),
                    a.zone.lng.toStringAsFixed(2),
                  ),
                  style: context.tt.bodySmall?.copyWith(
                    color: context.tones.muted,
                  ),
                ),
                if (a.reference.isNotEmpty)
                  Text(a.reference, style: context.tt.bodySmall),
                const SizedBox(height: 4),
                Wrap(
                  children: [
                    if (!a.isActive)
                      TextButton(
                        onPressed: () =>
                            ref.read(profileRepositoryProvider).setActive(a.id),
                        child: Text(l.addrUse),
                      ),
                    TextButton(
                      onPressed: () => _delete(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: context.tones.emergency,
                      ),
                      child: Text(l.addrDelete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
