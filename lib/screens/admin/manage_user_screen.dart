import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../provider/providers.dart';
import '../../data/models/models.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchCtrl = TextEditingController();
  String? _filterRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Lihat Helpdesk',
            onPressed: () => _setFilter('helpdesk'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter bar
          Container(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<UserManagementProvider>()
                      .setFilter(role: _filterRole, search: v.isEmpty ? null : v),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, username...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<UserManagementProvider>()
                            .setFilter(role: _filterRole);
                      },
                    )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 8),
                // Role filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RoleChip(label: 'Semua', value: null, current: _filterRole, onTap: () => _setFilter(null)),
                      const SizedBox(width: 8),
                      _RoleChip(label: '👑 Admin', value: 'admin', current: _filterRole, onTap: () => _setFilter('admin')),
                      const SizedBox(width: 8),
                      _RoleChip(label: '🛠 Helpdesk', value: 'helpdesk', current: _filterRole, onTap: () => _setFilter('helpdesk')),
                      const SizedBox(width: 8),
                      _RoleChip(label: '👤 User', value: 'user', current: _filterRole, onTap: () => _setFilter('user')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // User list
          Expanded(
            child: Consumer<UserManagementProvider>(
              builder: (_, um, __) {
                if (um.isLoading && um.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (um.errorMessage != null && um.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(um.errorMessage!, style: GoogleFonts.poppins(color: AppColors.error)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: um.loadUsers,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                if (um.users.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada pengguna ditemukan.',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: um.loadUsers,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: um.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _UserCard(
                      user: um.users[i],
                      onToggleActive: () => _toggleActive(um.users[i]),
                      onDelete: () => _confirmDelete(um.users[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setFilter(String? role) {
    setState(() => _filterRole = role);
    context.read<UserManagementProvider>().setFilter(
      role: role,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );
  }

  Future<void> _toggleActive(UserModel user) async {
    final um = context.read<UserManagementProvider>();
    final isActive = user.isActive;
    final action = isActive ? 'menonaktifkan' : 'mengaktifkan';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isActive ? 'Nonaktifkan Pengguna?' : 'Aktifkan Pengguna?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin $action akun ${user.name}?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.error : AppColors.success,
              minimumSize: const Size(80, 36),
            ),
            child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final ok = isActive
        ? await um.deactivateUser(user.id)
        : await um.activateUser(user.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? '${user.name} berhasil ${isActive ? 'dinonaktifkan' : 'diaktifkan'}.'
            : um.errorMessage ?? 'Gagal.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Pengguna?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Akun ${user.name} akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final um = context.read<UserManagementProvider>();
    final ok = await um.deleteUser(user.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '${user.name} berhasil dihapus.' : um.errorMessage ?? 'Gagal.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }
}

// ─── Role Filter Chip ─────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  final String? value;
  final String? current;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label, required this.value,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onToggleActive,
    required this.onDelete,
  });

  Color get _roleColor {
    switch (user.role) {
      case 'admin': return const Color(0xFF7C3AED);
      case 'helpdesk': return const Color(0xFF0F766E);
      default: return AppColors.primary;
    }
  }

  String get _roleLabel {
    switch (user.role) {
      case 'admin': return '👑 Admin';
      case 'helpdesk': return '🛠 Helpdesk';
      default: return '👤 User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = user.isActive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !isActive
              ? AppColors.error.withOpacity(0.3)
              : isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? _roleColor.withOpacity(0.12) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isActive ? _roleColor : AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : AppColors.textHint,
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Nonaktif',
                          style: GoogleFonts.poppins(
                            fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w600, color: _roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'toggle') onToggleActive();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: isActive ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isActive ? 'Nonaktifkan' : 'Aktifkan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isActive ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text('Hapus', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}