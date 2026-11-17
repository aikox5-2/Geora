import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/attendance_state_service.dart';
import '../../services/auth_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guru_piket.dart';
import 'absen_manual.dart';
import 'absen_kamera.dart';

class SiswaAttendanceHubTab extends StatefulWidget {
  const SiswaAttendanceHubTab({super.key});

  @override
  State<SiswaAttendanceHubTab> createState() => _SiswaAttendanceHubTabState();
}

class _SiswaAttendanceHubTabState extends State<SiswaAttendanceHubTab> {
  final TimeService _timeService = TimeService();
  final AttendanceStateService _stateService = AttendanceStateService();

  @override
  void initState() {
    super.initState();
    _timeService.addListener(_onServiceUpdate);
    _stateService.addListener(_onServiceUpdate);
    _stateService.syncTodayAttendance();
  }

  @override
  void dispose() {
    _timeService.removeListener(_onServiceUpdate);
    _stateService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  String get _greeting {
    final hour = _timeService.now.hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _showDutyTeachersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bantuan Guru Piket',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Jika mengalami kendala GPS/lokasi atau izin sakit, silakan hubungi guru piket bertugas melalui WhatsApp:',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const GuruPiketSection(showHeader: false),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final user = AuthService().currentUser;
    final studentName = user?.name ?? 'Budiono Siregar';
    final statusToday = _stateService.todayStatusLabel;
    final infoDisplay = (user?.info != null && user!.info!.isNotEmpty)
        ? user.info!
        : 'XII Keperawatan';
    final nisnDisplay = (user?.nisn != null && user!.nisn!.isNotEmpty)
        ? 'NISN : ${user.nisn}'
        : (user != null && user.aliases.isNotEmpty
            ? 'NISN : ${user.aliases.first}'
            : 'NISN : 0051283925');
    final isTimeOver = !_stateService.isDirectAttendanceTimeAllowed();
    final hasAuto = _stateService.hasAutomaticSubmitted;
    final hasManual = _stateService.hasManualSubmitted;
    final isAlreadyCheckedIn = hasAuto || hasManual;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header without right icon (Requirement 7)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Absensi Siswa',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Maroon Student Card (Image 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  studentName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nisnDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  infoDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status hari ini',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      statusToday,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Section Absensi Hari Ini
          Text(
            'Absensi Hari Ini',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          // Card matching Image 1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Absensi Hanya Dapat Dilakukan Diarea Sekolah',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeService.formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),

                if (isTimeOver && !isAlreadyCheckedIn) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade400, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded, color: Colors.amber.shade800, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Waktu absen langsung telah berakhir (Maksimal ${_stateService.endAttendanceTimeString} WIB). Silakan gunakan formulir Absen Manual di bawah.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Button 1: Absen Sekarang (Otomatis GPS & Kamera)
                // Requirement 5: Jika sudah absen manual, tombol ini terkunci dan tidak bisa ditekan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: hasManual
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anda telah mengajukan absen manual hari ini. Absen langsung tidak dapat dilakukan kecuali direset oleh admin.'),
                                backgroundColor: AppColors.maroon,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        : (hasAuto
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Anda sudah melakukan absensi hari ini ($statusToday).'),
                                    backgroundColor: AppColors.maroon,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            : (isTimeOver
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Waktu absensi langsung telah selesai (${_stateService.endAttendanceTimeString} WIB). Silakan ajukan melalui Absen Manual.'),
                                        backgroundColor: Colors.amber.shade900,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SiswaAutoAttendancePage(),
                                      ),
                                    );
                                  })),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (hasManual || hasAuto || isTimeOver)
                          ? Colors.grey.shade400
                          : AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      hasManual
                          ? 'Absen Sekarang (Terkunci)'
                          : (hasAuto
                              ? (statusToday.toLowerCase().contains('terlambat')
                                  ? 'Terlambat'
                                  : (statusToday.toLowerCase().contains('hadir') ? 'Hadir' : statusToday))
                              : (isTimeOver ? 'Waktu Absen Selesai' : 'Absen Sekarang')),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Button 2: Absen Manual (Izin & Sakit)
                // Requirement 5: Jika sudah absen otomatis, tombol ini terkunci dan tidak bisa ditekan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: hasAuto
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Anda sudah melakukan absen langsung hari ini ($statusToday). Absen manual tidak dapat diajukan kecuali direset oleh admin.'),
                                backgroundColor: AppColors.maroon,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AbsenManualPage(),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: hasAuto ? Colors.grey.shade400 : AppColors.maroon,
                      side: BorderSide(
                        color: hasAuto ? Colors.grey.shade300 : AppColors.maroon,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      hasAuto
                          ? 'Absen Manual (Terkunci)'
                          : (hasManual
                              ? 'Lihat Status Absen Manual'
                              : 'Absen Manual (Izin / Sakit)'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Rata Kiri: "Tidak Bisa Absen? , Hubungi Tim Geora" (Requirement 2)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Tidak Bisa Absen? , ',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showDutyTeachersBottomSheet,
                        child: Text(
                          'Hubungi Tim Geora',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
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
        ],
      ),
    );
  }
}

