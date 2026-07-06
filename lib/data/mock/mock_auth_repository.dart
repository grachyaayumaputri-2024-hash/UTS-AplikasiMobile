import '../models/models.dart';
import '../mock/mock_data.dart';

/// Login helpdesk:
///   username 'helpdeska' atau mengandung 'helpdeska' → Helpdesk A
///   username 'helpdeskb' atau mengandung 'helpdeskb' → Helpdesk B
///   username 'helpdeskc' atau mengandung 'helpdeskc' → Helpdesk C
///   username 'admin'    atau mengandung 'admin'      → Admin
///   username lainnya                                 → User biasa
class MockAuthRepository {
  UserModel? _currentUser;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final input = username.toLowerCase().trim();

    if (input == 'admin' || input.contains('admin')) {
      _currentUser = MockData.adminUser;
    } else if (input == 'helpdeska' || input.contains('helpdeska')) {
      _currentUser = MockData.helpdeskA;
    } else if (input == 'helpdeskb' || input.contains('helpdeskb')) {
      _currentUser = MockData.helpdeskB;
    } else if (input == 'helpdeskc' || input.contains('helpdeskc')) {
      _currentUser = MockData.helpdeskC;
    } else {
      // Username apapun selain di atas → user biasa
      final displayName = _capitalize(input.split('@').first);
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