import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/dummy_data_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';

class ManageGuruPage extends StatefulWidget {
  const ManageGuruPage({super.key});

  @override
  State<ManageGuruPage> createState() => _ManageGuruPageState();
}

class _ManageGuruPageState extends State<ManageGuruPage> {
  final DummyDataService _dataService = DummyDataService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<TeacherAccount> get _filteredTeachers {
    if (_searchQuery.isEmpty) return _dataService.teachers;
    final q = _searchQuery.toLowerCase();
    return _dataService.teachers
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.nip.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q))
        .toList();
  }

  void _showFeedbackDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(String teacherId, String teacherName) {
    final newPassCtrl = TextEditingController(text: 'Password123');
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EFE8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.maroon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reset Password Guru',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tentukan password baru untuk "$teacherName":',
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newPassCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () {
                final pass = newPassCtrl.text.trim();
                if (pass.isEmpty) return;
                _dataService.resetPassword(teacherId, pass);
                Navigator.pop(ctx);
                _showFeedbackDialog(
                  title: 'Password Berhasil Direset',
                  message: 'Password akun "$teacherName" berhasil direset.',
                  isSuccess: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTeacherDialog() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final nipCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final positionCtrl = TextEditingController(text: 'Guru Pengajar');
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Tambah Akun Guru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            color: AppColors.ink,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.maroon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Password awal: Password123 • Role: Guru',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username (Email/NIP)*',
                    hintText: 'Contoh: yudi@gmail.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap Guru*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nipCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'NIP*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subjectCtrl,
                  decoration: InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: positionCtrl,
                  decoration: InputDecoration(
                    labelText: 'Jabatan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP / WhatsApp',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                _showFeedbackDialog(
                  title: 'Data Belum Lengkap',
                  message: 'Harap masukkan nama lengkap guru terlebih dahulu.',
                  isSuccess: false,
                );
                return;
              }
              final newTeacher = TeacherAccount(
                id: 'tch_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                subject: subjectCtrl.text.trim().isEmpty ? 'Mata Pelajaran' : subjectCtrl.text.trim(),
                nip: nipCtrl.text.trim().isEmpty ? '198901012015011001' : nipCtrl.text.trim(),
                username: usernameCtrl.text.trim().isNotEmpty ? usernameCtrl.text.trim() : nipCtrl.text.trim(),
                position: positionCtrl.text.trim().isEmpty ? 'Guru Pengajar' : positionCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                status: 'aktif',
              );
              _dataService.addTeacher(newTeacher, password: 'Password123');
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Guru Berhasil Ditambahkan',
                message: 'Akun guru "${newTeacher.name}" (${newTeacher.subject}) berhasil didaftarkan.',
                isSuccess: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditTeacherDialog(TeacherAccount teacher) {
    final nameCtrl = TextEditingController(text: teacher.name);
    final subjectCtrl = TextEditingController(text: teacher.subject);
    final nipCtrl = TextEditingController(text: teacher.nip);
    final positionCtrl = TextEditingController(text: teacher.position ?? 'Guru Pengajar');
    final phoneCtrl = TextEditingController(text: teacher.phone ?? '');
    String currentStatus = teacher.currentStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Edit Akun Guru',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
              color: AppColors.ink,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subjectCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mata Pelajaran',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nipCtrl,
                    decoration: InputDecoration(
                      labelText: 'NIP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: positionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Jabatan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // STATUS (Muncul saat edit)
                  Text(
                    'Status Akun Guru',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: currentStatus,
                        items: const [
                          DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                          DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => currentStatus = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // RESET PASSWORD BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showResetPasswordDialog(teacher.id, teacher.name);
                      },
                      icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon, size: 20),
                      label: Text(
                        'Reset Password Guru',
                        style: GoogleFonts.poppins(
                          color: AppColors.maroon,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.maroon),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  _showFeedbackDialog(
                    title: 'Data Belum Lengkap',
                    message: 'Harap masukkan nama lengkap guru terlebih dahulu.',
                    isSuccess: false,
                  );
                  return;
                }
                _dataService.updateTeacher(
                  teacher.id,
                  nameCtrl.text.trim(),
                  subjectCtrl.text.trim(),
                  nipCtrl.text.trim(),
                  status: currentStatus,
                  position: positionCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                _showFeedbackDialog(
                  title: 'Data Diperbarui',
                  message: 'Data guru "${nameCtrl.text.trim()}" berhasil disimpan.',
                  isSuccess: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTeacherDialog(TeacherAccount teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hapus Akun Guru',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Hapus data akun "${teacher.name}" secara permanen? Data akses mengajar guru ini akan dicabut.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.deleteTeacher(teacher.id);
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Berhasil Dihapus',
                message: 'Akun guru "${teacher.name}" telah dihapus dari sistem.',
                isSuccess: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTeachers;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF5EDE5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EDE5),
        body: Column(
          children: [
            // Top Maroon Header
            GeoraHeader(
              title: 'Kelola Akun Guru',
              subtitle: 'Kelola data guru pengajar',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                hintText: 'Cari nama / NIP / mapel...',
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Belum ada data guru.'
                            : 'Tidak ada guru yang cocok.',
                        style: GoogleFonts.poppins(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final teacher = list[idx];
                        return _buildTeacherCard(teacher);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTeacherDialog,
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherAccount teacher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initials Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF7EFE8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              teacher.initials,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.maroon,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        teacher.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (teacher.status == 'nonaktif')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Nonaktif',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${teacher.subject} • NIP ${teacher.nip}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: Edit & Delete
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.muted, size: 20),
            onPressed: () => _showEditTeacherDialog(teacher),
            tooltip: 'Edit Guru',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
            onPressed: () => _showDeleteTeacherDialog(teacher),
            tooltip: 'Hapus Guru',
          ),
        ],
      ),
    );
  }
}
