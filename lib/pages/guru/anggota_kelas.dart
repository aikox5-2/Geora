import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class ClassStudentItem {
  final int absenNumber;
  final String name;
  final String time;
  final String status; // 'Hadir', 'Terlambat', 'Izin', 'Sakit', 'Alpha'
  final Color statusColor;

  const ClassStudentItem({
    required this.absenNumber,
    required this.name,
    required this.time,
    required this.status,
    required this.statusColor,
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

  const AnggotaKelasPage({
    super.key,
    this.className = 'XII RPL D',
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

  @override
  void initState() {
    super.initState();
    _loadRealStudents();
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
      default:
        return const Color(0xFFD32F2F);
    }
  }

  Future<void> _loadRealStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getStudentsForClass(widget.className);
      if (list.isNotEmpty) {
        _students = list.map((s) {
          return ClassStudentItem(
            absenNumber: s.absenNumber,
            name: s.name,
            time: s.time,
            status: s.status,
            statusColor: _getStatusColor(s.status),
          );
        }).toList();
      } else {
        // Fallback matching real 6 seed students from ERD
        _students = [
          ClassStudentItem(absenNumber: 1, name: 'Ahmad Farhan', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
          ClassStudentItem(absenNumber: 2, name: 'Budiono Siregar', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
          ClassStudentItem(absenNumber: 3, name: 'Chelsea Aqila Putri', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
          ClassStudentItem(absenNumber: 4, name: 'Dimas Ibrahimovic', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
          ClassStudentItem(absenNumber: 5, name: 'Malika Aisyabila', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
          ClassStudentItem(absenNumber: 6, name: 'Nabil Syafiq Afa', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ];
      }
    } catch (_) {
      _students = [
        ClassStudentItem(absenNumber: 1, name: 'Ahmad Farhan', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ClassStudentItem(absenNumber: 2, name: 'Budiono Siregar', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ClassStudentItem(absenNumber: 3, name: 'Chelsea Aqila Putri', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ClassStudentItem(absenNumber: 4, name: 'Dimas Ibrahimovic', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ClassStudentItem(absenNumber: 5, name: 'Malika Aisyabila', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
        ClassStudentItem(absenNumber: 6, name: 'Nabil Syafiq Afa', time: '— WIB', status: 'Alpha', statusColor: _getStatusColor('Alpha')),
      ];
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
                                  'YG',
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
                                      'Yudi Guru, S.Pd',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Wali Kelas • NIP 198503122010011005',
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
                                'Tidak ada murid yang cocok.',
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

  Widget _buildStudentCard(ClassStudentItem s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
