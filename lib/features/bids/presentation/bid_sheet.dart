import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/l10n.dart';
import '../../../app/ui/failure_text.dart';
import '../../../app/ui/sheet.dart';
import '../../../core/result.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/bid.dart';

/// "Mi oferta" / "Mi propuesta": precio, mensaje y cuándo puede. Devuelve `true` si se guardó.
Future<bool> showBidSheet(
  BuildContext context, {
  required BidSubject subject,
  Bid? existing,
}) async =>
    await showBvSheet<bool>(
      context,
      builder: (_) => _BidSheet(subject: subject, existing: existing),
    ) ??
    false;

class _BidSheet extends ConsumerStatefulWidget {
  const _BidSheet({required this.subject, this.existing});

  final BidSubject subject;
  final Bid? existing;

  @override
  ConsumerState<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends ConsumerState<_BidSheet> {
  late final _price = TextEditingController(
    text: widget.existing?.amountSoles.toString(),
  );
  late final _message = TextEditingController(text: widget.existing?.message);
  late final _when = TextEditingController(text: widget.existing?.whenText);
  String? _error;
  bool _busy = false;

  bool get _isSale => widget.subject.kind == BidKind.sale;

  @override
  void dispose() {
    _price.dispose();
    _message.dispose();
    _when.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final profile = ref.read(profileStreamProvider).value;
    final r = await ref.read(placeBidProvider)(
      subject: widget.subject,
      bidder: profile?.username ?? '',
      amountText: _price.text,
      message: _message.text,
      whenText: _when.text,
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        confirmHaptic(enabled: ref.read(appSettingsProvider).vibration);
        ref.read(syncControllerProvider.notifier).flushNow();
        Navigator.of(context).pop(true);
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
      title: _isSale ? l.bidMyOffer : l.bidMyProposal,
      subtitle: widget.subject.title,
      actionLabel: _isSale ? l.bidSendOffer : l.bidSendProposal,
      actionIcon: Icons.gavel_rounded,
      busy: _busy,
      onAction: _price.text.trim().isEmpty ? null : _send,
      disabledHint: l.bidHint,
      children: [
        TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 5,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: _isSale ? l.bidPriceOfferLabel : l.bidPriceLabel,
            prefixText: 'S/ ',
            errorText: _error,
            errorMaxLines: 2,
            counterText: '',
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _message,
          minLines: 2,
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l.bidMessageLabel,
            hintText: l.bidMessageHint,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _when,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l.bidWhenLabel,
            hintText: l.bidWhenHint,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
