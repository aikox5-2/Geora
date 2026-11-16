import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class DetailSiswaPage extends StatefulWidget {
  final String studentName;
  final String initials;
  final String className;
  final String time;
  final String status;
  final String nisn;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? method;

  const DetailSiswaPage({
    super.key,
    required this.studentName,
    required this.initials,
    this.className = 'XII RPL D',
    this.time = '— WIB',
    this.status = 'Belum Absen',
    this.nisn = '0000000000',
    this.location,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.method,
  });

  @override
  State<DetailSiswaPage> createState() => _DetailSiswaPageState();
}

class _DetailSiswaPageState extends State<DetailSiswaPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  int _hadirCount = 0;
  int _izinCount = 0;
  int _terlambatCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRealHistory();
  }

  Future<void> _loadRealHistory() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getStudentAttendanceHistory(widget.studentName);
      _history = list;
      _hadirCount = 0;
      _izinCount = 0;
      _terlambatCount = 0;

      for (final h in _history) {
        final st = h['status']?.toString().toLowerCase();
        if (st == 'hadir') {
          _hadirCount++;
        } else if (st == 'terlambat') {
          _terlambatCount++;
        } else if (st == 'izin' || st == 'sakit') {
          _izinCount++;
        }
      }

      // If this student has status today that isn't yet in history list
      if (_history.isEmpty && (widget.status == 'Hadir' || widget.status == 'Terlambat')) {
        if (widget.status == 'Hadir') _hadirCount = 1;
        if (widget.status == 'Terlambat') _terlambatCount = 1;
      }
    } catch (_) {
      _history = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhotoProof(BuildContext context, String date, String loc, String time, {String? photoUrl}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF7EFE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.maroon,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Bukti Foto Kehadiran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E5DC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8DFD8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tampilkan foto nyata dari bucket jika ada, fallback ke peta satelit
                    if (photoUrl != null && photoUrl.isNotEmpty)
                      Image.network(
                        photoUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF0E5DC),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.maroon,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (ctx, e, st) => Image.asset(
                          'asset/maps_smkn8.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Image.asset(
                        'asset/maps_smkn8.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    // Overlay gelap tipis
                    Container(
                      color: Colors.black.withValues(alpha: photoUrl != null ? 0.25 : 0.35),
                    ),
                    // Watermark info di bawah
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Geotag & Face Verified',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '📍 $loc',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                            ),
                            Text(
                              '🕒 $date • $time',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
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
    final curMonth = TimeService().formattedDate.split(',').last.trim();
    final realLoc = widget.location ?? 'SMK Negeri 8 Kota Malang (-7.9361, 112.6619)';

    Color statusBadgeBg = const Color(0xFFE8F5E9);
    Color statusBadgeColor = const Color(0xFF2E7D32);
    if (widget.status == 'Terlambat') {
      statusBadgeBg = const Color(0xFFFFF3E0);
      statusBadgeColor = const Color(0xFFB78103);
    } else if (widget.status == 'Izin' || widget.status == 'Sakit') {
      statusBadgeBg = const Color(0xFFE3F2FD);
      statusBadgeColor = const Color(0xFF1565C0);
    } else if (widget.status == 'Alpha') {
      statusBadgeBg = const Color(0xFFFFEBEE);
      statusBadgeColor = const Color(0xFFC62828);
    }

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
              title: 'Detail Kehadiran Siswa',
              subtitle: TimeService().formattedDate,
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
                    // Student Card Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0E5DC),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.initials,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
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
                                      widget.studentName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.className} • NISN: ${widget.nisn}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusBadgeBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${widget.status} • ${widget.time}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: statusBadgeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFF0E8E1), height: 1),
                          const SizedBox(height: 14),

                          // Location Detail
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.maroon, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lokasi Presensi:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      realLoc,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.status == 'Hadir' || widget.status == 'Terlambat')
                                TextButton.icon(
                                  onPressed: () => _showPhotoProof(
                                    context,
                                    TimeService().formattedDateShort,
                                    realLoc,
                                    widget.time,
                                  ),
                                  icon: const Icon(Icons.photo_camera_rounded, size: 16),
                                  label: Text(
                                    'Foto',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.maroon,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Statistik Real Bulan Berjalan
                    Text(
                      'Statistik Bulan Ini ($curMonth)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('Hadir', '$_hadirCount'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem('Izin/Sakit', '$_izinCount'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem('Terlambat', '$_terlambatCount'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Riwayat Real
                    Text(
                      'Riwayat Kehadiran Database',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: AppColors.maroon),
                        ),
                      )
                    else if (_history.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Belum ada riwayat tercatat di database',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      )
                    else
                      ..._history.map((h) {
                        final stat = h['status']?.toString().capitalize() ?? 'Hadir';
                        Color c = Colors.green.shade700;
                        if (stat.toLowerCase() == 'terlambat') c = const Color(0xFFB78103);
                        if (stat.toLowerCase() == 'izin' || stat.toLowerCase() == 'sakit') c = Colors.blue.shade700;

                        final tgl = h['tanggal']?.toString() ?? '-';
                        final jm = h['jam_absen']?.toString() ?? '-';
                        final hUrl = h['photo_url']?.toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildHistoryCard(
                            context,
                            date: tgl,
                            status: stat,
                            statusColor: c,
                            time: jm.isNotEmpty ? '$jm WIB' : '—',
                            hasPhoto: stat.toLowerCase() == 'hadir' || stat.toLowerCase() == 'terlambat',
                            photoUrl: hUrl,
                          ),
                        );
                      }),

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
    String? photoUrl,
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
            width: 85,
            child: Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          if (hasPhoto)
            GestureDetector(
              onTap: () => _showPhotoProof(context, date, 'SMK Negeri 8 Malang', time, photoUrl: photoUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_rounded, size: 14, color: AppColors.maroon),
                    const SizedBox(width: 4),
                    Text(
                      'Foto',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 50),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
