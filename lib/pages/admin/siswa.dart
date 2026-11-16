import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/dummy_data_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';

class AdminStudentsTab extends StatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  State<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<AdminStudentsTab> {
  final DummyDataService _dataService = DummyDataService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String> _attendanceStatusMap = {};
  bool _isLoadingStatus = false;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _loadRealAttendanceStatus();
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
    _loadRealAttendanceStatus();
  }

  Future<void> _loadRealAttendanceStatus() async {
    if (_isLoadingStatus) return;
    _isLoadingStatus = true;
    try {
      final supa = SupabaseService();
      final client = supa.client;
      if (client != null) {
        final todayStr = DateTime.now().toIso8601String().split('T')[0];

        // 1. Absensi
        final attList = await client
            .from('absensi')
            .select('siswa_id, status')
            .eq('tanggal', todayStr);

        // 2. Pengajuan
        final pengajuanList = await client
            .from('pengajuan_absen')
            .select('siswa_id, jenis, status')
            .eq('tanggal_absen', todayStr);

        final newMap = <String, String>{};

        for (final item in attList) {
          final sid = item['siswa_id']?.toString() ?? '';
          final st = item['status']?.toString().toLowerCase() ?? '';
          if (st == 'hadir') {
            newMap[sid] = 'Hadir';
          } else if (st == 'terlambat') {
            newMap[sid] = 'Terlambat';
          } else if (st == 'izin') {
            newMap[sid] = 'Izin';
          } else if (st == 'sakit') {
            newMap[sid] = 'Sakit';
          }
        }

        for (final item in pengajuanList) {
          final sid = item['siswa_id']?.toString() ?? '';
          final j = item['jenis']?.toString().toLowerCase() ?? 'izin';
          final s = item['status']?.toString().toLowerCase() ?? 'menunggu';
          if (!newMap.containsKey(sid)) {
            newMap[sid] = s == 'disetujui'
                ? (j == 'sakit' ? 'Sakit' : 'Izin')
                : 'Menunggu (${j == 'sakit' ? 'Sakit' : 'Izin'})';
          }
        }

        if (mounted) {
          setState(() {
            _attendanceStatusMap = newMap;
          });
        }
      }
    } catch (_) {} finally {
      _isLoadingStatus = false;
    }
  }

  String _getStudentStatus(StudentAccount student) {
    if (_attendanceStatusMap.containsKey(student.id)) {
      return _attendanceStatusMap[student.id]!;
    }
    return 'Belum Absen';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green.shade700;
      case 'terlambat':
        return Colors.orange.shade800;
      case 'izin':
        return Colors.blue.shade700;
      case 'sakit':
        return Colors.purple.shade700;
      case 'belum absen':
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _confirmResetAllAttendance() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.restart_alt_rounded, color: AppColors.maroon, size: 26),
            const SizedBox(width: 10),
            Text(
              'Reset Absensi Hari Ini',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mereset data absensi SELURUH siswa untuk hari ini? Semua status siswa akan dikembalikan menjadi "Belum Absen".',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await SupabaseService().resetAttendanceForToday();
              if (ok) {
                await _dataService.refreshFromDatabase();
                await _loadRealAttendanceStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Absensi seluruh siswa hari ini berhasil direset ke "Belum Absen".'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset Semua'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(StudentAccount student) {
    final status = _getStudentStatus(student);
    final statusColor = _getStatusColor(status);
    final hasAttended = status != 'Belum Absen';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFF0E5DC),
                  child: Text(
                    student.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '${student.className} • NISN: ${student.nisn}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F1EB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _detailRow(
                    'Status Kehadiran',
                    status,
                    valueColor: statusColor,
                  ),
                  const Divider(height: 18),
                  _detailRow('Kelas', student.className),
                  const Divider(height: 18),
                  _detailRow('Nomor Induk Siswa', student.nisn),
                  const Divider(height: 18),
                  _detailRow('Sekolah', 'SMK Negeri 8 Malang'),
                ],
              ),
            ),
            if (hasAttended) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await SupabaseService().resetAttendanceForToday(studentId: student.id);
                    if (ok) {
                      await _dataService.refreshFromDatabase();
                      await _loadRealAttendanceStatus();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Absensi untuk ${student.name} berhasil direset ke "Belum Absen".'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.red),
                  label: const Text(
                    'Reset Absensi Siswa Ini (Jadikan Belum Absen)',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppColors.muted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    final list = _filteredStudents;

    return Column(
      children: [
        // Top Header with Reset Button
        GeoraHeader(
          title: 'Data Siswa',
          subtitle: 'Kelola data seluruh siswa',
          trailing: IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 24),
            onPressed: _confirmResetAllAttendance,
            tooltip: 'Reset Absensi Hari Ini',
          ),
        ),

        // Search Bar & Action
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              IconButton(
                onPressed: _confirmResetAllAttendance,
                icon: const Icon(Icons.restart_alt_rounded, color: AppColors.maroon),
                tooltip: 'Reset Absensi Hari Ini',
              ),
            ],
          ),
        ),

        // List of Students
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data siswa ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = list[index];
                    final status = _getStudentStatus(student);
                    final statusColor = _getStatusColor(status);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showStudentDetail(student),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
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

                              // Name & Class
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
                                      '${student.className} • NISN: ${student.nisn}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Chevron arrow
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.muted,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
