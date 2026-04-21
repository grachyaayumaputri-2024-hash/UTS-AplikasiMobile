import '../models/models.dart';
import 'api_client.dart';

class NotificationRepository {
  final ApiClient _client;

  NotificationRepository({ApiClient? client}) : _client = client ?? ApiClient();

  /// Ambil semua notifikasi milik user yang sedang login
  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (isRead != null) queryParams['is_read'] = isRead;

    final response = await _client.get(
      '/notifications',
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<NotificationModel> markAsRead(String notificationId) async {
    final response = await _client.patch(
      '/notifications/$notificationId/read',
    );
    return NotificationModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    await _client.post('/notifications/read-all');
  }

  /// Hapus satu notifikasi
  Future<void> deleteNotification(String notificationId) async {
    await _client.delete('/notifications/$notificationId');
  }

  /// Ambil jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    return response['count'] as int;
  }

  /// Daftarkan FCM token perangkat untuk push notification
  Future<void> registerFcmToken(String fcmToken) async {
    await _client.post(
      '/notifications/fcm-token',
      body: {'fcm_token': fcmToken},
    );
  }

  /// Hapus FCM token saat logout
  Future<void> removeFcmToken(String fcmToken) async {
    await _client.delete('/notifications/fcm-token/$fcmToken');
  }
}
