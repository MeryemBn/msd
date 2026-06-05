// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileTitle => 'My Profile';

  @override
  String get personalInfo => 'PERSONAL INFORMATION';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get call => 'Call';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get medicalInfo => 'MEDICAL INFORMATION';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get allergies => 'Allergies';

  @override
  String get history => 'Medical History';

  @override
  String get insurance => 'Insurance';

  @override
  String get settings => 'SETTINGS';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Do you really want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get msdTagline => 'Your health, at your fingertips';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'e.g. sarah.martin';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Login';

  @override
  String get orDivider => 'OR';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create your account';

  @override
  String get registerSubtitle =>
      'Please fill in the information below to start your registration.';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'e.g. Sarah';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'e.g. Martin';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordMinChars => 'Min. 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get splashSubtitle =>
      'Connect instantly with qualified healthcare professionals';

  @override
  String get getStarted => 'Get Started';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address to receive a reset link.';

  @override
  String get sendLink => 'Send link';

  @override
  String get emailSentTitle => 'Email sent!';

  @override
  String emailSentSubtitle(String email) {
    return 'If an account exists for $email, a recovery email has been sent.';
  }

  @override
  String get backToLogin => 'Back to login';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'A confirmation link has been sent to $email. Please click on it to activate your account.';
  }

  @override
  String get hello => 'Hello ';

  @override
  String get sosServices => 'SOS SERVICES';

  @override
  String get onDutyPharmacy => 'On-duty Pharmacy';

  @override
  String get findNearest => 'Find nearest';

  @override
  String get allDosesDone => 'Daily course completed!';

  @override
  String get allDosesDoneSubtitle =>
      'All your doses are up to date for today. 👋';

  @override
  String get doseConfirmed => 'DOSE CONFIRMED';

  @override
  String get doseLate => 'LATE DOSE';

  @override
  String get nextDose => 'NEXT DOSE';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'You haven\'t received any messages yet.';

  @override
  String get clearNotificationsTitle => 'Clear notifications';

  @override
  String get clearNotificationsMessage =>
      'Do you really want to clear all history?';

  @override
  String get planningTitle => 'Planning & Tracking';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get details => 'Details';

  @override
  String get period => 'Period';

  @override
  String get times => 'Times';

  @override
  String get reminders => 'Reminders';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationNameHint => 'e.g. Paracetamol';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'e.g. 500mg';

  @override
  String get instruction => 'Instruction';

  @override
  String get startDate => 'Start Date';

  @override
  String get duration => 'Duration (days)';

  @override
  String get durationHint => 'e.g. 7';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get stockHint => 'e.g. 30';

  @override
  String get intakeTimes => 'Intake Times';

  @override
  String get addTimeHint => 'Click + to add a time';

  @override
  String get reminderIntensity => 'Reminder Intensity';

  @override
  String get notificationAlert => 'Notification';

  @override
  String get notificationSubtitle => 'A subtle alert';

  @override
  String get alarmAlert => 'Alarm';

  @override
  String get alarmSubtitle => 'Persistent ringtone';

  @override
  String notifyBefore(int minutes) {
    return 'Notify how many minutes before? ($minutes min)';
  }

  @override
  String get snoozeInterval => 'Snooze Interval';

  @override
  String get finish => 'Finish';

  @override
  String get next => 'Next';

  @override
  String get duringMeal => 'During meal';

  @override
  String get beforeMeal => 'Before meal';

  @override
  String get onEmptyStomach => 'On empty stomach';

  @override
  String get afterMeal => 'After meal';

  @override
  String get medicationNameRequired => 'Medication name is required';

  @override
  String get atLeastOneTimeRequired => 'Please add at least one intake time';

  @override
  String snooze(int minutes) {
    return 'Snooze ($minutes min)';
  }

  @override
  String get confirmTake => 'Confirm intake';

  @override
  String until(String date) {
    return 'Until $date';
  }

  @override
  String daysRemaining(int count) {
    return '$count d. remaining';
  }

  @override
  String get finishesToday => 'Ends today';

  @override
  String get criticalStock => 'Critical stock';

  @override
  String get lowStock => 'Low stock';

  @override
  String unitsRemaining(int count) {
    return '$count unit(s) remaining';
  }

  @override
  String get morning => 'Morning';

  @override
  String get noon => 'Noon';

  @override
  String get evening => 'Evening';

  @override
  String get bedtime => 'Bedtime';

  @override
  String actionFor(String name) {
    return 'Action for $name';
  }

  @override
  String get tooEarly => 'It is still too early for this intake';

  @override
  String get lateStatus => 'Late intake!';

  @override
  String get markAsTaken => 'Mark as taken';

  @override
  String get markAsMissed => 'Mark as missed';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get doctor => 'Doctor';

  @override
  String get teleconsultation => 'Teleconsultation';

  @override
  String get nurse => 'Nurse';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get myMedications => 'My Medications';

  @override
  String get dayTimeline => 'Today\'s Timeline';

  @override
  String get calendarAndTracking => 'Calendar & Tracking';

  @override
  String get noMedicationsToday => 'No medications for today';

  @override
  String get yourRequest => 'Your Request';

  @override
  String get specifySpecialtyAndIntervention =>
      'Specify the specialty and type of intervention';

  @override
  String get specialty => 'Specialty';

  @override
  String get chooseSpecialty => 'Choose a specialty';

  @override
  String get interventionType => 'Type of intervention';

  @override
  String get sosUrgency => 'Urgency (SOS)';

  @override
  String get sosUrgencyDesc => 'Closest available professional';

  @override
  String get appointment => 'By Appointment';

  @override
  String get appointmentDesc => 'Choose a date and time';

  @override
  String get continueText => 'Continue';

  @override
  String get confirmRequest => 'Confirm request';

  @override
  String get chooseInterventionType => 'Please choose an intervention type';

  @override
  String get requestSent => 'Request sent!';

  @override
  String get homeCare => 'Home care';

  @override
  String get specifyAmbulanceType => 'Specify ambulance type and intervention';

  @override
  String get ambulanceType => 'Ambulance type';

  @override
  String get chooseAmbulanceType => 'Choose ambulance type';

  @override
  String get interventionAddress => 'Intervention Address';

  @override
  String get specifyLocation => 'Specify the location where help is expected';

  @override
  String get exactAddress => 'Exact address';

  @override
  String get addressHint => 'Street, Neighborhood...';

  @override
  String get apartment => 'Appt / House';

  @override
  String get apartmentHint => 'e.g. Apt 4B';

  @override
  String get floor => 'Floor';

  @override
  String get floorHint => 'e.g. 2nd';

  @override
  String get entryCode => 'Entry code';

  @override
  String get entryCodeHint => 'e.g. A123';

  @override
  String gpsActivation(String error) {
    return 'Please enable your GPS: $error';
  }

  @override
  String get payment => 'Payment';

  @override
  String get choosePaymentMethod => 'Choose your payment method';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get consultationFee => 'Consultation fee';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentCashDesc => 'Pay on-site to the professional';

  @override
  String get paymentCard => 'Bank Card';

  @override
  String get paymentCardDesc => 'Secure pre-authorization';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusOnTheWay => 'On the way';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get specGeneral => 'General Medicine';

  @override
  String get specCardio => 'Cardiology';

  @override
  String get specDerma => 'Dermatology';

  @override
  String get specPediatry => 'Pediatrics';

  @override
  String get specGyneco => 'Gynecology';

  @override
  String get specOphtalmo => 'Ophthalmology';

  @override
  String get specOrl => 'ENT';

  @override
  String get specNeuro => 'Neurology';

  @override
  String get specPsychiatry => 'Psychiatry';

  @override
  String get specRhumato => 'Rheumatology';

  @override
  String get specGastro => 'Gastroenterology';

  @override
  String get specPneumo => 'Pulmonology';

  @override
  String get specUro => 'Urology';

  @override
  String get specEndocri => 'Endocrinology';

  @override
  String get specOrtho => 'Orthopedics';

  @override
  String get ambSmur => 'Medicalized ambulance (SMUR)';

  @override
  String get ambRea => 'Resuscitation ambulance';

  @override
  String get ambSanitary => 'Sanitary ambulance (standard)';

  @override
  String get ambVsl => 'VSL (Light Sanitary Vehicle)';

  @override
  String get specifyTeleconsult =>
      'Specify the specialty for your video consultation';

  @override
  String get appointmentDate => 'Appointment Date';

  @override
  String get desiredTime => 'Desired Time';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get realTimeTracking => 'Real-time tracking';

  @override
  String get proOnTheWay => 'Professional on the way';

  @override
  String get identityVerified => 'Identity verified by MSD';

  @override
  String get dateAndTime => 'DATE & TIME';

  @override
  String get addressLabel => 'ADDRESS';

  @override
  String get itinerary => 'Itinerary';

  @override
  String get professionalLabel => 'PROFESSIONAL';

  @override
  String get estimatedAmount => 'ESTIMATED AMOUNT';

  @override
  String get noteLabel => 'NOTE';

  @override
  String get cancelledByUser => 'Cancelled by user';

  @override
  String get rejectedByProfessional => 'Rejected by the professional';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelRequestConfirmTitle => 'Cancel request?';

  @override
  String get cancelRequestConfirmMessage =>
      'Are you sure you want to cancel this SOS request? This action is irreversible.';

  @override
  String get keepRequest => 'No, keep';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get requestCancelledSuccess => 'Request cancelled successfully';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String videoConsultation(String specialty) {
    return 'Video consultation • $specialty';
  }

  @override
  String get joinTeleconsultation => 'Join teleconsultation';

  @override
  String get healthServices => 'Health services';

  @override
  String get assigned => 'Assigned';

  @override
  String get waiting => 'Waiting...';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get city => 'City';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get insuranceLabel => 'Insurance (Policy No. / Type)';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get noneProvided => 'None provided';

  @override
  String get add => 'Add';

  @override
  String addTitle(String title) {
    return 'Add: $title';
  }

  @override
  String get description => 'Description';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get myRequestsTitle => 'My requests';

  @override
  String get filterAll => 'All';

  @override
  String get filterOngoing => 'Ongoing';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get noRequests => 'No requests';

  @override
  String get noRequestsAll => 'You haven\'t made any SOS requests yet.';

  @override
  String get noRequestsOngoing => 'No requests are currently being processed.';

  @override
  String get noRequestsCompleted =>
      'You have no completed interventions in your history.';

  @override
  String get noRequestsCancelled => 'No cancelled requests found.';

  @override
  String get legendTitle => 'Legend';

  @override
  String get legendTaken => 'Completed';

  @override
  String get legendPartial => 'Partial';

  @override
  String get legendMissed => 'Missed';

  @override
  String get legendFuture => 'Future';

  @override
  String get confirmClearHistory => 'Clear history?';

  @override
  String get clearHistoryMessage =>
      'Do you want to permanently delete all your notifications? This action is irreversible.';

  @override
  String get clearAll => 'Clear all';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get searchAddress => 'Search an address...';

  @override
  String get step => 'Step';

  @override
  String get ofTotal => 'of';

  @override
  String get loading => 'Loading...';

  @override
  String get medicationDetails => 'Medication details';

  @override
  String get instructions => 'Instructions';

  @override
  String get currentStock => 'Current stock';

  @override
  String get refillStock => 'Refill stock';

  @override
  String refillTitle(String name) {
    return 'Refill stock: $name';
  }

  @override
  String get quantityToAdd => 'Refilled quantity';

  @override
  String get quantityHint => 'e.g. 30';

  @override
  String get home => 'Home';

  @override
  String get planning => 'Medications';

  @override
  String get sos => 'Requests';

  @override
  String get profile => 'Profile';

  @override
  String get frequency => 'Frequency';

  @override
  String takesPerDay(int count) {
    return '$count take(s) per day';
  }

  @override
  String get startOfTreatment => 'Start of treatment';

  @override
  String get endOfTreatment => 'End of treatment';

  @override
  String stockRefilledSuccess(String name) {
    return 'Stock of $name refined!';
  }

  @override
  String get confirmRefill => 'Confirm refill';

  @override
  String newStock(int count) {
    return 'New stock: $count units';
  }

  @override
  String get noMedsForDay => 'No medications scheduled for this day';

  @override
  String regularizeTitle(String name) {
    return 'Regularize: $name';
  }

  @override
  String get statusPlanned => 'Planned';

  @override
  String notificationMedicationTitle(Object name) {
    return 'Reminder: $name';
  }

  @override
  String notificationMedicationBody(Object dosage) {
    return 'It\'s time to take your medicine ($dosage)';
  }

  @override
  String notificationMedicationSnoozeBody(Object dosage) {
    return 'Don\'t forget to take your medicine ($dosage)';
  }

  @override
  String get notificationEndOfDayTitle => 'Daily Summary';

  @override
  String get notificationEndOfDayBody => 'Don\'t forget your end-of-day doses.';

  @override
  String notificationStockUrgentTitle(Object name) {
    return 'URGENT — $name';
  }

  @override
  String notificationStockLowTitle(Object name) {
    return 'Low Stock — $name';
  }

  @override
  String notificationStockBody(Object count) {
    return 'There are $count unit(s) remaining.';
  }

  @override
  String get notificationActionConfirm => 'Confirm';

  @override
  String notificationActionSnooze(Object minutes) {
    return 'Remind me in $minutes min';
  }

  @override
  String get chooseProfile =>
      'Choose the type of profile that corresponds to you.';

  @override
  String get iAmPatient => 'I am a Patient';

  @override
  String get patientDesc =>
      'I want to manage my health and that of my relatives.';

  @override
  String get iAmProfessional => 'I am a Professional';

  @override
  String get professionalDesc =>
      'I want to offer my services and follow my patients.';

  @override
  String get missionInProgress => 'Mission in progress';

  @override
  String get addressNotSpecified => 'Address not specified';

  @override
  String get emergenciesTitle => 'SOS Emergencies';

  @override
  String get noEmergencyNearby => 'No emergency nearby';

  @override
  String get availableAppointments => 'Available Appointments';

  @override
  String get noAppointmentAvailable => 'No appointment available';

  @override
  String get professional => 'Professional';

  @override
  String get patient => 'Patient';

  @override
  String get professionalInfo => 'Professional Information';

  @override
  String get serviceType => 'Service Type';

  @override
  String get chooseProfessional => 'Choose a Professional';

  @override
  String get onDuty => 'On Duty';

  @override
  String get offDuty => 'Off Duty';

  @override
  String get visioConference => 'Visio-conference';

  @override
  String get distConsultation => 'Distance Consultation';

  @override
  String get join => 'Join';

  @override
  String get done => 'Done';

  @override
  String get start => 'Start';

  @override
  String get inPersonConsultation => 'Consultation';

  @override
  String get time => 'Time';

  @override
  String get cancelMission => 'Cancel Mission';

  @override
  String get noProfessionalFound => 'No professional found';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get agenda => 'Agenda';

  @override
  String get earnings => 'Earnings';

  @override
  String get onTheWay => 'On the way';

  @override
  String get estimatedTime => 'Estimated time';

  @override
  String get distance => 'Distance';

  @override
  String get user => 'User';

  @override
  String get occupation => 'Your occupation';

  @override
  String get proximityRange => 'Search range';

  @override
  String get available => 'Available';

  @override
  String get pendingAppointments => 'Pending Appointments';

  @override
  String get todaysAgenda => 'My missions for today';

  @override
  String get appointmentsTitle => 'My Appointments';

  @override
  String get noAppointmentsAssigned => 'No new appointments assigned';

  @override
  String get noAppointmentsToday => 'No appointments for today';

  @override
  String get tooEarlyForAppointment =>
      'It is still too early for this appointment. Come back 5 min before.';

  @override
  String get scheduleConflict =>
      'Your schedule is already full at this time (one hour margin required).';

  @override
  String get requestAlreadyTaken =>
      'This request has already been accepted by another professional.';

  @override
  String get appointmentLate => 'LATE';

  @override
  String get alreadyActiveMission =>
      'You already have an active mission. Finish it first.';

  @override
  String get acts => 'Acts';

  @override
  String get noMissionRecorded => 'No missions recorded';

  @override
  String get today => 'Today';

  @override
  String get notificationNewSosTitle => 'New SOS Urgency';

  @override
  String get notificationNewSosBody =>
      'A new patient needs immediate assistance nearby.';

  @override
  String get notificationNewAppointmentTitle => 'New Appointment';

  @override
  String get notificationNewAppointmentBody =>
      'You have received a new appointment request.';

  @override
  String get notificationSosAcceptedTitle => 'Request Accepted';

  @override
  String notificationSosAcceptedBody(Object name) {
    return 'A professional has accepted your request: $name';
  }

  @override
  String get notificationSosOnTheWayTitle => 'Professional on the way';

  @override
  String notificationSosOnTheWayBody(Object name) {
    return '$name is on the way to your location.';
  }

  @override
  String get notificationSosInProgressTitle => 'Teleconsultation started';

  @override
  String notificationSosInProgressBody(Object name) {
    return '$name is waiting for you for the video consultation.';
  }

  @override
  String get notificationSosCancelledTitle => 'Intervention cancelled';

  @override
  String get notificationSosCancelledBody => 'The request has been cancelled.';

  @override
  String get notificationSosCancelledByPatientBody =>
      'The patient cancelled their intervention.';

  @override
  String get notificationSosCancelledByProBody =>
      'The professional had to cancel the intervention.';

  @override
  String get notificationSosRejectedTitle => 'Request Declined';

  @override
  String notificationSosRejectedBody(Object name) {
    return '$name has declined your request.';
  }

  @override
  String get notificationSosRejectedBodyGeneric =>
      'Your request was declined. You can try again with another professional.';

  @override
  String get notificationNewRatingTitle => 'New Rating';

  @override
  String notificationNewRatingBody(String name, int rating) {
    return '$name gave you a $rating star rating!';
  }

  @override
  String get afternoon => 'Afternoon';

  @override
  String get availableTimeSlots => 'Available Time Slots';

  @override
  String get noAvailableSlots => 'No available slots';

  @override
  String get tryAnotherDate => 'Try another date';

  @override
  String get chooseTimeSlot => 'Please choose a time slot';

  @override
  String get profileSetup => 'Profile Setup';

  @override
  String get completeProProfile => 'Complete your professional profile';

  @override
  String get proSetupSubtitle =>
      'This information is required to validate your account.';

  @override
  String get verificationDocs => 'Verification Documents';

  @override
  String get cniFront => 'ID Card (Front)';

  @override
  String get cniBack => 'ID Card (Back)';

  @override
  String get diploma => 'Diploma / Certificate';

  @override
  String get authorization => 'Professional Authorization';

  @override
  String get vehicleRegistration => 'Vehicle Registration';

  @override
  String get transportAuth => 'Transport Authorization';

  @override
  String get validationPendingTitle => 'Verification in progress';

  @override
  String get validationPendingMessage =>
      'Your file is being reviewed by our services.';

  @override
  String get refresh => 'Refresh';

  @override
  String get validationRejectedTitle => 'File not validated';

  @override
  String get validationRejectedMessage =>
      'We could not validate your professional profile at this time. ';

  @override
  String get updateDocuments => 'Update my documents';

  @override
  String get updateDocumentsSubtitle => 'Correct and resend your files';

  @override
  String get contactSupportMessage =>
      'Please contact MSD support if you need help: support@msd.ma';

  @override
  String get startOver => 'Need to start over?';

  @override
  String get validationStatus => 'Validation Status';

  @override
  String get validated => 'Validated';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get chronicDiseases => 'Chronic Diseases';

  @override
  String get skip => 'Skip';

  @override
  String get adminManagementTools => 'Management Tools';

  @override
  String get adminProfessionals => 'Professionals';

  @override
  String get adminManageNetwork => 'Manage network';

  @override
  String get adminPatients => 'Patients';

  @override
  String get adminFullList => 'Full list';

  @override
  String get adminSosMonitor => 'SOS Monitor';

  @override
  String get adminLiveFlow => 'Live flow';

  @override
  String get adminWelcome => 'Welcome, Admin';

  @override
  String get adminPlatformStatus => 'Platform Status';

  @override
  String get adminTotalSos => 'Total SOS';

  @override
  String get adminMissions => 'Missions';

  @override
  String get adminValidatedPros => 'Validated Pros';

  @override
  String get adminSosDistribution => 'SOS Distribution';

  @override
  String get adminDoctors => 'Doctors';

  @override
  String get adminAmbulances => 'Ambulances';

  @override
  String get adminNurses => 'Nurses';

  @override
  String get adminTeleconsult => 'Teleconsultations';
}
