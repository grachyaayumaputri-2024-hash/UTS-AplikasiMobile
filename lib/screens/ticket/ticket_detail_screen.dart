import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/ticket_badge.dart';
import '../../widgets/empty_state.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentCtrl = TextEditingController();
  bool _isInternalComment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ticketId =
      ModalRoute.of(context)?.settings.arguments as String?;
      if (ticketId != null) {
        context.read<TicketProvider>().loadTicketDetail(ticketId);
        context.read<TicketProvider>().loadTicketHistory(ticketId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final tp = context.read<TicketProvider>();
    final ticketId = tp.selectedTicket?.id;
    if (ticketId == null) return;

    FocusScope.of(context).unfocus();
    final content = _commentCtrl.text.trim();
    _commentCtrl.clear();

    final ok = await tp.addComment(
      ticketId: ticketId,
      content: content,
      isInternal: _isInternalComment,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tp.errorMessage ?? 'Gagal mengirim komentar.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showUpdateStatusSheet(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UpdateStatusSheet(
        currentStatus: ticket.status,
        onUpdate: (status) async {
          final ok = await context.read<TicketProvider>().updateStatus(
            ticketId: ticket.id,
            status: status,
          );
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Status berhasil diperbarui'
                    : context.read<TicketProvider>().errorMessage ??
                    'Gagal update status'),
                backgroundColor: ok ? AppColors.success : AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
      ),
    );
  }

  void _showAssignSheet(TicketModel ticket) {
    context.read<DashboardProvider>().loadHelpdeskList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<DashboardProvider>(
        builder: (ctx, dash, __) => _AssignSheet(
          helpdeskList: dash.helpdeskList,
          currentAssignee: ticket.assignedTo,
          onAssign: (userId) async {
            final ok = await context.read<TicketProvider>().assignTicket(
              ticketId: ticket.id,
              helpdeskUserId: userId,
            );
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Tiket berhasil di-assign' : 'Gagal assign'),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TicketProvider>(
        builder: (_, tp, __) {
          if (tp.detailState == TicketLoadState.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (tp.detailState == TicketLoadState.error ||
              tp.selectedTicket == null) {
            return Scaffold(
              appBar: AppBar(),
              body: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Tiket Tidak Ditemukan',
                subtitle: tp.errorMessage ?? 'Terjadi kesalahan.',
                buttonLabel: 'Kembali',
                onButtonTap: () => Navigator.of(context).pop(),
              ),
            );
          }

          final ticket = tp.selectedTicket!;

          return Scaffold(
            appBar: _buildAppBar(ticket, auth, isDark),
            body: Column(
              children: [
                // Tab bar
                Container(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Detail'),
                      Tab(text: 'Komentar'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                ),

                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DetailTab(ticket: ticket),
                      _CommentsTab(ticket: ticket),
                      _HistoryTab(history: tp.ticketHistory),
                    ],
                  ),
                ),
              ],
            ),

            // Comment input bar (hanya di tab komentar)
            bottomNavigationBar: _buildCommentBar(auth, ticket, isDark),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(
      TicketModel ticket, AuthProvider auth, bool isDark) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${ticket.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            ticket.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        if (auth.isAdmin || auth.isHelpdesk) ...[
          // Assign button
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Assign',
              onPressed: () => _showAssignSheet(ticket),
            ),
          // Update status
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Update Status',
            onPressed: () => _showUpdateStatusSheet(ticket),
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildCommentBar(
      AuthProvider auth, TicketModel ticket, bool isDark) {
    // Jangan tampil jika tiket sudah closed
    if (ticket.status == TicketStatus.closed) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Internal toggle (hanya helpdesk/admin)
            if (auth.isAdmin || auth.isHelpdesk)
              Row(
                children: [
                  Switch(
                    value: _isInternalComment,
                    onChanged: (v) =>
                        setState(() => _isInternalComment = v),
                    activeColor: AppColors.warning,
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Catatan internal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _isInternalComment
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    maxLines: null,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<TicketProvider>(
                  builder: (_, tp, __) => GestureDetector(
                    onTap: tp.isActionLoading ? null : _sendComment,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: tp.isActionLoading
                          ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                              Colors.white),
                        ),
                      )
                          : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab: Detail ─────────────────────────────────────────────────────────────

class _DetailTab extends StatelessWidget {
  final TicketModel ticket;
  const _DetailTab({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & priority row
          Row(
            children: [
              TicketStatusBadge(status: ticket.status),
              const SizedBox(width: 8),
              TicketPriorityBadge(priority: ticket.priority),
            ],
          ),
          const SizedBox(height: 16),

          _InfoCard(
            isDark: isDark,
            children: [
              _InfoRow(
                label: 'Kategori',
                value: ticket.category,
                icon: Icons.category_outlined,
              ),
              _divider(),
              _InfoRow(
                label: 'Pelapor',
                value: ticket.reporter.name,
                icon: Icons.person_outline_rounded,
              ),
              _divider(),
              _InfoRow(
                label: 'Ditangani Oleh',
                value: ticket.assignedTo?.name ?? 'Belum di-assign',
                icon: Icons.support_agent_outlined,
                valueColor: ticket.assignedTo == null
                    ? AppColors.textHint
                    : null,
              ),
              _divider(),
              _InfoRow(
                label: 'Dibuat',
                value: _formatDate(ticket.createdAt),
                icon: Icons.calendar_today_outlined,
              ),
              _divider(),
              _InfoRow(
                label: 'Diperbarui',
                value: _formatDate(ticket.updatedAt),
                icon: Icons.update_rounded,
              ),
              if (ticket.resolvedAt != null) ...[
                _divider(),
                _InfoRow(
                  label: 'Diselesaikan',
                  value: _formatDate(ticket.resolvedAt!),
                  icon: Icons.check_circle_outline_rounded,
                  valueColor: AppColors.success,
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Deskripsi
          _SectionTitle(title: 'Deskripsi'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
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
            child: Text(
              ticket.description,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),

          // Attachments
          if (ticket.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: 'Lampiran (${ticket.attachments.length})'),
            const SizedBox(height: 8),
            ...ticket.attachments.map((a) => _AttachmentTile(attachment: a)),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Divider _divider() => const Divider(height: 1, indent: 12, endIndent: 12);

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Tab: Komentar ───────────────────────────────────────────────────────────

class _CommentsTab extends StatelessWidget {
  final TicketModel ticket;
  const _CommentsTab({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (ticket.comments.isEmpty) {
      return const EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Belum Ada Komentar',
        subtitle: 'Jadilah yang pertama berkomentar.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: ticket.comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final comment = ticket.comments[i];
        // Sembunyikan komentar internal dari user biasa
        if (comment.isInternal && auth.isUser) return const SizedBox.shrink();
        return _CommentBubble(comment: comment, auth: auth);
      },
    );
  }
}

// ─── Tab: Riwayat ────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'Belum Ada Riwayat',
        subtitle: 'Aktivitas tiket akan tercatat di sini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final item = history[i];
        final isLast = i == history.length - 1;
        return _HistoryItem(item: item, isLast: isLast);
      },
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _InfoCard({required this.isDark, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
      ),
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _AttachmentTile extends StatelessWidget {
  final AttachmentModel attachment;
  const _AttachmentTile({required this.attachment});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            attachment.type.isImage
                ? Icons.image_outlined
                : Icons.attach_file_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  attachment.fileSizeLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                size: 18, color: AppColors.primary),
            onPressed: () {}, // handle download
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  final AuthProvider auth;
  const _CommentBubble({required this.comment, required this.auth});

  bool get _isMe => comment.author.id == auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment:
      _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Author + time
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    comment.author.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                _isMe ? 'Anda' : comment.author.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(comment.createdAt),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              if (comment.isInternal) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Internal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bubble
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isMe
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(_isMe ? 14 : 4),
              bottomRight: Radius.circular(_isMe ? 4 : 14),
            ),
            border: _isMe
                ? null
                : Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            comment.content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _isMe ? Colors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  const _HistoryItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 52,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['action']?.toString() ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['actor'] ?? ''} · ${item['time'] ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Update Status Sheet ──────────────────────────────────────────────────────

class _UpdateStatusSheet extends StatelessWidget {
  final TicketStatus currentStatus;
  final void Function(TicketStatus) onUpdate;

  const _UpdateStatusSheet({
    required this.currentStatus,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
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
          ),
          const SizedBox(height: 20),
          const Text(
            'Update Status Tiket',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...TicketStatus.values.map(
                (s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: TicketStatusBadge(status: s),
              trailing: s == currentStatus
                  ? const Icon(Icons.check_rounded,
                  color: AppColors.primary)
                  : null,
              onTap: s == currentStatus ? null : () => onUpdate(s),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Assign Sheet ─────────────────────────────────────────────────────────────

class _AssignSheet extends StatelessWidget {
  final List<UserModel> helpdeskList;
  final UserModel? currentAssignee;
  final void Function(String userId) onAssign;

  const _AssignSheet({
    required this.helpdeskList,
    required this.currentAssignee,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
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
            ),
            const SizedBox(height: 20),
            const Text(
              'Assign ke Helpdesk',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (helpdeskList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Tidak ada helpdesk tersedia',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: helpdeskList.length,
                  itemBuilder: (_, i) {
                    final hd = helpdeskList[i];
                    final isAssigned = hd.id == currentAssignee?.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        AppColors.primary.withOpacity(0.12),
                        child: Text(
                          hd.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        hd.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        hd.email,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: isAssigned
                          ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                          : null,
                      onTap: () => onAssign(hd.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}