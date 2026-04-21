import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/empty_state.dart';

class HelpdeskDashboardScreen extends StatefulWidget {
  const HelpdeskDashboardScreen({super.key});

  @override
  State<HelpdeskDashboardScreen> createState() =>
      _HelpdeskDashboardScreenState();
}

class _HelpdeskDashboardScreenState extends State<HelpdeskDashboardScreen> {
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
        color: AppColors.primary,
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
                    _buildMyTicketsSection(),
                    const SizedBox(height: 28),
                    _buildAllOpenSection(),
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
      expandedHeight: 150,
      pinned: true,
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFF0F766E),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF134E4A), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF065F46)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      auth.currentUser?.name.substring(0, 1).toUpperCase() ?? 'H',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Halo, ${auth.currentUser?.name ?? 'Helpdesk'}!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
                            '🛠  Helpdesk',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notif bell
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
            Text('Statistik Tiket',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            if (dash.isLoading && stats == null)
              _shimmerGrid()
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  StatsCard(
                    label: 'Total Tiket',
                    count: stats?.totalTickets ?? 0,
                    color: const Color(0xFF0F766E),
                    icon: Icons.confirmation_number_outlined,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.ticketList),
                  ),
                  StatsCard(
                    label: 'Open',
                    count: stats?.openTickets ?? 0,
                    color: AppColors.statusOpen,
                    icon: Icons.inbox_outlined,
                  ),
                  StatsCard(
                    label: 'In Progress',
                    count: stats?.inProgressTickets ?? 0,
                    color: AppColors.statusInProgress,
                    icon: Icons.pending_outlined,
                  ),
                  StatsCard(
                    label: 'Resolved',
                    count: stats?.resolvedTickets ?? 0,
                    color: AppColors.statusResolved,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  // ─── Tiket yang di-assign ke saya ────────────────────────────────────────────

  Widget _buildMyTicketsSection() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        // Filter tiket yang assigned ke helpdesk ini
        final myTickets = dash.recentTickets
            .where((t) => t.assignedTo != null)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ditugaskan ke Saya',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.ticketList,
                    arguments: TicketStatus.inProgress,
                  ),
                  child: Text('Lihat Semua',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F766E))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dash.isLoading && myTickets.isEmpty)
              _shimmerList()
            else if (myTickets.isEmpty)
              _emptyCard('Tidak ada tiket yang ditugaskan ke Anda saat ini.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myTickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => TicketCard(
                  ticket: myTickets[i],
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.ticketDetail,
                    arguments: myTickets[i].id,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ─── Semua tiket Open ────────────────────────────────────────────────────────

  Widget _buildAllOpenSection() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        final openTickets = dash.recentTickets
            .where((t) => t.status == TicketStatus.open)
            .toList();

        return Column(
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
                Text(
                  'Tiket Open & Belum Ditangani',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (openTickets.isEmpty)
              _emptyCard('Semua tiket sudah ditangani. 🎉')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: openTickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => TicketCard(
                  ticket: openTickets[i],
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.ticketDetail,
                    arguments: openTickets[i].id,
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav(bool isDark) {
    return Consumer<NotificationProvider>(
      builder: (_, notif, __) => NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        indicatorColor: const Color(0xFF0F766E).withOpacity(0.12),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  Widget _emptyCard(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _shimmerGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.cardDark : const Color(0xFFE2E8F0);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: List.generate(
        4,
            (_) => Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _shimmerList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.cardDark : const Color(0xFFE2E8F0);
    return Column(
      children: List.generate(
        2,
            (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 110,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}