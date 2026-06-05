import 'sos_enums.dart';
import 'intervention_details.dart';

abstract class RequestDetails {
  final InterventionDetails interventionDetails;

  RequestDetails({required this.interventionDetails});

  Map<String, dynamic> toJson();
}

class DoctorDetails extends RequestDetails {
  final Specialty specialty;

  DoctorDetails({
    required super.interventionDetails,
    required this.specialty,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'DOCTOR',
      'specialty': specialty.name,
      'intervention_details': interventionDetails.toJson(),
    };
  }
}

class NurseDetails extends RequestDetails {
  NurseDetails({required super.interventionDetails});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'NURSE',
      'intervention_details': interventionDetails.toJson(),
    };
  }
}

class TeleconsultDetails extends RequestDetails {
  final Specialty specialty;

  TeleconsultDetails({
    required super.interventionDetails,
    required this.specialty,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'TELECONSULT',
      'specialty': specialty.name,
      'intervention_details': interventionDetails.toJson(),
    };
  }
}

class AmbulanceDetails extends RequestDetails {
  final AmbulanceType ambulanceType;

  AmbulanceDetails({
    required super.interventionDetails,
    required this.ambulanceType,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'AMBULANCE',
      'ambulance_type': ambulanceType.name,
      'intervention_details': interventionDetails.toJson(),
    };
  }
}
