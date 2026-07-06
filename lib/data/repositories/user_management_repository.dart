import '../models/models.dart';
import 'api_client.dart';

class UserManagementRepository {
  final ApiClient _client;
  UserManagementRepository({ApiClient? client}) : _client = client ?? ApiClient();

  /// Ambil semua pengguna (admin only)
  Future<List<UserModel>> getUsers({String? role, String? search}) async {
    final params = <String, dynamic>{};
    if (role != null) params['role'] = role;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get('/admin/users', queryParams: params);
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Nonaktifkan pengguna
  Future<UserModel> deactivateUser(String userId) async {
    final response = await _client.patch('/admin/users/$userId/deactivate');
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Aktifkan kembali pengguna
  Future<UserModel> activateUser(String userId) async {
    final response = await _client.patch('/admin/users/$userId/activate');
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Hapus pengguna
  Future<void> deleteUser(String userId) async {
    await _client.delete('/admin/users/$userId');
  }
}