class NotificationEntity {
  final String sentTo;
  final String title;
  final String body;
  final Map<String, dynamic> notificationData;

  NotificationEntity({
    required this.sentTo,
    required this.title,
    required this.body,
    required this.notificationData,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      sentTo: json['sent_to'],
      title: json['title'],
      body: json['body'],
      notificationData: json['notification_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sent_to': sentTo,
      'title': title,
      'body': body,
      'notification_data': notificationData,
    };
  }
}