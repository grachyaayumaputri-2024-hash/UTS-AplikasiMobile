import 'user_model.dart';
import 'attachment_model.dart';

class CommentModel {
  final String id;
  final String ticketId;
  final UserModel author;
  final String content;
  final List<AttachmentModel> attachments;
  final bool isInternal; // true = only visible to helpdesk/admin
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.author,
    required this.content,
    this.attachments = const [],
    this.isInternal = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      isInternal: json['is_internal'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'author': author.toJson(),
      'content': content,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'is_internal': isInternal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? ticketId,
    UserModel? author,
    String? content,
    List<AttachmentModel>? attachments,
    bool? isInternal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      author: author ?? this.author,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, author: ${author.name}, isInternal: $isInternal)';
  }
}