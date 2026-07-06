import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/repositories/repositories.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AuthProvider({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isHelpdesk => _currentUser?.role == 'helpdesk';
  bool get isUser => _currentUser?.role == 'user';

  void _setState(AuthState s) { _state = s; notifyListeners(); }
  void _setError(String msg) {
    _errorMessage = msg;
    _state = _currentUser != null ? AuthState.authenticated : AuthState.error;
    notifyListeners();
  }

  // Restore session dari SharedPreferences saat app dibuka
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) { _setState(AuthState.unauthenticated); return; }
    try {
      _repo.restoreToken(token);
      _currentUser = await _repo.getProfile();
      _setState(AuthState.authenticated);
    } catch (_) {
      await prefs.remove('auth_token');
      _repo.clearToken();
      _setState(AuthState.unauthenticated);
    }
  }

  Future<bool> login({required String username, required String password}) async {
    _setState(AuthState.loading);
    try {
      final result = await _repo.login(username: username, password: password);
      _currentUser = result['user'] as UserModel;
      final token = result['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Login gagal. Coba lagi.');
      return false;
    }
  }

  Future<bool> register({
    required String name, required String email,
    required String username, required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      final result = await _repo.register(
        name: name, email: email, username: username, password: password,
      );
      _currentUser = result['user'] as UserModel;
      final token = result['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Registrasi gagal. Coba lagi.');
      return false;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);
    try { await _repo.logout(); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  Future<bool> resetPassword({required String email}) async {
    _setState(AuthState.loading);
    try {
      await _repo.resetPassword(email: email);
      _setState(AuthState.unauthenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Gagal mengirim email reset.');
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _repo.updateProfile(name: name, email: email);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Gagal memperbarui profil.');
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword, required String newPassword,
  }) async {
    _setState(AuthState.loading);
    try {
      await _repo.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Gagal mengubah password.');
      return false;
    }
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}