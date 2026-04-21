import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/mock/mock_auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final MockAuthRepository _authRepository;

  AuthProvider({MockAuthRepository? authRepository})
      : _authRepository = authRepository ?? MockAuthRepository();

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

  void _setState(AuthState state) { _state = state; notifyListeners(); }
  void _setError(String message) { _errorMessage = message; _state = AuthState.error; notifyListeners(); }

  Future<void> tryRestoreSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _setState(AuthState.unauthenticated);
  }

  Future<bool> login({required String username, required String password}) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _authRepository.login(username: username, password: password);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Login gagal. Coba lagi.');
      return false;
    }
  }

  Future<bool> register({required String name, required String email, required String username, required String password}) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _authRepository.register(name: name, email: email, username: username, password: password);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Registrasi gagal. Coba lagi.');
      return false;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);
    try { await _authRepository.logout(); } finally {
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _setState(AuthState.loading);
    try {
      await _authRepository.resetPassword(email: email);
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Gagal mengirim email reset.');
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _authRepository.updateProfile(name: name, email: email);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Gagal memperbarui profil.');
      return false;
    }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _setState(AuthState.loading);
    try {
      await _authRepository.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Gagal mengubah password.');
      return false;
    }
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}