import 'dart:io';
import '../models/models.dart';
import 'api_client.dart';

class TicketRepository {
  final ApiClient _client;

  TicketRepository({ApiClient? client}) : _client = client ?? ApiClient();

  // ─── User: Ticket CRUD ──────────────────────────────────────────────────────

  /// Ambil semua tiket milik user yang sedang login
  /// Admin/Helpdesk: semua tiket
  Future<List<TicketModel>> getTickets({
    TicketStatus? status,
    TicketPriority? priority,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) queryParams['status'] = status.value;
    if (priority != null) queryParams['priority'] = priority.value;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get('/tickets', queryParams: queryParams);

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil detail satu tiket berdasarkan ID
  Future<TicketModel> getTicketById(String ticketId) async {
    final response = await _client.get('/tickets/$ticketId');
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Buat tiket baru
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required TicketPriority priority,
  }) async {
    final response = await _client.post(
      '/tickets',
      body: {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority.value,
      },
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ─── Helpdesk/Admin: Manajemen Tiket ───────────────────────────────────────

  /// Update status tiket (helpdesk/admin)
  Future<TicketModel> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    final response = await _client.patch(
      '/tickets/$ticketId/status',
      body: {'status': status.value},
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Assign tiket ke helpdesk tertentu (admin)
  Future<TicketModel> assignTicket({
    required String ticketId,
    required String helpdeskUserId,
  }) async {
    final response = await _client.patch(
      '/tickets/$ticketId/assign',
      body: {'assigned_to': helpdeskUserId},
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ─── Komentar / Reply ───────────────────────────────────────────────────────

  /// Ambil semua komentar dari sebuah tiket
  Future<List<CommentModel>> getComments(String ticketId) async {
    final response = await _client.get('/tickets/$ticketId/comments');
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah komentar/reply ke tiket
  Future<CommentModel> addComment({
    required String ticketId,
    required String content,
    bool isInternal = false,
  }) async {
    final response = await _client.post(
      '/tickets/$ticketId/comments',
      body: {
        'content': content,
        'is_internal': isInternal,
      },
    );
    return CommentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ─── Attachment / Upload ────────────────────────────────────────────────────

  /// Upload file/gambar ke tiket
  Future<AttachmentModel> uploadAttachment({
    required String ticketId,
    required File file,
  }) async {
    final response = await _client.uploadFile(
      '/tickets/$ticketId/attachments',
      file: file,
      fieldName: 'file',
      fields: {'ticket_id': ticketId},
    );
    return AttachmentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Hapus attachment dari tiket
  Future<void> deleteAttachment({
    required String ticketId,
    required String attachmentId,
  }) async {
    await _client.delete('/tickets/$ticketId/attachments/$attachmentId');
  }

  // ─── Riwayat Tiket ─────────────────────────────────────────────────────────

  /// Ambil riwayat aktivitas sebuah tiket (tracking)
  Future<List<Map<String, dynamic>>> getTicketHistory(String ticketId) async {
    final response = await _client.get('/tickets/$ticketId/history');
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
