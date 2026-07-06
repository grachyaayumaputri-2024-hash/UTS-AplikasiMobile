import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/repositories/repositories.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;
  NotificationProvider({NotificationRepository? repo})
      : _repo = repo ?? NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount  => _unreadCount;
  bool get isLoading   => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUnread   => _unreadCount > 0;

  Future<void> loadNotifications() async {
    _isLoading = true; notifyListeners();
    try {
      _notifications = await _repo.getNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal memuat notifikasi.';
    }
    _isLoading = false; notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final updated = await _repo.markAsRead(notificationId);
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        _notifications[idx] = updated;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0; notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message; notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repo.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _repo.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> registerFcmToken(String token) async {
    try { await _repo.registerFcmToken(token); } catch (_) {}
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}