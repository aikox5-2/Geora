import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';
import 'absen_kelas.dart';

class ClassItem {
  final String code;
  final String name;
  final String schoolYear;

  const ClassItem({
    required this.code,
    required this.name,
    this.schoolYear = 'Tahun Ajaran 2026 - 2027',
  });
}

class PilihKelasPage extends StatefulWidget {
  const PilihKelasPage({super.key});

  @override
  State<PilihKelasPage> createState() => _PilihKelasPageState();
}

class _PilihKelasPageState extends State<PilihKelasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ClassItem> _classes = const [
    ClassItem(code: 'XII RD', name: 'XII RPL D'),
    ClassItem(code: 'XII RB', name: 'XII RPL B'),
    ClassItem(code: 'XI RA', name: 'XI RPL A'),
    ClassItem(code: 'X TKJ A', name: 'X TKJ A'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClassItem> get _filteredClasses {
    if (_searchQuery.isEmpty) return _classes;
    final q = _searchQuery.toLowerCase();
    return _classes.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _openClass(ClassItem c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KelasAttendancePage(className: c.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredClasses;

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
            // Top Header matching Image 2
            const GeoraHeader(
              title: 'Absensi Siswa',
              subtitle: '16 September 2026',
              showBrandLogo: true,
              showBackButton: true,
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                controller: _searchController,
                hintText: 'Cari nama kelas...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Class List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada kelas ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = list[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openClass(c),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
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
                                children: [
                                  // Circle Avatar
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF0E5DC),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      c.code,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Class Name & Year
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          c.schoolYear,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // "Tampilkan" link
                                  Text(
                                    'Tampilkan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

