import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';

class StudentHistoryItem {
  final String? id;
  final String date; // "Senin, 16 November 2026"
  final String rawDate;
  final String time;
  final String status;
  final Color statusColor;
  final DateTime dateTime;
  final String? method;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? fileUrl;
  final String? keterangan;
  final String? approvedByGuru;
  final String? catatanGuru;
  final bool isManual;

  const StudentHistoryItem({
    this.id,
    required this.date,
    required this.rawDate,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.dateTime,
    this.method,
    this.location,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.fileUrl,
    this.keterangan,
    this.approvedByGuru,
    this.catatanGuru,
    this.isManual = false,
  });
}

class SiswaHistoryTab extends StatefulWidget {
  const SiswaHistoryTab({super.key});

  @override
  State<SiswaHistoryTab> createState() => _SiswaHistoryTabState();
}

class _SiswaHistoryTabState extends State<SiswaHistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedFilterDate;
  List<StudentHistoryItem> _allHistory = [];
  bool _isLoading = true;
  int _attendedThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadRealHistory();
  }

  static String _formatIndonesianDate(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$day, ${dt.day} $month ${dt.year}';
  }

  Future<void> _loadRealHistory() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      final userId = user?.id ?? '';
      final userName = user?.name ?? '';

      final rawList = await SupabaseService().getStudentAttendanceHistory(
        userId.isNotEmpty ? userId : userName,
      );

      _attendedThisMonth = 0;
      final now = TimeService().now;

      _allHistory = rawList.map((row) {
        final tglStr = row['tanggal']?.toString() ?? '';
        final jamStr = row['jam_absen']?.toString() ?? '';
        final statStr = row['status']?.toString().toLowerCase() ?? 'hadir';

        DateTime dt = now;
        try {
          dt = DateTime.parse(tglStr);
        } catch (_) {}

        final formattedDate = _formatIndonesianDate(dt);

        String displayStatus = 'Hadir';
        Color color = const Color(0xFF2E7D32);

        if (statStr == 'terlambat') {
          displayStatus = 'Terlambat';
          color = const Color(0xFFB78103);
          if (dt.month == now.month && dt.year == now.year) _attendedThisMonth++;
        } else if (statStr == 'izin') {
          displayStatus = 'Izin';
          color = const Color(0xFF1976D2);
        } else if (statStr == 'sakit') {
          displayStatus = 'Sakit';
          color = const Color(0xFFF57C00);
        } else if (statStr == 'dalam tinjauan') {
          displayStatus = 'Dalam Tinjauan';
          color = const Color(0xFFE65100);
        } else if (statStr == 'alpha') {
          displayStatus = 'Alpha';
          color = const Color(0xFFD32F2F);
        } else {
          displayStatus = 'Hadir';
          color = const Color(0xFF2E7D32);
          if (dt.month == now.month && dt.year == now.year) _attendedThisMonth++;
        }

        final timeFormatted = jamStr.isNotEmpty
            ? (jamStr.contains(':')
                ? '${jamStr.split(':').take(2).join('.')} WIB'
                : jamStr)
            : '— WIB';

        double? lat;
        double? lng;
        if (row['latitude'] != null) lat = double.tryParse(row['latitude'].toString());
        if (row['longitude'] != null) lng = double.tryParse(row['longitude'].toString());

        return StudentHistoryItem(
          id: row['id']?.toString(),
          date: formattedDate,
          rawDate: tglStr,
          time: timeFormatted,
          status: displayStatus,
          statusColor: color,
          dateTime: dt,
          method: row['metode']?.toString(),
          location: row['lokasi']?.toString(),
          latitude: lat,
          longitude: lng,
          photoUrl: row['photo_url']?.toString(),
          fileUrl: row['file_url']?.toString(),
          keterangan: row['keterangan']?.toString(),
          approvedByGuru: row['guru_nama']?.toString(),
          catatanGuru: row['catatan_guru']?.toString(),
          isManual: row['is_manual'] == true,
        );
      }).toList();
    } catch (_) {
      _allHistory = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentHistoryItem> get _filteredHistory {
    return _allHistory.where((item) {
      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          item.date.toLowerCase().contains(q) ||
          item.status.toLowerCase().contains(q) ||
          item.time.toLowerCase().contains(q);

      bool matchesDate = true;
      if (_selectedFilterDate != null) {
        matchesDate = item.dateTime.year == _selectedFilterDate!.year &&
            item.dateTime.month == _selectedFilterDate!.month &&
            item.dateTime.day == _selectedFilterDate!.day;
      }

      return matchesQuery && matchesDate;
    }).toList();
  }

  Future<void> _pickFilterDate() async {
    final now = TimeService().now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? now,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.maroon,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedFilterDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final list = _filteredHistory;
    final curMonth = TimeService().formattedDate.split(',').last.trim();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Text(
            'Riwayat Absensi',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Rekap kehadiran kamu di database sekolah',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 20),

          // Monthly Summary Banner (Maroon Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kehadiran Bulan Ini ($curMonth)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_attendedThisMonth Hadir',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Search Bar + Filter Icon Button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'Cari tanggal atau status...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.muted.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.maroon,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Filter Date Icon Button
              Material(
                color: _selectedFilterDate != null ? AppColors.maroon : Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                child: InkWell(
                  onTap: _pickFilterDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.tune_rounded,
                      color: _selectedFilterDate != null ? Colors.white : AppColors.maroon,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Active Date Filter Badge
          if (_selectedFilterDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.maroon),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${DateFormat('d MMM yyyy').format(_selectedFilterDate!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.maroon,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearDateFilter,
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.maroon),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // List of History Cards
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: CircularProgressIndicator(color: AppColors.maroon),
              ),
            )
          else if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.event_busy_rounded, color: AppColors.muted.withValues(alpha: 0.5), size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Tidak ada catatan presensi di database',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            )
          else
            ...list.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showDetailModal(context, item),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.date,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        item.time,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.photo_camera_rounded, size: 14, color: AppColors.maroon),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Foto',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            color: AppColors.maroon,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      if (item.fileUrl != null && item.fileUrl!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.attach_file_rounded, size: 14, color: AppColors.maroon),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Surat',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            color: AppColors.maroon,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: item.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context, StudentHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 14,
              left: 22,
              right: 22,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Presensi',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.status,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: item.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Tanggal & Jam Absen
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Hari & Tanggal',
                    value: item.date,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu Absen',
                    value: item.time,
                  ),
                  const SizedBox(height: 12),

                  // Metode Absen
                  _buildDetailRow(
                    icon: item.isManual ? Icons.assignment_outlined : Icons.camera_alt_outlined,
                    label: 'Metode Presensi',
                    value: item.method ?? (item.isManual ? 'Absen Manual' : 'Kamera & GPS'),
                  ),
                  const SizedBox(height: 12),

                  // Lokasi
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Lokasi Presensi',
                    value: item.location ?? 'SMK Negeri 8 Kota Malang',
                    subtitle: (item.latitude != null && item.longitude != null)
                        ? 'Koordinat: ${item.latitude!.toStringAsFixed(5)}, ${item.longitude!.toStringAsFixed(5)}'
                        : null,
                  ),

                  // Alasan (jika manual / izin / sakit)
                  if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Alasan / Keterangan',
                      value: item.keterangan!,
                    ),
                  ],

                  // Guru yang meng-ACC (untuk manual)
                  if (item.approvedByGuru != null && item.approvedByGuru!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diverifikasi / Di-ACC Oleh',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                                Text(
                                  item.approvedByGuru!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (item.catatanGuru != null && item.catatanGuru!.isNotEmpty)
                                  Text(
                                    'Catatan: ${item.catatanGuru}',
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
                    ),
                  ] else if (item.isManual && item.status == 'Dalam Tinjauan') ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pending_actions_rounded, color: Color(0xFFD97706), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pengajuan absensi manual sedang menunggu peninjauan dan persetujuan dari Wali Kelas / Guru.',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bukti Foto Kehadiran (benar-benar tampilkan gambar)
                  if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Bukti Foto Kehadiran',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade100,
                        child: Image.network(
                          item.photoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (c, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
                          },
                          errorBuilder: (c, err, stack) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_rounded, color: AppColors.muted, size: 36),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Foto tidak dapat dimuat',
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Bukti File Surat Manual (jika ada file_url, support multi-file hingga 3 berkas)
                  if (item.fileUrl != null && item.fileUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Bukti Berkas / Surat Dokter',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...item.fileUrl!
                        .split(',')
                        .map((u) => u.trim())
                        .where((u) => u.isNotEmpty)
                        .map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 240),
                            color: Colors.grey.shade100,
                            child: Image.network(
                              u,
                              fit: BoxFit.cover,
                              loadingBuilder: (c, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
                              },
                              errorBuilder: (c, err, stack) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.insert_drive_file_rounded, color: AppColors.maroon, size: 32),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Berkas surat terlampir di sistem.',
                                          style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.ink),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EDE5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.maroon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
