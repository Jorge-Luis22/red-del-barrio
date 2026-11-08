import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../../app/ui/failure_text.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../domain/emergency.dart';

/// Contactos de confianza: se guardan en el teléfono y reciben el SMS de aviso.
class ContactsBlock extends ConsumerWidget {
  const ContactsBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final contacts = ref.watch(contactsStreamProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BvSectionTitle(
          l.contactsTitle,
          subtitle: l.contactsHint,
          trailing: contacts.length >= maxTrustedContacts
              ? null
              : TextButton.icon(
                  onPressed: () => showBvSheet<void>(
                    context,
                    builder: (_) => const _ContactSheet(),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(l.contactAdd),
                ),
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          BvBanner(
            icon: Icons.contacts_outlined,
            tone: BvTone.violet,
            message: l.contactsEmpty,
          )
        else
          BvRows(children: [for (final c in contacts) _ContactRow(contact: c)]),
      ],
    );
  }
}

class _ContactRow extends ConsumerWidget {
  const _ContactRow({required this.contact});

  final TrustedContact contact;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.contactDeleteTitle(contact.name)),
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
    await ref.read(emergencyRepositoryProvider).deleteContact(contact.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.contactDeleted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    child: Row(
      children: [
        BvAvatar(contact.name, tone: BvTone.coral),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: context.tt.titleSmall),
              Text(
                contact.phone,
                style: context.tt.bodySmall?.copyWith(
                  color: context.tones.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l.addrDelete,
          onPressed: () => _delete(context, ref),
          icon: Icon(
            Icons.delete_outline_rounded,
            color: context.tones.emergency,
          ),
        ),
      ],
    ),
  );
}

class _ContactSheet extends ConsumerStatefulWidget {
  const _ContactSheet();

  @override
  ConsumerState<_ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends ConsumerState<_ContactSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(addContactProvider)(
      name: _name.text,
      phone: _phone.text,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        Navigator.of(context).pop();
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failureText(context.l, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BvSheetScaffold(
      title: l.contactAdd,
      subtitle: l.contactsHint,
      actionLabel: l.contactSave,
      actionIcon: Icons.person_add_alt_1_rounded,
      busy: _busy,
      onAction:
          (_name.text.trim().length >= 2 && _phone.text.trim().length >= 7)
          ? _save
          : null,
      disabledHint: l.hintContact,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l.contactName,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: InputDecoration(
            labelText: l.contactPhone,
            helperText: l.contactPhoneHelp,
            helperMaxLines: 2,
            errorText: _error,
            errorMaxLines: 2,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
      ],
    );
  }
}
