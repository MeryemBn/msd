import 'sos_enums.dart';
import 'request_details.dart';
import 'sos_type.dart';
import 'intervention_details.dart';
import 'location_details.dart';

class SosRequest {
  final String? id;
  final String? patientId;
  final String? patientFirstName;
  final String? patientLastName;
  final String? patientPhoneNumber;
  final String? professionalId;
  final String? professionalFirstName;
  final String? professionalLastName;
  final String? professionalPhoneNumber;
  final RequestDetails details;
  final PaymentMethod paymentMethod;
  final double price;
  final RequestStatus status;
  final String? meetingUrl;
  final bool isRated;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? roomName;
  final String? jitsiToken;

  SosRequest({
    this.id,
    this.patientId,
    this.patientFirstName,
    this.patientLastName,
    this.patientPhoneNumber,
    this.professionalId,
    this.professionalFirstName,
    this.professionalLastName,
    this.professionalPhoneNumber,
    required this.details,
    required this.paymentMethod,
    required this.price,
    this.status = RequestStatus.pending,
    this.meetingUrl,
    this.isRated = false,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.roomName,
    this.jitsiToken,
  });

  String get patientFullName => 
    '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim().isNotEmpty 
      ? '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim() 
      : 'Patient #${patientId ?? "---"}';

  String get professionalFullName =>
      (professionalFirstName != null || professionalLastName != null)
          ? '${professionalFirstName ?? ''} ${professionalLastName ?? ''}'.trim()
          : '';

  static InterventionType? parseInterventionMode(dynamic raw) {
    if (raw == null) return null;
    final normalized = raw.toString().toUpperCase().replaceAll(RegExp(r'[\s\-]'), '_');

    if (normalized.contains('SOS') ||
        normalized.contains('URGENC') ||
        normalized == 'IMMEDIATE' ||
        normalized == 'URGENT') {
      return InterventionType.sos_urgency;
    }
    if (normalized.contains('APPOINT') || normalized == 'RDV' || normalized == 'SCHEDULED') {
      return InterventionType.appointment;
    }

    for (final type in InterventionType.values) {
      if (type.name.toUpperCase() == normalized) return type;
    }
    return InterventionType.sos_urgency;
  }

  static DateTime? _parseDateTime(dynamic value, {bool assumeUtc = true}) {
    if (value == null) return null;
    try {
      String dateStr = value.toString();
      if (dateStr.isEmpty) return null;
      
      if (dateStr.contains('Z') || dateStr.contains('+')) {
        return DateTime.parse(dateStr).toLocal();
      }

      DateTime dt = DateTime.parse(dateStr);
      
      // Si la date est déjà marquée comme UTC par le parser, on convertit en local
      if (dt.isUtc) return dt.toLocal();

      // Si le parser ne sait pas (pas de Z), et qu'on doit assumer UTC (cas des RDV)
      if (assumeUtc) {
        return DateTime.utc(
          dt.year, dt.month, dt.day,
          dt.hour, dt.minute, dt.second,
          dt.millisecond, dt.microsecond,
        ).toLocal();
      }
      
      // Sinon on retourne la date telle quelle (cas du createdAt/updatedAt déjà en local)
      return dt;
    } catch (e) {
      return null;
    }
  }

  bool get isScheduledAppointment =>
      details.interventionDetails.interventionType == InterventionType.appointment;

  bool get isSosUrgency =>
      details.interventionDetails.interventionType != InterventionType.appointment;

  factory SosRequest.fromApiJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    final location = locationData != null ? LocationDetails.fromJson(locationData) : null;

    final intervention = InterventionDetails(
      location: location,
      interventionType: parseInterventionMode(json['interventionMode']),
      appointmentDateTime: _parseDateTime(json['appointmentDatetime'], assumeUtc: true),
    );

    RequestDetails details;
    final String? serviceTypeRaw = json['serviceType']?.toString().toUpperCase();
    
