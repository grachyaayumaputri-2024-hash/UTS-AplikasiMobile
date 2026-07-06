import '../models/models.dart';
import '../mock/mock_data.dart';

class MockTicketRepository {
  final List<TicketModel> _tickets = List.from(MockData.tickets);

  Future<List<TicketModel>> getTickets({
    TicketStatus? status,
    TicketPriority? priority,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    var result = List<TicketModel>.from(_tickets);
    if (status != null) result = result.where((t) => t.status == status).toList();
    if (priority != null) result = result.where((t) => t.priority == priority).toList();
    if (search != null && search.isNotEmpty) {
      result = result.where((t) =>
      t.title.toLowerCase().contains(search.toLowerCase()) ||
          t.description.toLowerCase().contains(search.toLowerCase())).toList();
    }
    final start = (page - 1) * limit;
    if (start >= result.length) return [];
    return result.sublist(start, (start + limit).clamp(0, result.length));
  }

  Future<TicketModel> getTicketById(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _tickets.firstWhere(
          (t) => t.id == ticketId,
      orElse: () => throw Exception('Tiket tidak ditemukan'),
    );
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required TicketPriority priority,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Auto-assign ke helpdesk berdasarkan kategori
    final assignedHelpdesk = MockData.getHelpdeskByCategory(category);

    final newTicket = TicketModel(
      id: 'tkt-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      title: title,
      description: description,
      status: assignedHelpdesk != null ? TicketStatus.inProgress : TicketStatus.open,
      priority: priority,
      category: category,
      reporter: MockData.regularUser,
      assignedTo: assignedHelpdesk,
      attachments: [],
      comments: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tickets.insert(0, newTicket);
    return newTicket;
  }

  Future<TicketModel> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) throw Exception('Tiket tidak ditemukan');
    final updated = _tickets[idx].copyWith(
      status: status,
      updatedAt: DateTime.now(),
      resolvedAt: status == TicketStatus.resolved ? DateTime.now() : null,
    );
    _tickets[idx] = updated;
    return updated;
  }

  Future<TicketModel> assignTicket({
    required String ticketId,
    required String helpdeskUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) throw Exception('Tiket tidak ditemukan');
    final helpdesk = MockData.helpdeskList.firstWhere(
          (u) => u.id == helpdeskUserId,
      orElse: () => MockData.helpdeskA,
    );
    final updated = _tickets[idx].copyWith(
      assignedTo: helpdesk,
      status: TicketStatus.inProgress,
      updatedAt: DateTime.now(),
    );
    _tickets[idx] = updated;
    return updated;
  }

  Future<List<CommentModel>> getComments(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ticket = _tickets.firstWhere((t) => t.id == ticketId,
        orElse: () => throw Exception('Tiket tidak ditemukan'));
    return ticket.comments;
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String content,
    bool isInternal = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final comment = CommentModel(
      id: 'cmt-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      author: MockData.regularUser,
      content: content,
      isInternal: isInternal,
      createdAt: DateTime.now(),
    );
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final updatedComments = [..._tickets[idx].comments, comment];
      _tickets[idx] = _tickets[idx].copyWith(
        comments: updatedComments,
        updatedAt: DateTime.now(),
      );
    }
    return comment;
  }

  Future<List<Map<String, dynamic>>> getTicketHistory(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Cek apakah tiket punya assignedTo untuk tentukan history
    final ticket = _tickets.firstWhere(
          (t) => t.id == ticketId,
      orElse: () => _tickets.first,
    );
    final scope = ticket.assignedTo != null
        ? MockData.getHelpdeskScope(ticket.assignedTo!.id)
        : '-';
    return [
      {'action': 'Tiket dibuat', 'actor': ticket.reporter.name, 'time': _timeAgo(ticket.createdAt)},
      if (ticket.assignedTo != null)
        {'action': 'Auto-assign ke ${ticket.assignedTo!.name} ($scope)', 'actor': 'Sistem', 'time': _timeAgo(ticket.createdAt)},
      if (ticket.status == TicketStatus.inProgress || ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed)
        {'action': 'Status diubah ke In Progress', 'actor': ticket.assignedTo?.name ?? '-', 'time': '20 jam lalu'},
      if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed)
        {'action': 'Tiket diselesaikan', 'actor': ticket.assignedTo?.name ?? '-', 'time': _timeAgo(ticket.resolvedAt ?? ticket.updatedAt)},
    ];
  }

  Future<dynamic> uploadAttachment({required String ticketId, required dynamic file}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AttachmentModel(
      id: 'att-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      fileName: 'lampiran_${DateTime.now().millisecondsSinceEpoch}.jpg',
      fileUrl: 'https://placeholder.com/attachment',
      mimeType: 'image/jpeg',
      fileSize: 204800,
      type: AttachmentType.image,
      uploadedAt: DateTime.now(),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}