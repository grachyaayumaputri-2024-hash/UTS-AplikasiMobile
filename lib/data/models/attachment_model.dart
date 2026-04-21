enum AttachmentType { image, file }

extension AttachmentTypeExtension on AttachmentType {
  String get value {
    switch (this) {
      case AttachmentType.image:
        return 'image';
      case AttachmentType.file:
        return 'file';
    }
  }

  static AttachmentType fromString(String value) {
    switch (value) {
      case 'image':
        return AttachmentType.image;
      case 'file':
        return AttachmentType.file;
      default:
        return AttachmentType.file;
    }
  }

  bool get isImage => this == AttachmentType.image;
}

class AttachmentModel {
  final String id;
  final String ticketId;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int fileSize; // in bytes
  final AttachmentType type;
  final DateTime uploadedAt;

  AttachmentModel({
    required this.id,
    required this.ticketId,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSize,
    required this.type,
    required this.uploadedAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      type: AttachmentTypeExtension.fromString(json['type'] as String),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'file_name': fileName,
      'file_url': fileUrl,
      'mime_type': mimeType,
      'file_size': fileSize,
      'type': type.value,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  /// Returns file size in human-readable format
  String get fileSizeLabel {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'AttachmentModel(id: $id, fileName: $fileName, type: ${type.value})';
  }
}