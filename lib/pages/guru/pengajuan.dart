import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class GuruSubmissionsTab extends StatefulWidget {
  const GuruSubmissionsTab({super.key});

  @override
  State<GuruSubmissionsTab> createState() => _GuruSubmissionsTabState();
}

class _GuruSubmissionsTabState extends State<GuruSubmissionsTab> {
  List<SubmissionItemModel> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService().getTeacherSubmissions();
      _submissions = list;
    } catch (_) {
      _submissions = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(SubmissionItemModel item, bool isApproved) async {
    final success = await SupabaseService().processSubmission(item.id, isApproved);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved
                ? 'Pengajuan ${item.name} berhasil disetujui'
                : 'Pengajuan ${item.name} telah ditolak',
          ),
          backgroundColor:
              isApproved ? Colors.green.shade800 : Colors.red.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
      _loadSubmissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses pengajuan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        const GeoraHeader(
          title: 'Pengajuan Siswa',
          subtitle: 'Periksa permohonan izin & sakit siswa',
          showBrandLogo: true,
        ),

        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                )
              : _submissions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 40,
                              color: AppColors.maroon,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tidak Ada Pengajuan',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada pengajuan izin atau sakit dari siswa.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSubmissions,
                      color: AppColors.maroon,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        itemCount: _submissions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _submissions[index];
                          final isDecided = item.status != 'Menunggu';

                          Color statusColor = const Color(0xFFB78103);
                          if (item.status == 'Disetujui') {
                            statusColor = Colors.green.shade700;
                          } else if (item.status == 'Ditolak') {
                            statusColor = Colors.red.shade700;
                          }

                          return Container(
                            padding: const EdgeInsets.all(20),
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
                                // Avatar & Info
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0E5DC),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.initials,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.maroon,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Nama siswa full width
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Baris kedua: tipe+tanggal di kiri, badge kelas di kanan
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.type} • ${item.date}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: AppColors.muted,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF7EFE8),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item.className,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.maroon,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Reason Container
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCFAF8),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFEFE8E1)),
                                  ),
                                  child: Text(
                                    item.reason.isNotEmpty ? item.reason : 'Tidak ada keterangan tertulis.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.ink.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Bukti Foto / Surat (jika ada)
                                if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppBar(
                                                title: Text(
                                                  'Bukti Surat / Foto: ${item.name}',
                                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                                                ),
                                                backgroundColor: AppColors.maroon,
                                                foregroundColor: Colors.white,
                                                automaticallyImplyLeading: false,
                                                actions: [
                                                  IconButton(
                                                    icon: const Icon(Icons.close_rounded),
                                                    onPressed: () => Navigator.pop(ctx),
                                                  ),
                                                ],
                                              ),
                                              Image.network(
                                                item.photoUrl!,
                                                fit: BoxFit.contain,
                                                loadingBuilder: (_, child, progress) {
                                                  if (progress == null) return child;
                                                  return const Padding(
                                                    padding: EdgeInsets.all(40),
                                                    child: CircularProgressIndicator(color: AppColors.maroon),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => const Padding(
                                                  padding: EdgeInsets.all(30),
                                                  child: Text('Gagal memuat gambar bukti.'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7EFE8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE8DFD8)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.image_outlined, color: AppColors.maroon, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Lihat Lampiran Bukti Surat/Foto',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.maroon,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Status Badge
                                Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    Text(
                                      item.status,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Action Buttons (Tolak / Setujui)
                                if (!isDecided) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _handleAction(item, false),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF8B1E1E),
                                          side: const BorderSide(color: Color(0xFF8B1E1E)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                        ),
                                        child: Text(
                                          'Tolak',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _handleAction(item, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.maroon,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 36,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          'Setujui',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Keputusan telah dicatat di database',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
