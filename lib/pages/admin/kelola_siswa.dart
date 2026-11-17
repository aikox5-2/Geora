import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/dummy_data_service.dart';
import '../../services/supabase_service.dart';
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
  List<Map<String, dynamic>> _availableClasses = [];

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final list = await SupabaseService().getClassesDetailed();
      if (mounted) {
        setState(() {
          _availableClasses = list;
        });
      }
    } catch (_) {}
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

  /// Reset Password Dialog for Admin
  void _showResetPasswordDialog(String studentId, String studentName) {
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
                  'Reset Password Siswa',
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
                'Tentukan password baru untuk "$studentName":',
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
                _dataService.resetPassword(studentId, pass);
                Navigator.pop(ctx);
                _showFeedbackDialog(
                  title: 'Password Berhasil Direset',
                  message: 'Password akun "$studentName" berhasil direset.',
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

  /// Tambah Akun Siswa (Sesuai ERD: role otomatis 'siswa', password default Password123, status tidak tampil)
  void _showAddStudentDialog() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final nisnCtrl = TextEditingController();
    final nisCtrl = TextEditingController();
    final classOptions = _availableClasses.isNotEmpty
        ? _availableClasses
            .map((c) => c['className']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : [
            'XII Rekayasa Perangkat Lunak D',
            'XII Keperawatan',
            'XII Desain Komunikasi Visual',
            'XII Teknik Komputer Jaringan',
          ];
    String selectedClass = classOptions.first;
    String gender = 'Laki-laki';
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Tambah Akun Siswa',
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
                  // Info Card: Role otomatis Siswa & Default Password
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
                            'Password awal: Password123 • Role: Siswa',
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

                  // Username
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username (Login)*',
                      hintText: 'Contoh: iko / budiono',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nama Siswa
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Siswa*',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NISN & NIS
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nisnCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'NISN*',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: nisCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'NIS',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Pilih Kelas Dropdown (Sesuai database kelas)
                  Text(
                    'Kelas*',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F4),
                      border: Border.all(color: const Color(0xFFE8DFD8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: classOptions.contains(selectedClass) ? selectedClass : classOptions.first,
                        isExpanded: true,
                        items: classOptions.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(
                              c,
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedClass = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Jenis Kelamin
                  Text(
                    'Jenis Kelamin',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setDialogState(() => gender = 'Laki-laki'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: gender == 'Laki-laki' ? AppColors.maroon : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Laki-laki',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: gender == 'Laki-laki' ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setDialogState(() => gender = 'Perempuan'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: gender == 'Perempuan' ? AppColors.maroon : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Perempuan',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: gender == 'Perempuan' ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // No HP & Alamat
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP / WhatsApp',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
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
                    message: 'Harap masukkan nama lengkap siswa terlebih dahulu.',
                    isSuccess: false,
                  );
                  return;
                }
                final matchedClass = _availableClasses.firstWhere(
                  (c) => c['className']?.toString() == selectedClass,
                  orElse: () => {},
                );
                final classIdVal = matchedClass['id']?.toString();

                final newStudent = StudentAccount(
                  id: 'std_${DateTime.now().millisecondsSinceEpoch}',
                  classId: classIdVal,
                  name: nameCtrl.text.trim(),
                  className: selectedClass,
                  nisn: nisnCtrl.text.trim().isEmpty ? '0051283999' : nisnCtrl.text.trim(),
                  nis: nisCtrl.text.trim(),
                  username: usernameCtrl.text.trim().isNotEmpty
                      ? usernameCtrl.text.trim()
                      : nisnCtrl.text.trim(),
                  gender: gender,
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  status: 'aktif', // Status otomatis aktif
                );
                _dataService.addStudent(newStudent, password: 'Password123');
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  /// Edit Akun Siswa (Memunculkan status & tombol Reset Password)
  void _showEditStudentDialog(StudentAccount student) {
    final nameCtrl = TextEditingController(text: student.name);
    final classOptions = _availableClasses.isNotEmpty
        ? _availableClasses
            .map((c) => c['className']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : [
            'XII Rekayasa Perangkat Lunak D',
            'XII Keperawatan',
            'XII Desain Komunikasi Visual',
            'XII Teknik Komputer Jaringan',
          ];
    String selectedClass = classOptions.contains(student.className) ? student.className : classOptions.first;
    final nisnCtrl = TextEditingController(text: student.nisn);
    final nisCtrl = TextEditingController(text: student.nis ?? '');
    final phoneCtrl = TextEditingController(text: student.phone ?? '');
    final addressCtrl = TextEditingController(text: student.address ?? '');
    String currentStatus = student.currentStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Edit Akun Siswa',
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

                  // Pilih Kelas Dropdown
                  Text(
                    'Kelas*',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F4),
                      border: Border.all(color: const Color(0xFFE8DFD8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: classOptions.contains(selectedClass) ? selectedClass : classOptions.first,
                        isExpanded: true,
                        items: classOptions.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(
                              c,
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedClass = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NISN
                  TextField(
                    controller: nisnCtrl,
                    decoration: InputDecoration(
                      labelText: 'NISN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nisCtrl,
                    decoration: InputDecoration(
                      labelText: 'NIS',
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // STATUS (Muncul saat edit sesuai instruksi)
                  Text(
                    'Status Akun Siswa',
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
                        _showResetPasswordDialog(student.id, student.name);
                      },
                      icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon, size: 20),
                      label: Text(
                        'Reset Password Siswa',
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
                    message: 'Harap masukkan nama lengkap siswa terlebih dahulu.',
                    isSuccess: false,
                  );
                  return;
                }
                final matchedClass = _availableClasses.firstWhere(
                  (c) => c['className']?.toString() == selectedClass,
                  orElse: () => {},
                );
                final classIdVal = matchedClass['id']?.toString();

                _dataService.updateStudent(
                  student.id,
                  nameCtrl.text.trim(),
                  selectedClass,
                  nisnCtrl.text.trim(),
                  classId: classIdVal,
                  status: currentStatus,
                  nis: nisCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Perbarui'),
            ),
          ],
        ),
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
            GeoraHeader(
              title: 'Kelola Akun Siswa',
              subtitle: 'Kelola data seluruh siswa',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                hintText: 'Cari nama / NISN...',
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),

            // List of Students
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Belum ada data siswa.'
                            : 'Tidak ada siswa yang cocok.',
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
                        final student = list[idx];
                        return _buildStudentCard(student);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddStudentDialog,
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentAccount student) {
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
              student.initials,
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
                        student.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (student.status == 'nonaktif')
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
                  '${student.className} • NISN ${student.nisn}',
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
            onPressed: () => _showEditStudentDialog(student),
            tooltip: 'Edit Siswa',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
            onPressed: () => _showDeleteStudentDialog(student),
            tooltip: 'Hapus Siswa',
          ),
        ],
      ),
    );
  }
}
