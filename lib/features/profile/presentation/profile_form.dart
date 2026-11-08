import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/failure_text.dart';
import '../../../core/result.dart';
import '../domain/profile.dart';

/// Usuario, correo opcional y (al crear) el consentimiento. Guarda y avisa con [onSaved].
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({
    super.key,
    required this.actionLabel,
    required this.onSaved,
    this.initial,
    this.askConsent = true,
  });

  final UserProfile? initial;
  final String actionLabel;
  final bool askConsent;
  final VoidCallback onSaved;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  late final _username = TextEditingController(text: widget.initial?.username);
  late final _email = TextEditingController(text: widget.initial?.email);
  late bool _consent = !widget.askConsent;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(saveProfileProvider)(
      username: _username.text,
      email: _email.text,
      current: widget.initial,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        widget.onSaved();
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
    final canSave = !_busy && _username.text.trim().length >= 3 && _consent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _username,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l.profUsername,
            helperText: l.profUsernameHelp,
            helperMaxLines: 2,
            errorText: _error,
            errorMaxLines: 3,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: l.profEmail,
            helperText: l.profEmailHelp,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
          ),
        ),
        if (widget.askConsent) ...[
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            title: Text(l.profConsent, style: context.tt.bodySmall),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canSave ? _save : null,
            icon: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(widget.actionLabel),
          ),
        ),
      ],
    );
  }
}
