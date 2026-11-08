import 'package:flutter/material.dart';

import '../../../app/ui/components.dart';
import '../domain/offer.dart';

class ModalityLabels {
  ModalityLabels._();

  static String name(Modality m) => switch (m) {
    Modality.free => 'Gratis',
    Modality.barter => 'Trueque',
    Modality.rent => 'Alquiler',
  };

  static String hint(Modality m) => switch (m) {
    Modality.free => 'Sin costo: un favor entre vecinos.',
    Modality.barter => 'Cambias una cosa o un favor por otro.',
    Modality.rent => 'Lo prestas a cambio de un pago acordado entre ustedes.',
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
