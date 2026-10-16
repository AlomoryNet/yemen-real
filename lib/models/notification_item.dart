class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.link,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      link: json['link'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'link': link,
      'is_read': isRead,
    };
  }
}
