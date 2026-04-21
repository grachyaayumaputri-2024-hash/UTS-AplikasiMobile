import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/ticket_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadData();
      });
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(auth, isDark),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreateTicketBanner(isDark),
                    const SizedBox(height: 24),
                    _buildMyStatusSection(isDark),
                    const SizedBox(height: 24),
                    _buildCategorySection(isDark),
                    const SizedBox(height: 24),
                    _buildTipsSection(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(AuthProvider auth, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF0F172A)]
              : [const Color(0xFF1A56DB), const Color(0xFF1E40AF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          auth.currentUser?.name ?? 'Pengguna',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notif + Avatar
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
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      auth.currentUser?.name
                          .substring(0, 1)
                          .toUpperCase() ??
                          'U',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status tiket ringkas
              Consumer<DashboardProvider>(
                builder: (_, dash, __) {
                  final stats = dash.stats;
                  return Row(
                    children: [
                      _StatPill(
                        label: 'Tiket Saya',
                        value: '${stats?.totalTickets ?? 0}',
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        label: 'Aktif',
                        value: '${(stats?.openTickets ?? 0) + (stats?.inProgressTickets ?? 0)}',
                        icon: Icons.pending_outlined,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        label: 'Selesai',
                        value: '${stats?.resolvedTickets ?? 0}',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Banner Buat Tiket ────────────────────────────────────────────────────────

  Widget _buildCreateTicketBanner(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.createTicket),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada masalah IT?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Laporkan sekarang dan tim helpdesk kami akan segera membantu Anda.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Buat Tiket Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic_rounded,
                  color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Status Tiket Saya ────────────────────────────────────────────────────────

  Widget _buildMyStatusSection(bool isDark) {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        final stats = dash.stats;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Tiket Saya',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatusBox(
                    label: 'Open',
                    count: stats?.openTickets ?? 0,
                    color: AppColors.statusOpen,
                    icon: Icons.inbox_outlined,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.ticketList,
                      arguments: TicketStatus.open,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusBox(
                    label: 'Proses',
                    count: stats?.inProgressTickets ?? 0,
                    color: AppColors.statusInProgress,
                    icon: Icons.pending_outlined,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.ticketList,
                      arguments: TicketStatus.inProgress,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusBox(
                    label: 'Selesai',
                    count: stats?.resolvedTickets ?? 0,
                    color: AppColors.statusResolved,
                    icon: Icons.check_circle_outline_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.ticketList,
                      arguments: TicketStatus.resolved,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ─── Kategori Laporan ─────────────────────────────────────────────────────────

  Widget _buildCategorySection(bool isDark) {
    final categories = [
      _CategoryItem(icon: Icons.computer_rounded, label: 'Hardware', color: const Color(0xFF8B5CF6)),
      _CategoryItem(icon: Icons.apps_rounded, label: 'Software', color: const Color(0xFF3B82F6)),
      _CategoryItem(icon: Icons.wifi_rounded, label: 'Jaringan', color: const Color(0xFF10B981)),
      _CategoryItem(icon: Icons.manage_accounts_rounded, label: 'Akun', color: const Color(0xFFF59E0B)),
      _CategoryItem(icon: Icons.print_rounded, label: 'Printer', color: const Color(0xFFEF4444)),
      _CategoryItem(icon: Icons.more_horiz_rounded, label: 'Lainnya', color: const Color(0xFF64748B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lapor Berdasarkan Kategori',
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.createTicket,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child:
                      Icon(cat.icon, color: cat.color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Tips Section ─────────────────────────────────────────────────────────────

  Widget _buildTipsSection(bool isDark) {
    final tips = [
      _Tip(
        icon: Icons.photo_camera_outlined,
        title: 'Sertakan Foto',
        desc: 'Lampirkan screenshot atau foto masalah agar lebih cepat ditangani.',
      ),
      _Tip(
        icon: Icons.description_outlined,
        title: 'Deskripsi Jelas',
        desc: 'Jelaskan kapan masalah terjadi dan apa yang sudah dicoba.',
      ),
      _Tip(
        icon: Icons.priority_high_rounded,
        title: 'Pilih Prioritas',
        desc: 'Atur prioritas sesuai tingkat urgensi masalah yang dialami.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Tips Pelaporan',
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 10),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tip.icon,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tip.desc,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav(bool isDark) {
    return Consumer<NotificationProvider>(
      builder: (_, notif, __) => NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Tiket Saya',
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi 👋';
    if (hour < 15) return 'Selamat Siang 👋';
    if (hour < 18) return 'Selamat Sore 👋';
    return 'Selamat Malam 👋';
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _StatusBox({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  _CategoryItem({required this.icon, required this.label, required this.color});
}

class _Tip {
  final IconData icon;
  final String title;
  final String desc;
  _Tip({required this.icon, required this.title, required this.desc});
}