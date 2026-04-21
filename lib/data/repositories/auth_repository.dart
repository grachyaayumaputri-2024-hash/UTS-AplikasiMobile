import '../models/models.dart';
import 'api_client.dart';

class AuthRepository {
  final ApiClient _client;
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  // Login — return Map berisi 'token' dan 'user'
  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    final response = await _client.post('/auth/login', body: {'username': username, 'password': password});
    final token = response['token'] as String;
    _client.setToken(token);
    return {
      'token': token,
      'user': UserModel.fromJson(response['user'] as Map<String, dynamic>),
    };
  }

  // Register — return Map berisi 'token' dan 'user'
  Future<Map<String, dynamic>> register({required String name, required String email, required String username, required String password}) async {
    final response = await _client.post('/auth/register', body: {
      'name': name, 'email': email, 'username': username, 'password': password,
    });
    final token = response['token'] as String;
    _client.setToken(token);
    return {
      'token': token,
      'user': UserModel.fromJson(response['user'] as Map<String, dynamic>),
    };
  }

  Future<void> logout() async {
    try { await _client.post('/auth/logout'); } finally { _client.clearToken(); }
  }

  Future<void> resetPassword({required String email}) async {
    await _client.post('/auth/reset-password', body: {'email': email});
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get('/auth/me');
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({String? name, String? email}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    final response = await _client.put('/auth/me', body: body);
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    await _client.post('/auth/change-password', body: {
      'old_password': oldPassword, 'new_password': newPassword,
    });
  }

  void restoreToken(String token) => _client.restoreToken(token);
  void clearToken() => _client.clearToken();
}