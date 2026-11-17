import 'package:flutter/foundation.dart';

import 'auth_service.dart';

import 'supabase_service.dart';

class ManualSubmission {

  final String id;

  String type; // 'Izin' or 'Sakit'

  String reason;

  final DateTime submissionTime;

  String status; // 'Menunggu', 'Disetujui', 'Ditolak'

  List<String> fileUrls;

  ManualSubmission({

    required this.id,

    required this.type,

    required this.reason,

    required this.submissionTime,

    this.status = 'Menunggu',

    this.fileUrls = const [],

  });

}

class AutomaticAttendance {

  final DateTime time;

  final String location;

  final double latitude;

  final double longitude;

  final Uint8List? photoBytes;

  final String? photoPath;

  AutomaticAttendance({

    required this.time,

    required this.location,

    required this.latitude,

    required this.longitude,

    this.photoBytes,

    this.photoPath,

  });

}

class AttendanceStateService extends ChangeNotifier {

  static final AttendanceStateService _instance = AttendanceStateService._internal();

  factory AttendanceStateService() => _instance;

  AttendanceStateService._internal();

  ManualSubmission? _todayManualSubmission;

  AutomaticAttendance? _todayAutomaticAttendance;

  String? _dbTodayStatus;

  Map<String, dynamic>? _activeConfig;

  ManualSubmission? get todayManualSubmission => _todayManualSubmission;

  bool get hasManualSubmitted =>

      _todayManualSubmission != null ||

      (_dbTodayStatus != null &&

          (_dbTodayStatus!.toLowerCase().contains('izin') ||

              _dbTodayStatus!.toLowerCase().contains('sakit') ||

              _dbTodayStatus!.toLowerCase().contains('tinjauan')));

  AutomaticAttendance? get todayAutomaticAttendance => _todayAutomaticAttendance;

  bool get hasAutomaticSubmitted =>

      _todayAutomaticAttendance != null ||

      (_dbTodayStatus != null &&

          (_dbTodayStatus!.toLowerCase() == 'hadir' ||

              _dbTodayStatus!.toLowerCase() == 'terlambat' ||

              _dbTodayStatus!.toLowerCase().contains('sudah absen')));

  bool get isAlreadyCheckedInToday => hasAutomaticSubmitted || hasManualSubmitted;

