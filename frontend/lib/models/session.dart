class Session {
  final int sessionId;
  final String childName;
  final String specialistName;
  final String institutionName;
  final String date;
  final String time;
  final int duration;
  final double price;
  final String sessionType;
  final String status;

  Session({
    required this.sessionId,
    required this.childName,
    required this.specialistName,
    required this.institutionName,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.sessionType,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'] ?? 0,
      childName: json['childName'] ?? '',
      specialistName: json['specialistName'] ?? '',
      institutionName: json['institutionName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      sessionType: json['sessionType'] ?? '',
      status: json['status'] ?? '',
    );
  }
}