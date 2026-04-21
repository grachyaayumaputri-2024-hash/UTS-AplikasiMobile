import 'user_model.dart';
import 'attachment_model.dart';
import 'comment_model.dart';

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

enum TicketPriority {
  low,
  medium,
  high,
  critical,
}

extension TicketStatusExtension on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String get value {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

extension TicketPriorityExtension on TicketPriority {
  String get label {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.critical:
        return 'Critical';
    }
  }

  String get value {
    switch (this) {
      case TicketPriority.low:
        return 'low';
      case TicketPriority.medium:
        return 'medium';
      case TicketPriority.high:
        return 'high';
      case TicketPriority.critical:
        return 'critical';
    }
  }

  static TicketPriority fromString(String value) {
    switch (value) {
      case 'low':
        return TicketPriority.low;
      case 'medium':
        return TicketPriority.medium;
      case 'high':
        return TicketPriority.high;
      case 'critical':
        return TicketPriority.critical;
      default:
        return TicketPriority.medium;
    }
  }
}

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String category;
  final UserModel reporter;
  final UserModel? assignedTo;
  final List<AttachmentModel> attachments;
  final List<CommentModel> comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.reporter,
    this.assignedTo,
    this.attachments = const [],
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TicketStatusExtension.fromString(json['status'] as String),
      priority: TicketPriorityExtension.fromString(json['priority'] as String),
      category: json['category'] as String,
      reporter: UserModel.fromJson(json['reporter'] as Map<String, dynamic>),
      assignedTo: json['assigned_to'] != null
          ? UserModel.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'category': category,
      'reporter': reporter.toJson(),
      'assigned_to': assignedTo?.toJson(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    String? category,
    UserModel? reporter,
    UserModel? assignedTo,
    List<AttachmentModel>? attachments,
    List<CommentModel>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      reporter: reporter ?? this.reporter,
      assignedTo: assignedTo ?? this.assignedTo,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() {
    return 'TicketModel(id: $id, title: $title, status: ${status.label})';
  }
}