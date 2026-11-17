import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_absensi.dart';
import '../../models/model_akun.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';
import 'detail_siswa.dart';

class KelasAttendancePage extends StatefulWidget {
  final String className;
  final String? classId;

  const KelasAttendancePage({
    super.key,
    this.className = 'XII RPL D',
    this.classId,
  });

  @override
  State<KelasAttendancePage> createState() => _KelasAttendancePageState();
}

class _KelasAttendancePageState extends State<KelasAttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<StudentAttendanceItem> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealStudents();
  }

  Future<void> _loadRealStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getStudentsForClass(widget.className, classId: widget.classId);
      if (list.isNotEmpty) {
        _students = list.map((s) {
          return StudentAttendanceItem(
            name: s.name,
            initials: calculateInitials(s.name),
            time: s.time,
            status: s.status,
            className: widget.className,
            nisn: s.nisn,
            location: s.location,
            latitude: s.latitude,
            longitude: s.longitude,
            photoUrl: s.photoUrl,
            method: s.method,
            keterangan: s.keterangan,
          );
        }).toList();
      } else {
        _students = [];
      }
    } catch (_) {
      _students = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentAttendanceItem> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  void _openDetail(StudentAttendanceItem student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSiswaPage(
          studentName: student.name,
          initials: student.initials,
          className: widget.className,
          time: student.time,
          status: student.status,
          nisn: student.nisn,
          location: student.location,
          latitude: student.latitude,
          longitude: student.longitude,
          photoUrl: student.photoUrl,
          method: student.method,
        ),
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
            // Top Header
            GeoraHeader(
              title: 'Absensi ${widget.className}',
              subtitle: TimeService().formattedDate,
              showBrandLogo: true,
              showBackButton: true,
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                controller: _searchController,
                hintText: 'Cari nama siswa...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Student List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : list.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada siswa ditemukan',
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
                            final s = list[index];
                            final isPresent = s.status.toLowerCase() == 'hadir' || s.status.toLowerCase() == 'terlambat';

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _openDetail(s),
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
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Circle Avatar with Initials
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF0E5DC),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          s.initials,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.maroon,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Student Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              s.time,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isPresent
                                                    ? const Color(0xFF2E7D32)
                                                    : AppColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Detail Button Icon
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3ECE6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.maroon,
                                          size: 24,
                                        ),
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
        ),
      ),
    );
  }
}
