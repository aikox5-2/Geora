import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class ManageKonfigurasiAbsenPage extends StatefulWidget {
  const ManageKonfigurasiAbsenPage({super.key});

  @override
  State<ManageKonfigurasiAbsenPage> createState() => _ManageKonfigurasiAbsenPageState();
}

class _ManageKonfigurasiAbsenPageState extends State<ManageKonfigurasiAbsenPage> {
  final SupabaseService _supa = SupabaseService();
  List<Map<String, dynamic>> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supa.getAttendanceConfigs();
      setState(() {
        _configs = list;
      });
    } catch (_) {
      setState(() => _configs = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTimeDisplay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '—';
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]} WIB';
    }
    return '$timeStr WIB';
  }

  TimeOfDay _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return const TimeOfDay(hour: 7, minute: 0);
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeOfDayToDbString(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

    Future<TimeOfDay?> _selectTime24H(BuildContext context, TimeOfDay initial) async {
    return showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.maroon,
                onPrimary: Colors.white,
                onSurface: AppColors.ink,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  void _showAddEditDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    String selectedHari = existing?['hari']?.toString() ?? 'Semua Hari';
    TimeOfDay jamMulai = _parseTimeOfDay(existing?['jam_mulai']?.toString() ?? '06:00:00');
    TimeOfDay jamSelesai = _parseTimeOfDay(existing?['jam_selesai']?.toString() ?? '08:00:00');
    TimeOfDay batasTerlambat = _parseTimeOfDay(existing?['batas_terlambat']?.toString() ?? '07:00:00');
    final lokasiCtrl = TextEditingController(text: existing?['lokasi']?.toString() ?? 'SMK Negeri 8 Malang');

    final hariOptions = const [
      'Semua Hari',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EFE8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.maroon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? 'Ubah Konfigurasi Absen' : 'Tambah Konfigurasi Absen',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Hari Berlaku',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F4),
                      border: Border.all(color: const Color(0xFFE8DFD8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: hariOptions.contains(selectedHari) ? selectedHari : hariOptions.first,
                        isExpanded: true,
                        items: hariOptions.map((h) {
                          return DropdownMenuItem<String>(
                            value: h,
                            child: Text(h, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedHari = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Jam Mulai
                  _buildTimePickerTile(
                    label: 'Jam Mulai Absen',
                    time: jamMulai,
                    onTap: () async {
                      final picked = await _selectTime24H(context, jamMulai);
                      if (picked != null) setDialogState(() => jamMulai = picked);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Batas Terlambat
                  _buildTimePickerTile(
                    label: 'Batas Terlambat (Mulai Terlambat)',
                    time: batasTerlambat,
                    highlightColor: Colors.orange.shade800,
                    onTap: () async {
                      final picked = await _selectTime24H(context, batasTerlambat);
                      if (picked != null) setDialogState(() => batasTerlambat = picked);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Jam Selesai
                  _buildTimePickerTile(
                    label: 'Jam Selesai (Batas Akhir Absen)',
                    time: jamSelesai,
                    highlightColor: Colors.red.shade700,
                    onTap: () async {
                      final picked = await _selectTime24H(context, jamSelesai);
                      if (picked != null) setDialogState(() => jamSelesai = picked);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Lokasi
                  Text(
                    'Keterangan Lokasi',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: lokasiCtrl,
                    decoration: InputDecoration(
                      hintText: 'SMK Negeri 8 Malang',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final mulaiStr = _timeOfDayToDbString(jamMulai);
                final selesaiStr = _timeOfDayToDbString(jamSelesai);
                final terlambatStr = _timeOfDayToDbString(batasTerlambat);
                final lokasiVal = lokasiCtrl.text.trim().isNotEmpty ? lokasiCtrl.text.trim() : 'SMK Negeri 8 Malang';

                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                bool ok = false;
                if (isEdit) {
                  final id = existing['id_konfig'].toString();
                  ok = await _supa.updateAttendanceConfig(
                    id: id,
                    hari: selectedHari,
                    jamMulai: mulaiStr,
                    jamSelesai: selesaiStr,
                    batasTerlambat: terlambatStr,
                    lokasi: lokasiVal,
                  );
                } else {
                  ok = await _supa.createAttendanceConfig(
                    hari: selectedHari,
                    jamMulai: mulaiStr,
                    jamSelesai: selesaiStr,
                    batasTerlambat: terlambatStr,
                    lokasi: lokasiVal,
                  );
                }

                await _loadConfigs();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? (isEdit ? 'Konfigurasi absen berhasil diperbarui.' : 'Konfigurasi absen baru berhasil disimpan.')
                            : 'Gagal menyimpan konfigurasi. Silakan coba lagi.',
                      ),
                      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F4),
          border: Border.all(color: const Color(0xFFE8DFD8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  '$h:$m WIB',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: highlightColor ?? AppColors.ink,
                  ),
                ),
              ],
            ),
            const Icon(Icons.access_time_rounded, color: AppColors.maroon, size: 22),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 26),
            const SizedBox(width: 10),
            Text(
              'Hapus Konfigurasi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink),
            ),
          ],
        ),
        content: Text(
          'Hapus jadwal absensi "${item['hari']}"? Aturan waktu absensi ini tidak akan berlaku lagi.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _supa.deleteAttendanceConfig(item['id_konfig'].toString());
              await _loadConfigs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Konfigurasi berhasil dihapus.' : 'Gagal menghapus konfigurasi.'),
                    backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            GeoraHeader(
              title: 'Konfigurasi Absen',
              subtitle: 'Atur jam mulai, batas terlambat, dan jam selesai',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
                  : _configs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_rounded, size: 54, color: AppColors.maroon.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada konfigurasi absen.',
                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.muted),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddEditDialog(),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Tambah Konfigurasi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.maroon,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                          itemCount: _configs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final item = _configs[idx];
                            final hari = item['hari']?.toString() ?? 'Semua Hari';
                            final mulai = _formatTimeDisplay(item['jam_mulai']?.toString());
                            final terlambat = _formatTimeDisplay(item['batas_terlambat']?.toString());
                            final selesai = _formatTimeDisplay(item['jam_selesai']?.toString());
                            final lokasi = item['lokasi']?.toString() ?? 'SMK Negeri 8 Malang';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7EFE8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.calendar_month_rounded, color: AppColors.maroon, size: 20),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            hari,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppColors.muted, size: 20),
                                            onPressed: () => _showAddEditDialog(item),
                                            tooltip: 'Edit Konfigurasi',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                                            onPressed: () => _confirmDelete(item),
                                            tooltip: 'Hapus Konfigurasi',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF0E5DC)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTimeInfoBox(
                                          title: 'Mulai',
                                          time: mulai,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTimeInfoBox(
                                          title: 'Terlambat',
                                          time: terlambat,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTimeInfoBox(
                                          title: 'Selesai',
                                          time: selesai,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          lokasi,
                                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text('Atur Jam', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildTimeInfoBox({
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8DFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

