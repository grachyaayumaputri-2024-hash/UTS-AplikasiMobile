import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../provider/providers.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedCategory;
  TicketPriority _selectedPriority = TicketPriority.medium;
  final List<File> _attachments = [];
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const List<String> _categories = [
    'Hardware',
    'Software',
    'Jaringan / Internet',
    'Akun & Akses',
    'Email',
    'Printer',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ─── Pick gambar dari kamera ────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _attachments.add(File(photo.path)));
    }
  }

  // ─── Pick gambar dari galeri ────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _attachments.add(File(image.path)));
    }
  }

  // ─── Pick file dari storage ─────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _attachments.add(File(result.files.single.path!)));
    }
  }

  // ─── Show attachment source picker ─────────────────────────────────────────

  void _showAttachmentPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
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
              'Tambah Lampiran',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _AttachmentOption(
              icon: Icons.camera_alt_outlined,
              label: 'Kamera',
              subtitle: 'Ambil foto langsung',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            const SizedBox(height: 10),
            _AttachmentOption(
              icon: Icons.photo_library_outlined,
              label: 'Galeri',
              subtitle: 'Pilih dari foto/gambar',
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            const SizedBox(height: 10),
            _AttachmentOption(
              icon: Icons.attach_file_rounded,
              label: 'File',
              subtitle: 'PDF, Word, Excel, TXT',
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackBar('Pilih kategori terlebih dahulu', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();

    final tp = context.read<TicketProvider>();
    final ticket = await tp.createTicket(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory!,
      priority: _selectedPriority,
      attachments: _attachments.isNotEmpty ? _attachments : null,
    );

    if (!mounted) return;

    if (ticket != null) {
      _showSnackBar('Tiket berhasil dibuat!', isError: false);
      // Navigasi ke detail tiket yang baru dibuat
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.ticketDetail,
        arguments: ticket.id,
      );
    } else {
      _showSnackBar(tp.errorMessage ?? 'Gagal membuat tiket.', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Judul ──────────────────────────────────────────────────
                _SectionLabel(label: 'Judul Tiket', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Laptop tidak bisa menyala',
                    prefixIcon:
                    Icon(Icons.title_rounded, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (v.trim().length < 5) {
                      return 'Judul minimal 5 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Kategori ───────────────────────────────────────────────
                _SectionLabel(label: 'Kategori', required: true),
                const SizedBox(height: 8),
                _buildCategoryDropdown(isDark),

                const SizedBox(height: 20),

                // ── Prioritas ──────────────────────────────────────────────
                _SectionLabel(label: 'Prioritas'),
                const SizedBox(height: 10),
                _buildPrioritySelector(),

                const SizedBox(height: 20),

                // ── Deskripsi ──────────────────────────────────────────────
                _SectionLabel(label: 'Deskripsi', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14),
                  decoration: const InputDecoration(
                    hintText:
                    'Jelaskan masalah secara detail: kapan terjadi, apa yang sudah dicoba, error yang muncul, dll.',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 70),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    if (v.trim().length < 10) {
                      return 'Deskripsi minimal 10 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Lampiran ───────────────────────────────────────────────
                _SectionLabel(label: 'Lampiran'),
                const SizedBox(height: 4),
                Text(
                  'Opsional — gambar, PDF, Word, Excel (maks. 5 file)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildAttachmentSection(isDark),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(isDark),
    );
  }

  // ─── Category Dropdown ──────────────────────────────────────────────────────

  Widget _buildCategoryDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        hintText: 'Pilih kategori masalah',
        prefixIcon: Icon(Icons.category_outlined, size: 20),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: _categories
          .map((c) => DropdownMenuItem(
        value: c,
        child: Text(c,
            style: const TextStyle(fontFamily: 'Poppins')),
      ))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) =>
      v == null ? 'Pilih kategori terlebih dahulu' : null,
    );
  }

  // ─── Priority Selector ──────────────────────────────────────────────────────

  Widget _buildPrioritySelector() {
    return Row(
      children: TicketPriority.values.map((p) {
        final selected = _selectedPriority == p;
        final color = _priorityColor(p);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: p != TicketPriority.critical ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? color : const Color(0xFFE2E8F0),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.low:
        return AppColors.priorityLow;
      case TicketPriority.medium:
        return AppColors.priorityMedium;
      case TicketPriority.high:
        return AppColors.priorityHigh;
      case TicketPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  // ─── Attachment Section ─────────────────────────────────────────────────────

  Widget _buildAttachmentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview attachments
        if (_attachments.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _attachments.asMap().entries.map((e) {
              final idx = e.key;
              final file = e.value;
              final isImage = _isImageFile(file.path);
              return _buildAttachmentPreview(file, isImage, idx, isDark);
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // Add button
        if (_attachments.length < 5)
          GestureDetector(
            onTap: _showAttachmentPicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.primary.withOpacity(0.7),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tambah Lampiran',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Kamera · Galeri · File',
                    style: TextStyle(
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

  Widget _buildAttachmentPreview(
      File file, bool isImage, int index, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isImage
                ? Image.file(file, fit: BoxFit.cover)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insert_drive_file_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    file.path.split('/').last,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _attachments.removeAt(index)),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  // ─── Submit Bar ─────────────────────────────────────────────────────────────

  Widget _buildSubmitBar(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
        child: Consumer<TicketProvider>(
          builder: (_, tp, __) => ElevatedButton(
            onPressed: tp.isActionLoading ? null : _onSubmit,
            child: tp.isActionLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text('Kirim Tiket'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFF),
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}