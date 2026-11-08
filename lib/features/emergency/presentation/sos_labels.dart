import '../../../app/l10n.dart';
import '../domain/emergency.dart';

/// Textos traducidos de la emergencia (el dominio solo guarda identificadores).
String sosLabel(AppLocalizations l, SosSituation s) => switch (s) {
  SosSituation.earthquake => l.sitEarthquake,
  SosSituation.fire => l.sitFire,
  SosSituation.medical => l.sitMedical,
  SosSituation.elderly => l.sitElderly,
  SosSituation.violence => l.sitViolence,
};

/// Texto que se prellena para que enviar el aviso sea un solo toque.
String sosTemplate(AppLocalizations l, SosSituation s) => switch (s) {
  SosSituation.earthquake => l.tplEarthquake,
  SosSituation.fire => l.tplFire,
  SosSituation.medical => l.tplMedical,
  SosSituation.elderly => l.tplElderly,
  SosSituation.violence => l.tplViolence,
};

String officialName(AppLocalizations l, String id) => switch (id) {
  'police' => l.offPolice,
  'fire' => l.offFire,
  'samu' => l.offSamu,
  'civil' => l.offCivil,
  _ => l.offLine100,
};

String officialUse(AppLocalizations l, String id) => switch (id) {
  'police' => l.offPoliceUse,
  'fire' => l.offFireUse,
  'samu' => l.offSamuUse,
  'civil' => l.offCivilUse,
  _ => l.offLine100Use,
};

String capabilityLabel(AppLocalizations l, String id) => switch (id) {
  'firstAid' => l.capFirstAid,
  'medkit' => l.capMedkit,
  'vehicle' => l.capVehicle,
  'tools' => l.capTools,
  'supplies' => l.capSupplies,
  _ => l.capCare,
};
