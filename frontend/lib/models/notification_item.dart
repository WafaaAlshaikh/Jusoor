class NotificationItem {
  final String icon;
  final String title;

  NotificationItem({required this.icon, required this.title});

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      icon: json['icon'] ?? 'notifications',
      title: json['title'] ?? '',
    );
  }
}
