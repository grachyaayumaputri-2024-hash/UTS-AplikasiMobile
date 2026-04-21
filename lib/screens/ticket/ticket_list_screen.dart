import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/empty_state.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final tp = context.read<TicketProvider>();
      if (args is TicketStatus) {
        tp.setFilter(status: args);
      } else {
        tp.loadTickets(refresh: true);
      }
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<TicketProvider>().loadTickets();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh setiap kali halaman ini aktif kembali
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TicketProvider>().loadTickets(refresh: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context
        .read<TicketProvider>()
        .setFilter(search: query.isEmpty ? null : query);
  }

  void _showFilterSheet() {
    final tp = context.read<TicketProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        currentStatus: tp.filterStatus,
        currentPriority: tp.filterPriority,
        onApply: (status, priority) {
          context.read<TicketProvider>().setFilter(
            status: status,
            priority: priority,
            search:
            _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
          );
        },
        onClear: () => context.read<TicketProvider>().clearFilter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: _onSearch,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Cari tiket...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        )
            : const Text('Daftar Tiket'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                context.read<TicketProvider>().clearFilter();
              }
            },
          ),
          Consumer<TicketProvider>(
            builder: (_, tp, __) {
              final hasFilter =
                  tp.filterStatus != null || tp.filterPriority != null;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded),
                    onPressed: _showFilterSheet,
                  ),
                  if (hasFilter)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (_, tp, __) {
          if (tp.listState == TicketLoadState.error && tp.tickets.isEmpty) {
            return EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal Memuat',
              subtitle: tp.errorMessage ?? 'Terjadi kesalahan.',
              buttonLabel: 'Coba Lagi',
              onButtonTap: () => tp.loadTickets(refresh: true),
            );
          }

          if (tp.listState == TicketLoadState.loading && tp.tickets.isEmpty) {
            return _buildShimmerList(isDark);
          }

          if (tp.tickets.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Tidak Ada Tiket',
              subtitle:
              tp.filterStatus != null || tp.filterPriority != null
                  ? 'Tidak ada tiket dengan filter ini.'
                  : 'Belum ada tiket yang dibuat.',
              buttonLabel: auth.isUser ? 'Buat Tiket' : null,
              onButtonTap: auth.isUser
                  ? () => Navigator.of(context)
                  .pushNamed(AppRoutes.createTicket)
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () => tp.loadTickets(refresh: true),
            color: AppColors.primary,
            child: Column(
              children: [
                // Active filter bar
                if (tp.filterStatus != null || tp.filterPriority != null)
                  _buildActiveFilterBar(tp, isDark),

                Expanded(
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount:
                    tp.tickets.length + (tp.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      if (i == tp.tickets.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          ),
                        );
                      }
                      return TicketCard(
                        ticket: tp.tickets[i],
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.ticketDetail,
                          arguments: tp.tickets[i].id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: auth.isUser
          ? FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.createTicket),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Buat Tiket',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600),
        ),
      )
          : null,
    );
  }

  Widget _buildActiveFilterBar(TicketProvider tp, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (tp.filterStatus != null)
            _FilterChipWidget(
              label: tp.filterStatus!.label,
              color: AppColors.statusOpen,
              onRemove: () => context.read<TicketProvider>().setFilter(
                priority: tp.filterPriority,
                search: _searchCtrl.text.isEmpty
                    ? null
                    : _searchCtrl.text,
              ),
            ),
          if (tp.filterPriority != null)
            _FilterChipWidget(
              label: tp.filterPriority!.label,
              color: AppColors.priorityMedium,
              onRemove: () => context.read<TicketProvider>().setFilter(
                status: tp.filterStatus,
                search: _searchCtrl.text.isEmpty
                    ? null
                    : _searchCtrl.text,
              ),
            ),
          GestureDetector(
            onTap: () => context.read<TicketProvider>().clearFilter(),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    final color =
    isDark ? AppColors.cardDark : const Color(0xFFE2E8F0);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ─── Widget helpers ──────────────────────────────────────────────────────────

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _FilterChipWidget({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ─────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final TicketStatus? currentStatus;
  final TicketPriority? currentPriority;
  final void Function(TicketStatus?, TicketPriority?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.currentStatus,
    required this.currentPriority,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  TicketStatus? _status;
  TicketPriority? _priority;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _priority = widget.currentPriority;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
            'Filter Tiket',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Status chips
          const Text(
            'Status',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketStatus.values.map((s) {
              final selected = _status == s;
              return ChoiceChip(
                label: Text(s.label,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12)),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) =>
                    setState(() => _status = selected ? null : s),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Priority chips
          const Text(
            'Prioritas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketPriority.values.map((p) {
              final selected = _priority == p;
              return ChoiceChip(
                label: Text(p.label,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12)),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) =>
                    setState(() => _priority = selected ? null : p),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side:
                    const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_status, _priority);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}