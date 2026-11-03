import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class AdminRecapTab extends StatefulWidget {
  const AdminRecapTab({super.key});

  @override
  State<AdminRecapTab> createState() => _AdminRecapTabState();
}

class _AdminRecapTabState extends State<AdminRecapTab> {
  String _selectedPeriod = 'September 2026';
  final List<String> _availablePeriods = [
    'September 2026',
    'Agustus 2026',
    'Juli 2026',
    'Juni 2026',
    'Mei 2026',
  ];

  // Daily attendance percentages: [Sen, Sel, Rab, Kam, Jum, Sab, Min]
  final List<Map<String, dynamic>> _dailyData = [
    {'day': 'Sen', 'pct': 0.58},
    {'day': 'Sel', 'pct': 0.78},
    {'day': 'Rab', 'pct': 0.62},
    {'day': 'Kam', 'pct': 0.90},
    {'day': 'Jum', 'pct': 0.82},
    {'day': 'Sab', 'pct': 0.96},
    {'day': 'Min', 'pct': 0.70},
  ];

  // Weekly attendance percentages: [Mg 1, Mg 2, Mg 3, Mg 4]
  final List<Map<String, dynamic>> _weeklyData = [
    {'week': 'Mg 1', 'pct': 0.65},
    {'week': 'Mg 2', 'pct': 0.85},
    {'week': 'Mg 3', 'pct': 0.74},
    {'week': 'Mg 4', 'pct': 0.95},
  ];

  // Monthly attendance percentages: [Apr, Mei, Jun, Jul, Agu, Sep]
  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Apr', 'pct': 0.65},
    {'month': 'Mei', 'pct': 0.76},
    {'month': 'Jun', 'pct': 0.84},
    {'month': 'Jul', 'pct': 0.90},
    {'month': 'Agu', 'pct': 0.78},
    {'month': 'Sep', 'pct': 0.96},
  ];

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                    const SizedBox(width: 12),
                    Text(
                      'Pilih Periode Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._availablePeriods.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      period,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.maroon : AppColors.ink,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.maroon)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedPeriod = period;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDownloadOptionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.maroon.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: AppColors.maroon,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unduh Laporan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Periode $_selectedPeriod',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Silakan pilih format dokumen laporan yang ingin disimpan:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _buildDownloadFormatOption(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: Colors.red.shade700,
              formatTitle: 'Dokumen PDF (.pdf)',
              formatDesc: 'Cocok untuk cetak dan arsip resmi sekolah',
              onTap: () {
                Navigator.pop(ctx);
                _triggerDownloadSuccess('PDF');
              },
            ),
            const SizedBox(height: 10),
            _buildDownloadFormatOption(
              icon: Icons.table_chart_rounded,
              iconColor: Colors.green.shade700,
              formatTitle: 'Spreadsheet Excel (.xlsx)',
              formatDesc: 'Cocok untuk olah data dan rekap spreadsheet',
              onTap: () {
                Navigator.pop(ctx);
                _triggerDownloadSuccess('Excel (.xlsx)');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadFormatOption({
    required IconData icon,
    required Color iconColor,
    required String formatTitle,
    required String formatDesc,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF7EFE8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      formatDesc,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerDownloadSuccess(String format) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unduh Berhasil!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Laporan Absensi periode $_selectedPeriod format $format berhasil diunduh dan tersimpan di folder Dokumen perangkat Anda.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );

    // Also surface notification snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Laporan Absensi $_selectedPeriod ($format) selesai diunduh.',
                style: GoogleFonts.poppins(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header matching Gambar 5: "Laporan Absensi" / "Rekap dan analisis kehadiran"
        const GeoraHeader(
          title: 'Laporan Absensi',
          subtitle: 'Rekap dan analisis kehadiran',
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Periode Dropdown Card
                _buildPeriodCard(),
                const SizedBox(height: 20),

                // 2. Statistik Kehadiran (3 stat cards)
                Text(
                  'Statistik Kehadiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        label: 'Hadir',
                        value: '84%',
                        valueColor: const Color(0xFF15803D), // Green
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        label: 'Izin',
                        value: '6%',
                        valueColor: const Color(0xFFD97706), // Amber / Gold
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        label: 'Terlambat',
                        value: '10%',
                        valueColor: const Color(0xFF6B0504), // Dark Maroon
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Statistik Kehadiran Charts
                Text(
                  'Statistik Kehadiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),

                // Chart 1: Harian
                _buildChartCard(
                  title: 'Harian',
                  bars: _dailyData
                      .map((d) => _BarItem(
                            label: d['day'] as String,
                            ratio: (d['pct'] as double).clamp(0.0, 1.0),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 14),

                // Chart 2: Mingguan
                _buildChartCard(
                  title: 'Mingguan',
                  bars: _weeklyData
                      .map((d) => _BarItem(
                            label: d['week'] as String,
                            ratio: (d['pct'] as double).clamp(0.0, 1.0),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 14),

                // Chart 3: Bulanan
                _buildChartCard(
                  title: 'Bulanan',
                  bars: _monthlyData
                      .map((d) => _BarItem(
                            label: d['month'] as String,
                            ratio: (d['pct'] as double).clamp(0.0, 1.0),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 24),

                // 4. Unduh Laporan Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _showDownloadOptionsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Unduh Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Periode Card matching Gambar 5
  Widget _buildPeriodCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _showPeriodPicker,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
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
            children: [
              Text(
                'Periode',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _selectedPeriod,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metric stat card (Hadir 84%, Izin 6%, Terlambat 10%)
  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Bar chart card matching Gambar 5
  Widget _buildChartCard({
    required String title,
    required List<_BarItem> bars,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
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
      child: Column(
        children: [
          // Header: Title on left, 'Kehadiran (%)' on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'Kehadiran (%)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Area
          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                const maxBarHeight = 65.0;
                final barHeight = maxBarHeight * bar.ratio;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bar.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem {
  final String label;
  final double ratio;

  const _BarItem({required this.label, required this.ratio});
}
