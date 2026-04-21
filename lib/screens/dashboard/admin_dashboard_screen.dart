import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/ticket_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) { if (mounted) _loadData(); });
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<DashboardProvider>().loadDashboard(),
      context.read<DashboardProvider>().loadHelpdeskList(),
      context.read<NotificationProvider>().refreshUnreadCount(),
    ]);
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.ticketList);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.notification);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF7C3AED),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(auth, isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSection(),
                    const SizedBox(height: 28),
                    _buildHelpdeskOverview(),
                    const SizedBox(height: 28),
                    _buildRecentTickets(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(AuthProvider auth, bool isDark) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFF7C3AED),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF3B0764), const Color(0xFF0F172A)]
                  : [const Color(0xFF7C3AED), const Color(0xFF4F46E5)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          auth.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${auth.currentUser?.name ?? 'Admin'}!',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '👑  Admin',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<NotificationProvider>(
                        builder: (_, notif, __) => Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white, size: 26),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.notification),
                            ),
                            if (notif.hasUnread)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick action buttons
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.list_alt_rounded,
                        label: 'Semua Tiket',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.ticketList),
                      ),
                      const SizedBox(width: 10),
                      _QuickAction(
                        icon: Icons.inbox_outlined,
                        label: 'Tiket Open',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.ticketList,
                          arguments: TicketStatus.open,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _QuickAction(
                        icon: Icons.pending_outlined,
                        label: 'In Progress',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.ticketList,
                          arguments: TicketStatus.inProgress,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Stats ───────────────────────────────────────────────────────────────────

  Widget _buildStatsSection() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        final stats = dash.stats;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Ringkasan Sistem',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            // Row pertama: total + open
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    label: 'Total Tiket',
                    count: stats?.totalTickets ?? 0,
                    color: const Color(0xFF7C3AED),
                    icon: Icons.confirmation_number_outlined,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.ticketList),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    label: 'Open',
                    count: stats?.openTickets ?? 0,
                    color: AppColors.statusOpen,
                    icon: Icons.inbox_outlined,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.ticketList,
                      arguments: TicketStatus.open,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row kedua: in progress + resolved + closed
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    label: 'In Progress',
                    count: stats?.inProgressTickets ?? 0,
                    color: AppColors.statusInProgress,
                    icon: Icons.pending_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    label: 'Resolved',
                    count: stats?.resolvedTickets ?? 0,
                    color: AppColors.statusResolved,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    label: 'Closed',
                    count: stats?.closedTickets ?? 0,
                    color: AppColors.statusClosed,
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ─── Helpdesk Overview ────────────────────────────────────────────────────────

  Widget _buildHelpdeskOverview() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Tim Helpdesk',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            if (dash.helpdeskList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text('Tidak ada helpdesk terdaftar.',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dash.helpdeskList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final hd = dash.helpdeskList[i];
                  // Hitung tiket yang di-assign ke helpdesk ini
                  final assignedCount = dash.recentTickets
                      .where((t) => t.assignedTo?.id == hd.id)
                      .length;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                          const Color(0xFF7C3AED).withOpacity(0.12),
                          child: Text(
                            hd.name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hd.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(hd.email,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        // Badge jumlah tiket
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: assignedCount > 0
                                ? AppColors.statusInProgress.withOpacity(0.12)
                                : AppColors.statusResolved.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$assignedCount tiket',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: assignedCount > 0
                                  ? AppColors.statusInProgress
                                  : AppColors.statusResolved,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ─── Recent Tickets ───────────────────────────────────────────────────────────

  Widget _buildRecentTickets() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.statusOpen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Tiket Terbaru',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.ticketList),
                child: Text('Lihat Semua',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C3AED))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dash.recentTickets.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text('Belum ada tiket.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondary)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dash.recentTickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => TicketCard(
                ticket: dash.recentTickets[i],
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.ticketDetail,
                  arguments: dash.recentTickets[i].id,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav(bool isDark) {
    return Consumer<NotificationProvider>(
      builder: (_, notif, __) => NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        indicatorColor: const Color(0xFF7C3AED).withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Tiket',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: notif.hasUnread,
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: notif.hasUnread,
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Notifikasi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}