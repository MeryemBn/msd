class Review {
  final int id;
  final String patientFirstName;
  final String patientLastName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.patientFirstName,
    required this.patientLastName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      patientFirstName: json['patientFirstName'] ?? 'Patient',
      patientLastName: json['patientLastName'] ?? '',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get patientFullName => '$patientFirstName $patientLastName'.trim();
}
