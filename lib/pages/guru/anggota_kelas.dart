import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import 'detail_siswa.dart';

class ClassStudentItem {
  final int absenNumber;
  final String name;
  final String time;
  final String status; // 'Hadir', 'Terlambat', 'Izin', 'Sakit', 'Alpha'
  final Color statusColor;
  final String nisn;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? method;
  final String? keterangan;

  const ClassStudentItem({
    required this.absenNumber,
    required this.name,
    required this.time,
    required this.status,
    required this.statusColor,
    this.nisn = '0000000000',
    this.location,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.method,
    this.keterangan,
  });

  bool matchesFilter(String filter) {
    if (filter == 'Semua') return true;
    if (filter == 'Hadir') {
      return status == 'Hadir' || status == 'Terlambat';
    }
    if (filter == 'Tidak Hadir') return status == 'Alpha';
    if (filter == 'Izin') return status == 'Izin';
    if (filter == 'Sakit') return status == 'Sakit';
    return true;
  }
}

class AnggotaKelasPage extends StatefulWidget {
  final String className;
  final String? classId;

  const AnggotaKelasPage({
    super.key,
    this.className = 'XII RPL D',
    this.classId,
  });

  @override
  State<AnggotaKelasPage> createState() => _AnggotaKelasPageState();
}

class _AnggotaKelasPageState extends State<AnggotaKelasPage> {
  final TimeService _timeService = TimeService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  List<ClassStudentItem> _students = [];
  bool _isLoading = true;

  String _waliKelasName = 'Memuat...';
  String _waliKelasNip = '';
  String _waliKelasInitials = '...';

  @override
  void initState() {
    super.initState();
    _loadWaliKelas();
    _loadRealStudents();
  }

