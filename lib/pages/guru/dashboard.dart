import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import 'pilih_kelas.dart';

class GuruDashboardTab extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const GuruDashboardTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<GuruDashboardTab> createState() => _GuruDashboardTabState();
}

class _GuruDashboardTabState extends State<GuruDashboardTab> {
  List<StudentAttendanceDetail> _todayStudents = [];
  int _totalStudents = 0;
  int _hadirCount = 0;
  int _terlambatCount = 0;
  int _izinCount = 0;
  int _pendingSubmissions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getStudentsForClass('XII RPL D');
      final subs = await SupabaseService().getTeacherSubmissions();

      _totalStudents = list.length;
      _hadirCount = 0;
      _terlambatCount = 0;
      _izinCount = 0;

      for (final s in list) {
        final st = s.status.toLowerCase();
        if (st == 'hadir') {
          _hadirCount++;
        } else if (st == 'terlambat') {
          _terlambatCount++;
        } else if (st == 'izin' || st == 'sakit') {
          _izinCount++;
        }
      }

      _pendingSubmissions = subs.where((sub) => sub.status == 'Menunggu').length;
      _todayStudents = list.where((s) => s.status != 'Alpha').toList();
    } catch (_) {
      _totalStudents = 6;
      _hadirCount = 0;
      _terlambatCount = 0;
      _izinCount = 0;
      _pendingSubmissions = 0;
      _todayStudents = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final displayName = user?.name.split(' ').first ?? 'Bapak/Ibu Guru';

    return Column(
      children: [
        // Top Header
        GeoraHeader(
          title: 'Halo, $displayName',
          subtitle: '${TimeService().formattedDate} • XII RPL D',
          showBrandLogo: true,
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppColors.maroon,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Ringkasan Hari Ini
                  Text(
                    'Ringkasan Hari Ini',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2x2 Grid of Stat Cards (Real data from database)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: 'Total Siswa',
                          value: '$_totalStudents',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Hadir',
                          value: '$_hadirCount',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(label: 'Terlambat', value: '$_terlambatCount'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(label: 'Izin / Sakit', value: '$_izinCount'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 2. Absensi Hari Ini
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Absensi Hari Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onNavigateTab?.call(1), // Switch to Absensi
                        child: Text(
                          'Lihat semua',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: AppColors.maroon),
                      ),
                    )
                  else if (_todayStudents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Belum ada siswa yang melakukan presensi hari ini',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  else
                    ..._todayStudents.take(3).map((s) {
                      Color bg = const Color(0xFFE8F5E9);
                      Color text = const Color(0xFF2E7D32);
                      if (s.status == 'Terlambat') {
                        bg = const Color(0xFFFFF8E1);
                        text = const Color(0xFFB78103);
                      } else if (s.status == 'Izin' || s.status == 'Sakit') {
                        bg = const Color(0xFFE3F2FD);
                        text = const Color(0xFF1565C0);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildStudentTile(
                          initials: calculateInitials(s.name),
                          name: s.name,
                          time: s.time,
                          status: s.status,
                          badgeColor: bg,
                          textColor: text,
                        ),
                      );
                    }),

                  const SizedBox(height: 12),

                  // Pengajuan perlu dicek Card (Real count from database)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengajuan perlu dicek',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _pendingSubmissions > 0
                                    ? '$_pendingSubmissions pengajuan menunggu konfirmasi'
                                    : 'Tidak ada pengajuan baru saat ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.onNavigateTab?.call(2), // Switch to Pengajuan
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maroon,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Cek',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Data Presensi Kelas (Full width button without awkward empty gaps)
                  Text(
                    'Data Presensi Kelas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PilihKelasPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE8DFD8),
                            width: 1.2,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF7EFE8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_outline_rounded,
                                size: 24,
                                color: AppColors.maroon,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar Anggota & Presensi Kelas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lihat detail absensi dan verifikasi seluruh siswa',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile({
    required String initials,
    required String name,
    required String time,
    required String status,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E5DC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.maroon,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
