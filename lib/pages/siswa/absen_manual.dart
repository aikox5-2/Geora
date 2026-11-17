import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/attendance_state_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/camera_viewfinder.dart';
import '../../widgets/guru_piket.dart';

class ManualProofFile {
  final String? url;
  final Uint8List? bytes;
  final String name;

  ManualProofFile({
    this.url,
    this.bytes,
    required this.name,
  });

  bool get isNetwork => url != null && url!.isNotEmpty;
}

class AbsenManualPage extends StatefulWidget {
  const AbsenManualPage({super.key});

  @override
  State<AbsenManualPage> createState() => _AbsenManualPageState();
}

class _AbsenManualPageState extends State<AbsenManualPage> {
  final AttendanceStateService _stateService = AttendanceStateService();
  final TimeService _timeService = TimeService();
  final ImagePicker _picker = ImagePicker();

  String _selectedType = 'Izin';
  final TextEditingController _reasonController = TextEditingController();
  final List<ManualProofFile> _proofFiles = [];
  bool _isSubmitting = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _stateService.addListener(_onStateChanged);
    _syncLatestStatus();
  }

  Future<void> _syncLatestStatus() async {
    await _stateService.syncTodayAttendance();
  }

  @override
  void dispose() {
    _stateService.removeListener(_onStateChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickProof(ImageSource source) async {
    if (_proofFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal lampiran 3 berkas bukti.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        // Can pick multiple images from gallery
        final pickedList = await _picker.pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );

        if (pickedList.isNotEmpty) {
          int availableSlots = 3 - _proofFiles.length;
          for (int i = 0; i < pickedList.length && i < availableSlots; i++) {
            final file = pickedList[i];
            final bytes = await file.readAsBytes();
            setState(() {
              _proofFiles.add(ManualProofFile(
                bytes: bytes,
                name: file.name,
              ));
            });
          }
        }
      } else {
        // Camera source: langsung buka in-app camera viewfinder seperti absen kamera
        final capture = await CameraViewfinderScreen.open(context);
        if (capture != null && mounted) {
          setState(() {
            _proofFiles.add(ManualProofFile(
              bytes: capture.bytes,
              name: 'bukti_kamera_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  void _removeProofFile(int index) {
    if (index >= 0 && index < _proofFiles.length) {
      setState(() {
        _proofFiles.removeAt(index);
      });
    }
  }

  void _startEditing(ManualSubmission submission) {
    setState(() {
      _isEditing = true;
      _selectedType = submission.type;
      _reasonController.text = submission.reason;
      _proofFiles.clear();
      for (final url in submission.fileUrls) {
        if (url.trim().isNotEmpty) {
          final uri = Uri.tryParse(url);
          final rawName = uri != null && uri.pathSegments.isNotEmpty
              ? uri.pathSegments.last
              : 'surat_bukti.jpg';
          _proofFiles.add(ManualProofFile(url: url, name: rawName));
        }
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _proofFiles.clear();
      _reasonController.clear();
    });
  }

  void _submitManualAttendance() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
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
                child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Alasan Diperlukan',
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
            'Silakan tuliskan alasan izin atau sakit secara jelas sebelum mengirimkan formulir ke guru piket.',
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
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    if (_isEditing) {
      final existingUrls = _proofFiles
          .where((f) => f.isNetwork && f.url != null)
          .map((f) => f.url!)
          .toList();

      final newFiles = _proofFiles.where((f) => !f.isNetwork && f.bytes != null).toList();
      final newBytes = newFiles.map((f) => f.bytes!).toList();
      final newNames = newFiles.map((f) => f.name).toList();

      final ok = await _stateService.updateManual(
        type: _selectedType,
        reason: reason,
        existingUrls: existingUrls,
        newFileBytesList: newBytes,
        newFileNamesList: newNames,
      );

      setState(() {
        _isSubmitting = false;
        if (ok) _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Pengajuan absensi berhasil diperbarui.'
                : 'Pengajuan sudah disetujui dan tidak dapat diubah lagi.'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
      return;
    }

    // New submission mode
    final newBytes = _proofFiles.where((f) => f.bytes != null).map((f) => f.bytes!).toList();
    final newNames = _proofFiles.where((f) => f.bytes != null).map((f) => f.name).toList();

    await _stateService.submitManual(
      type: _selectedType,
      reason: reason,
      fileBytesList: newBytes,
      fileNamesList: newNames,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

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
              child: Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pengajuan Terkirim!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Permohonan $_selectedType beserta berkas bukti telah dikirimkan ke guru piket dan tersimpan di sistem.',
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

  void _confirmCancelSubmission() {
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
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Batalkan Pengajuan?',
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
          'Apakah Anda yakin ingin membatalkan pengajuan absensi manual hari ini? Anda dapat mengisi formulir kembali setelahnya.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              _stateService.cancelManualSubmission();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengajuan absensi dibatalkan.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showImagePreviewDialog(String? url, Uint8List? bytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: bytes != null
                  ? Image.memory(bytes, fit: BoxFit.contain)
                  : (url != null && url.isNotEmpty
                      ? Image.network(url, fit: BoxFit.contain)
                      : const SizedBox()),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submission = _stateService.todayManualSubmission;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFAF9F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F9),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                      onPressed: () {
                        if (_isEditing) {
                          _cancelEditing();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _isEditing ? 'Edit Absen Manual' : 'Absen Manual',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    _isEditing
                        ? 'Perbarui jenis izin, alasan, atau kelola berkas bukti'
                        : 'Ajukan absensi jika lokasi tidak dapat digunakan',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // If already submitted and NOT currently editing: Show Status Card
                if (submission != null && !_isEditing) ...[
                  _buildSubmittedStatusCard(submission),
                  const SizedBox(height: 24),
                ] else ...[
                  // Show Submission Form (Creation or Full Edit Mode)
                  _buildSubmissionForm(isEdit: _isEditing),
                  const SizedBox(height: 28),
                ],

                // Always display Guru / Karyawan Bertugas List with WhatsApp buttons
                const GuruPiketSection(showHeader: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Active Submission Status View matching database state
  Widget _buildSubmittedStatusCard(ManualSubmission submission) {
    final isApproved = submission.status.toLowerCase() == 'disetujui';
    final isIzin = submission.type.toLowerCase() == 'izin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isApproved
              ? Colors.green.shade300
              : (isIzin ? Colors.blue.shade100 : Colors.orange.shade100),
          width: 1.5,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isIzin ? Colors.blue.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      submission.type,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isIzin ? Colors.blue.shade800 : Colors.orange.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isApproved) ...[
                          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isApproved ? 'Disetujui' : submission.status,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isApproved ? Colors.green.shade800 : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isApproved)
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: AppColors.maroon, size: 24),
                  onPressed: () => _startEditing(submission),
                  tooltip: 'Edit Pengajuan',
                ),
            ],
          ),
          const SizedBox(height: 14),

          // User Requirement 5: Title changes when approved: "Izin absensi disetujui"
          Text(
            isApproved
                ? '${submission.type} absensi disetujui'
                : 'Pengajuan Berhasil Dicatat',
            style: GoogleFonts.poppins(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: isApproved ? const Color(0xFF2E7D32) : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isApproved
                ? 'Pengajuan absensi Anda telah disetujui oleh guru piket.'
                : '${_timeService.formattedDate} • ${_timeService.formattedTime}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),

          // Alasan Pengajuan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alasan Pengajuan:',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  submission.reason,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Lampiran Bukti
          if (submission.fileUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Berkas Bukti (${submission.fileUrls.length} file):',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: submission.fileUrls.map((url) {
                return InkWell(
                  onTap: () => _showImagePreviewDialog(url, null),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5DDD5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 16, color: AppColors.maroon),
                        const SizedBox(width: 4),
                        Text(
                          'Lihat Bukti',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // If NOT approved yet: Show action buttons (Edit & Cancel)
          // If APPROVED: Hide edit & cancel buttons!
          if (!isApproved) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startEditing(submission),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Pengajuan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.maroon,
                      side: const BorderSide(color: AppColors.maroon),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _confirmCancelSubmission,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: 'Batalkan Pengajuan',
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Presensi telah tercatat sebagai ${submission.type}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Submission Form View (Used for both Create and Full Edit)
  Widget _buildSubmissionForm({required bool isEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEdit) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: Colors.amber.shade900),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anda sedang mengubah formulir pengajuan absensi manual.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Dropdown Jenis Absen
        Text(
          'Jenis Absen',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.ink),
              items: const [
                DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Textarea Alasan
        Text(
          'Alasan',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD8)),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Tulis alasan pengajuan...',
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Upload Bukti Surat / Foto (Max 3 files)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Bukti Surat / Foto',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            Text(
              'Max 3 Berkas (${_proofFiles.length}/3)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _proofFiles.length >= 3 ? Colors.green.shade700 : AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // List of attached files
        if (_proofFiles.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _proofFiles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final file = _proofFiles[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0D8D0)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _showImagePreviewDialog(file.url, file.bytes),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: file.bytes != null
                            ? Image.memory(
                                file.bytes!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              )
                            : (file.url != null && file.url!.isNotEmpty
                                ? Image.network(
                                    file.url!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 44,
                                      height: 44,
                                      color: const Color(0xFFF0E5DC),
                                      child: const Icon(Icons.description_rounded,
                                          color: AppColors.maroon, size: 22),
                                    ),
                                  )
                                : Container(
                                    width: 44,
                                    height: 44,
                                    color: const Color(0xFFF0E5DC),
                                    child: const Icon(Icons.description_rounded,
                                        color: AppColors.maroon, size: 22),
                                  )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            file.isNetwork ? 'Berkas tersimpan di cloud' : 'Berkas baru siap diunggah',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: file.isNetwork ? Colors.blue.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      tooltip: 'Hapus Berkas',
                      onPressed: () => _removeProofFile(index),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],

        // Pick buttons if slots available
        if (_proofFiles.length < 3) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DFD8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickProof(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_rounded, size: 18),
                    label: const Text('Kamera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.maroon,
                      side: const BorderSide(color: AppColors.maroon),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickProof(ImageSource.gallery),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Pilih Berkas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: Color(0xFFE8DFD8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action Buttons
        if (isEdit) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: Color(0xFFE8DFD8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitManualAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitManualAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Mengirim & Mengunggah...'),
                      ],
                    )
                  : Text(
                      'Kirim Pengajuan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
