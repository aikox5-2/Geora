import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';
import 'anggota_kelas.dart';

class ClassItem {
  final String? id;
  final String code;
  final String name;
  final String schoolYear;

  const ClassItem({
    this.id,
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
  List<ClassItem> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealClasses();
  }

  Future<void> _loadRealClasses() async {
    setState(() => _isLoading = true);
    try {
      final realClasses = await SupabaseService().getClasses();
      if (realClasses.isNotEmpty) {
        _classes = realClasses.map((rc) => ClassItem(id: rc.id, code: rc.code, name: rc.name)).toList();
      } else {
        // Only if database returns exactly 0 classes, default to 1 real class matching ERD
        _classes = const [
          ClassItem(code: 'XII RD', name: 'XII RPL D'),
        ];
      }
    } catch (_) {
      _classes = const [
        ClassItem(code: 'XII RD', name: 'XII RPL D'),
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

  List<ClassItem> get _filteredClasses {
    if (_searchQuery.isEmpty) return _classes;
    final q = _searchQuery.toLowerCase();
    return _classes.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _openClass(ClassItem c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnggotaKelasPage(classId: c.id, className: c.name),
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
            // Top Header
            const GeoraHeader(
              title: 'Absensi Siswa',
              subtitle: 'Pilih kelas untuk absensi hari ini',
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : list.isEmpty
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
                                      // Class Icon Container
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF0E5DC),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.school_rounded,
                                          color: AppColors.maroon,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Class Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              c.schoolYear,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Chevron Icon
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.maroon,
                                        size: 26,
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
