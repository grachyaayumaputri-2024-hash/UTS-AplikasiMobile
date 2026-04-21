enum NotificationType {
  ticketCreated,
  ticketUpdated,
  ticketAssigned,
  ticketResolved,
  ticketClosed,
  newComment,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.ticketCreated:
        return 'ticket_created';
      case NotificationType.ticketUpdated:
        return 'ticket_updated';
      case NotificationType.ticketAssigned:
        return 'ticket_assigned';
      case NotificationType.ticketResolved:
        return 'ticket_resolved';
      case NotificationType.ticketClosed:
        return 'ticket_closed';
      case NotificationType.newComment:
        return 'new_comment';
    }
  }

  String get label {
    switch (this) {
      case NotificationType.ticketCreated:
        return 'Tiket Dibuat';
      case NotificationType.ticketUpdated:
        return 'Tiket Diperbarui';
      case NotificationType.ticketAssigned:
        return 'Tiket Ditugaskan';
      case NotificationType.ticketResolved:
        return 'Tiket Diselesaikan';
      case NotificationType.ticketClosed:
        return 'Tiket Ditutup';
      case NotificationType.newComment:
        return 'Komentar Baru';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'ticket_created':
        return NotificationType.ticketCreated;
      case 'ticket_updated':
        return NotificationType.ticketUpdated;
      case 'ticket_assigned':
        return NotificationType.ticketAssigned;
      case 'ticket_resolved':
        return NotificationType.ticketResolved;
      case 'ticket_closed':
        return NotificationType.ticketClosed;
      case 'new_comment':
        return NotificationType.newComment;
      default:
        return NotificationType.ticketUpdated;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? ticketId; // route target
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.ticketId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationTypeExtension.fromString(json['type'] as String),
      ticketId: json['ticket_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.value,
      'ticket_id': ticketId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? ticketId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      ticketId: ticketId ?? this.ticketId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.label}, isRead: $isRead)';
  }
}