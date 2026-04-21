import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../provider/providers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, auth, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMenuSection(
                    title: 'Akun',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        onTap: () => _showEditProfileSheet(context, auth),
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Ubah Password',
                        onTap: () =>
                            _showChangePasswordSheet(context, auth),
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuSection(
                    title: 'Tiket Saya',
                    items: [
                      _MenuItem(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Semua Tiket',
                        trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.ticketList),
                      ),
                      if (auth.isUser)
                        _MenuItem(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Buat Tiket Baru',
                          trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textHint),
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.createTicket),
                        ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuSection(
                    title: 'Aplikasi',
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.notification),
                      ),
                      _MenuItem(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        label: isDark ? 'Mode Terang' : 'Mode Gelap',
                        trailing: Switch(
                          value: isDark,
                          onChanged: (_) =>
                              _toggleTheme(context, isDark),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () => _toggleTheme(context, isDark),
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  // Logout
                  _buildMenuSection(
                    items: [
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Keluar',
                        labelColor: AppColors.error,
                        iconColor: AppColors.error,
                        onTap: () => _confirmLogout(context, auth),
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  // Version
                  Text(
                    'E-Ticketing Helpdesk v1.0.0\nUniversitas Airlangga',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textHint,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver AppBar ─────────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(
      BuildContext context, AuthProvider auth, bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark ? AppColors.bgDark : AppColors.primary,
      title: const Text(
        'Profil',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      auth.currentUser?.name
                          .substring(0, 1)
                          .toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Nama
                Text(
                  auth.currentUser?.name ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  auth.currentUser?.email ?? '-',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _roleLabel(auth),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Menu Section ──────────────────────────────────────────────────────────

  Widget _buildMenuSection({
    String? title,
    required List<_MenuItem> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
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
            children: items.asMap().entries.map((e) {
              final index = e.key;
              final item = e.value;
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (item.iconColor ?? AppColors.primary)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: item.iconColor ?? AppColors.primary,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.labelColor ?? AppColors.textPrimary,
                      ),
                    ),
                    trailing: item.trailing ??
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint, size: 18),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Edit Profile Sheet ────────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, AuthProvider auth) {
    final nameCtrl =
    TextEditingController(text: auth.currentUser?.name);
    final emailCtrl =
    TextEditingController(text: auth.currentUser?.email);
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(isDark),
              const SizedBox(height: 20),
              const Text(
                'Edit Profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _sheetField(
                  label: 'Nama Lengkap',
                  controller: nameCtrl,
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null),
              const SizedBox(height: 16),
              _sheetField(
                  label: 'Email',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  }),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (_, a, __) => ElevatedButton(
                  onPressed: a.isLoading
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await a.updateProfile(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Profil berhasil diperbarui'
                              : a.errorMessage ?? 'Gagal'),
                          backgroundColor: ok
                              ? AppColors.success
                              : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  child: a.isLoading
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                              Colors.white)))
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Change Password Sheet ─────────────────────────────────────────────────

  void _showChangePasswordSheet(
      BuildContext context, AuthProvider auth) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(isDark),
              const SizedBox(height: 20),
              const Text(
                'Ubah Password',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _sheetField(
                  label: 'Password Lama',
                  controller: oldCtrl,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Wajib diisi'
                      : null),
              const SizedBox(height: 14),
              _sheetField(
                  label: 'Password Baru',
                  controller: newCtrl,
                  icon: Icons.lock_reset_rounded,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (v.length < 6) {
                      return 'Minimal 6 karakter';
                    }
                    return null;
                  }),
              const SizedBox(height: 14),
              _sheetField(
                  label: 'Konfirmasi Password Baru',
                  controller: confirmCtrl,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (v != newCtrl.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  }),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (_, a, __) => ElevatedButton(
                  onPressed: a.isLoading
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await a.changePassword(
                      oldPassword: oldCtrl.text,
                      newPassword: newCtrl.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Password berhasil diubah'
                              : a.errorMessage ?? 'Gagal'),
                          backgroundColor: ok
                              ? AppColors.success
                              : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  child: a.isLoading
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                              Colors.white)))
                      : const Text('Ubah Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Confirm Logout Dialog ─────────────────────────────────────────────────

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Aplikasi?',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Anda akan keluar dari akun ini.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 38),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ─── Theme Toggle ──────────────────────────────────────────────────────────

  void _toggleTheme(BuildContext context, bool isDark) {
    // Theme management bisa pakai ThemeProvider atau shared_preferences
    // Contoh sederhana — bisa dikembangkan dengan ThemeProvider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDark
              ? 'Beralih ke Mode Terang'
              : 'Beralih ke Mode Gelap',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ─── Helper builders ───────────────────────────────────────────────────────

  Widget _sheetHandle(bool isDark) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF475569)
            : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _sheetField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          style:
          const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }

  String _roleLabel(AuthProvider auth) {
    if (auth.isAdmin) return '👑  Admin';
    if (auth.isHelpdesk) return '🛠  Helpdesk';
    return '👤  User';
  }
}

// ─── Menu Item Model ─────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    this.trailing,
    this.onTap,
  });
}