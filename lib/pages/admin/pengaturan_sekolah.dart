import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../services/location_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';

class SchoolRadiusSettingsPage extends StatefulWidget {
  const SchoolRadiusSettingsPage({super.key});

  @override
  State<SchoolRadiusSettingsPage> createState() => _SchoolRadiusSettingsPageState();
}

class _SchoolRadiusSettingsPageState extends State<SchoolRadiusSettingsPage> {
  final SupabaseService _supa = SupabaseService();
  final MapController _mapController = MapController();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();

  double _radiusMeters = LocationService.defaultMaxRadiusMeters;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGettingGps = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final config = await _supa.getSchoolSettings();
      _nameCtrl.text = config['name']?.toString() ?? 'SMK Negeri 8 Malang';
      _addressCtrl.text = config['address']?.toString() ?? 'Jl. Teluk Pacitan, Malang';
      final lat = (config['latitude'] as num?)?.toDouble() ?? LocationService.schoolLatitude;
      final lng = (config['longitude'] as num?)?.toDouble() ?? LocationService.schoolLongitude;
      _radiusMeters = (config['radius'] as num?)?.toDouble() ?? LocationService.maxRadiusMeters;

      _latCtrl.text = lat.toStringAsFixed(6);
      _lngCtrl.text = lng.toStringAsFixed(6);
    } catch (_) {
      _nameCtrl.text = LocationService.schoolName;
      _addressCtrl.text = LocationService.schoolAddress;
      _latCtrl.text = LocationService.schoolLatitude.toStringAsFixed(6);
      _lngCtrl.text = LocationService.schoolLongitude.toStringAsFixed(6);
      _radiusMeters = LocationService.maxRadiusMeters;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentDeviceLocation() async {
    setState(() => _isGettingGps = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin GPS tidak diberikan oleh perangkat.')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latCtrl.text = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koordinat GPS perangkat saat ini berhasil disematkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil GPS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingGps = false);
    }
  }

  Future<void> _saveSettings() async {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format Latitude dan Longitude harus berupa angka desimal.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await _supa.updateSchoolSettings(
      latitude: lat,
      longitude: lng,
      radius: _radiusMeters,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan radius dan lokasi sekolah berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui pengaturan sekolah. Periksa koneksi internet.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openInGoogleMaps() async {
    final lat = double.tryParse(_latCtrl.text.trim()) ?? LocationService.schoolLatitude;
    final lng = double.tryParse(_lngCtrl.text.trim()) ?? LocationService.schoolLongitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
        );
      }
    }
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
            'Radius & Lokasi Sekolah',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFE8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8DFD8)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.pin_drop_rounded, color: AppColors.maroon, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pusat Presensi GPS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tentukan koordinat sekolah dan batas radius meter yang diizinkan untuk siswa melakukan absensi.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: AppColors.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Map View Visual Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Interactive Google Maps Overlay
                          SizedBox(
                            width: double.infinity,
                            height: 230,
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: ll.LatLng(
                                      double.tryParse(_latCtrl.text.trim()) ?? LocationService.schoolLatitude,
                                      double.tryParse(_lngCtrl.text.trim()) ?? LocationService.schoolLongitude,
                                    ),
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
                                          point: ll.LatLng(
                                            double.tryParse(_latCtrl.text.trim()) ?? LocationService.schoolLatitude,
                                            double.tryParse(_lngCtrl.text.trim()) ?? LocationService.schoolLongitude,
                                          ),
                                          radius: _radiusMeters,
                                          useRadiusInMeter: true,
                                          color: AppColors.maroon.withValues(alpha: 0.22),
                                          borderColor: AppColors.maroon,
                                          borderStrokeWidth: 2.5,
                                        ),
                                      ],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: ll.LatLng(
                                            double.tryParse(_latCtrl.text.trim()) ?? LocationService.schoolLatitude,
                                            double.tryParse(_lngCtrl.text.trim()) ?? LocationService.schoolLongitude,
                                          ),
                                          width: 44,
                                          height: 44,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppColors.maroon,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: Colors.black38, blurRadius: 6),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.school_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Zoom In / Out Controls & Center button
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Column(
                                    children: [
                                      _buildZoomButton(
                                        icon: Icons.add_rounded,
                                        tooltip: 'Perbesar',
                                        onTap: () {
                                          final z = _mapController.camera.zoom;
                                          _mapController.move(_mapController.camera.center, (z + 1).clamp(11.0, 19.0));
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      _buildZoomButton(
                                        icon: Icons.remove_rounded,
                                        tooltip: 'Perkecil',
                                        onTap: () {
                                          final z = _mapController.camera.zoom;
                                          _mapController.move(_mapController.camera.center, (z - 1).clamp(11.0, 19.0));
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      _buildZoomButton(
                                        icon: Icons.my_location_rounded,
                                        tooltip: 'Pusatkan ke Sekolah',
                                        onTap: () {
                                          final lat = double.tryParse(_latCtrl.text.trim()) ?? LocationService.schoolLatitude;
                                          final lng = double.tryParse(_lngCtrl.text.trim()) ?? LocationService.schoolLongitude;
                                          _mapController.move(ll.LatLng(lat, lng), 16.0);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Google Maps External Button
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: InkWell(
                                    onTap: _openInGoogleMaps,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 4),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.map_rounded, size: 14, color: AppColors.ink),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Buka Maps',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Radius label overlay at bottom
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.94),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 4),
                                      ],
                                    ),
                                    child: Text(
                                      'Radius Aktif: ${_radiusMeters.round()} meter',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jangkauan Radius Absensi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.maroon,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_radiusMeters.round()} Meter',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.maroon,
                                    inactiveTrackColor: const Color(0xFFF0E5DC),
                                    thumbColor: AppColors.maroon,
                                    overlayColor: AppColors.maroon.withValues(alpha: 0.15),
                                    valueIndicatorColor: AppColors.maroon,
                                  ),
                                  child: Slider(
                                    value: _radiusMeters,
                                    min: 50,
                                    max: 1000,
                                    divisions: 19,
                                    label: '${_radiusMeters.round()}m',
                                    onChanged: (val) {
                                      setState(() {
                                        _radiusMeters = val;
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  'Siswa yang berjarak lebih dari ${_radiusMeters.round()}m dari titik sekolah tidak dapat melakukan presensi mandiri.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Inputs Section
                    Text(
                      'Detail Koordinat & Sekolah',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // School Name
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Sekolah',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Address
                    TextField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Alamat Sekolah',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Latitude & Longitude in Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _lngCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // "Gunakan Lokasi GPS Saya" Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGettingGps ? null : _getCurrentDeviceLocation,
                        icon: _isGettingGps
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.maroon),
                              )
                            : const Icon(Icons.my_location_rounded, size: 18),
                        label: Text(
                          _isGettingGps ? 'Mendeteksi Posisi GPS...' : 'Gunakan Koordinat GPS Saya Saat Ini',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.maroon,
                          side: const BorderSide(color: AppColors.maroon, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
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
                                  Text('Menyimpan perubahan...'),
                                ],
                              )
                            : Text(
                                'Simpan Pengaturan Sekolah',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
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
