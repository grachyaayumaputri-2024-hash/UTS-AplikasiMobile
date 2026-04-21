import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import 'dashboard_screen.dart';
import 'helpdesk_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

/// Router dashboard — otomatis tampilkan dashboard sesuai role user
class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAdmin) {
      return const AdminDashboardScreen();
    } else if (auth.isHelpdesk) {
      return const HelpdeskDashboardScreen();
    } else {
      return const DashboardScreen();
    }
  }
}