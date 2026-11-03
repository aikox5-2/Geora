import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../guru/anggota_kelas.dart';

class ClassAttendanceOverview {
  final String className;
  final int hadir;
  final int belum;

  const ClassAttendanceOverview({
    required this.className,
    required this.hadir,
    required this.belum,
  });
}

class AdminAttendanceTab extends StatelessWidget {
  const AdminAttendanceTab({super.key});

  static const List<ClassAttendanceOverview> _classList = [
    ClassAttendanceOverview(className: 'XII RPL A', hadir: 30, belum: 1),
    ClassAttendanceOverview(className: 'XII RPL B', hadir: 25, belum: 7),
    ClassAttendanceOverview(className: 'XII RPL C', hadir: 23, belum: 6),
    ClassAttendanceOverview(className: 'XII RPL D', hadir: 27, belum: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header matching Gambar 3
        GeoraHeader(
          title: 'Monitoring Absensi',
          subtitle: 'Seluruh kelas • ${TimeService().formattedDate}',
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top 2 Stat Cards matching Gambar 3
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(label: 'Hadir', value: '98'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildStatCard(label: 'Belum Absen', value: '15'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section: Status Kehadiran
                Text(
                  'Status Kehadiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),

                // Class list matching Gambar 3
                ..._classList.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
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
                                Text(
                                  item.className,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(14),
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
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(14),
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

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
}
