import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/mock/mock_repositories.dart';
import '../data/mock/mock_ticket_repository.dart';

enum TicketLoadState { initial, loading, loaded, error }

class TicketProvider extends ChangeNotifier {
  final MockTicketRepository _ticketRepository;

  // Pakai singleton agar data share dengan DashboardProvider
  TicketProvider({MockTicketRepository? ticketRepository})
      : _ticketRepository = ticketRepository ?? MockTicketStore.instance;

  TicketLoadState _listState = TicketLoadState.initial;
  TicketLoadState _detailState = TicketLoadState.initial;
  TicketLoadState _actionState = TicketLoadState.initial;

  List<TicketModel> _tickets = [];
  TicketModel? _selectedTicket;
  List<Map<String, dynamic>> _ticketHistory = [];
  String? _errorMessage;

  TicketStatus? _filterStatus;
  TicketPriority? _filterPriority;
  String? _searchQuery;
  int _currentPage = 1;
  bool _hasMore = true;

  TicketLoadState get listState => _listState;
  TicketLoadState get detailState => _detailState;
  TicketLoadState get actionState => _actionState;
  List<TicketModel> get tickets => _tickets;
  TicketModel? get selectedTicket => _selectedTicket;
  List<Map<String, dynamic>> get ticketHistory => _ticketHistory;
  String? get errorMessage => _errorMessage;
  TicketStatus? get filterStatus => _filterStatus;
  TicketPriority? get filterPriority => _filterPriority;
  String? get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  bool get isListLoading => _listState == TicketLoadState.loading;
  bool get isDetailLoading => _detailState == TicketLoadState.loading;
  bool get isActionLoading => _actionState == TicketLoadState.loading;

  Future<void> loadTickets({bool refresh = false}) async {
    if (refresh) { _currentPage = 1; _hasMore = true; _tickets = []; }
    if (!_hasMore || _listState == TicketLoadState.loading) return;
    _listState = TicketLoadState.loading;
    notifyListeners();
    try {
      final result = await _ticketRepository.getTickets(
        status: _filterStatus, priority: _filterPriority,
        search: _searchQuery, page: _currentPage,
      );
      if (refresh) { _tickets = result; } else { _tickets.addAll(result); }
      _hasMore = result.length >= 20;
      if (_hasMore) _currentPage++;
      _errorMessage = null;
      _listState = TicketLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat tiket.';
      _listState = TicketLoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadTicketDetail(String ticketId) async {
    _detailState = TicketLoadState.loading;
    notifyListeners();
    try {
      _selectedTicket = await _ticketRepository.getTicketById(ticketId);
      _errorMessage = null;
      _detailState = TicketLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat detail tiket.';
      _detailState = TicketLoadState.error;
    }
    notifyListeners();
  }

  Future<TicketModel?> createTicket({
    required String title, required String description,
    required String category, required TicketPriority priority,
    List<File>? attachments,
  }) async {
    _actionState = TicketLoadState.loading;
    notifyListeners();
    try {
      final ticket = await _ticketRepository.createTicket(
        title: title, description: description,
        category: category, priority: priority,
      );
      _tickets.insert(0, ticket);
      _errorMessage = null;
      _actionState = TicketLoadState.loaded;
      notifyListeners();
      return ticket;
    } catch (e) {
      _errorMessage = 'Gagal membuat tiket.';
      _actionState = TicketLoadState.error;
      notifyListeners();
      return null;
    }
  }

  Future<bool> addComment({required String ticketId, required String content, bool isInternal = false}) async {
    _actionState = TicketLoadState.loading;
    notifyListeners();
    try {
      final comment = await _ticketRepository.addComment(ticketId: ticketId, content: content, isInternal: isInternal);
      if (_selectedTicket?.id == ticketId) {
        final updated = [..._selectedTicket!.comments, comment];
        _selectedTicket = _selectedTicket!.copyWith(comments: updated);
      }
      _errorMessage = null;
      _actionState = TicketLoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim komentar.';
      _actionState = TicketLoadState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus({required String ticketId, required TicketStatus status}) async {
    _actionState = TicketLoadState.loading;
    notifyListeners();
    try {
      final updated = await _ticketRepository.updateTicketStatus(ticketId: ticketId, status: status);
      _selectedTicket = updated;
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _errorMessage = null;
      _actionState = TicketLoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah status tiket.';
      _actionState = TicketLoadState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignTicket({required String ticketId, required String helpdeskUserId}) async {
    _actionState = TicketLoadState.loading;
    notifyListeners();
    try {
      final updated = await _ticketRepository.assignTicket(ticketId: ticketId, helpdeskUserId: helpdeskUserId);
      _selectedTicket = updated;
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _errorMessage = null;
      _actionState = TicketLoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal assign tiket.';
      _actionState = TicketLoadState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTicketHistory(String ticketId) async {
    try {
      _ticketHistory = await _ticketRepository.getTicketHistory(ticketId);
      notifyListeners();
    } catch (_) { _ticketHistory = []; }
  }

  void setFilter({TicketStatus? status, TicketPriority? priority, String? search}) {
    _filterStatus = status; _filterPriority = priority; _searchQuery = search;
    loadTickets(refresh: true);
  }

  void clearFilter() {
    _filterStatus = null; _filterPriority = null; _searchQuery = null;
    loadTickets(refresh: true);
  }

  void clearError() { _errorMessage = null; notifyListeners(); }
  void clearSelectedTicket() { _selectedTicket = null; _ticketHistory = []; notifyListeners(); }
}