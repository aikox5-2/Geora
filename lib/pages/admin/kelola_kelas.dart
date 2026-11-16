import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/model_akun.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';

class ManageKelasPage extends StatefulWidget {
  const ManageKelasPage({super.key});

  @override
  State<ManageKelasPage> createState() => _ManageKelasPageState();
}

class _ManageKelasPageState extends State<ManageKelasPage> {
  final SupabaseService _supa = SupabaseService();
  List<Map<String, dynamic>> _classes = [];
  List<TeacherAccount> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cList = await _supa.getClassesDetailed();
      final tList = await _supa.getTeachers();
      _classes = cList;
      _teachers = tList;
    } catch (_) {
      _classes = [];
      _teachers = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditClassDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    String selectedTingkat = existing?['tingkat']?.toString() ?? 'XII';
    final jurusanCtrl = TextEditingController(text: existing?['jurusan']?.toString() ?? '');
    String? selectedGuruId = existing?['guruId']?.toString();

    // Verify selectedGuruId is in list of teachers
    if (selectedGuruId != null && !_teachers.any((t) => t.id == selectedGuruId)) {
      selectedGuruId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                Icon(
                  isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                  color: AppColors.maroon,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'Ubah Data Kelas' : 'Tambah Kelas Baru',
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
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
                    // Tingkat Dropdown
                    Text('Tingkat / Jenjang', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE8DFD8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTingkat,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'X', child: Text('Kelas X')),
                            DropdownMenuItem(value: 'XI', child: Text('Kelas XI')),
                            DropdownMenuItem(value: 'XII', child: Text('Kelas XII')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedTingkat = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Jurusan / Nama Kelas
                    Text('Jurusan & Rombel', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: jurusanCtrl,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Rekayasa Perangkat Lunak D',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Wali Kelas Dropdown
                    Text('Wali Kelas (Guru)', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE8DFD8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedGuruId,
                          isExpanded: true,
                          hint: const Text('Pilih Guru Wali Kelas'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('— Belum Ditentukan —'),
                            ),
                            ..._teachers.map((g) => DropdownMenuItem<String?>(
                                  value: g.id,
                                  child: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (val) {
                            setDialogState(() => selectedGuruId = val);
                          },
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
                onPressed: () async {
                  final jur = jurusanCtrl.text.trim();
                  if (jur.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jurusan / Rombel wajib diisi')),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  bool ok;
                  if (isEdit) {
                    ok = await _supa.updateClass(
                      id: existing['id'].toString(),
                      tingkat: selectedTingkat,
                      jurusan: jur,
                      guruId: selectedGuruId,
                    );
                  } else {
                    ok = await _supa.createClass(
                      tingkat: selectedTingkat,
                      jurusan: jur,
                      guruId: selectedGuruId,
                    );
                  }

                  if (ok) {
                    _loadData();
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Kelas berhasil diperbarui' : 'Kelas baru berhasil dibuat'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Simpan' : 'Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteClass(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Hapus Kelas?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelas "${c['className']}"? Siswa di kelas ini akan dilepas dari rombel.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final ok = await _supa.deleteClass(c['id'].toString());
              if (ok) {
                _loadData();
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Kelas berhasil dihapus.'), backgroundColor: Colors.red),
                  );
                }
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

  void _manageClassMembers(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _ClassMembersSheet(
        classInfo: c,
        onChanged: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFAF9F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Kelola Data Kelas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.maroon, size: 26),
              tooltip: 'Tambah Kelas',
              onPressed: () => _showAddEditClassDialog(),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
            : _classes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 50, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada data kelas.',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditClassDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Kelas Pertama'),
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    itemCount: _classes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _classes[index];
                      final className = item['className'] ?? '';
                      final waliKelas = item['waliKelas'] ?? 'Belum Ditentukan';
                      final total = item['totalSiswa'] ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.maroon,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item['tingkat'] ?? 'XII',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    className,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
                                  onPressed: () => _showAddEditClassDialog(item),
                                  tooltip: 'Ubah Kelas',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                  onPressed: () => _confirmDeleteClass(item),
                                  tooltip: 'Hapus Kelas',
                                ),
                              ],
                            ),

                            const Divider(height: 20),

                            // Wali Kelas Info
                            Row(
                              children: [
                                const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.muted),
                                const SizedBox(width: 8),
                                Text(
                                  'Wali Kelas: ',
                                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
                                ),
                                Expanded(
                                  child: Text(
                                    waliKelas,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Bottom Row: Members count & Manage members button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7EFE8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$total Anggota Siswa',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _manageClassMembers(item),
                                  icon: const Icon(Icons.people_alt_outlined, size: 16),
                                  label: const Text('Anggota Kelas'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.maroon,
                                    side: const BorderSide(color: AppColors.maroon),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}

class _ClassMembersSheet extends StatefulWidget {
  final Map<String, dynamic> classInfo;
  final VoidCallback onChanged;

  const _ClassMembersSheet({
    required this.classInfo,
    required this.onChanged,
  });

  @override
  State<_ClassMembersSheet> createState() => _ClassMembersSheetState();
}

class _ClassMembersSheetState extends State<_ClassMembersSheet> {
  final SupabaseService _supa = SupabaseService();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supa.getClassStudents(widget.classInfo['id'].toString());
      _members = list;
    } catch (_) {
      _members = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddStudentDialog() async {
    final available = await _supa.getAvailableStudents();
    if (!mounted) return;

    final unassigned = available.where((s) => s['kelas_id'] != widget.classInfo['id']).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Tambah Siswa ke Kelas',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: unassigned.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada siswa lain yang tersedia.',
                    style: GoogleFonts.poppins(color: AppColors.muted),
                  ),
                )
              : ListView.separated(
                  itemCount: unassigned.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = unassigned[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s['nama_siswa']?.toString() ?? '',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'NISN: ${s['nisn'] ?? '-'}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _supa.assignStudentToClass(
                            s['id_siswa'].toString(),
                            widget.classInfo['id'].toString(),
                          );
                          _loadMembers();
                          widget.onChanged();
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggota ${widget.classInfo['className']}',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Total ${_members.length} Siswa Terdaftar',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.maroon, size: 24),
                tooltip: 'Tambah Siswa',
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
                : _members.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada siswa di kelas ini.',
                          style: GoogleFonts.poppins(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _members.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final student = _members[i];
                          final name = student['nama_siswa']?.toString() ?? '';
                          final nisn = student['nisn']?.toString() ?? '-';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F1EB),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.maroon,
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      Text(
                                        'NISN: $nisn',
                                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                  tooltip: 'Keluarkan dari Kelas',
                                  onPressed: () async {
                                    await _supa.removeStudentFromClass(student['id_siswa'].toString());
                                    _loadMembers();
                                    widget.onChanged();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
