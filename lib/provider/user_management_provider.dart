import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/repositories/repositories.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRepository _repo;
  UserManagementProvider({UserManagementRepository? repo})
      : _repo = repo ?? UserManagementRepository();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchQuery;
  String? _filterRole;

  List<UserModel> get users        => _users;
  bool get isLoading               => _isLoading;
  String? get errorMessage         => _errorMessage;
  String? get filterRole           => _filterRole;

  Future<void> loadUsers() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      _users = await _repo.getUsers(role: _filterRole, search: _searchQuery);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal memuat data pengguna.';
    }
    _isLoading = false; notifyListeners();
  }

  void setFilter({String? role, String? search}) {
    _filterRole = role;
    _searchQuery = search;
    loadUsers();
  }

  Future<bool> deactivateUser(String userId) async {
    try {
      final updated = await _repo.deactivateUser(userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) { _users[idx] = updated; notifyListeners(); }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message; notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menonaktifkan pengguna.'; notifyListeners();
      return false;
    }
  }

  Future<bool> activateUser(String userId) async {
    try {
      final updated = await _repo.activateUser(userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) { _users[idx] = updated; notifyListeners(); }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message; notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal mengaktifkan pengguna.'; notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message; notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus pengguna.'; notifyListeners();
      return false;
    }
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}