  String get todayStatusLabel {
    if (_todayAutomaticAttendance != null) {
      if (_dbTodayStatus != null && _dbTodayStatus!.isNotEmpty) {
        final s = _dbTodayStatus!.toLowerCase();
        if (s.contains('terlambat')) return 'Terlambat';
        if (s.contains('hadir')) return 'Hadir';
        return _dbTodayStatus!;
      }
      return 'Hadir';
    }
    if (_todayManualSubmission != null) {
      final stat = _todayManualSubmission!.status.toLowerCase();
      if (stat == 'disetujui') {
        return _todayManualSubmission!.type;
      } else if (stat == 'ditolak') {
        return 'Ditolak';
      }
      return 'Dalam Tinjauan';
    }
    if (_dbTodayStatus != null && _dbTodayStatus!.isNotEmpty) {
      final s = _dbTodayStatus!.toLowerCase();
      if (s.contains('terlambat')) return 'Terlambat';
      if (s.contains('hadir')) return 'Hadir';
      if (s == 'izin') return 'Izin';
      if (s == 'sakit') return 'Sakit';
      if (s.contains('tinjauan') || s.contains('menunggu')) return 'Dalam Tinjauan';
      if (s == 'ditolak') return 'Ditolak';
      final clean = _dbTodayStatus!
          .replaceAll('Sudah Absen', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
      return clean.isNotEmpty ? clean : 'Hadir';
    }
    return 'Belum Absen';
  }

  /// Sync today's attendance status & schedule directly from Supabase

  Future<void> syncTodayAttendance([String? userId]) async {

    final uid = userId ?? AuthService().currentUser?.id;

    if (uid == null || uid.isEmpty) return;

    try {

      _activeConfig = await SupabaseService().getTodayAttendanceConfig();

      final att = await SupabaseService().getTodayStudentAttendance(uid);

      if (att != null) {

        final st = att['status']?.toString() ?? '';

        final subStatus = att['submissionStatus']?.toString().toLowerCase() ?? '';

        final isManual = att['method'] == 'manual' || subStatus.isNotEmpty;

        if (isManual) {

          final isApproved = subStatus == 'disetujui' || att['isApproved'] == true;

          final isPending = subStatus == 'menunggu' || att['isPending'] == true;

          final rawJenis = att['jenis']?.toString().toLowerCase() ?? 'izin';

          final jenis = rawJenis == 'sakit' ? 'Sakit' : 'Izin';

          final fileUrlStr = att['fileUrl']?.toString() ?? '';

          final fileList = fileUrlStr.isNotEmpty

              ? fileUrlStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()

              : <String>[];

          _todayManualSubmission = ManualSubmission(

            id: att['id_pengajuan']?.toString() ?? 'synced_sub',

            type: jenis,

            reason: att['alasan']?.toString() ?? '',

            submissionTime: DateTime.now(),

            status: isApproved ? 'Disetujui' : (isPending ? 'Menunggu' : 'Ditolak'),

            fileUrls: fileList,

          );

          if (isApproved) {

            _dbTodayStatus = jenis;

          } else if (isPending) {

            _dbTodayStatus = 'Dalam Tinjauan';

          } else {

            _dbTodayStatus = 'Ditolak';

          }

        } else {

          _todayManualSubmission = null;

          _dbTodayStatus = st;

        }

      } else {

        _dbTodayStatus = null;

        _todayAutomaticAttendance = null;

        _todayManualSubmission = null;

      }

    } catch (_) {}

    notifyListeners();

  }

  /// Check whether direct (automatic / camera) attendance is currently allowed based on config

  bool isDirectAttendanceTimeAllowed() {

    final config = _activeConfig;

    if (config == null) return true;

    final jamSelesaiStr = config['jam_selesai']?.toString() ?? '08:00:00';

    final parts = jamSelesaiStr.split(':');

    final endHour = int.tryParse(parts[0]) ?? 8;

    final endMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final now = DateTime.now();

    final endTime = DateTime(now.year, now.month, now.day, endHour, endMinute);

    return now.isBefore(endTime) || now.isAtSameMomentAs(endTime);

  }

  String get endAttendanceTimeString {

    final config = _activeConfig;

    if (config == null) return '08:00';

    final raw = config['jam_selesai']?.toString() ?? '08:00';

    final p = raw.split(':');

    if (p.length >= 2) return '${p[0]}:${p[1]}';

    return raw;

  }

  Future<bool> submitManual({

    required String type,

    required String reason,

    Uint8List? fileBytes,

    String? fileName,

    List<Uint8List>? fileBytesList,

    List<String>? fileNamesList,

  }) async {

    _todayManualSubmission = ManualSubmission(

      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',

      type: type,

      reason: reason,

      submissionTime: DateTime.now(),

      status: 'Menunggu',

      fileUrls: const [],

    );

    _dbTodayStatus = 'Dalam Tinjauan';

    notifyListeners();

    final currentUser = AuthService().currentUser;

    final userId = currentUser?.id ?? '';

    final ok = await SupabaseService().submitManualAttendance(

      siswaId: userId,

      type: type,

      reason: reason,

      date: DateTime.now(),

      fileBytes: fileBytes,

      fileName: fileName,

      fileBytesList: fileBytesList,

      fileNamesList: fileNamesList,

    );

    await syncTodayAttendance(userId);

    return ok;

  }

  Future<bool> updateManual({

    required String type,

    required String reason,

    required List<String> existingUrls,

    List<Uint8List>? newFileBytesList,

    List<String>? newFileNamesList,

  }) async {

    if (_todayManualSubmission != null) {

      _todayManualSubmission!.type = type;

      _todayManualSubmission!.reason = reason;

      notifyListeners();

    }

    final currentUser = AuthService().currentUser;

    final userId = currentUser?.id ?? '';

    final ok = await SupabaseService().updateManualAttendance(

      siswaId: userId,

      type: type,

      reason: reason,

      existingUrls: existingUrls,

      newFileBytes: newFileBytesList ?? [],

      newFileNames: newFileNamesList ?? [],

    );

    await syncTodayAttendance(userId);

    return ok;

  }

  void updateManualReason(String newReason) {

    if (_todayManualSubmission != null) {

      _todayManualSubmission!.reason = newReason;

      notifyListeners();

    }

  }

  void cancelManualSubmission() {

    _todayManualSubmission = null;

    _dbTodayStatus = null;

    notifyListeners();

  }

  Future<bool> submitAutomatic({

    required DateTime time,

    required String location,

    required double latitude,

    required double longitude,

    Uint8List? photoBytes,

    String? photoPath,

  }) async {

    _todayAutomaticAttendance = AutomaticAttendance(

      time: time,

      location: location,

      latitude: latitude,

      longitude: longitude,

      photoBytes: photoBytes,

      photoPath: photoPath,

    );

    // Calculate late status against configured batas_terlambat

    int lateHour = 7;

    int lateMinute = 0;

    if (_activeConfig != null && _activeConfig!['batas_terlambat'] != null) {

      final p = _activeConfig!['batas_terlambat'].toString().split(':');

      lateHour = int.tryParse(p[0]) ?? 7;

      lateMinute = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;

    }

    final isLate = time.hour > lateHour || (time.hour == lateHour && time.minute > lateMinute);

    _dbTodayStatus = isLate ? 'Terlambat' : 'Hadir';

    notifyListeners();

    // Async record to Supabase

    final currentUser = AuthService().currentUser;

    final userId = currentUser?.id ?? '';

    final success = await SupabaseService().recordAttendance(

      siswaId: userId,

      time: time,

      location: location,

      latitude: latitude,

      longitude: longitude,

      status: isLate ? 'terlambat' : 'hadir',

      metode: photoBytes != null ? 'kamera' : 'otomatis',

      photoBytes: photoBytes,

    );

    return success;

  }

  void resetForTest() {

    _todayManualSubmission = null;

    _todayAutomaticAttendance = null;

    _dbTodayStatus = null;

    notifyListeners();

  }

}

