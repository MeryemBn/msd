/// A home-feature-owned model for the next dose card.
/// HomeProvider populates this — NextDoseCard reads it.
class NextDoseInfo {
  final String slotId;
  final String medicationName;
  final String dosage;
  final String formattedTime;
  final String instruction;
  final DateTime scheduledDateTime;

  const NextDoseInfo({
    required this.slotId,
    required this.medicationName,
    required this.dosage,
    required this.formattedTime,
    required this.instruction,
    required this.scheduledDateTime,
  });

  /// Factory constructor to create NextDoseInfo from JSON
  factory NextDoseInfo.fromJson(Map<String, dynamic> json) {
    return NextDoseInfo(
      slotId: json['slotId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      formattedTime: json['formattedTime'] as String,
      instruction: json['instruction'] as String,
      scheduledDateTime: DateTime.parse(json['scheduledDateTime'] as String),
    );
  }

  /// Convert NextDoseInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'medicationName': medicationName,
      'dosage': dosage,
      'formattedTime': formattedTime,
      'instruction': instruction,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
    };
  }
}
