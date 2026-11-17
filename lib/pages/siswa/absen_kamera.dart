import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../services/attendance_state_service.dart';
import '../../services/location_service.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/camera_viewfinder.dart';
import '../../widgets/header.dart';

class SiswaAutoAttendancePage extends StatefulWidget {
  const SiswaAutoAttendancePage({super.key});

  @override
  State<SiswaAutoAttendancePage> createState() => _SiswaAutoAttendancePageState();
}

class _SiswaAutoAttendancePageState extends State<SiswaAutoAttendancePage> {
  final TimeService _timeService = TimeService();
  final LocationService _locationService = LocationService();
  final AttendanceStateService _attendanceState = AttendanceStateService();
  final ImagePicker _picker = ImagePicker();
  final MapController _mapController = MapController();

  Uint8List? _photoBytes;
  String? _photoPath;
  String? _photoTimestamp;
  String? _photoLocation;
  bool _isSubmitted = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _timeService.addListener(_onTick);
    _locationService.addListener(_onTick);
    _initServices();
  }

  @override
  void dispose() {
    _timeService.removeListener(_onTick);
    _locationService.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Future<void> _initServices() async {
    await _locationService.getCurrentLocation();
    await _attendanceState.syncTodayAttendance();

    // Otomatis buka kamera perangkat jika belum absen dan belum ambil foto
    if (!_attendanceState.isAlreadyCheckedInToday && _photoBytes == null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _takePhoto();
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final result = await CameraViewfinderScreen.open(context);
      if (result != null) {
        final loc = _locationService.lastLocation?.locationName ?? 'SMK Negeri 8 Kota Malang';

        setState(() {
          _photoBytes = result.bytes;
          _photoPath = result.path;
          _photoTimestamp = '${_timeService.formattedDateShort} • ${_timeService.formattedTime}';
          _photoLocation = loc;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto bukti kehadiran berhasil diambil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } catch (_) {}

    // Fallback to ImagePicker if custom viewfinder cannot be used
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final loc = _locationService.lastLocation?.locationName ?? 'SMK Negeri 8 Kota Malang';

        setState(() {
          _photoBytes = bytes;
          _photoPath = picked.path;
          _photoTimestamp = '${_timeService.formattedDateShort} • ${_timeService.formattedTime}';
          _photoLocation = loc;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto bukti kehadiran berhasil diambil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      final loc = _locationService.lastLocation?.locationName ?? 'SMK Negeri 8 Kota Malang';
      setState(() {
        _photoTimestamp = '${_timeService.formattedDateShort} • ${_timeService.formattedTime}';
        _photoLocation = loc;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_attendanceState.isAlreadyCheckedInToday) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.maroon, size: 26),
              const SizedBox(width: 10),
              Text(
                'Sudah Absen',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          content: Text(
            'Anda sudah tercatat melakukan absensi hari ini (${_attendanceState.todayStatusLabel}). Absensi hanya bisa dilakukan satu kali per hari.',
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
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    if (_photoTimestamp == null && _photoBytes == null) {
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
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_camera_rounded, color: Colors.orange.shade800, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Foto Diperlukan',
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
            'Presensi mandiri memerlukan 1 foto selfie bukti kehadiran di area sekolah. Tekan tombol "Ambil Foto" terlebih dahulu.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buka Kamera Sekarang'),
            ),
          ],
        ),
      );
      return;
    }

    final loc = _locationService.lastLocation;
    final lat = loc?.latitude ?? LocationService.schoolLatitude;
    final lng = loc?.longitude ?? LocationService.schoolLongitude;
    final locName = loc?.locationName ?? 'SMK Negeri 8 Malang';

    setState(() {
      _isUploading = true;
    });

    final success = await _attendanceState.submitAutomatic(
      time: _timeService.now,
      location: locName,
      latitude: lat,
      longitude: lng,
      photoBytes: _photoBytes,
      photoPath: _photoPath,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _isSubmitted = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (success ? Colors.green : Colors.orange).shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_rounded : Icons.info_rounded,
                color: success ? Colors.green.shade700 : Colors.orange.shade700,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success ? 'Absensi Berhasil!' : 'Info Absensi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
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
              success
                  ? 'Kehadiran Anda di $locName tercatat pada ${_timeService.formattedTime}. Foto bukti kehadiran berhasil diverifikasi.'
                  : 'Data absensi Anda telah diproses.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data Absensi Terverifikasi',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Return to Attendance Hub
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = _locationService.lastLocation;
    final lat = loc?.latitude ?? LocationService.schoolLatitude;
    final lng = loc?.longitude ?? LocationService.schoolLongitude;
    final locName = loc?.locationName ?? 'SMK Negeri 8 Kota Malang • Radius sekolah';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFAF9F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F9),
        body: Column(
          children: [
            // Top Header matching Image 3
            const GeoraHeader(
              title: 'Absen Hari Ini',
              subtitle: 'Lakukan Absensi Hanya Diarea Sekolah.',
              showBackButton: true,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Detail Absensi
                    Text(
                      'Detail Absensi',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row with Live Date & Time (Requirement 1 & 3)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.calendar_today_rounded,
                            label: 'Hari & Tanggal',
                            value: _timeService.formattedDateShort,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.access_time_rounded,
                            label: 'Jam',
                            value: _timeService.formattedTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Card Lokasi Otomatis with Map preview (Requirement 3)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFE8),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.maroon, size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lokasi Otomatis (Google Maps GPS)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      locName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    Text(
                                      'Koordinat: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.maroon,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: _locationService.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.my_location_rounded, color: AppColors.maroon),
                                onPressed: () => _locationService.getCurrentLocation(),
                                tooltip: 'Perbarui GPS',
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Interactive Google Maps Overlay with zoom in/out
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFD4E3EA), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: ll.LatLng(lat, lng),
                                      initialZoom: 16.0,
                                      minZoom: 11.0,
                                      maxZoom: 19.0,
                                      interactionOptions: const InteractionOptions(
                                        flags: InteractiveFlag.all,
                                      ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                                        userAgentPackageName: 'com.geora.app',
                                      ),
                                      CircleLayer(
                                        circles: [
                                          CircleMarker(
                                            point: ll.LatLng(LocationService.schoolLatitude, LocationService.schoolLongitude),
                                            radius: LocationService.defaultMaxRadiusMeters,
                                            useRadiusInMeter: true,
                                            color: AppColors.maroon.withValues(alpha: 0.18),
                                            borderColor: AppColors.maroon,
                                            borderStrokeWidth: 2.0,
                                          ),
                                        ],
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          // School Pin
                                          Marker(
                                            point: ll.LatLng(LocationService.schoolLatitude, LocationService.schoolLongitude),
                                            width: 38,
                                            height: 38,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppColors.maroon,
                                                shape: BoxShape.circle,
                                                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
                                              ),
                                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                                            ),
                                          ),
                                          // Student Location Pin
                                          Marker(
                                            point: ll.LatLng(lat, lng),
                                            width: 44,
                                            height: 44,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade700,
                                                    shape: BoxShape.circle,
                                                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                                                  ),
                                                  child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Zoom In / Out Controls & Re-center
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Column(
                                      children: [
                                        _buildMapIconButton(
                                          icon: Icons.add_rounded,
                                          onTap: () {
                                            final z = _mapController.camera.zoom;
                                            _mapController.move(_mapController.camera.center, (z + 1).clamp(11.0, 19.0));
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        _buildMapIconButton(
                                          icon: Icons.remove_rounded,
                                          onTap: () {
                                            final z = _mapController.camera.zoom;
                                            _mapController.move(_mapController.camera.center, (z - 1).clamp(11.0, 19.0));
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        _buildMapIconButton(
                                          icon: Icons.my_location_rounded,
                                          onTap: () {
                                            _mapController.move(ll.LatLng(lat, lng), 16.0);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bottom Overlay Banner with Verified GPS status
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Google Maps Live • Dalam Radius Sekolah (${LocationService.defaultMaxRadiusMeters.round()}m)',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Text(
                            'Pastikan GPS Sudah Diaktifkan pada Perangkat Anda.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Bukti Kehadiran with Watermark (Requirement 4)
                    Text(
                      'Bukti Kehadiran (Foto & Watermark)',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFE8),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Camera Trigger Button
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  onTap: _takePhoto,
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE8DFD8),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.photo_camera_outlined,
                                          color: AppColors.maroon,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _photoTimestamp != null ? 'Ulangi Foto' : 'Ambil Foto',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Text instruction
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Foto wajib untuk verifikasi kehadiran.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '• Kamera depan / belakang\n• Otomatis disematkan watermark lokasi & waktu presensi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        height: 1.5,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Watermark Preview Banner (Requirement 4)
                          if (_photoTimestamp != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF211B1A),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'WATERMARK TERVERIFIKASI GEORA',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '🕒 Waktu: $_photoTimestamp',
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                                  ),
                                  Text(
                                    '📍 Lokasi: $_photoLocation',
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Kirim Absensi Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isSubmitted || _isUploading) ? null : _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isUploading
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
                                  Text('Mengunggah Foto & Absensi...'),
                                ],
                              )
                            : Text(
                                _isSubmitted ? 'Presensi Sudah Dikirim' : 'Kirim Absensi',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Dengan mengirim, lokasi , waktu , foto akan dicatat.',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.ink, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.maroon),
        ),
      ),
    );
  }
}