    if (serviceTypeRaw == 'DOCTOR' || serviceTypeRaw == 'DOCTOR_HOME') {
      details = DoctorDetails(
        interventionDetails: intervention,
        specialty: Specialty.values.firstWhere(
            (e) => e.toJson() == json['specialty']?.toString().toUpperCase(), 
            orElse: () => Specialty.medecineGenerale),
      );
    } else if (serviceTypeRaw == 'AMBULANCE') {
      details = AmbulanceDetails(
        interventionDetails: intervention,
        ambulanceType: AmbulanceType.values.firstWhere(
            (e) => e.toJson() == json['ambulanceType']?.toString().toUpperCase(), 
            orElse: () => AmbulanceType.medicalisee_smur),
      );
    } else if (serviceTypeRaw == 'TELECONSULTATION' || serviceTypeRaw == 'TELECONSULT') {
      details = TeleconsultDetails(
        interventionDetails: intervention,
        specialty: Specialty.values.firstWhere(
            (e) => e.toJson() == json['specialty']?.toString().toUpperCase(), 
            orElse: () => Specialty.medecineGenerale),
      );
    } else {
      details = NurseDetails(interventionDetails: intervention);
    }

    return SosRequest(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString(),
      patientFirstName: json['patientFirstName'],
      patientLastName: json['patientLastName'],
      patientPhoneNumber: json['patientPhoneNumber'],
      professionalId: json['professionalId']?.toString(),
      professionalFirstName: json['professionalFirstName'],
      professionalLastName: json['professionalLastName'],
      professionalPhoneNumber: json['professionalPhoneNumber'],
      paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.toJson() == json['paymentMethod']?.toString().toUpperCase(), 
          orElse: () => PaymentMethod.cash),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: RequestStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == json['status']?.toString().toUpperCase(), 
          orElse: () => RequestStatus.pending),
      meetingUrl: json['meetingUrl'],
      isRated: json['isRated'] ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : null,
      // Ici on met assumeUtc: false car le serveur envoie ces dates en local
      createdAt: _parseDateTime(json['createdAt'], assumeUtc: false),
      updatedAt: _parseDateTime(json['updatedAt'], assumeUtc: false),
      details: details,
      roomName: json['roomName']?.toString(),
      jitsiToken: json['jitsiToken']?.toString(),
    );
  }

  Map<String, dynamic> toApiJson(SosType type) {
    final intervention = details.interventionDetails;
    final Map<String, dynamic> data = {
      'serviceType': type.apiKey, 
      'interventionMode': intervention.interventionType?.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'price': price,
      'location': intervention.location?.toJson(),
      'professionalId': professionalId,
    };

    if (intervention.appointmentDateTime != null) {
      data['appointmentDatetime'] = intervention.appointmentDateTime!.toUtc().toIso8601String();
    }

    if (details is DoctorDetails) {
      data['specialty'] = (details as DoctorDetails).specialty.toJson();
    } else if (details is TeleconsultDetails) {
      data['specialty'] = (details as TeleconsultDetails).specialty.toJson();
    } else if (details is AmbulanceDetails) {
      data['ambulanceType'] = (details as AmbulanceDetails).ambulanceType.toJson();
    }

    return data;
  }

  SosRequest copyWith({
    String? id,
    String? patientId,
    String? patientFirstName,
    String? patientLastName,
    String? patientPhoneNumber,
    String? professionalId,
    String? professionalFirstName,
    String? professionalLastName,
    String? professionalPhoneNumber,
    RequestDetails? details,
    PaymentMethod? paymentMethod,
    double? price,
    RequestStatus? status,
    String? meetingUrl,
    bool? isRated,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomName,
    String? jitsiToken,
  }) {
    return SosRequest(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastName: patientLastName ?? this.patientLastName,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
      professionalId: professionalId ?? this.professionalId,
      professionalFirstName: professionalFirstName ?? this.professionalFirstName,
      professionalLastName: professionalLastName ?? this.professionalLastName,
      professionalPhoneNumber: professionalPhoneNumber ?? this.professionalPhoneNumber,
      details: details ?? this.details,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      price: price ?? this.price,
      status: status ?? this.status,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomName: roomName ?? this.roomName,
      jitsiToken: jitsiToken ?? this.jitsiToken,
    );
  }
}
