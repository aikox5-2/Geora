import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class DetailSiswaPage extends StatelessWidget {
  final String studentName;
  final String initials;
  final String className;
  final String time;

  const DetailSiswaPage({
    super.key,
    this.studentName = 'Chelsea Aqila Putri',
    this.initials = 'CA',
    this.className = 'XII RPL D',
    this.time = '07.05 WIB',
  });

  void _showPhotoProof(BuildContext context, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Bukti Foto Kehadiran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E5DC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 64,
                    color: AppColors.maroon,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Geotag & Face Verified',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.maroon,
                    ),
                  ),
                  Text(
                    'SMK Negeri 8 Malang • $date',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: AppColors.maroon,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const GeoraHeader(
              title: 'Detail Siswa',
              subtitle: 'Informasi kehadiran siswa',
              showBrandLogo: true,
              showBackButton: true,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Card Info matching Image 4
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E5DC),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
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
                                  studentName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  className,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hadir • $time',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistik Bulan Ini
                    Text(
                      'Statistik Bulan Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('Hadir', '22'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem('Izin', '2'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem('Terlambat', '1'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Riwayat Terbaru
                    Text(
                      'Riwayat Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildHistoryCard(
                      context,
                      date: '16 Sep',
                      status: 'Hadir',
                      statusColor: Colors.green.shade700,
                      time: '07.05 WIB',
                      hasPhoto: true,
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryCard(
                      context,
                      date: '15 Sep',
                      status: 'Hadir',
                      statusColor: Colors.green.shade700,
                      time: '07.01 WIB',
                      hasPhoto: true,
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryCard(
                      context,
                      date: '14 Sep',
                      status: 'Izin',
                      statusColor: Colors.blue.shade700,
                      time: '—',
                      hasPhoto: false,
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryCard(
                      context,
                      date: '11 Sep',
                      status: 'Hadir',
                      statusColor: Colors.green.shade700,
                      time: '07.08 WIB',
                      hasPhoto: true,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String date,
    required String status,
    required Color statusColor,
    required String time,
    required bool hasPhoto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          SizedBox(
            width: 75,
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
          ),
          if (hasPhoto)
            GestureDetector(
              onTap: () => _showPhotoProof(context, date),
              child: Text(
                'Lihat Bukti Foto',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }
}

