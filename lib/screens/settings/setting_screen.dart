import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../provider/providers.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notifEnabled    = true;
  bool _soundEnabled    = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Tampilan ─────────────────────────────────────────────────────
            _sectionTitle('Tampilan'),
            const SizedBox(height: 8),
            _menuCard(
              isDark: isDark,
              children: [
                _switchItem(
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  iconColor: isDark ? AppColors.warning : AppColors.textSecondary,
                  label: 'Mode Gelap',
                  subtitle: 'Mengikuti pengaturan sistem',
                  value: isDark,
                  onChanged: (_) => _showThemeInfo(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Notifikasi ────────────────────────────────────────────────────
            _sectionTitle('Notifikasi'),
            const SizedBox(height: 8),
            _menuCard(
              isDark: isDark,
              children: [
                _switchItem(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.primary,
                  label: 'Notifikasi',
                  subtitle: 'Terima pemberitahuan tiket',
                  value: _notifEnabled,
                  onChanged: (v) => setState(() => _notifEnabled = v),
                ),
                _divider(),
                _switchItem(
                  icon: Icons.volume_up_outlined,
                  iconColor: AppColors.success,
                  label: 'Suara',
                  subtitle: 'Putar suara saat notifikasi masuk',
                  value: _soundEnabled && _notifEnabled,
                  onChanged: _notifEnabled ? (v) => setState(() => _soundEnabled = v) : null,
                ),
                _divider(),
                _switchItem(
                  icon: Icons.vibration_rounded,
                  iconColor: AppColors.info,
                  label: 'Getar',
                  subtitle: 'Getar saat notifikasi masuk',
                  value: _vibrationEnabled && _notifEnabled,
                  onChanged: _notifEnabled ? (v) => setState(() => _vibrationEnabled = v) : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tiket ─────────────────────────────────────────────────────────
            _sectionTitle('Tiket'),
            const SizedBox(height: 8),
            _menuCard(
              isDark: isDark,
              children: [
                _arrowItem(
                  icon: Icons.confirmation_number_outlined,
                  iconColor: AppColors.primary,
                  label: 'Tiket Saya',
                  subtitle: 'Lihat semua tiket yang pernah dibuat',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tentang ────────────────────────────────────────────────────────
            _sectionTitle('Tentang Aplikasi'),
            const SizedBox(height: 8),
            _menuCard(
              isDark: isDark,
              children: [
                _arrowItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.info,
                  label: 'Versi Aplikasi',
                  subtitle: 'v2.0.0',
                  onTap: () {},
                  showArrow: false,
                ),
                _divider(),
                _arrowItem(
                  icon: Icons.school_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  label: 'Program Studi',
                  subtitle: 'DIV Teknik Informatika',
                  onTap: () {},
                  showArrow: false,
                ),
                _divider(),
                _arrowItem(
                  icon: Icons.location_city_outlined,
                  iconColor: const Color(0xFF0F766E),
                  label: 'Universitas',
                  subtitle: 'Universitas Airlangga',
                  onTap: () {},
                  showArrow: false,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Akun ──────────────────────────────────────────────────────────
            _sectionTitle('Akun'),
            const SizedBox(height: 8),
            _menuCard(
              isDark: isDark,
              children: [
                _arrowItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  label: 'Keluar',
                  labelColor: AppColors.error,
                  onTap: () => _confirmLogout(),
                  showArrow: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary, letterSpacing: .5,
    ),
  );

  Widget _menuCard({required bool isDark, required List<Widget> children}) =>
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
    height: 1, indent: 56, endIndent: 16,
    color: const Color(0xFFF1F5F9),
  );

  Widget _switchItem({
    required IconData icon, required Color iconColor,
    required String label, required String subtitle,
    required bool value, required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _arrowItem({
    required IconData icon, required Color iconColor,
    required String label, String? subtitle, Color? labelColor,
    required VoidCallback onTap, bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary))
          : null,
      trailing: showArrow
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20)
          : null,
    );
  }

  void _showThemeInfo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Mode tampilan mengikuti pengaturan sistem perangkat Anda.',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar dari Aplikasi?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Anda akan keluar dari akun ini.', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, minimumSize: const Size(80, 38),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }
}