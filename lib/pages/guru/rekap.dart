import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dummy_data_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class GuruRecapTab extends StatefulWidget {
  const GuruRecapTab({super.key});

  @override
  State<GuruRecapTab> createState() => _GuruRecapTabState();
}

class _GuruRecapTabState extends State<GuruRecapTab> {
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = TimeService().currentMonthYear;
  }

  void _showPeriodPicker() {
    final periods = TimeService().availablePeriods;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                    'Pilih Periode Rekap',
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
                'Data rekap kehadiran disinkronkan secara berkala',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              ...periods.map(
                (p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.calendar_month_rounded,
                    color: _selectedPeriod == p ? AppColors.maroon : AppColors.muted,
                  ),
                  title: Text(
                    p,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: _selectedPeriod == p ? FontWeight.w700 : FontWeight.w500,
                      color: _selectedPeriod == p ? AppColors.maroon : AppColors.ink,
                    ),
                  ),
                  trailing: _selectedPeriod == p
                      ? const Icon(Icons.check_rounded, color: AppColors.maroon)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPeriod = p;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        GeoraHeader(
          title: 'Rekap Kehadiran',
          subtitle: 'XII RPL D • $_selectedPeriod',
          showBrandLogo: true,
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Periode Selector Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periode Data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    InkWell(
                      onTap: _showPeriodPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5DDD5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.maroon),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPeriod,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.maroon,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.maroon),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 1. Chart Card
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Persentase Kehadiran',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 7 Vertical Capsule Bars
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('Sen', 0.85),
                            _buildBar('Sel', 0.90),
                            _buildBar('Rab', 0.80),
                            _buildBar('Kam', 0.92),
                            _buildBar('Jum', 0.88),
                            _buildBar('Sab', 0.95),
                            _buildBar('Min', 0.75),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bottom legend row
                      Builder(
                        builder: (context) {
                          final data = DummyDataService();
                          final hadirPct = data.totalStudents > 0
                              ? ((data.attendedToday / data.totalStudents) * 100).round()
                              : 0;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hadir $hadirPct%',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              Text(
                                'Terlambat 0%',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB78103),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Row of 3 Stat Cards
                Builder(
                  builder: (context) {
                    final data = DummyDataService();
                    final hadirPct = data.totalStudents > 0
                        ? ((data.attendedToday / data.totalStudents) * 100).round()
                        : 0;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildSmallStatCard(
                            label: 'Hadir',
                            value: '$hadirPct%',
                            valColor: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallStatCard(
                            label: 'Izin',
                            value: '0%',
                            valColor: const Color(0xFFF5A623),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallStatCard(
                            label: 'Terlambat',
                            value: '0%',
                            valColor: const Color(0xFF8B1E1E),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 3. Unduh Rekap Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mengunduh berkas Rekap Kehadiran XII RPL D ($_selectedPeriod)...',
                          ),
                          backgroundColor: AppColors.maroon,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Unduh Rekap',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double heightFraction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 145 * heightFraction,
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String label,
    required String value,
    required Color valColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}
