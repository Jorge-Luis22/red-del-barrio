import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/ui/components.dart';
import '../domain/offer.dart';

class ModalityLabels {
  ModalityLabels._();

  static String name(AppLocalizations l, Modality m) => switch (m) {
    Modality.free => l.modFree,
    Modality.barter => l.modBarter,
    Modality.rent => l.modRent,
  };

  static String hint(AppLocalizations l, Modality m) => switch (m) {
    Modality.free => l.modFreeHint,
    Modality.barter => l.modBarterHint,
    Modality.rent => l.modRentHint,
  };

  static IconData icon(Modality m) => switch (m) {
    Modality.free => Icons.volunteer_activism_rounded,
    Modality.barter => Icons.swap_horiz_rounded,
    Modality.rent => Icons.payments_rounded,
  };

  static BvTone tone(Modality m) => switch (m) {
    Modality.free => BvTone.trust,
    Modality.barter => BvTone.violet,
    Modality.rent => BvTone.sun,
  };
}
