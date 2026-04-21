import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/mock/mock_repositories.dart';

class DashboardProvider extends ChangeNotifier {
  final MockDashboardRepository _repo;

  DashboardProvider({MockDashboardRepository? repo})
      : _repo = repo ?? MockDashboardRepository();

  DashboardStatsModel? _stats;
  List<TicketModel> _recentTickets = [];
  List<UserModel> _helpdeskList = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStatsModel? get stats => _stats;
  List<TicketModel> get recentTickets => _recentTickets;
  List<UserModel> get helpdeskList => _helpdeskList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getStats(),
        _repo.getRecentTickets(),
      ]);
      _stats = results[0] as DashboardStatsModel;
      _recentTickets = results[1] as List<TicketModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat dashboard.';
    }
    _isLoading = false; notifyListeners();
  }

  Future<void> loadHelpdeskList() async {
    try {
      _helpdeskList = await _repo.getHelpdeskList();
      notifyListeners();
    } catch (_) {}
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
}