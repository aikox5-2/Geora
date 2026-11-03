import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // "untuk yang terlambat masih dikategorikan didalam hadir"
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

  // 36 Students list ordered from Absen 1 to 36
  static final List<ClassStudentItem> _students = [
    const ClassStudentItem(absenNumber: 1, name: 'Ahmad Farhan', time: '— WIB', status: 'Izin', statusColor: Color(0xFF1976D2)),
    const ClassStudentItem(absenNumber: 2, name: 'Alya Putri', time: '06:45 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 3, name: 'Bayu Pratama', time: '06:50 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 4, name: 'Budiono Siregar', time: '06:55 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 5, name: 'Chelsea Aqila Putri', time: '06:30 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 6, name: 'Deni Setiawan', time: '07:18 WIB', status: 'Terlambat', statusColor: Color(0xFFB78103)),
    const ClassStudentItem(absenNumber: 7, name: 'Dimas Ibrahimovic', time: '— WIB', status: 'Alpha', statusColor: Color(0xFFD32F2F)),
    const ClassStudentItem(absenNumber: 8, name: 'Fajar Adi', time: '06:40 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 9, name: 'Gilang Ramadhan', time: '06:48 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 10, name: 'Hana Safitri', time: '06:52 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 11, name: 'Irfan Maulana', time: '07:00 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 12, name: 'Joko Prasetyo', time: '07:15 WIB', status: 'Terlambat', statusColor: Color(0xFFB78103)),
    const ClassStudentItem(absenNumber: 13, name: 'Kania Dewi', time: '06:35 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 14, name: 'Lukman Hakim', time: '06:58 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 15, name: 'Malika Aisyabila', time: '— WIB', status: 'Sakit', statusColor: Color(0xFFF57C00)),
    const ClassStudentItem(absenNumber: 16, name: 'Nabil Syafiq Afa', time: '07:15 WIB', status: 'Terlambat', statusColor: Color(0xFFB78103)),
    const ClassStudentItem(absenNumber: 17, name: 'Nadya Amanda', time: '06:42 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 18, name: 'Oki Setiawan', time: '06:50 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 19, name: 'Putri Ayu', time: '06:38 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 20, name: 'Qori Alamsyah', time: '06:46 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 21, name: 'Rani Wulandari', time: '06:44 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 22, name: 'Reza Fauzi', time: '07:20 WIB', status: 'Terlambat', statusColor: Color(0xFFB78103)),
    const ClassStudentItem(absenNumber: 23, name: 'Rian Saputra', time: '— WIB', status: 'Izin', statusColor: Color(0xFF1976D2)),
    const ClassStudentItem(absenNumber: 24, name: 'Salma Khairunnisa', time: '06:32 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 25, name: 'Surya Dharma', time: '06:50 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 26, name: 'Taufik Hidayat', time: '06:54 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 27, name: 'Tiara Lestari', time: '06:36 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 28, name: 'Umar Bakri', time: '06:48 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 29, name: 'Vina Panduwinata', time: '— WIB', status: 'Sakit', statusColor: Color(0xFFF57C00)),
    const ClassStudentItem(absenNumber: 30, name: 'Wahyu Nugroho', time: '07:02 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 31, name: 'Wulan Guritno', time: '06:40 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 32, name: 'Xavier Ardiansyah', time: '06:55 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 33, name: 'Yohanes Kristian', time: '— WIB', status: 'Alpha', statusColor: Color(0xFFD32F2F)),
    const ClassStudentItem(absenNumber: 34, name: 'Yulia Rachmawati', time: '06:42 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 35, name: 'Zahra Cantika', time: '06:35 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
    const ClassStudentItem(absenNumber: 36, name: 'Zidan Al-Farizi', time: '06:58 WIB', status: 'Hadir', statusColor: Color(0xFF2E7D32)),
  ];

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
              child: ListView(
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
                      border: Border.all(
                        color: const Color(0xFFE8DFD8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                                'Yudi Guru, S.Pd.',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Wali Kelas ${widget.className} • NIP 198501012010011001',
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
                            color: const Color(0xFFF5EDE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Wali Kelas',
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

                  const SizedBox(height: 22),

                  // Requirement 8: SEARCH BAR
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.ink),
                            decoration: InputDecoration(
                              hintText: 'Cari nama atau nomor absen 1–36...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.muted.withValues(alpha: 0.7),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.maroon,
                            borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(height: 14),

                  // Requirement 8: FILTER CHIPS ROW (Hadir includes Terlambat)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('Semua'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Hadir'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tidak Hadir'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Izin'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Sakit'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header with Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Murid (Absen 01–36)',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '${list.length} Murid',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.maroon,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 36 Student Cards
                  if (list.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text(
                        'Tidak ada siswa yang sesuai dengan pencarian atau filter.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilter = label);
      },
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.ink,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.maroon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.maroon : const Color(0xFFE8DFD8),
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildStudentCard(ClassStudentItem student) {
    final absenStr = student.absenNumber.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DFD8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Absen Number + Name & Time
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE8),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  absenStr,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.time,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status Badge
          Text(
            student.status,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: student.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
