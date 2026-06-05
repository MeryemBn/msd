import '../../../../l10n/app_localizations.dart';

enum RequestStatus {
  pending,
  awaiting_payment,
  confirmed,
  on_the_way,
  in_progress,
  completed,
  cancelled,
  rejected;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case RequestStatus.pending: return l10n.statusPending;
      case RequestStatus.awaiting_payment: return "En attente de paiement";
      case RequestStatus.confirmed: return l10n.statusConfirmed;
      case RequestStatus.on_the_way: return l10n.statusOnTheWay;
      case RequestStatus.in_progress: return l10n.statusInProgress;
      case RequestStatus.completed: return l10n.statusCompleted;
      case RequestStatus.cancelled: return l10n.statusCancelled;
      case RequestStatus.rejected: return l10n.statusRejected;
    }
  }

  String toJson() => name.toUpperCase();
}

enum PaymentMethod {
  cash,
  card;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.cash: return l10n.paymentCash;
      case PaymentMethod.card: return l10n.paymentCard;
    }
  }

  String getDescription(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.cash: return l10n.paymentCashDesc;
      case PaymentMethod.card: return l10n.paymentCardDesc;
    }
  }

  String toJson() => this == PaymentMethod.cash ? "CASH" : "BANK_CARD";
}

enum InterventionType {
  sos_urgency,
  appointment;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case InterventionType.sos_urgency: return l10n.sosUrgency;
      case InterventionType.appointment: return l10n.appointment;
    }
  }

  String getDescription(AppLocalizations l10n) {
    switch (this) {
      case InterventionType.sos_urgency: return l10n.sosUrgencyDesc;
      case InterventionType.appointment: return l10n.appointmentDesc;
    }
  }

  String toJson() => name.toUpperCase();
}

enum Specialty {
  medecineGenerale,
  cardiologie,
  dermatologie,
  pediatrie,
  gynecologie,
  ophtalmologie,
  orl,
  neurologie,
  psychiatrie,
  rhumatologie,
  gastroEnterologie,
  pneumologie,
  urologie,
  endocrinologie,
  orthopedie,
  soinsADomicile;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case Specialty.medecineGenerale: return l10n.specGeneral;
      case Specialty.cardiologie: return l10n.specCardio;
      case Specialty.dermatologie: return l10n.specDerma;
      case Specialty.pediatrie: return l10n.specPediatry;
      case Specialty.gynecologie: return l10n.specGyneco;
      case Specialty.ophtalmologie: return l10n.specOphtalmo;
      case Specialty.orl: return l10n.specOrl;
      case Specialty.neurologie: return l10n.specNeuro;
      case Specialty.psychiatrie: return l10n.specPsychiatry;
      case Specialty.rhumatologie: return l10n.specRhumato;
      case Specialty.gastroEnterologie: return l10n.specGastro;
      case Specialty.pneumologie: return l10n.specPneumo;
      case Specialty.urologie: return l10n.specUro;
      case Specialty.endocrinologie: return l10n.specEndocri;
      case Specialty.orthopedie: return l10n.specOrtho;
      case Specialty.soinsADomicile: return l10n.homeCare;
    }
  }

  String toJson() {
    if (this == Specialty.medecineGenerale) return "MEDECINE_GENERALE";
    if (this == Specialty.gastroEnterologie) return "GASTRO_ENTEROLOGIE";
    return name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)}').toUpperCase();
  }
}

enum AmbulanceType {
  medicalisee_smur,
  reanimation,
  sanitaire,
  vsl;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case AmbulanceType.medicalisee_smur: return l10n.ambSmur;
      case AmbulanceType.reanimation: return l10n.ambRea;
      case AmbulanceType.sanitaire: return l10n.ambSanitary;
      case AmbulanceType.vsl: return l10n.ambVsl;
    }
  }

  String toJson() {
    switch (this) {
      case AmbulanceType.medicalisee_smur: return "AMBULANCE_MEDICALISEE_SMUR";
      case AmbulanceType.reanimation: return "AMBULANCE_REANIMATION";
      case AmbulanceType.sanitaire: return "AMBULANCE_SANITAIRE";
      case AmbulanceType.vsl: return "VSL";
    }
  }
}
