import 'notification_item.dart';

class Summaries {
  final int upcomingSessions;
  final int newAIAdviceCount;
  final List<NotificationItem> notifications;

  Summaries({
    required this.upcomingSessions,
    required this.newAIAdviceCount,
    required this.notifications,
  });

  factory Summaries.fromJson(Map<String, dynamic> json) {
    var notificationsJson = json['notifications'] as List<dynamic>? ?? [];
    List<NotificationItem> notificationsList =
    notificationsJson.map((n) => NotificationItem.fromJson(n)).toList();

    return Summaries(
      upcomingSessions: json['upcomingSessions'] ?? 0,
      newAIAdviceCount: json['newAIAdviceCount'] ?? 0,
      notifications: notificationsList,
    );
  }
}
