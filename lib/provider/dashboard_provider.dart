import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/repositories/repositories.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repo;
  DashboardProvider({DashboardRepository? repo})
      : _repo = repo ?? DashboardRepository();

  DashboardStatsModel? _stats;
  List<TicketModel>    _recentTickets = [];
  List<UserModel>      _helpdeskList  = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStatsModel? get stats        => _stats;
  List<TicketModel>    get recentTickets => _recentTickets;
  List<UserModel>      get helpdeskList  => _helpdeskList;
  bool get isLoading   => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TicketModel> _myAssignedTickets = [];
  List<TicketModel> get myAssignedTickets => _myAssignedTickets;

  List<TicketModel> _unassignedOpenTickets = [];
  List<TicketModel> get unassignedOpenTickets => _unassignedOpenTickets;

  Future<void> loadDashboard() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getStats(),
        _repo.getRecentTickets(),
        _repo.getMyAssignedTickets(),
        _repo.getUnassignedOpenTickets(),
      ]);
      _stats                 = results[0] as DashboardStatsModel;
      _recentTickets         = results[1] as List<TicketModel>;
      _myAssignedTickets     = results[2] as List<TicketModel>;
      _unassignedOpenTickets = results[3] as List<TicketModel>;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
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