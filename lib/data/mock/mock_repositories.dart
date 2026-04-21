import '../models/models.dart';
import '../mock/mock_data.dart';
import '../mock/mock_ticket_repository.dart';

// ─── Singleton ticket repo agar data share antara Dashboard & TicketProvider ──

class MockTicketStore {
  static final MockTicketRepository instance = MockTicketRepository();
}

// ─── Mock Notification Repository ─────────────────────────────────────────────

class MockNotificationRepository {
  final List<NotificationModel> _notifications =
  List.from(MockData.notifications);

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var result = List<NotificationModel>.from(_notifications);
    if (isRead != null) {
      result = result.where((n) => n.isRead == isRead).toList();
    }
    return result;
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      return _notifications[idx];
    }
    throw Exception('Notifikasi tidak ditemukan');
  }

  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> registerFcmToken(String fcmToken) async {}
  Future<void> removeFcmToken(String fcmToken) async {}
}

// ─── Mock Dashboard Repository ─────────────────────────────────────────────────

class MockDashboardRepository {
  // Pakai singleton agar data tiket sama dengan TicketProvider
  MockTicketRepository get _ticketRepo => MockTicketStore.instance;

  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tickets = await _ticketRepo.getTickets();
    return DashboardStatsModel(
      totalTickets: tickets.length,
      openTickets: tickets.where((t) => t.status == TicketStatus.open).length,
      inProgressTickets: tickets.where((t) => t.status == TicketStatus.inProgress).length,
      resolvedTickets: tickets.where((t) => t.status == TicketStatus.resolved).length,
      closedTickets: tickets.where((t) => t.status == TicketStatus.closed).length,
    );
  }

  Future<List<TicketModel>> getRecentTickets() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final tickets = await _ticketRepo.getTickets();
    return tickets.take(5).toList();
  }

  Future<List<UserModel>> getHelpdeskList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.helpdeskList;
  }
}
