class Child {
  final int id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final int? diagnosisId;
  final String photo;
  final String medicalHistory;

  Child({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.diagnosisId,
    required this.photo,
    required this.medicalHistory,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? json['child_id'],
      fullName: json['full_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      diagnosisId: json['diagnosis_id'],
      photo: json['photo'] ?? '',
      medicalHistory: json['medical_history'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'diagnosis_id': diagnosisId,
      'photo': photo,
      'medical_history': medicalHistory,
    };
  }
}
