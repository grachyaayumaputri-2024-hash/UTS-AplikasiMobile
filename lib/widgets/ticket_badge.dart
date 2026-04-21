import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';

class TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;
  final bool small;

  const TicketStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  Color get _color {
    switch (status) {
      case TicketStatus.open:
        return AppColors.statusOpen;
      case TicketStatus.inProgress:
        return AppColors.statusInProgress;
      case TicketStatus.resolved:
        return AppColors.statusResolved;
      case TicketStatus.closed:
        return AppColors.statusClosed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class TicketPriorityBadge extends StatelessWidget {
  final TicketPriority priority;
  final bool small;

  const TicketPriorityBadge({
    super.key,
    required this.priority,
    this.small = false,
  });

  Color get _color {
    switch (priority) {
      case TicketPriority.low:
        return AppColors.priorityLow;
      case TicketPriority.medium:
        return AppColors.priorityMedium;
      case TicketPriority.high:
        return AppColors.priorityHigh;
      case TicketPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: small ? 6 : 8,
          height: small ? 6 : 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          priority.label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: small ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }
}
