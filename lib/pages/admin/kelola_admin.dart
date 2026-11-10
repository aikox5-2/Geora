import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/dummy_data_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import '../../widgets/kolom_cari.dart';

class ManageAdminsPage extends StatefulWidget {
  const ManageAdminsPage({super.key});

  @override
  State<ManageAdminsPage> createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final DummyDataService _dataService = DummyDataService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<AdminAccount> get _filteredAdmins {
    if (_searchQuery.isEmpty) return _dataService.admins;
    final q = _searchQuery.toLowerCase();
    return _dataService.admins
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            a.adminId.toLowerCase().contains(q) ||
            (a.email?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _showFeedbackDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
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
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
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
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(String adminId, String adminName) {
    final newPassCtrl = TextEditingController(text: 'Password123');
    bool obscure = true;

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
                  Icons.lock_reset_rounded,
                  color: AppColors.maroon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reset Password Admin',
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
                'Tentukan password baru untuk admin "$adminName":',
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newPassCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () {
                final pass = newPassCtrl.text.trim();
                if (pass.isEmpty) return;
                _dataService.resetPassword(adminId, pass);
                Navigator.pop(ctx);
                _showFeedbackDialog(
                  title: 'Password Berhasil Direset',
                  message: 'Password akun admin "$adminName" berhasil direset.',
                  isSuccess: true,
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
      ),
    );
  }

  void _showAddAdminDialog() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Tambah Akun Admin',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            color: AppColors.ink,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.maroon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Password awal: Password123 • Role: Admin',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username (Email)*',
                    hintText: 'Contoh: admin2@gmail.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap Admin*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
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
              if (nameCtrl.text.trim().isEmpty) {
                _showFeedbackDialog(
                  title: 'Data Belum Lengkap',
                  message: 'Harap masukkan nama admin terlebih dahulu.',
                  isSuccess: false,
                );
                return;
              }
              final newAdmin = AdminAccount(
                id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                roleTitle: 'Administrator',
                adminId: 'ADM-00${_dataService.admins.length + 1}',
                username: usernameCtrl.text.trim().isNotEmpty
                    ? usernameCtrl.text.trim()
                    : '${nameCtrl.text.trim().toLowerCase().replaceAll(' ', '')}@gmail.com',
                email: usernameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                status: 'aktif',
              );
              _dataService.addAdmin(newAdmin, password: 'Password123');
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Admin Berhasil Ditambahkan',
                message: 'Akun admin "${newAdmin.name}" berhasil didaftarkan.',
                isSuccess: true,
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

  void _showEditAdminDialog(AdminAccount admin) {
    final nameCtrl = TextEditingController(text: admin.name);
    final phoneCtrl = TextEditingController(text: admin.phone ?? '');
    final addressCtrl = TextEditingController(text: admin.address ?? '');
    String currentStatus = admin.currentStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Edit Akun Admin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
              color: AppColors.ink,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // STATUS (Muncul saat edit)
                  Text(
                    'Status Akun Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: currentStatus,
                        items: const [
                          DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                          DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => currentStatus = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // RESET PASSWORD BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showResetPasswordDialog(admin.id, admin.name);
                      },
                      icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon, size: 20),
                      label: Text(
                        'Reset Password Admin',
                        style: GoogleFonts.poppins(
                          color: AppColors.maroon,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.maroon),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
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
                if (nameCtrl.text.trim().isEmpty) {
                  _showFeedbackDialog(
                    title: 'Data Belum Lengkap',
                    message: 'Harap masukkan nama admin terlebih dahulu.',
                    isSuccess: false,
                  );
                  return;
                }
                _dataService.updateAdmin(
                  admin.id,
                  nameCtrl.text.trim(),
                  'Administrator',
                  admin.adminId,
                  status: currentStatus,
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                _showFeedbackDialog(
                  title: 'Data Diperbarui',
                  message: 'Data admin "${nameCtrl.text.trim()}" berhasil disimpan.',
                  isSuccess: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAdminDialog(AdminAccount admin) {
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
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hapus Akun Admin',
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
          'Hapus data akun admin "${admin.name}"? Hak akses administrator pengguna ini akan dicabut.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.deleteAdmin(admin.id);
              Navigator.pop(ctx);
              _showFeedbackDialog(
                title: 'Berhasil Dihapus',
                message: 'Akun admin "${admin.name}" telah dihapus dari sistem.',
                isSuccess: true,
              );
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
    final list = _filteredAdmins;

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
              title: 'Kelola Akun Admin',
              subtitle: 'Kelola data administrator sistem',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: GeoraSearchBar(
                hintText: 'Cari nama / email admin...',
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Belum ada data admin.'
                            : 'Tidak ada admin yang cocok.',
                        style: GoogleFonts.poppins(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final admin = list[idx];
                        return _buildAdminCard(admin);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddAdminDialog,
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildAdminCard(AdminAccount admin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF7EFE8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              admin.initials,
              style: GoogleFonts.poppins(
                fontSize: 15,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        admin.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (admin.status == 'nonaktif')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Nonaktif',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${admin.roleTitle} • ${admin.adminId}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.muted, size: 20),
            onPressed: () => _showEditAdminDialog(admin),
            tooltip: 'Edit Admin',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
            onPressed: () => _showDeleteAdminDialog(admin),
            tooltip: 'Hapus Admin',
          ),
        ],
      ),
    );
  }
}
