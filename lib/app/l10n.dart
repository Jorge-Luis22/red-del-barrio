import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

/// Acceso corto a los textos traducidos: `context.l.pedirAlgo`.
extension L10nContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}
