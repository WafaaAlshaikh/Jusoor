class Child {
  final int id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final int? diagnosisId;
  final String photo;
  final String medicalHistory;
  final String? condition;
  final int age;
  final DateTime? lastSessionDate;
  final String? status;
  final int? institutionId;
  final DateTime? deletedAt; // ⬅️ جديد
  final bool isArchived; // ⬅️ جديد
  final String registrationStatus; // 'Not Registered', 'Pending', 'Approved'
  final int? currentInstitutionId;
  final String? currentInstitutionName;

  Child({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.diagnosisId,
    required this.photo,
    required this.medicalHistory,
    this.condition,
    required this.age,
    this.lastSessionDate,
    this.status,
    this.institutionId,

    // ⬇️⬇️⬇️ الحقول الجديدة ⬇️⬇️⬇️
    required this.registrationStatus,
    this.currentInstitutionId,
    this.currentInstitutionName,
    this.deletedAt,
    required this.isArchived,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    // حساب العمر من تاريخ الميلاد
    int calculatedAge = 0;
    try {
      if (json['date_of_birth'] != null && json['date_of_birth'].isNotEmpty) {
        final birthDate = DateTime.parse(json['date_of_birth']);
        final today = DateTime.now();
        calculatedAge = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          calculatedAge--;
        }
      }
    } catch (_) {
      calculatedAge = 0;
    }

    // تحويل تاريخ آخر جلسة
    DateTime? parsedLastSessionDate;
    if (json['last_session_date'] != null && json['last_session_date'].isNotEmpty) {
      parsedLastSessionDate = DateTime.tryParse(json['last_session_date']);
    }

    DateTime? parsedDeletedAt;
    if (json['deleted_at'] != null && json['deleted_at'].isNotEmpty) {
      parsedDeletedAt = DateTime.tryParse(json['deleted_at']);
    }

    return Child(
      id: json['id'] ?? json['child_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      diagnosisId: json['diagnosis_id'],
      photo: json['photo'] ?? '',
      medicalHistory: json['medical_history'] ?? '',
      condition: json['condition'],
      age: json['age'] ?? calculatedAge,
      lastSessionDate: parsedLastSessionDate,
      status: json['status'] ?? 'Active',
      institutionId: json['institution_id'],

      // ⬇️⬇️⬇️ الحقول الجديدة ⬇️⬇️⬇️
      registrationStatus: json['registration_status'] ?? 'Not Registered',
      currentInstitutionId: json['current_institution_id'],
      currentInstitutionName: json['current_institution_name'],
      deletedAt: parsedDeletedAt,
      isArchived: parsedDeletedAt != null,
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
      'institution_id': institutionId,
    };
  }
}