import '../models/models.dart';
import 'api_client.dart';

class DashboardRepository {
  final ApiClient _client;

  DashboardRepository({ApiClient? client}) : _client = client ?? ApiClient();

  /// Ambil statistik tiket untuk dashboard
  /// - User       : hanya tiket miliknya
  /// - Helpdesk   : tiket yang di-assign kepadanya
  /// - Admin      : semua tiket
  Future<DashboardStatsModel> getStats() async {
    final response = await _client.get('/dashboard/stats');
    return DashboardStatsModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Ambil daftar tiket terbaru untuk preview di dashboard (limit 5)
  Future<List<TicketModel>> getRecentTickets() async {
    final response = await _client.get(
      '/tickets',
      queryParams: {'limit': 5, 'page': 1, 'sort': 'created_at:desc'},
    );
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil daftar helpdesk yang tersedia (untuk admin assign tiket)
  Future<List<UserModel>> getHelpdeskList() async {
    final response = await _client.get(
      '/users',
      queryParams: {'role': 'helpdesk'},
    );
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
