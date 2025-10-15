// models/session.dart
class Session {
  final String title;
  final String date;
  final String center;

  Session({
    required this.title,
    required this.date,
    required this.center,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      center: json['center'] ?? '',
    );
  }
}
