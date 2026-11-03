import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_absensi.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';
import 'detail_siswa.dart';
import 'pilih_kelas.dart';

class GuruAttendanceTab extends StatefulWidget {
  const GuruAttendanceTab({super.key});

  @override
  State<GuruAttendanceTab> createState() => _GuruAttendanceTabState();
}

class _GuruAttendanceTabState extends State<GuruAttendanceTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<StudentAttendanceItem> _students = const [
    StudentAttendanceItem(
      initials: 'BS',
      name: 'Budiono Siregar',
      time: '07.02 WIB',
    ),
    StudentAttendanceItem(
      initials: 'CA',
      name: 'Chelsea Aqila Putri',
      time: '07.05 WIB',
    ),
    StudentAttendanceItem(
      initials: 'MA',
      name: 'Malika Aisyabila',
      time: '07.28 WIB',
    ),
    StudentAttendanceItem(
      initials: 'AP',
      name: 'Alya Putri',
      time: '—',
    ),
    StudentAttendanceItem(
      initials: 'FA',
      name: 'Fajar Adi',
      time: '—',
    ),
  ];

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
          className: student.className,
          time: student.time,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredStudents;

    return Column(
      children: [
        // Top Header matching Image 3
        GeoraHeader(
          title: 'Absensi Siswa',
          subtitle: TimeService().formattedDate,
          showBrandLogo: true,
          trailing: IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            tooltip: 'Pilih Kelas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PilihKelasPage(),
                ),
              );
            },
          ),
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

        // List
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
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openDetail(student),
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

                              // Name & Time
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
                                      student.time,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // "Detail" link in Maroon
                              Text(
                                'Detail',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.maroon,
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
    );
  }
}

