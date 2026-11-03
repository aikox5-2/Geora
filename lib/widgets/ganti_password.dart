import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class ChangePasswordCard extends StatelessWidget {
  final VoidCallback? onSuccess;

  const ChangePasswordCard({
    super.key,
    this.onSuccess,
  });

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EFE8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.maroon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Change Password',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan kata sandi saat ini dan tentukan kata sandi baru Anda.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 16),

                // Old Password
                _buildPassField(
                  label: 'Password Lama',
                  controller: oldPassController,
                  obscure: obscureOld,
                  onToggle: () {
                    setModalState(() {
                      obscureOld = !obscureOld;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // New Password
                _buildPassField(
                  label: 'Password Baru',
                  controller: newPassController,
                  obscure: obscureNew,
                  onToggle: () {
                    setModalState(() {
                      obscureNew = !obscureNew;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Confirm Password
                _buildPassField(
                  label: 'Konfirmasi Password Baru',
                  controller: confirmPassController,
                  obscure: obscureConfirm,
                  onToggle: () {
                    setModalState(() {
                      obscureConfirm = !obscureConfirm;
                    });
                  },
                ),
              ],
            ),
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
            ElevatedButton(
              onPressed: () {
                final oldP = oldPassController.text.trim();
                final newP = newPassController.text.trim();
                final confP = confirmPassController.text.trim();

                // Validations with Alert Dialogs
                if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
                  _showCustomAlert(
                    ctx,
                    title: 'Peringatan',
                    message: 'Semua kolom kata sandi wajib diisi.',
                    isSuccess: false,
                  );
                  return;
                }

                if (newP.length < 4) {
                  _showCustomAlert(
                    ctx,
                    title: 'Kata Sandi Terlalu Pendek',
                    message: 'Kata sandi baru minimal terdiri dari 4 karakter.',
                    isSuccess: false,
                  );
                  return;
                }

                if (newP != confP) {
                  _showCustomAlert(
                    ctx,
                    title: 'Konfirmasi Tidak Cocok',
                    message: 'Konfirmasi kata sandi tidak cocok dengan kata sandi baru.',
                    isSuccess: false,
                  );
                  return;
                }

                final success = AuthService().updatePassword(oldP, newP);
                if (!success) {
                  _showCustomAlert(
                    ctx,
                    title: 'Kata Sandi Lama Salah',
                    message: 'Kata sandi lama yang Anda masukkan tidak sesuai akun ini.',
                    isSuccess: false,
                  );
                  return;
                }

                // Success
                Navigator.pop(ctx);
                _showCustomAlert(
                  context,
                  title: 'Berhasil Diperbarui!',
                  message: 'Kata sandi akun Anda telah berhasil diperbarui.',
                  isSuccess: true,
                );
                onSuccess?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAlert(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
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
          message,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.ink.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green.shade700 : AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.muted),
        filled: true,
        fillColor: const Color(0xFFFCFAF8),
        isDense: true,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: AppColors.muted,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5DDD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exact layout matching Gambar 2
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showChangePasswordDialog(context),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          child: Row(
            children: [
              // Lock Icon matching Gambar 2
              const Icon(
                Icons.lock_outline_rounded,
                size: 24,
                color: AppColors.maroon,
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perbarui kata sandi akun',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              // Maroon Chevron Right matching Gambar 2
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.maroon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

