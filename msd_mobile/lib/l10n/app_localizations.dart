import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS PERSONNELLES'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @medicalInfo.
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS MÉDICALES'**
  String get medicalInfo;

  /// No description provided for @bloodType.
  ///
  /// In fr, this message translates to:
  /// **'Groupe sanguin'**
  String get bloodType;

  /// No description provided for @allergies.
  ///
  /// In fr, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Antécédents'**
  String get history;

  /// No description provided for @insurance.
  ///
  /// In fr, this message translates to:
  /// **'Assurance'**
  String get insurance;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'PARAMÈTRES'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @chooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get chooseLanguage;

  /// No description provided for @msdTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre santé, à portée de main'**
  String get msdTagline;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: sarah.martin'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @orDivider.
  ///
  /// In fr, this message translates to:
  /// **'OU'**
  String get orDivider;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre compte'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir les informations ci-dessous pour commencer votre inscription.'**
  String get registerSubtitle;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: Sarah'**
  String get firstNameHint;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: Martin'**
  String get lastNameHint;

  /// No description provided for @emailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'exemple@email.com'**
  String get emailHint;

  /// No description provided for @passwordMinChars.
  ///
  /// In fr, this message translates to:
  /// **'Min. 8 caractères'**
  String get passwordMinChars;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre mot de passe'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @splashSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous instantanément avec des professionnels de santé qualifiés'**
  String get splashSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get getStarted;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse email pour recevoir un lien de réinitialisation.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get sendLink;

  /// No description provided for @emailSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé !'**
  String get emailSentTitle;

  /// No description provided for @emailSentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {email}, un email de récupération a été envoyé.'**
  String emailSentSubtitle(String email);

  /// No description provided for @backToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get backToLogin;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un lien de confirmation a été envoyé à {email}. Veuillez cliquer dessus pour activer votre compte.'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour '**
  String get hello;

  /// No description provided for @sosServices.
  ///
  /// In fr, this message translates to:
  /// **'SERVICES SOS'**
  String get sosServices;

  /// No description provided for @onDutyPharmacy.
  ///
  /// In fr, this message translates to:
  /// **'Pharmacie de garde'**
  String get onDutyPharmacy;

  /// No description provided for @findNearest.
  ///
  /// In fr, this message translates to:
  /// **'Trouver la plus proche'**
  String get findNearest;

  /// No description provided for @allDosesDone.
  ///
  /// In fr, this message translates to:
  /// **'Parcours terminé !'**
  String get allDosesDone;

  /// No description provided for @allDosesDoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos prises sont à jour pour aujourd\'hui. 👋'**
  String get allDosesDoneSubtitle;

  /// No description provided for @doseConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'PRISE CONFIRMÉE'**
  String get doseConfirmed;

  /// No description provided for @doseLate.
  ///
  /// In fr, this message translates to:
  /// **'PRISE EN RETARD'**
  String get doseLate;

  /// No description provided for @nextDose.
  ///
  /// In fr, this message translates to:
  /// **'PROCHAINE PRISE'**
  String get nextDose;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez reçu aucun message pour le moment.'**
  String get noNotificationsSubtitle;

  /// No description provided for @clearNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les notifications'**
  String get clearNotificationsTitle;

  /// No description provided for @clearNotificationsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer définitivement toutes vos notifications ? Cette action est irréversible.'**
  String get clearNotificationsMessage;

  /// No description provided for @planningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning & Suivi'**
  String get planningTitle;

  /// No description provided for @addMedication.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un médicament'**
  String get addMedication;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @period.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get period;

  /// No description provided for @times.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get times;

  /// No description provided for @reminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get reminders;

  /// No description provided for @medicationName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du médicament'**
  String get medicationName;

  /// No description provided for @medicationNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Paracétamol'**
  String get medicationNameHint;

  /// No description provided for @dosage.
  ///
  /// In fr, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @dosageHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 500mg'**
  String get dosageHint;

  /// No description provided for @instruction.
  ///
  /// In fr, this message translates to:
  /// **'Instruction'**
  String get instruction;

  /// No description provided for @startDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get startDate;

  /// No description provided for @duration.
  ///
  /// In fr, this message translates to:
  /// **'Durée du traitement (jours)'**
  String get duration;

  /// No description provided for @durationHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 7'**
  String get durationHint;

  /// No description provided for @initialStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock initial'**
  String get initialStock;

  /// No description provided for @stockHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 30'**
  String get stockHint;

  /// No description provided for @intakeTimes.
  ///
  /// In fr, this message translates to:
  /// **'Heures de prise'**
  String get intakeTimes;

  /// No description provided for @addTimeHint.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez sur + pour ajouter une heure'**
  String get addTimeHint;

  /// No description provided for @reminderIntensity.
  ///
  /// In fr, this message translates to:
  /// **'Intensité du rappel'**
  String get reminderIntensity;

  /// No description provided for @notificationAlert.
  ///
  /// In fr, this message translates to:
  /// **'Notification'**
  String get notificationAlert;

  /// No description provided for @notificationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une alerte discrète'**
  String get notificationSubtitle;

  /// No description provided for @alarmAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alarme'**
  String get alarmAlert;

  /// No description provided for @alarmSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sonnerie persistante'**
  String get alarmSubtitle;

  /// No description provided for @notifyBefore.
  ///
  /// In fr, this message translates to:
  /// **'Notifier combien de minutes avant ? ({minutes} min)'**
  String notifyBefore(int minutes);

  /// No description provided for @snoozeInterval.
  ///
  /// In fr, this message translates to:
  /// **'Intervalle de répétition (Snooze)'**
  String get snoozeInterval;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @duringMeal.
  ///
  /// In fr, this message translates to:
  /// **'Pendant le repas'**
  String get duringMeal;

  /// No description provided for @beforeMeal.
  ///
  /// In fr, this message translates to:
  /// **'Avant le repas'**
  String get beforeMeal;

  /// No description provided for @onEmptyStomach.
  ///
  /// In fr, this message translates to:
  /// **'À jeun'**
  String get onEmptyStomach;

  /// No description provided for @afterMeal.
  ///
  /// In fr, this message translates to:
  /// **'Après le repas'**
  String get afterMeal;

  /// No description provided for @medicationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du médicament est obligatoire'**
  String get medicationNameRequired;

  /// No description provided for @atLeastOneTimeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez ajouter au moins un horaire de prise'**
  String get atLeastOneTimeRequired;

  /// No description provided for @snooze.
  ///
  /// In fr, this message translates to:
  /// **'Répéter ({minutes} min)'**
  String snooze(int minutes);

  /// No description provided for @confirmTake.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la prise'**
  String get confirmTake;

  /// No description provided for @until.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'au {date}'**
  String until(String date);

  /// No description provided for @daysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} j. restants'**
  String daysRemaining(int count);

  /// No description provided for @finishesToday.
  ///
  /// In fr, this message translates to:
  /// **'Termine aujourd\'hui'**
  String get finishesToday;

  /// No description provided for @criticalStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock critique'**
  String get criticalStock;

  /// No description provided for @lowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible'**
  String get lowStock;

  /// No description provided for @unitsRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} unité(s) restante(s)'**
  String unitsRemaining(int count);

  /// No description provided for @morning.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get morning;

  /// No description provided for @noon.
  ///
  /// In fr, this message translates to:
  /// **'Midi'**
  String get noon;

  /// No description provided for @evening.
  ///
  /// In fr, this message translates to:
  /// **'Soir'**
  String get evening;

  /// No description provided for @bedtime.
  ///
  /// In fr, this message translates to:
  /// **'Coucher'**
  String get bedtime;

  /// No description provided for @actionFor.
  ///
  /// In fr, this message translates to:
  /// **'Action pour {name}'**
  String actionFor(String name);

  /// No description provided for @tooEarly.
  ///
  /// In fr, this message translates to:
  /// **'Il est encore trop tôt pour cette prise'**
  String get tooEarly;

  /// No description provided for @lateStatus.
  ///
  /// In fr, this message translates to:
  /// **'Prise en retard !'**
  String get lateStatus;

  /// No description provided for @markAsTaken.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme pris'**
  String get markAsTaken;

  /// No description provided for @markAsMissed.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme raté'**
  String get markAsMissed;

  /// No description provided for @reschedule.
  ///
  /// In fr, this message translates to:
  /// **'Décaler l\'horaire'**
  String get reschedule;

  /// No description provided for @doctor.
  ///
  /// In fr, this message translates to:
  /// **'Médecin'**
  String get doctor;

  /// No description provided for @teleconsultation.
  ///
  /// In fr, this message translates to:
  /// **'Téléconsultation'**
  String get teleconsultation;

  /// No description provided for @nurse.
  ///
  /// In fr, this message translates to:
  /// **'Infirmier'**
  String get nurse;

  /// No description provided for @ambulance.
  ///
  /// In fr, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @myMedications.
  ///
  /// In fr, this message translates to:
  /// **'Mes Médicaments'**
  String get myMedications;

  /// No description provided for @dayTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Timeline du jour'**
  String get dayTimeline;

  /// No description provided for @calendarAndTracking.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier & Suivi'**
  String get calendarAndTracking;

  /// No description provided for @noMedicationsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucun médicament pour aujourd\'hui'**
  String get noMedicationsToday;

  /// No description provided for @yourRequest.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande'**
  String get yourRequest;

  /// No description provided for @specifySpecialtyAndIntervention.
  ///
  /// In fr, this message translates to:
  /// **'Précisez la spécialité et le type d\'intervention'**
  String get specifySpecialtyAndIntervention;

  /// No description provided for @specialty.
  ///
  /// In fr, this message translates to:
  /// **'Spécialité'**
  String get specialty;

  /// No description provided for @chooseSpecialty.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une spécialité'**
  String get chooseSpecialty;

  /// No description provided for @interventionType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'intervention'**
  String get interventionType;

  /// No description provided for @sosUrgency.
  ///
  /// In fr, this message translates to:
  /// **'En Urgence (SOS)'**
  String get sosUrgency;

  /// No description provided for @sosUrgencyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel disponible le plus proche'**
  String get sosUrgencyDesc;

  /// No description provided for @appointment.
  ///
  /// In fr, this message translates to:
  /// **'Sur Rendez-vous'**
  String get appointment;

  /// No description provided for @appointmentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une date et une heure'**
  String get appointmentDesc;

  /// No description provided for @continueText.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueText;

  /// No description provided for @confirmRequest.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la demande'**
  String get confirmRequest;

  /// No description provided for @chooseInterventionType.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir un type d\'intervention'**
  String get chooseInterventionType;

  /// No description provided for @requestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée !'**
  String get requestSent;

  /// No description provided for @homeCare.
  ///
  /// In fr, this message translates to:
  /// **'Soins à domicile'**
  String get homeCare;

  /// No description provided for @specifyAmbulanceType.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le type d\'ambulance et l\'intervention'**
  String get specifyAmbulanceType;

  /// No description provided for @ambulanceType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'ambulance'**
  String get ambulanceType;

  /// No description provided for @chooseAmbulanceType.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un type d\'ambulance'**
  String get chooseAmbulanceType;

  /// No description provided for @interventionAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse d\'intervention'**
  String get interventionAddress;

  /// No description provided for @specifyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le lieu où l\'aide est attendue'**
  String get specifyLocation;

  /// No description provided for @exactAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse exacte'**
  String get exactAddress;

  /// No description provided for @addressHint.
  ///
  /// In fr, this message translates to:
  /// **'Rue, Quartier...'**
  String get addressHint;

  /// No description provided for @apartment.
  ///
  /// In fr, this message translates to:
  /// **'Appt / Maison'**
  String get apartment;

  /// No description provided for @apartmentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Apt 4B'**
  String get apartmentHint;

  /// No description provided for @floor.
  ///
  /// In fr, this message translates to:
  /// **'Étage'**
  String get floor;

  /// No description provided for @floorHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 2ème'**
  String get floorHint;

  /// No description provided for @entryCode.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'entrée'**
  String get entryCode;

  /// No description provided for @entryCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: A123'**
  String get entryCodeHint;

  /// No description provided for @gpsActivation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez activer votre GPS : {error}'**
  String gpsActivation(String error);

  /// No description provided for @payment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get payment;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre mode de paiement'**
  String get choosePaymentMethod;

  /// No description provided for @paymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get paymentMethod;

  /// No description provided for @consultationFee.
  ///
  /// In fr, this message translates to:
  /// **'Tarif de la consultation'**
  String get consultationFee;

  /// No description provided for @paymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get paymentCash;

  /// No description provided for @paymentCashDesc.
  ///
  /// In fr, this message translates to:
  /// **'Payer sur place au professionnel'**
  String get paymentCashDesc;

  /// No description provided for @paymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte Bancaire'**
  String get paymentCard;

  /// No description provided for @paymentCardDesc.
  ///
  /// In fr, this message translates to:
  /// **'Pré-autorisation sécurisée'**
  String get paymentCardDesc;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get statusConfirmed;

  /// No description provided for @statusOnTheWay.
  ///
  /// In fr, this message translates to:
  /// **'En route'**
  String get statusOnTheWay;

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get statusCancelled;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejetée'**
  String get statusRejected;

  /// No description provided for @specGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Médecine Générale'**
  String get specGeneral;

  /// No description provided for @specCardio.
  ///
  /// In fr, this message translates to:
  /// **'Cardiologie'**
  String get specCardio;

  /// No description provided for @specDerma.
  ///
  /// In fr, this message translates to:
  /// **'Dermatologie'**
  String get specDerma;

  /// No description provided for @specPediatry.
  ///
  /// In fr, this message translates to:
  /// **'Pédiatrie'**
  String get specPediatry;

  /// No description provided for @specGyneco.
  ///
  /// In fr, this message translates to:
  /// **'Gynécologie'**
  String get specGyneco;

  /// No description provided for @specOphtalmo.
  ///
  /// In fr, this message translates to:
  /// **'Ophtalmologie'**
  String get specOphtalmo;

  /// No description provided for @specOrl.
  ///
  /// In fr, this message translates to:
  /// **'ORL'**
  String get specOrl;

  /// No description provided for @specNeuro.
  ///
  /// In fr, this message translates to:
  /// **'Neurologie'**
  String get specNeuro;

  /// No description provided for @specPsychiatry.
  ///
  /// In fr, this message translates to:
  /// **'Psychiatrie'**
  String get specPsychiatry;

  /// No description provided for @specRhumato.
  ///
  /// In fr, this message translates to:
  /// **'Rhumatologie'**
  String get specRhumato;

  /// No description provided for @specGastro.
  ///
  /// In fr, this message translates to:
  /// **'Gastro-entérologie'**
  String get specGastro;

  /// No description provided for @specPneumo.
  ///
  /// In fr, this message translates to:
  /// **'Pneumologie'**
  String get specPneumo;

  /// No description provided for @specUro.
  ///
  /// In fr, this message translates to:
  /// **'Urologie'**
  String get specUro;

  /// No description provided for @specEndocri.
  ///
  /// In fr, this message translates to:
  /// **'Endocrinologie'**
  String get specEndocri;

  /// No description provided for @specOrtho.
  ///
  /// In fr, this message translates to:
  /// **'Orthopédie'**
  String get specOrtho;

  /// No description provided for @ambSmur.
  ///
  /// In fr, this message translates to:
  /// **'Ambulance médicalisée (SMUR)'**
  String get ambSmur;

  /// No description provided for @ambRea.
  ///
  /// In fr, this message translates to:
  /// **'Ambulance de réanimation'**
  String get ambRea;

  /// No description provided for @ambSanitary.
  ///
  /// In fr, this message translates to:
  /// **'Ambulance sanitaire (standard)'**
  String get ambSanitary;

  /// No description provided for @ambVsl.
  ///
  /// In fr, this message translates to:
  /// **'VSL (Véhicule Sanitaire Léger)'**
  String get ambVsl;

  /// No description provided for @specifyTeleconsult.
  ///
  /// In fr, this message translates to:
  /// **'Précisez la spécialité pour votre consultation vidéo'**
  String get specifyTeleconsult;

  /// No description provided for @appointmentDate.
  ///
  /// In fr, this message translates to:
  /// **'Date du rendez-vous'**
  String get appointmentDate;

  /// No description provided for @desiredTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure souhaitée'**
  String get desiredTime;

  /// No description provided for @chooseDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get chooseDate;

  /// No description provided for @realTimeTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi en temps réel'**
  String get realTimeTracking;

  /// No description provided for @proOnTheWay.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel en route'**
  String get proOnTheWay;

  /// No description provided for @identityVerified.
  ///
  /// In fr, this message translates to:
  /// **'Identité vérifiée par MSD'**
  String get identityVerified;

  /// No description provided for @dateAndTime.
  ///
  /// In fr, this message translates to:
  /// **'DATE & HEURE'**
  String get dateAndTime;

  /// No description provided for @addressLabel.
  ///
  /// In fr, this message translates to:
  /// **'ADRESSE'**
  String get addressLabel;

  /// No description provided for @itinerary.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get itinerary;

  /// No description provided for @professionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'PROFESSIONNEL'**
  String get professionalLabel;

  /// No description provided for @estimatedAmount.
  ///
  /// In fr, this message translates to:
  /// **'MONTANT ESTIMÉ'**
  String get estimatedAmount;

  /// No description provided for @noteLabel.
  ///
  /// In fr, this message translates to:
  /// **'NOTE'**
  String get noteLabel;

  /// No description provided for @cancelledByUser.
  ///
  /// In fr, this message translates to:
  /// **'Annulée par l\'utilisateur'**
  String get cancelledByUser;

  /// No description provided for @rejectedByProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Rejetée par le professionnel'**
  String get rejectedByProfessional;

  /// No description provided for @cancelRequest.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande ?'**
  String get cancelRequestConfirmTitle;

  /// No description provided for @cancelRequestConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir annuler cette demande SOS ? Cette action est irréversible.'**
  String get cancelRequestConfirmMessage;

  /// No description provided for @keepRequest.
  ///
  /// In fr, this message translates to:
  /// **'Non, garder'**
  String get keepRequest;

  /// No description provided for @yesCancel.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get yesCancel;

  /// No description provided for @requestCancelledSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Demande annulée avec succès'**
  String get requestCancelledSuccess;

  /// No description provided for @errorPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorPrefix(String error);

  /// No description provided for @videoConsultation.
  ///
  /// In fr, this message translates to:
  /// **'Consultation vidéo • {specialty}'**
  String videoConsultation(String specialty);

  /// No description provided for @joinTeleconsultation.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre la téléconsultation'**
  String get joinTeleconsultation;

  /// No description provided for @healthServices.
  ///
  /// In fr, this message translates to:
  /// **'Services de santé'**
  String get healthServices;

  /// No description provided for @assigned.
  ///
  /// In fr, this message translates to:
  /// **'Assigné'**
  String get assigned;

  /// No description provided for @waiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente...'**
  String get waiting;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le Profil'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @bloodGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe Sanguin'**
  String get bloodGroup;

  /// No description provided for @insuranceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Assurance (N° de police / Type)'**
  String get insuranceLabel;

  /// No description provided for @medicalHistory.
  ///
  /// In fr, this message translates to:
  /// **'Antécédents Médicaux'**
  String get medicalHistory;

  /// No description provided for @noneProvided.
  ///
  /// In fr, this message translates to:
  /// **'Aucun renseigné'**
  String get noneProvided;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @addTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter : {title}'**
  String addTitle(String title);

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès'**
  String get profileUpdatedSuccess;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get fieldRequired;

  /// No description provided for @myRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get myRequestsTitle;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterOngoing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get filterOngoing;

  /// No description provided for @filterCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get filterCompleted;

  /// No description provided for @filterCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulés'**
  String get filterCancelled;

  /// No description provided for @noRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande'**
  String get noRequests;

  /// No description provided for @noRequestsAll.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore effectué de demande SOS.'**
  String get noRequestsAll;

  /// No description provided for @noRequestsOngoing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande n\'est actuellement en cours de traitement.'**
  String get noRequestsOngoing;

  /// No description provided for @noRequestsCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez aucune intervention terminée dans votre historique.'**
  String get noRequestsCompleted;

  /// No description provided for @noRequestsCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande annulée trouvée.'**
  String get noRequestsCancelled;

  /// No description provided for @legendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Légende'**
  String get legendTitle;

  /// No description provided for @legendTaken.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get legendTaken;

  /// No description provided for @legendPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get legendPartial;

  /// No description provided for @legendMissed.
  ///
  /// In fr, this message translates to:
  /// **'Raté'**
  String get legendMissed;

  /// No description provided for @legendFuture.
  ///
  /// In fr, this message translates to:
  /// **'Futur'**
  String get legendFuture;

  /// No description provided for @confirmClearHistory.
  ///
  /// In fr, this message translates to:
  /// **'Effacer l\'historique ?'**
  String get confirmClearHistory;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer définitivement toutes vos notifications ? Cette action est irréversible.'**
  String get clearHistoryMessage;

  /// No description provided for @clearAll.
  ///
  /// In fr, this message translates to:
  /// **'Effacer tout'**
  String get clearAll;

  /// No description provided for @confirmLocation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'emplacement'**
  String get confirmLocation;

  /// No description provided for @searchAddress.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une adresse...'**
  String get searchAddress;

  /// No description provided for @step.
  ///
  /// In fr, this message translates to:
  /// **'Étape'**
  String get step;

  /// No description provided for @ofTotal.
  ///
  /// In fr, this message translates to:
  /// **'sur'**
  String get ofTotal;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @medicationDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du médicament'**
  String get medicationDetails;

  /// No description provided for @instructions.
  ///
  /// In fr, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @currentStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock actuel'**
  String get currentStock;

  /// No description provided for @refillStock.
  ///
  /// In fr, this message translates to:
  /// **'Recharger le stock'**
  String get refillStock;

  /// No description provided for @refillTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recharger le stock : {name}'**
  String refillTitle(String name);

  /// No description provided for @quantityToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Quantité rachetée'**
  String get quantityToAdd;

  /// No description provided for @quantityHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: 30'**
  String get quantityHint;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @planning.
  ///
  /// In fr, this message translates to:
  /// **'Médicaments'**
  String get planning;

  /// No description provided for @sos.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get sos;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @frequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get frequency;

  /// No description provided for @takesPerDay.
  ///
  /// In fr, this message translates to:
  /// **'{count} prise(s) par jour'**
  String takesPerDay(int count);

  /// No description provided for @startOfTreatment.
  ///
  /// In fr, this message translates to:
  /// **'Début du traitement'**
  String get startOfTreatment;

  /// No description provided for @endOfTreatment.
  ///
  /// In fr, this message translates to:
  /// **'Fin du traitement'**
  String get endOfTreatment;

  /// No description provided for @stockRefilledSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Stock de {name} renouvelé !'**
  String stockRefilledSuccess(String name);

  /// No description provided for @confirmRefill.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le renouvellement'**
  String get confirmRefill;

  /// No description provided for @newStock.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau stock : {count} unités'**
  String newStock(int count);

  /// No description provided for @noMedsForDay.
  ///
  /// In fr, this message translates to:
  /// **'Aucun médicament prévu pour ce jour'**
  String get noMedsForDay;

  /// No description provided for @regularizeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Régulariser : {name}'**
  String regularizeTitle(String name);

  /// No description provided for @statusPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Prévu'**
  String get statusPlanned;

  /// No description provided for @notificationMedicationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel : {name}'**
  String notificationMedicationTitle(Object name);

  /// No description provided for @notificationMedicationBody.
  ///
  /// In fr, this message translates to:
  /// **'C\'est l\'heure de votre prise ({dosage})'**
  String notificationMedicationBody(Object dosage);

  /// No description provided for @notificationMedicationSnoozeBody.
  ///
  /// In fr, this message translates to:
  /// **'N\'oubliez pas votre prise ({dosage})'**
  String notificationMedicationSnoozeBody(Object dosage);

  /// No description provided for @notificationEndOfDayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan de votre journée'**
  String get notificationEndOfDayTitle;

  /// No description provided for @notificationEndOfDayBody.
  ///
  /// In fr, this message translates to:
  /// **'N\'oubliez pas vos prises de fin de journée.'**
  String get notificationEndOfDayBody;

  /// No description provided for @notificationStockUrgentTitle.
  ///
  /// In fr, this message translates to:
  /// **'URGENT — {name}'**
  String notificationStockUrgentTitle(Object name);

  /// No description provided for @notificationStockLowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible — {name}'**
  String notificationStockLowTitle(Object name);

  /// No description provided for @notificationStockBody.
  ///
  /// In fr, this message translates to:
  /// **'Il reste {count} unité(s).'**
  String notificationStockBody(Object count);

  /// No description provided for @notificationActionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get notificationActionConfirm;

  /// No description provided for @notificationActionSnooze.
  ///
  /// In fr, this message translates to:
  /// **'Rappel dans {minutes} min'**
  String notificationActionSnooze(Object minutes);

  /// No description provided for @chooseProfile.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le type de profil qui vous correspond.'**
  String get chooseProfile;

  /// No description provided for @iAmPatient.
  ///
  /// In fr, this message translates to:
  /// **'Je suis un Patient'**
  String get iAmPatient;

  /// No description provided for @patientDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je souhaite gérer ma santé et celle de mes proches.'**
  String get patientDesc;

  /// No description provided for @iAmProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Je suis un Professionnel'**
  String get iAmProfessional;

  /// No description provided for @professionalDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je souhaite proposer mes services et suivre mes patients.'**
  String get professionalDesc;

  /// No description provided for @missionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Mission en cours'**
  String get missionInProgress;

  /// No description provided for @addressNotSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Adresse non spécifiée'**
  String get addressNotSpecified;

  /// No description provided for @emergenciesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Urgences SOS'**
  String get emergenciesTitle;

  /// No description provided for @noEmergencyNearby.
  ///
  /// In fr, this message translates to:
  /// **'Aucune urgence à proximité'**
  String get noEmergencyNearby;

  /// No description provided for @availableAppointments.
  ///
  /// In fr, this message translates to:
  /// **'RDV Disponibles'**
  String get availableAppointments;

  /// No description provided for @noAppointmentAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous disponible'**
  String get noAppointmentAvailable;

  /// No description provided for @professional.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel'**
  String get professional;

  /// No description provided for @patient.
  ///
  /// In fr, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @professionalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations Professionnelles'**
  String get professionalInfo;

  /// No description provided for @serviceType.
  ///
  /// In fr, this message translates to:
  /// **'Type de service'**
  String get serviceType;

  /// No description provided for @chooseProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un professionnel'**
  String get chooseProfessional;

  /// No description provided for @onDuty.
  ///
  /// In fr, this message translates to:
  /// **'En Service'**
  String get onDuty;

  /// No description provided for @offDuty.
  ///
  /// In fr, this message translates to:
  /// **'Hors Service'**
  String get offDuty;

  /// No description provided for @visioConference.
  ///
  /// In fr, this message translates to:
  /// **'Visio-conférence'**
  String get visioConference;

  /// No description provided for @distConsultation.
  ///
  /// In fr, this message translates to:
  /// **'Consultation à distance'**
  String get distConsultation;

  /// No description provided for @join.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get join;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get start;

  /// No description provided for @inPersonConsultation.
  ///
  /// In fr, this message translates to:
  /// **'Consultation'**
  String get inPersonConsultation;

  /// No description provided for @time.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get time;

  /// No description provided for @cancelMission.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la mission'**
  String get cancelMission;

  /// No description provided for @noProfessionalFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun professionnel trouvé'**
  String get noProfessionalFound;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @agenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @earnings.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get earnings;

  /// No description provided for @onTheWay.
  ///
  /// In fr, this message translates to:
  /// **'En route'**
  String get onTheWay;

  /// No description provided for @estimatedTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps estimé'**
  String get estimatedTime;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @occupation.
  ///
  /// In fr, this message translates to:
  /// **'Votre métier'**
  String get occupation;

  /// No description provided for @proximityRange.
  ///
  /// In fr, this message translates to:
  /// **'Rayon de recherche'**
  String get proximityRange;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @pendingAppointments.
  ///
  /// In fr, this message translates to:
  /// **'RDV en attente'**
  String get pendingAppointments;

  /// No description provided for @todaysAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Mes missions d\'aujourd\'hui'**
  String get todaysAgenda;

  /// No description provided for @appointmentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get appointmentsTitle;

  /// No description provided for @noAppointmentsAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Aucun nouveau rendez-vous assigné'**
  String get noAppointmentsAssigned;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous pour aujourd\'hui'**
  String get noAppointmentsToday;

  /// No description provided for @tooEarlyForAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Il est encore trop tôt pour ce rendez-vous. Revenez 5 min avant.'**
  String get tooEarlyForAppointment;

  /// No description provided for @scheduleConflict.
  ///
  /// In fr, this message translates to:
  /// **'Votre planning est déjà complet à ce moment (marge d\'une heure requise).'**
  String get scheduleConflict;

  /// No description provided for @requestAlreadyTaken.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande a déjà été acceptée par un autre professionnel.'**
  String get requestAlreadyTaken;

  /// No description provided for @appointmentLate.
  ///
  /// In fr, this message translates to:
  /// **'EN RETARD'**
  String get appointmentLate;

  /// No description provided for @alreadyActiveMission.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà une mission active. Terminez-la d\'abord.'**
  String get alreadyActiveMission;

  /// No description provided for @acts.
  ///
  /// In fr, this message translates to:
  /// **'Actes'**
  String get acts;

  /// No description provided for @noMissionRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mission enregistrée'**
  String get noMissionRecorded;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @notificationNewSosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Urgence SOS'**
  String get notificationNewSosTitle;

  /// No description provided for @notificationNewSosBody.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau patient a besoin d\'une assistance immédiate à proximité.'**
  String get notificationNewSosBody;

  /// No description provided for @notificationNewAppointmentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Rendez-vous'**
  String get notificationNewAppointmentTitle;

  /// No description provided for @notificationNewAppointmentBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez reçu une nouvelle demande de rendez-vous.'**
  String get notificationNewAppointmentBody;

  /// No description provided for @notificationSosAcceptedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande Acceptée'**
  String get notificationSosAcceptedTitle;

  /// No description provided for @notificationSosAcceptedBody.
  ///
  /// In fr, this message translates to:
  /// **'Un professionnel a accepté votre demande : {name}'**
  String notificationSosAcceptedBody(Object name);

  /// No description provided for @notificationSosOnTheWayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel en route'**
  String get notificationSosOnTheWayTitle;

  /// No description provided for @notificationSosOnTheWayBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} est en route vers votre position.'**
  String notificationSosOnTheWayBody(Object name);

  /// No description provided for @notificationSosInProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Téléconsultation démarrée'**
  String get notificationSosInProgressTitle;

  /// No description provided for @notificationSosInProgressBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} vous attend pour la consultation vidéo.'**
  String notificationSosInProgressBody(Object name);

  /// No description provided for @notificationSosCancelledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Intervention annulée'**
  String get notificationSosCancelledTitle;

  /// No description provided for @notificationSosCancelledBody.
  ///
  /// In fr, this message translates to:
  /// **'La demande a été annulée.'**
  String get notificationSosCancelledBody;

  /// No description provided for @notificationSosCancelledByPatientBody.
  ///
  /// In fr, this message translates to:
  /// **'Le patient a annulé son intervention.'**
  String get notificationSosCancelledByPatientBody;

  /// No description provided for @notificationSosCancelledByProBody.
  ///
  /// In fr, this message translates to:
  /// **'Le professionnel a dû annuler l\'intervention.'**
  String get notificationSosCancelledByProBody;

  /// No description provided for @notificationSosRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande Refusée'**
  String get notificationSosRejectedTitle;

  /// No description provided for @notificationSosRejectedBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} a refusé votre demande.'**
  String notificationSosRejectedBody(Object name);

  /// No description provided for @notificationSosRejectedBodyGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande a été refusée. Vous pouvez réessayer avec un autre professionnel.'**
  String get notificationSosRejectedBodyGeneric;

  /// No description provided for @notificationNewRatingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle évaluation'**
  String get notificationNewRatingTitle;

  /// No description provided for @notificationNewRatingBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} vous a donné une note de {rating} étoiles !'**
  String notificationNewRatingBody(String name, int rating);

  /// No description provided for @afternoon.
  ///
  /// In fr, this message translates to:
  /// **'Après-midi'**
  String get afternoon;

  /// No description provided for @availableTimeSlots.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux disponibles'**
  String get availableTimeSlots;

  /// No description provided for @noAvailableSlots.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible'**
  String get noAvailableSlots;

  /// No description provided for @tryAnotherDate.
  ///
  /// In fr, this message translates to:
  /// **'Essayez une autre date'**
  String get tryAnotherDate;

  /// No description provided for @chooseTimeSlot.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir un créneau horaire'**
  String get chooseTimeSlot;

  /// No description provided for @profileSetup.
  ///
  /// In fr, this message translates to:
  /// **'Configuration du profil'**
  String get profileSetup;

  /// No description provided for @completeProProfile.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre profil professionnel'**
  String get completeProProfile;

  /// No description provided for @proSetupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations sont nécessaires pour valider votre compte.'**
  String get proSetupSubtitle;

  /// No description provided for @verificationDocs.
  ///
  /// In fr, this message translates to:
  /// **'Documents de vérification'**
  String get verificationDocs;

  /// No description provided for @cniFront.
  ///
  /// In fr, this message translates to:
  /// **'Carte d\'identité (Recto)'**
  String get cniFront;

  /// No description provided for @cniBack.
  ///
  /// In fr, this message translates to:
  /// **'Carte d\'identité (Verso)'**
  String get cniBack;

  /// No description provided for @diploma.
  ///
  /// In fr, this message translates to:
  /// **'Diplôme / Attestation'**
  String get diploma;

  /// No description provided for @authorization.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation d\'exercer'**
  String get authorization;

  /// No description provided for @vehicleRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Carte grise'**
  String get vehicleRegistration;

  /// No description provided for @transportAuth.
  ///
  /// In fr, this message translates to:
  /// **'Agrément de transport'**
  String get transportAuth;

  /// No description provided for @validationPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en cours'**
  String get validationPendingTitle;

  /// No description provided for @validationPendingMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre dossier est en cours d\'examen par nos services.'**
  String get validationPendingMessage;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @validationRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dossier non validé'**
  String get validationRejectedTitle;

  /// No description provided for @validationRejectedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nous n\'avons pas pu valider votre profil professionnel pour le moment. '**
  String get validationRejectedMessage;

  /// No description provided for @updateDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour mes documents'**
  String get updateDocuments;

  /// No description provided for @updateDocumentsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Corrigez et renvoyez vos fichiers'**
  String get updateDocumentsSubtitle;

  /// No description provided for @contactSupportMessage.
  ///
  /// In fr, this message translates to:
  /// **'Pensez à contacter le support MSD si vous avez besoin d\'aide : support@msd.ma'**
  String get contactSupportMessage;

  /// No description provided for @startOver.
  ///
  /// In fr, this message translates to:
  /// **'Besoin de repartir à zéro ?'**
  String get startOver;

  /// No description provided for @validationStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut de validation'**
  String get validationStatus;

  /// No description provided for @validated.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get validated;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @chronicDiseases.
  ///
  /// In fr, this message translates to:
  /// **'Maladies Chroniques'**
  String get chronicDiseases;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skip;

  /// No description provided for @adminManagementTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils de gestion'**
  String get adminManagementTools;

  /// No description provided for @adminProfessionals.
  ///
  /// In fr, this message translates to:
  /// **'Professionnels'**
  String get adminProfessionals;

  /// No description provided for @adminManageNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le réseau'**
  String get adminManageNetwork;

  /// No description provided for @adminPatients.
  ///
  /// In fr, this message translates to:
  /// **'Patients'**
  String get adminPatients;

  /// No description provided for @adminFullList.
  ///
  /// In fr, this message translates to:
  /// **'Liste complète'**
  String get adminFullList;

  /// No description provided for @adminSosMonitor.
  ///
  /// In fr, this message translates to:
  /// **'Moniteur SOS'**
  String get adminSosMonitor;

  /// No description provided for @adminLiveFlow.
  ///
  /// In fr, this message translates to:
  /// **'Flux en direct'**
  String get adminLiveFlow;

  /// No description provided for @adminWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, Admin'**
  String get adminWelcome;

  /// No description provided for @adminPlatformStatus.
  ///
  /// In fr, this message translates to:
  /// **'État de la plateforme'**
  String get adminPlatformStatus;

  /// No description provided for @adminTotalSos.
  ///
  /// In fr, this message translates to:
  /// **'Total SOS'**
  String get adminTotalSos;

  /// No description provided for @adminMissions.
  ///
  /// In fr, this message translates to:
  /// **'Missions'**
  String get adminMissions;

  /// No description provided for @adminValidatedPros.
  ///
  /// In fr, this message translates to:
  /// **'Pros validés'**
  String get adminValidatedPros;

  /// No description provided for @adminSosDistribution.
  ///
  /// In fr, this message translates to:
  /// **'Distribution SOS'**
  String get adminSosDistribution;

  /// No description provided for @adminDoctors.
  ///
  /// In fr, this message translates to:
  /// **'Médecins'**
  String get adminDoctors;

  /// No description provided for @adminAmbulances.
  ///
  /// In fr, this message translates to:
  /// **'Ambulances'**
  String get adminAmbulances;

  /// No description provided for @adminNurses.
  ///
  /// In fr, this message translates to:
  /// **'Infirmiers'**
  String get adminNurses;

  /// No description provided for @adminTeleconsult.
  ///
  /// In fr, this message translates to:
  /// **'Téléconsultations'**
  String get adminTeleconsult;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
