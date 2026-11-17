import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';
import 'anggota_kelas.dart';

class GuruAttendanceTab extends StatefulWidget {
  const GuruAttendanceTab({super.key});

  @override
  State<GuruAttendanceTab> createState() => _GuruAttendanceTabState();
}

class _GuruAttendanceTabState extends State<GuruAttendanceTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ClassAttendanceOverview> _classList = [];
  bool _isLoading = true;
  int _totalHadir = 0;
  int _totalBelum = 0;

  @override
  void initState() {
    super.initState();
    _loadRealAttendance();
  }

  Future<void> _loadRealAttendance() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getClassAttendanceOverview();
      if (list.isNotEmpty) {
        _classList = list;
      } else {
        _classList = const [
          ClassAttendanceOverview(
            classId: 'ca3af166-14b7-4af2-b894-656c5e6a7379',
            className: 'XII RPL D',
            hadir: 0,
            belum: 6,
            total: 6,
          ),
        ];
      }
      _totalHadir = _classList.fold(0, (sum, c) => sum + c.hadir);
      _totalBelum = _classList.fold(0, (sum, c) => sum + c.belum);
    } catch (_) {
      _classList = [];
      _totalHadir = 0;
      _totalBelum = 0;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClassAttendanceOverview> get _filteredClasses {
    if (_searchQuery.isEmpty) return _classList;
    final q = _searchQuery.toLowerCase();
    return _classList.where((c) => c.className.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredClasses;

    return Column(
      children: [
        // Top Header
        GeoraHeader(
          title: 'Presensi Siswa',
          subtitle: TimeService().formattedDate,
          showBrandLogo: true,
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Segarkan',
            onPressed: _loadRealAttendance,
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: GeoraSearchBar(
            controller: _searchController,
            hintText: 'Cari nama kelas atau rombel...',
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                )
              : RefreshIndicator(
                  color: AppColors.maroon,
                  onRefresh: _loadRealAttendance,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rekap Hadir & Belum Absen
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(label: 'Hadir', value: '$_totalHadir'),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStatCard(label: 'Belum Absen', value: '$_totalBelum'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section: Status Kehadiran Per Kelas
                        Text(
                          'Daftar Kelas & Status Presensi',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (list.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Tidak ada kelas yang sesuai',
                                style: GoogleFonts.poppins(color: AppColors.muted),
                              ),
                            ),
                          )
                        else
                          ...list.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AnggotaKelasPage(
                                            classId: item.classId,
                                            className: item.className,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE8DFD8),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.className,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Hadir ${item.hadir}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF2E7D32),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFF3E0),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Belum ${item.belum}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFFB78103),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DFD8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
