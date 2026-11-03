import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class SubmissionItem {
  final String id;
  final String initials;
  final String name;
  final String typeAndDate;
  final String reason;
  String status;
  Color statusColor;

  SubmissionItem({
    required this.id,
    required this.initials,
    required this.name,
    required this.typeAndDate,
    required this.reason,
    this.status = 'Status: Menunggu',
    this.statusColor = const Color(0xFFB78103),
  });
}

class GuruSubmissionsTab extends StatefulWidget {
  const GuruSubmissionsTab({super.key});

  @override
  State<GuruSubmissionsTab> createState() => _GuruSubmissionsTabState();
}

class _GuruSubmissionsTabState extends State<GuruSubmissionsTab> {
  final List<SubmissionItem> _submissions = [
    SubmissionItem(
      id: 'sub_1',
      initials: 'AP',
      name: 'Alya Putri',
      typeAndDate: 'Izin • 16 Sep 2026',
      reason: 'Keperluan keluarga.',
    ),
    SubmissionItem(
      id: 'sub_2',
      initials: 'FA',
      name: 'Fajar Adi',
      typeAndDate: 'Sakit • 16 Sep 2026',
      reason: 'Tidak dapat mengikuti pembelajaran.',
    ),
  ];

  void _handleAction(SubmissionItem item, bool isApproved) {
    setState(() {
      if (isApproved) {
        item.status = 'Status: Disetujui';
        item.statusColor = Colors.green.shade700;
      } else {
        item.status = 'Status: Ditolak';
        item.statusColor = Colors.red.shade700;
      }
    });

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header matching Image 5
        const GeoraHeader(
          title: 'Pengajuan Siswa XII RPL D',
          subtitle: 'Periksa izin dan sakit',
          showBrandLogo: true,
        ),

        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            itemCount: _submissions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = _submissions[index];
              final isDecided = item.status != 'Status: Menunggu';

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
                      children: [
                        Container(
                          width: 54,
                          height: 54,
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
                              Text(
                                item.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.typeAndDate,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Reason Text
                    Text(
                      item.reason,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.ink.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Status Text
                    Text(
                      item.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: item.statusColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Action Buttons (Tolak / Setujui)
                    if (!isDecided) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _handleAction(item, false),
                            child: Text(
                              'Tolak',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8B1E1E),
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
                                horizontal: 48,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Setujui',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
                          'Keputusan telah dicatat',
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
      ],
    );
  }
}

