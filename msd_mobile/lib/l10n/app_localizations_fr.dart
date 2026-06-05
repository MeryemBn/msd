// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get personalInfo => 'INFORMATIONS PERSONNELLES';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phone => 'Téléphone';

  @override
  String get call => 'Appeler';

  @override
  String get email => 'Email';

  @override
  String get address => 'Adresse';

  @override
  String get medicalInfo => 'INFORMATIONS MÉDICALES';

  @override
  String get bloodType => 'Groupe sanguin';

  @override
  String get allergies => 'Allergies';

  @override
  String get history => 'Antécédents';

  @override
  String get insurance => 'Assurance';

  @override
  String get settings => 'PARAMÈTRES';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get msdTagline => 'Votre santé, à portée de main';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get usernameHint => 'ex: sarah.martin';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get login => 'Se connecter';

  @override
  String get orDivider => 'OU';

  @override
  String get noAccount => 'Pas encore de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer votre compte';

  @override
  String get registerSubtitle =>
      'Veuillez remplir les informations ci-dessous pour commencer votre inscription.';

  @override
  String get firstName => 'Prénom';

  @override
  String get firstNameHint => 'ex: Sarah';

  @override
  String get lastName => 'Nom';

  @override
  String get lastNameHint => 'ex: Martin';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get passwordMinChars => 'Min. 8 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Confirmez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get splashSubtitle =>
      'Connectez-vous instantanément avec des professionnels de santé qualifiés';

  @override
  String get getStarted => 'Commencer';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre adresse email pour recevoir un lien de réinitialisation.';

  @override
  String get sendLink => 'Envoyer le lien';

  @override
  String get emailSentTitle => 'Email envoyé !';

  @override
  String emailSentSubtitle(String email) {
    return 'Si un compte existe pour $email, un email de récupération a été envoyé.';
  }

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get verifyEmailTitle => 'Vérifiez votre email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Un lien de confirmation a été envoyé à $email. Veuillez cliquer dessus pour activer votre compte.';
  }

  @override
  String get hello => 'Bonjour ';

  @override
  String get sosServices => 'SERVICES SOS';

  @override
  String get onDutyPharmacy => 'Pharmacie de garde';

  @override
  String get findNearest => 'Trouver la plus proche';

  @override
  String get allDosesDone => 'Parcours terminé !';

  @override
  String get allDosesDoneSubtitle =>
      'Toutes vos prises sont à jour pour aujourd\'hui. 👋';

  @override
  String get doseConfirmed => 'PRISE CONFIRMÉE';

  @override
  String get doseLate => 'PRISE EN RETARD';

  @override
  String get nextDose => 'PROCHAINE PRISE';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noNotificationsSubtitle =>
      'Vous n\'avez reçu aucun message pour le moment.';

  @override
  String get clearNotificationsTitle => 'Effacer les notifications';

  @override
  String get clearNotificationsMessage =>
      'Voulez-vous supprimer définitivement toutes vos notifications ? Cette action est irréversible.';

  @override
  String get planningTitle => 'Planning & Suivi';

  @override
  String get addMedication => 'Ajouter un médicament';

  @override
  String get details => 'Détails';

  @override
  String get period => 'Période';

  @override
  String get times => 'Horaires';

  @override
  String get reminders => 'Rappels';

  @override
  String get medicationName => 'Nom du médicament';

  @override
  String get medicationNameHint => 'Ex: Paracétamol';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'Ex: 500mg';

  @override
  String get instruction => 'Instruction';

  @override
  String get startDate => 'Date de début';

  @override
  String get duration => 'Durée du traitement (jours)';

  @override
  String get durationHint => 'Ex: 7';

  @override
  String get initialStock => 'Stock initial';

  @override
  String get stockHint => 'Ex: 30';

  @override
  String get intakeTimes => 'Heures de prise';

  @override
  String get addTimeHint => 'Cliquez sur + pour ajouter une heure';

  @override
  String get reminderIntensity => 'Intensité du rappel';

  @override
  String get notificationAlert => 'Notification';

  @override
  String get notificationSubtitle => 'Une alerte discrète';

  @override
  String get alarmAlert => 'Alarme';

  @override
  String get alarmSubtitle => 'Sonnerie persistante';

  @override
  String notifyBefore(int minutes) {
    return 'Notifier combien de minutes avant ? ($minutes min)';
  }

  @override
  String get snoozeInterval => 'Intervalle de répétition (Snooze)';

  @override
  String get finish => 'Terminer';

  @override
  String get next => 'Suivant';

  @override
  String get duringMeal => 'Pendant le repas';

  @override
  String get beforeMeal => 'Avant le repas';

  @override
  String get onEmptyStomach => 'À jeun';

  @override
  String get afterMeal => 'Après le repas';

  @override
  String get medicationNameRequired => 'Le nom du médicament est obligatoire';

  @override
  String get atLeastOneTimeRequired =>
      'Veuillez ajouter au moins un horaire de prise';

  @override
  String snooze(int minutes) {
    return 'Répéter ($minutes min)';
  }

  @override
  String get confirmTake => 'Confirmer la prise';

  @override
  String until(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String daysRemaining(int count) {
    return '$count j. restants';
  }

  @override
  String get finishesToday => 'Termine aujourd\'hui';

  @override
  String get criticalStock => 'Stock critique';

  @override
  String get lowStock => 'Stock faible';

  @override
  String unitsRemaining(int count) {
    return '$count unité(s) restante(s)';
  }

  @override
  String get morning => 'Matin';

  @override
  String get noon => 'Midi';

  @override
  String get evening => 'Soir';

  @override
  String get bedtime => 'Coucher';

  @override
  String actionFor(String name) {
    return 'Action pour $name';
  }

  @override
  String get tooEarly => 'Il est encore trop tôt pour cette prise';

  @override
  String get lateStatus => 'Prise en retard !';

  @override
  String get markAsTaken => 'Marquer comme pris';

  @override
  String get markAsMissed => 'Marquer comme raté';

  @override
  String get reschedule => 'Décaler l\'horaire';

  @override
  String get doctor => 'Médecin';

  @override
  String get teleconsultation => 'Téléconsultation';

  @override
  String get nurse => 'Infirmier';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get myMedications => 'Mes Médicaments';

  @override
  String get dayTimeline => 'Timeline du jour';

  @override
  String get calendarAndTracking => 'Calendrier & Suivi';

  @override
  String get noMedicationsToday => 'Aucun médicament pour aujourd\'hui';

  @override
  String get yourRequest => 'Votre demande';

  @override
  String get specifySpecialtyAndIntervention =>
      'Précisez la spécialité et le type d\'intervention';

  @override
  String get specialty => 'Spécialité';

  @override
  String get chooseSpecialty => 'Choisir une spécialité';

  @override
  String get interventionType => 'Type d\'intervention';

  @override
  String get sosUrgency => 'En Urgence (SOS)';

  @override
  String get sosUrgencyDesc => 'Professionnel disponible le plus proche';

  @override
  String get appointment => 'Sur Rendez-vous';

  @override
  String get appointmentDesc => 'Choisissez une date et une heure';

  @override
  String get continueText => 'Continuer';

  @override
  String get confirmRequest => 'Confirmer la demande';

  @override
  String get chooseInterventionType =>
      'Veuillez choisir un type d\'intervention';

  @override
  String get requestSent => 'Demande envoyée !';

  @override
  String get homeCare => 'Soins à domicile';

  @override
  String get specifyAmbulanceType =>
      'Précisez le type d\'ambulance et l\'intervention';

  @override
  String get ambulanceType => 'Type d\'ambulance';

  @override
  String get chooseAmbulanceType => 'Choisir un type d\'ambulance';

  @override
  String get interventionAddress => 'Adresse d\'intervention';

  @override
  String get specifyLocation => 'Précisez le lieu où l\'aide est attendue';

  @override
  String get exactAddress => 'Adresse exacte';

  @override
  String get addressHint => 'Rue, Quartier...';

  @override
  String get apartment => 'Appt / Maison';

  @override
  String get apartmentHint => 'Ex: Apt 4B';

  @override
  String get floor => 'Étage';

  @override
  String get floorHint => 'Ex: 2ème';

  @override
  String get entryCode => 'Code d\'entrée';

  @override
  String get entryCodeHint => 'Ex: A123';

  @override
  String gpsActivation(String error) {
    return 'Veuillez activer votre GPS : $error';
  }

  @override
  String get payment => 'Paiement';

  @override
  String get choosePaymentMethod => 'Choisissez votre mode de paiement';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get consultationFee => 'Tarif de la consultation';

  @override
  String get paymentCash => 'Espèces';

  @override
  String get paymentCashDesc => 'Payer sur place au professionnel';

  @override
  String get paymentCard => 'Carte Bancaire';

  @override
  String get paymentCardDesc => 'Pré-autorisation sécurisée';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusConfirmed => 'Confirmé';

  @override
  String get statusOnTheWay => 'En route';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusRejected => 'Rejetée';

  @override
  String get specGeneral => 'Médecine Générale';

  @override
  String get specCardio => 'Cardiologie';

  @override
  String get specDerma => 'Dermatologie';

  @override
  String get specPediatry => 'Pédiatrie';

  @override
  String get specGyneco => 'Gynécologie';

  @override
  String get specOphtalmo => 'Ophtalmologie';

  @override
  String get specOrl => 'ORL';

  @override
  String get specNeuro => 'Neurologie';

  @override
  String get specPsychiatry => 'Psychiatrie';

  @override
  String get specRhumato => 'Rhumatologie';

  @override
  String get specGastro => 'Gastro-entérologie';

  @override
  String get specPneumo => 'Pneumologie';

  @override
  String get specUro => 'Urologie';

  @override
  String get specEndocri => 'Endocrinologie';

  @override
  String get specOrtho => 'Orthopédie';

  @override
  String get ambSmur => 'Ambulance médicalisée (SMUR)';

  @override
  String get ambRea => 'Ambulance de réanimation';

  @override
  String get ambSanitary => 'Ambulance sanitaire (standard)';

  @override
  String get ambVsl => 'VSL (Véhicule Sanitaire Léger)';

  @override
  String get specifyTeleconsult =>
      'Précisez la spécialité pour votre consultation vidéo';

  @override
  String get appointmentDate => 'Date du rendez-vous';

  @override
  String get desiredTime => 'Heure souhaitée';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get realTimeTracking => 'Suivi en temps réel';

  @override
  String get proOnTheWay => 'Professionnel en route';

  @override
  String get identityVerified => 'Identité vérifiée par MSD';

  @override
  String get dateAndTime => 'DATE & HEURE';

  @override
  String get addressLabel => 'ADRESSE';

  @override
  String get itinerary => 'Itinéraire';

  @override
  String get professionalLabel => 'PROFESSIONNEL';

  @override
  String get estimatedAmount => 'MONTANT ESTIMÉ';

  @override
  String get noteLabel => 'NOTE';

  @override
  String get cancelledByUser => 'Annulée par l\'utilisateur';

  @override
  String get rejectedByProfessional => 'Rejetée par le professionnel';

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String get cancelRequestConfirmTitle => 'Annuler la demande ?';

  @override
  String get cancelRequestConfirmMessage =>
      'Êtes-vous sûr de vouloir annuler cette demande SOS ? Cette action est irréversible.';

  @override
  String get keepRequest => 'Non, garder';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get requestCancelledSuccess => 'Demande annulée avec succès';

  @override
  String errorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String videoConsultation(String specialty) {
    return 'Consultation vidéo • $specialty';
  }

  @override
  String get joinTeleconsultation => 'Rejoindre la téléconsultation';

  @override
  String get healthServices => 'Services de santé';

  @override
  String get assigned => 'Assigné';

  @override
  String get waiting => 'En attente...';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get city => 'Ville';

  @override
  String get bloodGroup => 'Groupe Sanguin';

  @override
  String get insuranceLabel => 'Assurance (N° de police / Type)';

  @override
  String get medicalHistory => 'Antécédents Médicaux';

  @override
  String get noneProvided => 'Aucun renseigné';

  @override
  String get add => 'Ajouter';

  @override
  String addTitle(String title) {
    return 'Ajouter : $title';
  }

  @override
  String get description => 'Description';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get myRequestsTitle => 'Mes demandes';

  @override
  String get filterAll => 'TOUT';

  @override
  String get filterOngoing => 'En cours';

  @override
  String get filterCompleted => 'TERMINÉS';

  @override
  String get filterCancelled => 'Annulés';

  @override
  String get noRequests => 'Aucune demande';

  @override
  String get noRequestsAll =>
      'Vous n\'avez pas encore effectué de demande SOS.';

  @override
  String get noRequestsOngoing =>
      'Aucune demande n\'est actuellement en cours de traitement.';

  @override
  String get noRequestsCompleted =>
      'Vous n\'avez aucune intervention terminée dans votre historique.';

  @override
  String get noRequestsCancelled => 'Aucune demande annulée trouvée.';

  @override
  String get legendTitle => 'Légende';

  @override
  String get legendTaken => 'Complet';

  @override
  String get legendPartial => 'Partiel';

  @override
  String get legendMissed => 'Raté';

  @override
  String get legendFuture => 'Futur';

  @override
  String get confirmClearHistory => 'Effacer l\'historique ?';

  @override
  String get clearHistoryMessage =>
      'Voulez-vous supprimer définitivement toutes vos notifications ? Cette action est irréversible.';

  @override
  String get clearAll => 'Effacer tout';

  @override
  String get confirmLocation => 'Confirmer l\'emplacement';

  @override
  String get searchAddress => 'Rechercher une adresse...';

  @override
  String get step => 'Étape';

  @override
  String get ofTotal => 'sur';

  @override
  String get loading => 'Chargement...';

  @override
  String get medicationDetails => 'Détails du médicament';

  @override
  String get instructions => 'Instructions';

  @override
  String get currentStock => 'Stock actuel';

  @override
  String get refillStock => 'Recharger le stock';

  @override
  String refillTitle(String name) {
    return 'Recharger le stock : $name';
  }

  @override
  String get quantityToAdd => 'Quantité rachetée';

  @override
  String get quantityHint => 'ex: 30';

  @override
  String get home => 'Accueil';

  @override
  String get planning => 'Médicaments';

  @override
  String get sos => 'Demandes';

  @override
  String get profile => 'Profil';

  @override
  String get frequency => 'Fréquence';

  @override
  String takesPerDay(int count) {
    return '$count prise(s) par jour';
  }

  @override
  String get startOfTreatment => 'Début du traitement';

  @override
  String get endOfTreatment => 'Fin du traitement';

  @override
  String stockRefilledSuccess(String name) {
    return 'Stock de $name renouvelé !';
  }

  @override
  String get confirmRefill => 'Confirmer le renouvellement';

  @override
  String newStock(int count) {
    return 'Nouveau stock : $count unités';
  }

  @override
  String get noMedsForDay => 'Aucun médicament prévu pour ce jour';

  @override
  String regularizeTitle(String name) {
    return 'Régulariser : $name';
  }

  @override
  String get statusPlanned => 'Prévu';

  @override
  String notificationMedicationTitle(Object name) {
    return 'Rappel : $name';
  }

  @override
  String notificationMedicationBody(Object dosage) {
    return 'C\'est l\'heure de votre prise ($dosage)';
  }

  @override
  String notificationMedicationSnoozeBody(Object dosage) {
    return 'N\'oubliez pas votre prise ($dosage)';
  }

  @override
  String get notificationEndOfDayTitle => 'Bilan de votre journée';

  @override
  String get notificationEndOfDayBody =>
      'N\'oubliez pas vos prises de fin de journée.';

  @override
  String notificationStockUrgentTitle(Object name) {
    return 'URGENT — $name';
  }

  @override
  String notificationStockLowTitle(Object name) {
    return 'Stock faible — $name';
  }

  @override
  String notificationStockBody(Object count) {
    return 'Il reste $count unité(s).';
  }

  @override
  String get notificationActionConfirm => 'Confirmer';

  @override
  String notificationActionSnooze(Object minutes) {
    return 'Rappel dans $minutes min';
  }

  @override
  String get chooseProfile =>
      'Choisissez le type de profil qui vous correspond.';

  @override
  String get iAmPatient => 'Je suis un Patient';

  @override
  String get patientDesc =>
      'Je souhaite gérer ma santé et celle de mes proches.';

  @override
  String get iAmProfessional => 'Je suis un Professionnel';

  @override
  String get professionalDesc =>
      'Je souhaite proposer mes services et suivre mes patients.';

  @override
  String get missionInProgress => 'Mission en cours';

  @override
  String get addressNotSpecified => 'Adresse non spécifiée';

  @override
  String get emergenciesTitle => 'Urgences SOS';

  @override
  String get noEmergencyNearby => 'Aucune urgence à proximité';

  @override
  String get availableAppointments => 'RDV Disponibles';

  @override
  String get noAppointmentAvailable => 'Aucun rendez-vous disponible';

  @override
  String get professional => 'Professionnel';

  @override
  String get patient => 'Patient';

  @override
  String get professionalInfo => 'Informations Professionnelles';

  @override
  String get serviceType => 'Type de service';

  @override
  String get chooseProfessional => 'Choisir un professionnel';

  @override
  String get onDuty => 'En Service';

  @override
  String get offDuty => 'Hors Service';

  @override
  String get visioConference => 'Visio-conférence';

  @override
  String get distConsultation => 'Consultation à distance';

  @override
  String get join => 'Rejoindre';

  @override
  String get done => 'Terminé';

  @override
  String get start => 'Démarrer';

  @override
  String get inPersonConsultation => 'Consultation';

  @override
  String get time => 'Heure';

  @override
  String get cancelMission => 'Annuler la mission';

  @override
  String get noProfessionalFound => 'Aucun professionnel trouvé';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get agenda => 'Agenda';

  @override
  String get earnings => 'Revenus';

  @override
  String get onTheWay => 'En route';

  @override
  String get estimatedTime => 'Temps estimé';

  @override
  String get distance => 'Distance';

  @override
  String get user => 'Utilisateur';

  @override
  String get occupation => 'Votre métier';

  @override
  String get proximityRange => 'Rayon de recherche';

  @override
  String get available => 'Disponible';

  @override
  String get pendingAppointments => 'RDV en attente';

  @override
  String get todaysAgenda => 'Mes missions d\'aujourd\'hui';

  @override
  String get appointmentsTitle => 'Rendez-vous';

  @override
  String get noAppointmentsAssigned => 'Aucun nouveau rendez-vous assigné';

  @override
  String get noAppointmentsToday => 'Aucun rendez-vous pour aujourd\'hui';

  @override
  String get tooEarlyForAppointment =>
      'Il est encore trop tôt pour ce rendez-vous. Revenez 5 min avant.';

  @override
  String get scheduleConflict =>
      'Votre planning est déjà complet à ce moment (marge d\'une heure requise).';

  @override
  String get requestAlreadyTaken =>
      'Cette demande a déjà été acceptée par un autre professionnel.';

  @override
  String get appointmentLate => 'EN RETARD';

  @override
  String get alreadyActiveMission =>
      'Vous avez déjà une mission active. Terminez-la d\'abord.';

  @override
  String get acts => 'Actes';

  @override
  String get noMissionRecorded => 'Aucune mission enregistrée';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get notificationNewSosTitle => 'Nouvelle Urgence SOS';

  @override
  String get notificationNewSosBody =>
      'Un nouveau patient a besoin d\'une assistance immédiate à proximité.';

  @override
  String get notificationNewAppointmentTitle => 'Nouveau Rendez-vous';

  @override
  String get notificationNewAppointmentBody =>
      'Vous avez reçu une nouvelle demande de rendez-vous.';

  @override
  String get notificationSosAcceptedTitle => 'Demande Acceptée';

  @override
  String notificationSosAcceptedBody(Object name) {
    return 'Un professionnel a accepté votre demande : $name';
  }

  @override
  String get notificationSosOnTheWayTitle => 'Professionnel en route';

  @override
  String notificationSosOnTheWayBody(Object name) {
    return '$name est en route vers votre position.';
  }

  @override
  String get notificationSosInProgressTitle => 'Téléconsultation démarrée';

  @override
  String notificationSosInProgressBody(Object name) {
    return '$name vous attend pour la consultation vidéo.';
  }

  @override
  String get notificationSosCancelledTitle => 'Intervention annulée';

  @override
  String get notificationSosCancelledBody => 'La demande a été annulée.';

  @override
  String get notificationSosCancelledByPatientBody =>
      'Le patient a annulé son intervention.';

  @override
  String get notificationSosCancelledByProBody =>
      'Le professionnel a dû annuler l\'intervention.';

  @override
  String get notificationSosRejectedTitle => 'Demande Refusée';

  @override
  String notificationSosRejectedBody(Object name) {
    return '$name a refusé votre demande.';
  }

  @override
  String get notificationSosRejectedBodyGeneric =>
      'Votre demande a été refusée. Vous pouvez réessayer avec un autre professionnel.';

  @override
  String get notificationNewRatingTitle => 'Nouvelle évaluation';

  @override
  String notificationNewRatingBody(String name, int rating) {
    return '$name vous a donné une note de $rating étoiles !';
  }

  @override
  String get afternoon => 'Après-midi';

  @override
  String get availableTimeSlots => 'Créneaux disponibles';

  @override
  String get noAvailableSlots => 'Aucun créneau disponible';

  @override
  String get tryAnotherDate => 'Essayez une autre date';

  @override
  String get chooseTimeSlot => 'Veuillez choisir un créneau horaire';

  @override
  String get profileSetup => 'Configuration du profil';

  @override
  String get completeProProfile => 'Complétez votre profil professionnel';

  @override
  String get proSetupSubtitle =>
      'Ces informations sont nécessaires pour valider votre compte.';

  @override
  String get verificationDocs => 'Documents de vérification';

  @override
  String get cniFront => 'Carte d\'identité (Recto)';

  @override
  String get cniBack => 'Carte d\'identité (Verso)';

  @override
  String get diploma => 'Diplôme / Attestation';

  @override
  String get authorization => 'Autorisation d\'exercer';

  @override
  String get vehicleRegistration => 'Carte grise';

  @override
  String get transportAuth => 'Agrément de transport';

  @override
  String get validationPendingTitle => 'Vérification en cours';

  @override
  String get validationPendingMessage =>
      'Votre dossier est en cours d\'examen par nos services.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get validationRejectedTitle => 'Dossier non validé';

  @override
  String get validationRejectedMessage =>
      'Nous n\'avons pas pu valider votre profil professionnel pour le moment. ';

  @override
  String get updateDocuments => 'Mettre à jour mes documents';

  @override
  String get updateDocumentsSubtitle => 'Corrigez et renvoyez vos fichiers';

  @override
  String get contactSupportMessage =>
      'Pensez à contacter le support MSD si vous avez besoin d\'aide : support@msd.ma';

  @override
  String get startOver => 'Besoin de repartir à zéro ?';

  @override
  String get validationStatus => 'Statut de validation';

  @override
  String get validated => 'Validé';

  @override
  String get rejected => 'Rejeté';

  @override
  String get pending => 'En attente';

  @override
  String get chronicDiseases => 'Maladies Chroniques';

  @override
  String get skip => 'Passer';

  @override
  String get adminManagementTools => 'Outils de gestion';

  @override
  String get adminProfessionals => 'Professionnels';

  @override
  String get adminManageNetwork => 'Gérer le réseau';

  @override
  String get adminPatients => 'Patients';

  @override
  String get adminFullList => 'Liste complète';

  @override
  String get adminSosMonitor => 'Moniteur SOS';

  @override
  String get adminLiveFlow => 'Flux en direct';

  @override
  String get adminWelcome => 'Bienvenue, Admin';

  @override
  String get adminPlatformStatus => 'État de la plateforme';

  @override
  String get adminTotalSos => 'Total SOS';

  @override
  String get adminMissions => 'Missions';

  @override
  String get adminValidatedPros => 'Pros validés';

  @override
  String get adminSosDistribution => 'Distribution SOS';

  @override
  String get adminDoctors => 'Médecins';

  @override
  String get adminAmbulances => 'Ambulances';

  @override
  String get adminNurses => 'Infirmiers';

  @override
  String get adminTeleconsult => 'Téléconsultations';

  @override
  String get chatbotTitle => 'MSD AI Assistant';

  @override
  String get chatbotHistory => 'Historique';

  @override
  String get chatbotHint => 'Posez votre question...';

  @override
  String get chatbotNoHistory => 'Aucun historique';

  @override
  String get chatbotNewChat => 'Nouveau Chat';

  @override
  String get chatbotCopied => 'Copié dans le presse-papier';

  @override
  String get chatbotConsult => 'Consulter';

  @override
  String get financialDashboard => 'Tableau de Bord Financier';

  @override
  String get performanceLast6Months => 'Performance (6 derniers mois)';

  @override
  String get earningsHistory => 'Historique des Gains';

  @override
  String get totalRevenue => 'Chiffre d\'affaires total';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get pricingManagement => 'Gestion des Tarifs';

  @override
  String get adjustPricesAndLimits => 'Ajustez vos prix et limites';

  @override
  String get noEarningsRecorded => 'Aucun gain enregistré.';

  @override
  String get pricingPilot => 'PILOTAGE DES TARIFS';

  @override
  String get pricingFreedom => 'Liberté des Tarifs';

  @override
  String get pricingFreedomDesc =>
      'Déterminez vos propres tarifs selon votre expertise et la qualité de vos services.';

  @override
  String get updateMyServices => 'METTRE À JOUR MES SERVICES';

  @override
  String get consultationFeeLabel => 'Tarif de la consultation';

  @override
  String get extraKmFee => 'Frais / KM';

  @override
  String get includedRadius => 'Rayon inclus';

  @override
  String get pricingSaveSuccess => 'Configurations enregistrées avec succès';

  @override
  String get adminPatientsList => 'Liste des Patients';

  @override
  String get searchPatientHint => 'Rechercher un patient...';

  @override
  String get noPatientFound => 'Aucun patient trouvé';

  @override
  String get proDirectory => 'Annuaire Professionnels';

  @override
  String get searchProHint => 'Rechercher un nom...';

  @override
  String get filterValidated => 'VALIDÉS';

  @override
  String get filterPending => 'EN ATTENTE';

  @override
  String get filterRejected => 'REJETÉS';

  @override
  String get noResultFound => 'Aucun résultat trouvé';

  @override
  String get noMedicalInfoProvided =>
      'Aucune information médicale renseignée pour ce patient.';

  @override
  String get adminRequestDetails => 'Détails de la Demande';

  @override
  String get adminServiceIntervention => 'Service & Intervention';

  @override
  String get adminCreationDate => 'Date Création';

  @override
  String get adminAppointmentDate => 'Date RDV';

  @override
  String get adminAssignedPro => 'Professionnel Assigné';

  @override
  String get adminNotYetAssigned => 'Non encore assigné';

  @override
  String get adminRequestsMonitor => 'Moniteur des Demandes';

  @override
  String get adminAllDates => 'Toutes dates';

  @override
  String get adminThisWeek => 'Cette semaine';

  @override
  String get adminThisMonth => 'Ce mois';

  @override
  String get proReviewsTitle => 'Mes Avis';

  @override
  String proReviewsOf(String name) {
    return 'Avis sur $name';
  }

  @override
  String get proNoReviewsYet => 'Aucun avis pour le moment';

  @override
  String get proNoReviewsProDesc =>
      'Ce professionnel n\'a pas encore reçu d\'évaluations.';

  @override
  String get proNoReviewsMeDesc =>
      'Vos évaluations apparaîtront ici dès que les patients auront noté vos interventions.';

  @override
  String get adminReviewTitle => 'Vérification Dossier';

  @override
  String get adminRejectionReasonTitle => 'Motif du refus';

  @override
  String get adminRejectionHint =>
      'Expliquez pourquoi ce dossier est rejeté...';

  @override
  String get adminConfirmRejection => 'Confirmer le rejet';

  @override
  String get adminSupportingDocs => 'Pièces Justificatives';

  @override
  String get adminProAlreadyValidated => 'Ce professionnel est déjà validé';

  @override
  String get adminProAlreadyRejected => 'Ce professionnel a été rejeté';

  @override
  String get adminServiceLabel => 'Service';

  @override
  String get adminSpecTypeLabel => 'Spécialité / Type';

  @override
  String get adminNoOcrData =>
      '⚠️ Aucune donnée OCR disponible pour ce document.';

  @override
  String get adminRejectAction => 'REJETER';

  @override
  String get adminValidateAction => 'VALIDER LE DOSSIER';

  @override
  String get statusAwaitingPayment => 'En attente de paiement';

  @override
  String get adminRole => 'Administrateur';

  @override
  String get filterConfirmed => 'CONFIRMÉS';

  @override
  String get filterInProgress => 'EN COURS';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get notificationAdminNewProTitle => 'Dossier à valider';

  @override
  String notificationAdminNewProBody(Object name) {
    return 'Le professionnel $name a soumis ses documents pour validation.';
  }

  @override
  String get notificationAdminNewPatientTitle => 'Nouveau Patient';

  @override
  String notificationAdminNewPatientBody(Object name) {
    return 'Un nouveau patient, $name, vient de créer son compte.';
  }

  @override
  String get notificationAdminNewSosTitle => 'Nouvelle Alerte SOS';

  @override
  String notificationAdminNewSosBody(Object name) {
    return 'Une nouvelle demande SOS a été créée par $name.';
  }
}
