// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get personalInfo => 'معلومات شخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'الهاتف';

  @override
  String get call => 'اتصال';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get address => 'العنوان';

  @override
  String get medicalInfo => 'معلومات طبية';

  @override
  String get bloodType => 'فصيلة الدم';

  @override
  String get allergies => 'الحساسية';

  @override
  String get history => 'السجل الطبي';

  @override
  String get insurance => 'التأمين';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل تريد حقًا تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get msdTagline => 'صحتك بين يديك';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameHint => 'مثال: sarah.martin';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get createAccount => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'يرجى ملء المعلومات أدناه لبدء عملية التسجيل.';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get firstNameHint => 'مثال: سارة';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get lastNameHint => 'مثال: مارتن';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordMinChars => '8 أحرف على الأقل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أكد كلمة المرور الخاصة بك';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get splashSubtitle => 'تواصل فوراً مع أخصائيي رعاية صحية مؤهلين';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.';

  @override
  String get sendLink => 'إرسال الرابط';

  @override
  String get emailSentTitle => 'تم إرسال البريد!';

  @override
  String emailSentSubtitle(String email) {
    return 'إذا كان هناك حساب مسجل بـ $email، فقد تم إرسال بريد استرداد.';
  }

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String verifyEmailSubtitle(String email) {
    return 'تم إرسال رابط تأكيد إلى $email. يرجى النقر عليه لتفعيل حسابك.';
  }

  @override
  String get hello => 'مرحباً ';

  @override
  String get sosServices => 'خدمات SOS';

  @override
  String get onDutyPharmacy => 'صيدلية الحراسة';

  @override
  String get findNearest => 'ابحث عن الأقرب';

  @override
  String get allDosesDone => 'اكتمل المسار اليومي!';

  @override
  String get allDosesDoneSubtitle => 'جميع جرعاتك محدثة لهذا اليوم. 👋';

  @override
  String get doseConfirmed => 'تم تأكيد الجرعة';

  @override
  String get doseLate => 'جرعة متأخرة';

  @override
  String get nextDose => 'الجرعة القادمة';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noNotificationsSubtitle => 'لم تتلق أي رسائل بعد.';

  @override
  String get clearNotificationsTitle => 'مسح الإشعارات';

  @override
  String get clearNotificationsMessage => 'هل تريد حقاً مسح جميع السجلات؟';

  @override
  String get planningTitle => 'التخطيط والمتابعة';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get details => 'التفاصيل';

  @override
  String get period => 'الفترة';

  @override
  String get times => 'الأوقات';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get medicationNameHint => 'مثال: باراسيتامول';

  @override
  String get dosage => 'الجرعة';

  @override
  String get dosageHint => 'مثال: 500 ملغ';

  @override
  String get instruction => 'التعليمات';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get duration => 'مدة العلاج (بالأيام)';

  @override
  String get durationHint => 'مثال: 7';

  @override
  String get initialStock => 'المخزون الأولي';

  @override
  String get stockHint => 'مثال: 30';

  @override
  String get intakeTimes => 'أوقات التناول';

  @override
  String get addTimeHint => 'انقر على + لإضافة وقت';

  @override
  String get reminderIntensity => 'شدة التذكير';

  @override
  String get notificationAlert => 'إشعار';

  @override
  String get notificationSubtitle => 'تنبيه هادئ';

  @override
  String get alarmAlert => 'منبه';

  @override
  String get alarmSubtitle => 'نغمة رنين مستمرة';

  @override
  String notifyBefore(int minutes) {
    return 'تنبيه قبل كم دقيقة؟ ($minutes دقيقة)';
  }

  @override
  String get snoozeInterval => 'فاصل التكرار (Snooze)';

  @override
  String get finish => 'إنهاء';

  @override
  String get next => 'التالي';

  @override
  String get duringMeal => 'أثناء الطعام';

  @override
  String get beforeMeal => 'قبل الطعام';

  @override
  String get onEmptyStomach => 'على الريق';

  @override
  String get afterMeal => 'بعد الطعام';

  @override
  String get medicationNameRequired => 'اسم الدواء مطلوب';

  @override
  String get atLeastOneTimeRequired => 'يرجى إضافة وقت تناول واحد على الأقل';

  @override
  String snooze(int minutes) {
    return 'تكرار ($minutes دقيقة)';
  }

  @override
  String get confirmTake => 'تأكيد التناول';

  @override
  String until(String date) {
    return 'حتى $date';
  }

  @override
  String daysRemaining(int count) {
    return 'باقي $count أيام';
  }

  @override
  String get finishesToday => 'ينتهي اليوم';

  @override
  String get criticalStock => 'مخزون حرج';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String unitsRemaining(int count) {
    return 'باقي $count وحدة';
  }

  @override
  String get morning => 'صباحا';

  @override
  String get noon => 'ظهراً';

  @override
  String get evening => 'مساءً';

  @override
  String get bedtime => 'عند النوم';

  @override
  String actionFor(String name) {
    return 'إجراء لـ $name';
  }

  @override
  String get tooEarly => 'لا يزال الوقت مبكراً جداً لهذا التناول';

  @override
  String get lateStatus => 'تأخر التناول!';

  @override
  String get markAsTaken => 'تحديد كمأخوذ';

  @override
  String get markAsMissed => 'تحديد كفائت';

  @override
  String get reschedule => 'تغيير الموعد';

  @override
  String get doctor => 'طبيب';

  @override
  String get teleconsultation => 'استشارة عن بعد';

  @override
  String get nurse => 'ممرض';

  @override
  String get ambulance => 'إسعاف';

  @override
  String get myMedications => 'أدويتي';

  @override
  String get dayTimeline => 'جدول اليوم';

  @override
  String get calendarAndTracking => 'التقويم والمتابعة';

  @override
  String get noMedicationsToday => 'لا توجد أدوية لليوم';

  @override
  String get yourRequest => 'طلبك';

  @override
  String get specifySpecialtyAndIntervention => 'حدد التخصص ونوع التدخل';

  @override
  String get specialty => 'التخصص';

  @override
  String get chooseSpecialty => 'اختر تخصصاً';

  @override
  String get interventionType => 'نوع التدخل';

  @override
  String get sosUrgency => 'حالة طارئة (SOS)';

  @override
  String get sosUrgencyDesc => 'أقرب محترف متاح';

  @override
  String get appointment => 'بموعد';

  @override
  String get appointmentDesc => 'اختر التاريخ والوقت';

  @override
  String get continueText => 'متابعة';

  @override
  String get confirmRequest => 'تأكيد الطلب';

  @override
  String get chooseInterventionType => 'يرجى اختيار نوع التدخل';

  @override
  String get requestSent => 'تم إرسال الطلب!';

  @override
  String get homeCare => 'رعاية منزلية';

  @override
  String get specifyAmbulanceType => 'حدد نوع الإسعاف والتدخل';

  @override
  String get ambulanceType => 'نوع الإسعاف';

  @override
  String get chooseAmbulanceType => 'اختر نوع الإسعاف';

  @override
  String get interventionAddress => 'عنوان التدخل';

  @override
  String get specifyLocation => 'حدد الموقع الذي يتوقع فيه المساعدة';

  @override
  String get exactAddress => 'العنوان الدقيق';

  @override
  String get addressHint => 'الشارع، الحي...';

  @override
  String get apartment => 'شقة / منزل';

  @override
  String get apartmentHint => 'مثال: شقة 4B';

  @override
  String get floor => 'الطابق';

  @override
  String get floorHint => 'مثال: الثاني';

  @override
  String get entryCode => 'رمز الدخول';

  @override
  String get entryCodeHint => 'مثال: A123';

  @override
  String gpsActivation(String error) {
    return 'يرجى تفعيل نظام تحديد المواقع (GPS): $error';
  }

  @override
  String get payment => 'الدفع';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get consultationFee => 'رسوم الاستشارة';

  @override
  String get paymentCash => 'نقداً';

  @override
  String get paymentCashDesc => 'الدفع في الموقع للمحترف';

  @override
  String get paymentCard => 'بطاقة مصرفية';

  @override
  String get paymentCardDesc => 'تفويض مسبق آمن';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'تم التأكيد';

  @override
  String get statusOnTheWay => 'في الطريق';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get specGeneral => 'الطب العام';

  @override
  String get specCardio => 'طب القلب';

  @override
  String get specDerma => 'طب الأمراض الجلدية';

  @override
  String get specPediatry => 'طب الأطفال';

  @override
  String get specGyneco => 'طب النساء';

  @override
  String get specOphtalmo => 'طب العيون';

  @override
  String get specOrl => 'طب الأنف والأذن الحنجرة';

  @override
  String get specNeuro => 'طب الأعصاب';

  @override
  String get specPsychiatry => 'الطب النفسي';

  @override
  String get specRhumato => 'طب الروماتيزم';

  @override
  String get specGastro => 'طب الجهاز الهضمي';

  @override
  String get specPneumo => 'طب الأمراض الصدرية';

  @override
  String get specUro => 'طب المسالك البولية';

  @override
  String get specEndocri => 'طب الغدد الصماء';

  @override
  String get specOrtho => 'طب العظام';

  @override
  String get ambSmur => 'سيارة إسعاف مجهزة (SMUR)';

  @override
  String get ambRea => 'سيارة إسعاف إنعاش';

  @override
  String get ambSanitary => 'سيارة إسعاف عادية';

  @override
  String get ambVsl => 'سيارة نقل صحي خفيف (VSL)';

  @override
  String get specifyTeleconsult => 'حدد التخصص لاستشارتك عبر الفيديو';

  @override
  String get appointmentDate => 'تاريخ الموعد';

  @override
  String get desiredTime => 'الوقت المطلوب';

  @override
  String get chooseDate => 'اختر تاريخاً';

  @override
  String get realTimeTracking => 'تتبع في الوقت الفعلي';

  @override
  String get proOnTheWay => 'المحترف في الطريق';

  @override
  String get identityVerified => 'الهوية معتمدة من MSD';

  @override
  String get dateAndTime => 'التاريخ والوقت';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get itinerary => 'مسار';

  @override
  String get professionalLabel => 'المحترف';

  @override
  String get estimatedAmount => 'المبلغ المقدر';

  @override
  String get noteLabel => 'ملاحظة';

  @override
  String get cancelledByUser => 'ألغيت من قبل المستخدم';

  @override
  String get rejectedByProfessional => 'مرفوض من قبل المختص';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get cancelRequestConfirmTitle => 'إلغاء الطلب؟';

  @override
  String get cancelRequestConfirmMessage =>
      'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟ هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get keepRequest => 'لا، الاحتفاظ به';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get requestCancelledSuccess => 'تم إلغاء الطلب بنجاح';

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String videoConsultation(String specialty) {
    return 'استشارة فيديو • $specialty';
  }

  @override
  String get joinTeleconsultation => 'الانضمام إلى الاستشارة عن بعد';

  @override
  String get healthServices => 'خدمات صحية';

  @override
  String get assigned => 'تم التعيين';

  @override
  String get waiting => 'قيد الانتظار...';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get city => 'المدينة';

  @override
  String get bloodGroup => 'فصيلة الدم';

  @override
  String get insuranceLabel => 'التأمين (رقم البوليصة / النوع)';

  @override
  String get medicalHistory => 'السجل الطبي';

  @override
  String get noneProvided => 'لم يتم تقديم أي معلومات';

  @override
  String get add => 'إضافة';

  @override
  String addTitle(String title) {
    return 'إضافة: $title';
  }

  @override
  String get description => 'الوصف';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get myRequestsTitle => 'طلباتي';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterOngoing => 'قيد التنفيذ';

  @override
  String get filterCompleted => 'المكتملة';

  @override
  String get filterCancelled => 'الملغاة';

  @override
  String get noRequests => 'لا توجد طلبات';

  @override
  String get noRequestsAll => 'لم تقم بإجراء أي طلبات SOS بعد.';

  @override
  String get noRequestsOngoing => 'لا توجد طلبات قيد المعالجة حالياً.';

  @override
  String get noRequestsCompleted => 'ليس لديك أي تدخلات مكتملة في سجلك.';

  @override
  String get noRequestsCancelled => 'لم يتم العثور على طلبات ملغاة.';

  @override
  String get legendTitle => 'دليل الألوان';

  @override
  String get legendTaken => 'مكتمل';

  @override
  String get legendPartial => 'جزئي';

  @override
  String get legendMissed => 'فائت';

  @override
  String get legendFuture => 'مستقبلي';

  @override
  String get confirmClearHistory => 'مسح السجل؟';

  @override
  String get clearHistoryMessage =>
      'هل تريد حذف جميع الإشعارات نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get searchAddress => 'البحث عن عنوان...';

  @override
  String get step => 'خطوة';

  @override
  String get ofTotal => 'من';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get medicationDetails => 'تفاصيل الدواء';

  @override
  String get instructions => 'التعليمات';

  @override
  String get currentStock => 'المخزون الحالي';

  @override
  String get refillStock => 'تجديد المخزون';

  @override
  String refillTitle(String name) {
    return 'تجديد المخزون: $name';
  }

  @override
  String get quantityToAdd => 'الكمية المضافة';

  @override
  String get quantityHint => 'مثال: 30';

  @override
  String get home => 'الرئيسية';

  @override
  String get planning => 'ادويتي';

  @override
  String get sos => 'الطلبات';

  @override
  String get profile => 'الحساب';

  @override
  String get frequency => 'التكرار';

  @override
  String takesPerDay(int count) {
    return '$count مرة/مرات في اليوم';
  }

  @override
  String get startOfTreatment => 'بداية العلاج';

  @override
  String get endOfTreatment => 'نهاية العلاج';

  @override
  String stockRefilledSuccess(String name) {
    return 'تم تجديد مخزون $name!';
  }

  @override
  String get confirmRefill => 'تأكيد التجديد';

  @override
  String newStock(int count) {
    return 'المخزون الجديد: $count وحدات';
  }

  @override
  String get noMedsForDay => 'لا توجد أدوية مقررة لهذا اليوم';

  @override
  String regularizeTitle(String name) {
    return 'تنظيم: $name';
  }

  @override
  String get statusPlanned => 'مقرر';

  @override
  String notificationMedicationTitle(Object name) {
    return 'تذكير: $name';
  }

  @override
  String notificationMedicationBody(Object dosage) {
    return 'حان وقت تناول جرعتك ($dosage)';
  }

  @override
  String notificationMedicationSnoozeBody(Object dosage) {
    return 'لا تنس تناول جرعتك ($dosage)';
  }

  @override
  String get notificationEndOfDayTitle => 'ملخص يومك';

  @override
  String get notificationEndOfDayBody => 'لا تنس جرعات نهاية اليوم.';

  @override
  String notificationStockUrgentTitle(Object name) {
    return 'عاجل - $name';
  }

  @override
  String notificationStockLowTitle(Object name) {
    return 'مخزون منخفض - $name';
  }

  @override
  String notificationStockBody(Object count) {
    return 'بقي $count وحدة/وحدات.';
  }

  @override
  String get notificationActionConfirm => 'تأكيد';

  @override
  String notificationActionSnooze(Object minutes) {
    return 'تذكير بعد $minutes دقيقة';
  }

  @override
  String get chooseProfile => 'اختر نوع الملف الشخصي الذي يناسبك.';

  @override
  String get iAmPatient => 'أنا مريض';

  @override
  String get patientDesc => 'أريد إدارة صحتي وصحة أقاربي.';

  @override
  String get iAmProfessional => 'أنا مهني صحي';

  @override
  String get professionalDesc => 'أريد تقديم خدماتي ومتابعة مرضاي.';

  @override
  String get missionInProgress => 'المهمة قيد التنفيذ';

  @override
  String get addressNotSpecified => 'العنوان غير حدد';

  @override
  String get emergenciesTitle => 'الطوارئ';

  @override
  String get noEmergencyNearby => 'لا توجد حالات طوارئ قريبة';

  @override
  String get availableAppointments => 'المواعيد المتاحة';

  @override
  String get noAppointmentAvailable => 'لا توجد مواعيد متاحة';

  @override
  String get professional => 'مهني صحي';

  @override
  String get patient => 'مريض';

  @override
  String get professionalInfo => 'معلومات مهنية';

  @override
  String get serviceType => 'نوع الخدمة';

  @override
  String get chooseProfessional => 'اختر مهنياً صحياً';

  @override
  String get onDuty => 'في الخدمة';

  @override
  String get offDuty => 'خارج الخدمة';

  @override
  String get visioConference => 'مؤتمر فيديو';

  @override
  String get distConsultation => 'استشارة عن بعد';

  @override
  String get join => 'انضمام';

  @override
  String get done => 'تم';

  @override
  String get start => 'بدء';

  @override
  String get inPersonConsultation => 'استشارة حضورية';

  @override
  String get time => 'الوقت';

  @override
  String get cancelMission => 'إلغاء المهمة';

  @override
  String get noProfessionalFound => 'لم يتم العثور على مهنيين';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get agenda => 'جدول المواعيد';

  @override
  String get earnings => 'الأرباح';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get estimatedTime => 'الوقت المقدر';

  @override
  String get distance => 'المسافة';

  @override
  String get user => 'مستخدم';

  @override
  String get occupation => 'مهنتك';

  @override
  String get proximityRange => 'نطاق البحث';

  @override
  String get available => 'متاح';

  @override
  String get pendingAppointments => 'مواعيد في الانتظار';

  @override
  String get todaysAgenda => 'مهماتي اليوم';

  @override
  String get appointmentsTitle => 'المواعيد';

  @override
  String get noAppointmentsAssigned => 'لا توجد مواعيد جديدة معينة';

  @override
  String get noAppointmentsToday => 'لا توجد مواعيد اليوم';

  @override
  String get tooEarlyForAppointment =>
      'الوقت لا يزال مبكراً لهذا الموعد. يرجى العودة قبل 5 دقائق.';

  @override
  String get scheduleConflict =>
      'لديك مهمة أخرى في هذا الوقت (مطلوب فاصل زمني لمدة ساعة).';

  @override
  String get requestAlreadyTaken =>
      'تم قبول هذا الطلب بالفعل من قبل محترف آخر.';

  @override
  String get appointmentLate => 'متأخر';

  @override
  String get alreadyActiveMission =>
      'لديك مهمة نشطة حالياً. يرجى إكمالها أولاً.';

  @override
  String get acts => 'أفعال';

  @override
  String get noMissionRecorded => 'لم تُسجّل أي مهمة';

  @override
  String get today => 'اليوم';

  @override
  String get notificationNewSosTitle => 'حالة طارئة جديدة (SOS)';

  @override
  String get notificationNewSosBody =>
      'مريض جديد يحتاج إلى مساعدة فورية في مكان قريب.';

  @override
  String get notificationNewAppointmentTitle => 'موعد جديد';

  @override
  String get notificationNewAppointmentBody => 'لقد تلقيت طلباً جديداً لموعد.';

  @override
  String get notificationSosAcceptedTitle => 'تم قبول الطلب';

  @override
  String notificationSosAcceptedBody(Object name) {
    return 'قبل مختص طلبك: $name';
  }

  @override
  String get notificationSosOnTheWayTitle => 'المختص في الطريق';

  @override
  String notificationSosOnTheWayBody(Object name) {
    return '$name في طريقه إلى موقعك.';
  }

  @override
  String get notificationSosInProgressTitle => 'بدأت الاستشارة عن بعد';

  @override
  String notificationSosInProgressBody(Object name) {
    return '$name في انتظارك للاستشارة عبر الفيديو.';
  }

  @override
  String get notificationSosCancelledTitle => 'تم إلغاء التدخل';

  @override
  String get notificationSosCancelledBody => 'تم إلغاء الطلب.';

  @override
  String get notificationSosCancelledByPatientBody =>
      'قام المريض بإلغاء التدخل.';

  @override
  String get notificationSosCancelledByProBody =>
      'اضطر المهني الصحي لإلغاء التدخل.';

  @override
  String get notificationSosRejectedTitle => 'تم رفض الطلب';

  @override
  String notificationSosRejectedBody(Object name) {
    return 'رفض $name طلبك.';
  }

  @override
  String get notificationSosRejectedBodyGeneric =>
      'تم رفض طلبك. يمكنك المحاولة مرة أخرى مع مختص آخر.';

  @override
  String get notificationNewRatingTitle => 'Nouvelle évaluation';

  @override
  String notificationNewRatingBody(String name, int rating) {
    return '$name vous a donné une note de $rating étoiles !';
  }

  @override
  String get afternoon => 'بعد الظهر';

  @override
  String get availableTimeSlots => 'الأوقات المتاحة';

  @override
  String get noAvailableSlots => 'لا توجد أوقات متاحة';

  @override
  String get tryAnotherDate => 'جرب تاريخا آخر';

  @override
  String get chooseTimeSlot => 'الرجاء اختيار وقت';

  @override
  String get profileSetup => 'إعداد الملف الشخصي';

  @override
  String get completeProProfile => 'أكمل ملفك الشخصي المهني';

  @override
  String get proSetupSubtitle => 'هذه المعلومات ضرورية للتحقق من حسابك.';

  @override
  String get verificationDocs => 'وثائق التحقق';

  @override
  String get cniFront => 'بطاقة التعريف الوطنية (الوجه)';

  @override
  String get cniBack => 'بطاقة التعريف الوطنية (الظهر)';

  @override
  String get diploma => 'الدبلوم / الشهادة';

  @override
  String get authorization => 'ترخيص مزاولة المهنة';

  @override
  String get vehicleRegistration => 'البطاقة الرمادية';

  @override
  String get transportAuth => 'رخصة النقل';

  @override
  String get validationPendingTitle => 'التحقق قيد التنفيذ';

  @override
  String get validationPendingMessage => 'ملفك قيد المراجعة من قبل مصالحنا.';

  @override
  String get refresh => 'تحديث';

  @override
  String get validationRejectedTitle => 'لم يتم قبول الملف';

  @override
  String get validationRejectedMessage =>
      'تعذر علينا التحقق من ملفك المهني في الوقت الحالي. ';

  @override
  String get updateDocuments => 'تحديث وثائقي';

  @override
  String get updateDocumentsSubtitle => 'صحح وأعد إرسال ملفاتك';

  @override
  String get contactSupportMessage =>
      'يرجى الاتصال بالدعم الفني لـ MSD إذا كنت بحاجة للمساعدة: support@msd.ma';

  @override
  String get startOver => 'هل تريد البدء من جديد؟';

  @override
  String get validationStatus => 'حالة التحقق';

  @override
  String get validated => 'تم التحقق';

  @override
  String get rejected => 'مرفوض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get chronicDiseases => 'الأمراض المزمنة';

  @override
  String get skip => 'تخطي';

  @override
  String get adminManagementTools => 'أدوات الإدارة';

  @override
  String get adminProfessionals => 'المهنيين';

  @override
  String get adminManageNetwork => 'إدارة الشبكة';

  @override
  String get adminPatients => 'المرضى';

  @override
  String get adminFullList => 'القائمة الكاملة';

  @override
  String get adminSosMonitor => 'مراقب SOS';

  @override
  String get adminLiveFlow => 'التدفق المباشر';

  @override
  String get adminWelcome => 'مرحباً، المسؤول';

  @override
  String get adminPlatformStatus => 'حالة المنصة';

  @override
  String get adminTotalSos => 'إجمالي SOS';

  @override
  String get adminMissions => 'المهمات';

  @override
  String get adminValidatedPros => 'المهنيين المعتمدين';

  @override
  String get adminSosDistribution => 'توزيع SOS';

  @override
  String get adminDoctors => 'الأطباء';

  @override
  String get adminAmbulances => 'سيارات الإسعاف';

  @override
  String get adminNurses => 'الممرضين';

  @override
  String get adminTeleconsult => 'الاستشارات عن بعد';

  @override
  String get chatbotTitle => 'مساعد MSD الذكي';

  @override
  String get chatbotHistory => 'السجل';

  @override
  String get chatbotHint => 'اسأل سؤالك هنا...';

  @override
  String get chatbotNoHistory => 'لا يوجد سجل محادثات';

  @override
  String get chatbotNewChat => 'محادثة جديدة';

  @override
  String get chatbotCopied => 'تم النسخ إلى الحافظة';

  @override
  String get chatbotConsult => 'عرض التفاصيل';
}
