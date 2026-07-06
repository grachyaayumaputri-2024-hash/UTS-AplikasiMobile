class DashboardStatsModel {
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int resolvedTickets;
  final int assignedTickets;
  final int closedTickets;

  DashboardStatsModel({
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
    required this.assignedTickets,
    required this.closedTickets,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalTickets: json['total_tickets'] as int,
      openTickets: json['open_tickets'] as int,
      inProgressTickets: json['in_progress_tickets'] as int,
      resolvedTickets: json['resolved_tickets'] as int,
      assignedTickets: json['assigned_tickets'] as int? ?? 0,
      closedTickets: json['closed_tickets'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tickets': totalTickets,
      'open_tickets': openTickets,
      'in_progress_tickets': inProgressTickets,
      'resolved_tickets': resolvedTickets,
      'assigned_tickets': assignedTickets,
      'closed_tickets': closedTickets,
    };
  }

  /// Returns percentage of resolved tickets (0.0 - 1.0)
  double get resolvedRate {
    if (totalTickets == 0) return 0.0;
    return resolvedTickets / totalTickets;
  }

  @override
  String toString() {
    return 'DashboardStatsModel(total: $totalTickets, open: $openTickets, inProgress: $inProgressTickets)';
  }
}