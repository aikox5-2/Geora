import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class DutyTeacher {
  final String name;
  final String shift;
  final String phone;
  final String cleanPhone;

  const DutyTeacher({
    required this.name,
    required this.shift,
    required this.phone,
    required this.cleanPhone,
  });
}

class GuruPiketSection extends StatelessWidget {
  final bool showHeader;

  const GuruPiketSection({
    super.key,
    this.showHeader = true,
  });

  static const List<DutyTeacher> dutyTeachers = [
    DutyTeacher(
      name: 'Budi Santoso',
      shift: '07:00–10:00',
      phone: '0812 3456 7890',
      cleanPhone: '6281234567890',
    ),
    DutyTeacher(
      name: 'Siti Rahma',
      shift: '10:00–13:00',
      phone: '0813 4567 8901',
      cleanPhone: '6281345678901',
    ),
    DutyTeacher(
      name: 'Deni Pratama',
      shift: '13:00–16:00',
      phone: '0814 5678 9012',
      cleanPhone: '6281456789012',
    ),
  ];

  static Future<void> openWhatsApp(BuildContext context, DutyTeacher teacher) async {
    final message = Uri.encodeComponent(
      'Halo Bapak/Ibu ${teacher.name}, saya siswa SMK Negeri 8 Malang ingin menanyakan informasi terkait absensi GEORA.',
    );
    final url = Uri.parse('https://wa.me/${teacher.cleanPhone}?text=$message');

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showContactDialog(context, teacher);
      }
    } catch (_) {
      if (context.mounted) {
        _showContactDialog(context, teacher);
      }
    }
  }

  static void _showContactDialog(BuildContext context, DutyTeacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_rounded, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kontak Guru Piket',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teacher.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jadwal Piket: ${teacher.shift}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
            ),
            Text(
              'Nomor WhatsApp: ${teacher.phone}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Guru / Karyawan Bertugas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Petugas yang sedang piket dapat menyetujui pengajuan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 14),
        ],
        ...dutyTeachers.map((teacher) => _buildTeacherCard(context, teacher)),
      ],
    );
  }

  Widget _buildTeacherCard(BuildContext context, DutyTeacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${teacher.shift} • ${teacher.phone}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => openWhatsApp(context, teacher),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'WhatsApp',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B0000), // Dark maroon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

