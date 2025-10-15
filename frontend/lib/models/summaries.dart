import 'notification_item.dart';
import 'session.dart';

class Summaries {
  final int upcomingSessions;
  final List<Session> upcomingSessionsList;
  final int newAIAdviceCount;
  final List<NotificationItem> notifications;

  Summaries({
    required this.upcomingSessions,
    required this.upcomingSessionsList,
    required this.newAIAdviceCount,
    required this.notifications,
  });

  factory Summaries.fromJson(Map<String, dynamic> json) {
    return Summaries(
      upcomingSessions: json['upcomingSessions'] ?? 0,
      upcomingSessionsList: (json['upcomingSessionsList'] as List<dynamic>?)
          ?.map((e) => Session.fromJson(e))
          .toList() ??
          [],
      newAIAdviceCount: json['newAIAdviceCount'] ?? 0,
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}
