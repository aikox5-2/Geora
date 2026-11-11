import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/attendance_state_service.dart';
import '../../services/auth_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guru_piket.dart';
import '../guru/anggota_kelas.dart';
import 'absen_manual.dart';

class SiswaDashboardTab extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const SiswaDashboardTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final user = AuthService().currentUser;
    final studentName = user?.name ?? 'Budiono Siregar';

    final hour = TimeService().now.hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
            ? 'Selamat siang'
            : hour < 18
                ? 'Selamat sore'
                : 'Selamat malam';

    final nisnDisplay = (user != null && user.aliases.isNotEmpty)
        ? 'NISN • ${user.aliases.first}'
        : 'NISN • Terverifikasi';
    final classDisplay = (user != null && user.info != null && user.info!.isNotEmpty)
        ? user.info!
        : 'XII RPL D • Rekayasa Perangkat Lunak';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & GEORA Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    'Absensi Siswa',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'asset/logo.png',
                height: 44,
                width: 44,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 1. Informasi Siswa Card (Maroon Container)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INFORMASI SISWA',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream.withValues(alpha: 0.8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  studentName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nisnDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  classDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status hari ini',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      AttendanceStateService().todayStatusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Absensi Hari Ini
          Text(
            'Absensi Hari Ini',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE8),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Absensi Hanya Dapat Dilakukan Diarea Sekolah',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TimeService().formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => onNavigateTab?.call(2), // Switch to Tab Absen
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Absen Sekarang',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Tidak Bisa Absen? , ',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            builder: (ctx) => const SafeArea(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
                                child: GuruPiketSection(showHeader: true),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Hubungi Tim Geora',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.maroon,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Akses Cepat
          Text(
            'Akses Cepat',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.access_time_rounded,
                  title: 'Riwayat',
                  subtitle: 'Lihat absensi',
                  onTap: () => onNavigateTab?.call(1), // Switch to Tab Riwayat
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Absen Manual',
                  subtitle: 'Ajukan izin',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AbsenManualPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Full-width Anggota Kelas card (no awkward gaps)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnggotaKelasPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                            'Daftar Anggota Kelas',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lihat rekap dan status kehadiran teman sekelas',
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
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 26, color: AppColors.ink),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

