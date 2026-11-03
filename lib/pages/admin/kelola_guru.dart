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

  void _showAddTeacherDialog() {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final nipCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Akun Guru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nipCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'NIP'),
            ),
          ],
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
                subject: subjectCtrl.text.trim().isEmpty
                    ? 'Guru Mapel'
                    : subjectCtrl.text.trim(),
                nip: nipCtrl.text.trim().isEmpty
                    ? '198901012015011001'
                    : nipCtrl.text.trim(),
              );
              _dataService.addTeacher(newTeacher);
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Guru Berhasil Ditambahkan',
                message: 'Akun guru "${newTeacher.name}" dengan mata pelajaran "${newTeacher.subject}" telah aktif.',
                isSuccess: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Akun Guru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nipCtrl,
              decoration: const InputDecoration(labelText: 'NIP'),
            ),
          ],
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
              _dataService.updateTeacher(
                teacher.id,
                nameCtrl.text.trim(),
                subjectCtrl.text.trim(),
                nipCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Data Diperbarui',
                message: 'Data akun guru "${nameCtrl.text.trim()}" berhasil disimpan.',
                isSuccess: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
            ),
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
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
                isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
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
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.muted,
            height: 1.5,
          ),
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
          'Hapus data guru "${teacher.name}" secara permanen? Data absensi dan akun login terkait tidak dapat dipulihkan kembali.',
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
            const GeoraHeader(
              title: 'Kelola Akun Guru',
              subtitle: 'Kelola data seluruh Guru',
              showBackButton: true,
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                controller: _searchController,
                hintText: 'Cari nama / NIP...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Teachers List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada akun guru ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final teacher = list[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar circle with initials
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0E5DC),
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

                              // Name & Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teacher.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${teacher.subject} • NIP',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Action icons (Edit & Delete)
                              IconButton(
                                icon: const Icon(
                                  Icons.drive_file_rename_outline_rounded,
                                  color: Color(0xFFE5A100),
                                  size: 22,
                                ),
                                onPressed: () =>
                                    _showEditTeacherDialog(teacher),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF8B1E1E),
                                  size: 22,
                                ),
                                onPressed: () =>
                                    _showDeleteTeacherDialog(teacher),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        // Floating Action Button matching screenshot
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 8),
          child: SizedBox(
            width: 58,
            height: 58,
            child: FloatingActionButton(
              onPressed: _showAddTeacherDialog,
              backgroundColor: AppColors.maroon,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
