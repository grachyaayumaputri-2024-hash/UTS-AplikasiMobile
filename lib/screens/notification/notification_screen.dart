import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/empty_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, notif, __) {
              if (!notif.hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: notif.isLoading ? null : notif.markAllAsRead,
                child: const Text(
                  'Baca Semua',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (_, notif, __) {
          // Loading
          if (notif.isLoading && notif.notifications.isEmpty) {
            return _buildShimmer(isDark);
          }

          // Error
          if (notif.errorMessage != null && notif.notifications.isEmpty) {
            return EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal Memuat',
              subtitle: notif.errorMessage!,
              buttonLabel: 'Coba Lagi',
              onButtonTap: notif.loadNotifications,
            );
          }

          // Empty
          if (notif.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Tidak Ada Notifikasi',
              subtitle: 'Pembaruan tiket akan tampil di sini.',
            );
          }

          return RefreshIndicator(
            onRefresh: notif.loadNotifications,
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: notif.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = notif.notifications[i];
                return _NotifCard(
                  notification: item,
                  isDark: isDark,
                  onTap: () => _onNotifTap(context, notif, item),
                  onDismiss: () => notif.deleteNotification(item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onNotifTap(BuildContext context, NotificationProvider notif,
      NotificationModel item) {
    // Tandai sebagai sudah dibaca
    if (!item.isRead) notif.markAsRead(item.id);

    // Navigasi ke tiket terkait jika ada
    if (item.ticketId != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.ticketDetail,
        arguments: item.ticketId,
      );
    }
  }

  Widget _buildShimmer(bool isDark) {
    final color =
    isDark ? AppColors.cardDark : const Color(0xFFE2E8F0);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? (isDark ? AppColors.surfaceDark : Colors.white)
                : (isDark
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? (isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0))
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Unread dot
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Type chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.type.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _iconColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(notification.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 22),
          SizedBox(height: 4),
          Text(
            'Hapus',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.ticketCreated:
        return AppColors.primary;
      case NotificationType.ticketUpdated:
        return AppColors.info;
      case NotificationType.ticketAssigned:
        return AppColors.warning;
      case NotificationType.ticketResolved:
        return AppColors.success;
      case NotificationType.ticketClosed:
        return AppColors.statusClosed;
      case NotificationType.newComment:
        return AppColors.primaryLight;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.ticketCreated:
        return Icons.add_circle_outline_rounded;
      case NotificationType.ticketUpdated:
        return Icons.edit_outlined;
      case NotificationType.ticketAssigned:
        return Icons.person_add_outlined;
      case NotificationType.ticketResolved:
        return Icons.check_circle_outline_rounded;
      case NotificationType.ticketClosed:
        return Icons.cancel_outlined;
      case NotificationType.newComment:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}