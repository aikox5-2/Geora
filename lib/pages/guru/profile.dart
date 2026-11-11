import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ganti_password.dart';

class GuruProfileTab extends StatefulWidget {
  const GuruProfileTab({super.key});

  @override
  State<GuruProfileTab> createState() => _GuruProfileTabState();
}

class _GuruProfileTabState extends State<GuruProfileTab> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _editField(String title, String currentValue, ValueChanged<String> onSaved) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Ubah $title',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.ink,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final val = controller.text.trim();
                onSaved(val);
                if (title == 'Nomor Telepon') {
                  _authService.updateProfile(phone: val);
                } else if (title == 'Email') {
                  _authService.updateProfile(email: val);
                } else if (title == 'Alamat') {
                  _authService.updateProfile(address: val);
                }
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title berhasil diperbarui'),
                    duration: const Duration(seconds: 2),
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
    );
  }

  /// Dialog Perbarui Data Diri Lengkap sesuai ERD
  void _showUpdateProfileDialog() {
    final user = _authService.currentUser;
    final nameCtrl = TextEditingController(text: (user != null && user.name.isNotEmpty) ? user.name : 'Yudi Guru, S.Pd');
    final emailCtrl = TextEditingController(text: (user != null && user.email.isNotEmpty) ? user.email : 'yudi@gmail.com');
    final phoneCtrl = TextEditingController(text: (user != null && user.phone != null && user.phone!.isNotEmpty) ? user.phone! : '+62 812-3456-7890');
    final addressCtrl = TextEditingController(text: (user != null && user.address != null && user.address!.isNotEmpty) ? user.address! : 'Jl. Pendidikan No. 10, Blitar');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                Icons.badge_outlined,
                color: AppColors.maroon,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Perbarui Data Diri',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
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
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email / Akun Guru',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alamat Domisili',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              _authService.updateProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data diri berhasil diperbarui'),
                  duration: Duration(seconds: 2),
                ),
              );
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
    );
  }

  void _showLogoutDialog() {
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
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Keluar dari Akun Guru?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Anda akan diarahkan kembali ke halaman login utama aplikasi GEORA.',
          style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final user = _authService.currentUser;
    final teacherName = (user != null && user.name.isNotEmpty) ? user.name : 'Yudi Guru, S.Pd';
    final initials = (user != null && user.avatarInitials.isNotEmpty) ? user.avatarInitials : 'YG';
    final nip = (user != null && user.aliases.isNotEmpty)
        ? user.aliases.first
        : '198503122010011005';
    final userEmail = (user != null && user.email.isNotEmpty) ? user.email : 'yudi@gmail.com';
    final userPhone = (user != null && user.phone != null && user.phone!.isNotEmpty) ? user.phone! : '+62 812-3456-7890';
    final userAddress = (user != null && user.address != null && user.address!.isNotEmpty) ? user.address! : 'Jl. Pendidikan No. 10, Blitar';
    final teacherInfo = (user != null && user.info != null && user.info!.isNotEmpty) ? user.info! : 'Wali Kelas XII RPL D';

    return Column(
      children: [
        // Top Maroon Header Section
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -45,
                  right: -35,
                  child: Container(
                    width: 175,
                    height: 175,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 20,
                    top: topPadding + 14,
                    bottom: 26,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Saya',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Data akun dan informasi guru',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.cream.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Profile Info Row inside Maroon Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E5DC),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.maroon,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacherName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Angka NIP langsung tanpa label
                                Text(
                                  nip,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.cream.withValues(alpha: 0.95),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    teacherInfo.split('•').first.trim(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onSelected: (val) {
                              if (val == 'logout') {
                                _showLogoutDialog();
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout_rounded,
                                        size: 20, color: AppColors.maroon),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Keluar Akun',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Informasi & Kontak Section
                Text(
                  'Informasi & Kontak',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE8DFD8),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildContactRow(
                        icon: Icons.phone_outlined,
                        label: 'Nomor Telepon',
                        value: userPhone,
                        onEdit: () => _editField(
                          'Nomor Telepon',
                          userPhone,
                          (v) => _authService.updateProfile(phone: v),
                        ),
                      ),
                      const Divider(height: 26, color: Color(0xFFEFE7DF)),
                      _buildContactRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email Akun Guru',
                        value: userEmail,
                        onEdit: () => _editField(
                          'Email',
                          userEmail,
                          (v) => _authService.updateProfile(email: v),
                        ),
                      ),
                      const Divider(height: 26, color: Color(0xFFEFE7DF)),
                      _buildContactRow(
                        icon: Icons.home_outlined,
                        label: 'Alamat',
                        value: userAddress,
                        onEdit: () => _editField(
                          'Alamat',
                          userAddress,
                          (v) => _authService.updateProfile(address: v),
                        ),
                      ),
                      const Divider(height: 26, color: Color(0xFFEFE7DF)),

                      // Tombol Perbarui Data Diri Lengkap di Container yang Sama
                      InkWell(
                        onTap: _showUpdateProfileDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF7EFE8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.maroon,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Perbarui Data Diri',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                    Text(
                                      'Ubah nama, email, nomor HP, dan alamat',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.maroon,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const ChangePasswordCard(),
                const SizedBox(height: 14),

                // Keluar Sesi Guru
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.shade100,
                      width: 1.2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showLogoutDialog,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Keluar Sesi Guru',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Kembali ke halaman login utama',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.red.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.ink),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF5EDE5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
