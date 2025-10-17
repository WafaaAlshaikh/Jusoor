  class SessionModel {
    final int sessionId;
    final String childName;
    final String specialistName;
    final String institutionName;
    final String date;
    final String time;
    final int? duration;
    final double? price;
    final String sessionType;
    final String status;

    SessionModel({
      required this.sessionId,
      required this.childName,
      required this.specialistName,
      required this.institutionName,
      required this.date,
      required this.time,
      this.duration,
      this.price,
      required this.sessionType,
      required this.status,
    });

    factory SessionModel.fromJson(Map<String, dynamic> json) {
      return SessionModel(
        sessionId: json['sessionId'],
        childName: json['childName'],
        specialistName: json['specialistName'],
        institutionName: json['institutionName'],
        date: json['date'],
        time: json['time'],
        duration: json['duration'],
        price: (json['price'] != null) ? double.tryParse(json['price'].toString()) : null,
        sessionType: json['sessionType'],
        status: json['status'],
      );
    }
  }