  Future<void> _loadWaliKelas() async {
    final c = SupabaseService().client;
    if (c == null) return;
    try {
      Map<String, dynamic>? kelasData;
      if (widget.classId != null && widget.classId!.isNotEmpty) {
        kelasData = await c
            .from('kelas')
            .select('guru(nama, nip)')
            .eq('id_kelas', widget.classId!)
            .maybeSingle();
      }
      if (kelasData == null) {
        final cleanTarget = widget.className.toLowerCase().replaceAll(' ', '');
        final kList = await c.from('kelas').select('tingkat, jurusan, guru(nama, nip)');
        for (final k in kList) {
          final fullName = '${k['tingkat'] ?? ''}${k['jurusan'] ?? ''}'.toLowerCase().replaceAll(' ', '');
          if (fullName == cleanTarget || fullName.contains(cleanTarget) || cleanTarget.contains(fullName)) {
            kelasData = k;
            break;
          }
        }
      }

      if (kelasData != null && kelasData['guru'] != null) {
        final g = kelasData['guru'] as Map<String, dynamic>;
        final name = g['nama']?.toString() ?? 'Belum Ditentukan';
        final nip = g['nip']?.toString() ?? '';
        if (mounted) {
          setState(() {
            _waliKelasName = name;
            _waliKelasNip = nip;
            _waliKelasInitials = _calculateInitials(name);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _waliKelasName = 'Belum Ditentukan';
            _waliKelasNip = '';
            _waliKelasInitials = '—';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _waliKelasName = 'Belum Ditentukan';
          _waliKelasNip = '';
          _waliKelasInitials = '—';
        });
      }
    }
  }

  String _calculateInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '—';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF2E7D32);
      case 'terlambat':
        return const Color(0xFFB78103);
      case 'izin':
        return const Color(0xFF1976D2);
      case 'sakit':
        return const Color(0xFFF57C00);
      case 'dalam tinjauan':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  Future<void> _loadRealStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getStudentsForClass(widget.className, classId: widget.classId);
      if (list.isNotEmpty) {
        _students = list.map((s) {
          return ClassStudentItem(
            absenNumber: s.absenNumber,
            name: s.name,
            time: s.time,
            status: s.status,
            statusColor: _getStatusColor(s.status),
            nisn: s.nisn,
            location: s.location,
            latitude: s.latitude,
            longitude: s.longitude,
            photoUrl: s.photoUrl,
            method: s.method,
            keterangan: s.keterangan,
          );
        }).toList();
      } else {
        _students = [];
      }
    } catch (_) {
      _students = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClassStudentItem> get _filteredStudents {
    final q = _searchQuery.toLowerCase().trim();

    return _students.where((student) {
      final matchesQuery = q.isEmpty ||
          student.name.toLowerCase().contains(q) ||
          student.absenNumber.toString() == q ||
          'absen ${student.absenNumber}'.contains(q) ||
          student.status.toLowerCase().contains(q);

      final matchesFilter = student.matchesFilter(_selectedFilter);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredStudents;

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
              title: 'Anggota Kelas ${widget.className}',
              subtitle: 'Rekap kehadiran anggota kelas',
              showBackButton: true,
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        // Real-time Date Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E7DC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE5D5C6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Presensi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _timeService.formattedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.maroon.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.maroon,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Requirement 8: WALI KELAS CARD (No Attendance Status)
                        Text(
                          'Wali Kelas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(16),
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
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0E5DC),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _waliKelasInitials,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
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
                                      _waliKelasName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _waliKelasNip.isNotEmpty
                                          ? 'Wali Kelas • NIP $_waliKelasNip'
                                          : 'Wali Kelas',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.maroon.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Guru',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Heading: DAFTAR MURID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Murid',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E7DC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${list.length} / ${_students.length} Siswa',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.maroon,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search and Filter Row: { search } [ = ]
                        Row(
                          children: [
                            // Search bar
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Cari murid / nomor absen...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: AppColors.muted,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.muted,
                                      size: 20,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                              });
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Filter Icon Button [ = ]
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: _selectedFilter != 'Semua'
                                    ? AppColors.maroon
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: _selectedFilter != 'Semua'
                                      ? Colors.white
                                      : AppColors.ink,
                                  size: 20,
                                ),
                                onPressed: _showFilterDialog,
                              ),
                            ),
                          ],
                        ),

                        // Active filter badge if selected
                        if (_selectedFilter != 'Semua') ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Filter aktif:',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  _selectedFilter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.maroon,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFF7EFE8),
                                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _selectedFilter = 'Semua';
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // List of Students (Absen 1 to N)
                        if (list.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                _students.isEmpty
                                    ? 'Belum ada siswa yang terdaftar di kelas ini.'
                                    : 'Tidak ada murid yang cocok dengan pencarian.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          )
                        else
                          ...list.map((student) => _buildStudentCard(student)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Status Kehadiran',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih status kehadiran murid yang ingin ditampilkan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      _buildFilterChip('Semua', ctx),
                      _buildFilterChip('Hadir', ctx),
                      _buildFilterChip('Tidak Hadir', ctx),
                      _buildFilterChip('Izin', ctx),
                      _buildFilterChip('Sakit', ctx),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Terapkan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, BuildContext ctx) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.ink,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.maroon,
      backgroundColor: const Color(0xFFF7EFE8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.maroon : const Color(0xFFE5D5C6),
        ),
      ),
      onSelected: (val) {
        setState(() {
          _selectedFilter = label;
        });
        Navigator.pop(ctx);
      },
    );
  }

  void _showStudentDetailBottomSheet(ClassStudentItem s) {
    final initials = s.name.isNotEmpty
        ? s.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase()
        : 'S';
    final isManual = (s.method ?? '').toLowerCase().contains('manual') ||
        s.status == 'Izin' ||
        s.status == 'Sakit' ||
        s.status == 'Dalam Tinjauan';
    final isAlpha = s.status == 'Alpha' || s.status == 'Belum Presensi';
    final hasRealGps = !isManual && !isAlpha && (s.status == 'Hadir' || s.status == 'Terlambat');
    final realLoc = isManual
        ? 'Pengajuan Presensi Manual (Tanpa Koordinat GPS)'
        : (s.location ?? ((s.status == 'Hadir' || s.status == 'Terlambat')
            ? 'SMK Negeri 8 Kota Malang (-7.9361, 112.6619)'
            : 'Belum Terdeteksi'));

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Student Info
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0E5DC),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
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
                              s.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Absen ${s.absenNumber} • ${widget.className} • NISN: ${s.nisn}',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: s.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s.status,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: s.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFF0E8E1)),
                  const SizedBox(height: 12),

                  // Jam Absen & Metode
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F5F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu Presensi',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.time,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F5F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Metode Kehadiran',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.method ?? (s.status == 'Alpha' ? 'Belum Presensi' : 'Kamera GPS'),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Detail Lokasi dengan Frame Google Maps
                  Text(
                    'Lokasi Presensi Siswa',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFE8E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.maroon, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            realLoc,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tampilkan Peta Google Maps Asli jika presensi GPS nyata
                  if (hasRealGps) ...[
                    const SizedBox(height: 14),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4E3EA)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: ll.LatLng(s.latitude!, s.longitude!),
                                initialZoom: 16.0,
                                minZoom: 10.0,
                                maxZoom: 19.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                                  userAgentPackageName: 'com.geora.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: ll.LatLng(s.latitude!, s.longitude!),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.red,
                                        size: 38,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${s.latitude},${s.longitude}');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.maroon),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Buka Maps',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.maroon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Bukti Kehadiran (Foto GPS Asli atau Surat Pengajuan Manual)
                  Text(
                    isManual ? 'Bukti Surat / Dokumen Izin' : 'Bukti Foto Kehadiran',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (s.photoUrl != null && s.photoUrl!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    s.photoUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                                  onPressed: () => Navigator.pop(c),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFE8E1)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                s.photoUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: const Color(0xFFF8F5F2),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: AppColors.maroon, strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, e, st) => Container(
                                  color: const Color(0xFFF8F5F2),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image_outlined, size: 36, color: AppColors.muted),
                                        const SizedBox(height: 6),
                                        Text('Gagal memuat foto', style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.muted)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Perbesar Foto',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selfie Asli Terverifikasi',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFE8E1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5DDD5)),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isManual ? Icons.notes_rounded : Icons.no_photography_outlined,
                              color: isManual ? AppColors.maroon : AppColors.muted,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isManual
                                      ? (s.keterangan != null && s.keterangan!.isNotEmpty
                                          ? 'Alasan: ${s.keterangan}'
                                          : 'Pengajuan Absensi Manual')
                                      : 'Tidak Ada Foto Presensi',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  isManual
                                      ? 'Pengajuan izin / sakit dicatat tanpa berkas foto.'
                                      : 'Murid belum mengambil foto presensi hari ini.',
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
                  ],

                  const SizedBox(height: 18),

                  // Tombol Riwayat Lengkap Siswa
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailSiswaPage(
                              studentName: s.name,
                              initials: initials,
                              className: widget.className,
                              time: s.time,
                              status: s.status,
                              nisn: s.nisn,
                              location: s.location,
                              latitude: s.latitude,
                              longitude: s.longitude,
                              photoUrl: s.photoUrl,
                              method: s.method,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: Text(
                        'Buka Profil & Riwayat Lengkap',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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

  Widget _buildStudentCard(ClassStudentItem s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showStudentDetailBottomSheet(s),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Absen Number Circle (1/N)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E7DC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${s.absenNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.time,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: s.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: s.statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
