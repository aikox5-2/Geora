import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/dummy_data_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';

class ManageSiswaPage extends StatefulWidget {
  const ManageSiswaPage({super.key});

  @override
  State<ManageSiswaPage> createState() => _ManageSiswaPageState();
}

class _ManageSiswaPageState extends State<ManageSiswaPage> {
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

  List<StudentAccount> get _filteredStudents {
    if (_searchQuery.isEmpty) return _dataService.students;
    final q = _searchQuery.toLowerCase();
    return _dataService.students
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.nisn.toLowerCase().contains(q) ||
            s.className.toLowerCase().contains(q))
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

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController(text: 'XII RPL D');
    final nisnCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Akun Siswa',
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
              controller: classCtrl,
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nisnCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'NISN'),
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
                  message: 'Harap masukkan nama lengkap siswa terlebih dahulu.',
                  isSuccess: false,
                );
                return;
              }
              final newStudent = StudentAccount(
                id: 'std_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                className: classCtrl.text.trim().isEmpty
                    ? 'XII RPL D'
                    : classCtrl.text.trim(),
                nisn: nisnCtrl.text.trim().isEmpty
                    ? '0051283999'
                    : nisnCtrl.text.trim(),
              );
              _dataService.addStudent(newStudent);
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Siswa Berhasil Ditambahkan',
                message: 'Akun siswa "${newStudent.name}" (${newStudent.className}) berhasil didaftarkan.',
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

  void _showEditStudentDialog(StudentAccount student) {
    final nameCtrl = TextEditingController(text: student.name);
    final classCtrl = TextEditingController(text: student.className);
    final nisnCtrl = TextEditingController(text: student.nisn);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Akun Siswa',
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
              controller: classCtrl,
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nisnCtrl,
              decoration: const InputDecoration(labelText: 'NISN'),
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
                  message: 'Harap masukkan nama lengkap siswa terlebih dahulu.',
                  isSuccess: false,
                );
                return;
              }
              _dataService.updateStudent(
                student.id,
                nameCtrl.text.trim(),
                classCtrl.text.trim(),
                nisnCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Data Diperbarui',
                message: 'Data siswa "${nameCtrl.text.trim()}" berhasil disimpan.',
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

  void _showDeleteStudentDialog(StudentAccount student) {
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
                'Hapus Akun Siswa',
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
          'Hapus data akun "${student.name}" secara permanen? Seluruh riwayat presensi siswa ini akan dihapus.',
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
              _dataService.deleteStudent(student.id);
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Berhasil Dihapus',
                message: 'Akun siswa "${student.name}" telah dihapus dari sistem.',
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
    final list = _filteredStudents;

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
              title: 'Kelola Akun Siswa',
              subtitle: 'Kelola data seluruh siswa',
              showBackButton: true,
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                controller: _searchController,
                hintText: 'Cari nama / NISN...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Students List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada akun siswa ditemukan',
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
                        final student = list[index];
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
                                  student.initials,
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
                                      student.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${student.className} • NISN',
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
                                    _showEditStudentDialog(student),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF8B1E1E),
                                  size: 22,
                                ),
                                onPressed: () =>
                                    _showDeleteStudentDialog(student),
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
              onPressed: _showAddStudentDialog,
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
