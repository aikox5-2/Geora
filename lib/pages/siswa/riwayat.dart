import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';

class StudentHistoryItem {
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final DateTime dateTime;

  const StudentHistoryItem({
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.dateTime,
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

        String formattedDate = tglStr;
        try {
          formattedDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dt);
        } catch (_) {
          formattedDate = tglStr;
        }

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
        } else if (statStr == 'alpha') {
          displayStatus = 'Alpha';
          color = const Color(0xFFD32F2F);
        } else {
          displayStatus = 'Hadir';
          color = const Color(0xFF2E7D32);
          if (dt.month == now.month && dt.year == now.year) _attendedThisMonth++;
        }

        final timeFormatted = jamStr.isNotEmpty
            ? '${jamStr.split(':').take(2).join('.')} WIB'
            : '— WIB';

        return StudentHistoryItem(
          date: formattedDate,
          time: timeFormatted,
          status: displayStatus,
          statusColor: color,
          dateTime: dt,
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
                              Text(
                                item.time,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
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
                )),
        ],
      ),
    );
  }
}
