import '../models/models.dart';
import '../mock/mock_data.dart';

class MockAuthRepository {
  UserModel? _currentUser;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final input = username.toLowerCase().trim();

    // Cek admin — username atau email mengandung 'admin'
    if (input == 'admin' || input.contains('admin')) {
      _currentUser = MockData.adminUser;
    }
    // Cek helpdesk — username atau email mengandung 'helpdesk'
    else if (input == 'helpdesk' || input.contains('helpdesk')) {
      _currentUser = MockData.helpdeskUser;
    }
    // Selain itu → user biasa
    else {
      final displayName = _capitalize(username.split('@').first);
      _currentUser = MockData.regularUser.copyWith(
        name: displayName,
        username: username,
      );
      MockData.regularUser = _currentUser!;
    }

    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'user-new-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      username: username,
      role: 'user',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser ?? MockData.regularUser;
  }

  Future<UserModel> updateProfile({String? name, String? email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = (_currentUser ?? MockData.regularUser).copyWith(
      name: name,
      email: email,
    );
    return _currentUser!;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}