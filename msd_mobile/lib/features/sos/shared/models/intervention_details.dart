import 'sos_enums.dart';
import 'location_details.dart';

class InterventionDetails {
  final InterventionType? interventionType; // Rendu optionnel pour la non-pré-sélection
  final DateTime? appointmentDateTime;
  final LocationDetails? location;

  InterventionDetails({
    this.interventionType,
    this.appointmentDateTime,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'intervention_type': interventionType?.name,
      'appointment_date_time': appointmentDateTime?.toIso8601String(),
      'location': location?.toJson(),
    };
  }

  factory InterventionDetails.fromJson(Map<String, dynamic> json) {
    return InterventionDetails(
      interventionType: json['intervention_type'] != null 
          ? InterventionType.values.byName(json['intervention_type']) 
          : null,
      appointmentDateTime: json['appointment_date_time'] != null 
          ? DateTime.parse(json['appointment_date_time']) 
          : null,
      location: json['location'] != null 
          ? LocationDetails.fromJson(json['location']) 
          : null,
    );
  }

  InterventionDetails copyWith({
    InterventionType? interventionType,
    DateTime? appointmentDateTime,
    LocationDetails? location,
    bool clearInterventionType = false,
  }) {
    return InterventionDetails(
      interventionType: clearInterventionType ? null : (interventionType ?? this.interventionType),
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      location: location ?? this.location,
    );
  }
}
