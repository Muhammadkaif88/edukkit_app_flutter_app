class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final bool isRead;
  final String type; // e.g., 'course', 'order', 'welcome'

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });
}
