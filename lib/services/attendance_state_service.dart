import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class ManualSubmission {
  final String id;
  final String type; // 'Izin' or 'Sakit'
  String reason;
  final DateTime submissionTime;
  String status; // 'Menunggu Konfirmasi', 'Disetujui', 'Ditolak'

  ManualSubmission({
    required this.id,
    required this.type,
    required this.reason,
    required this.submissionTime,
    this.status = 'Menunggu Konfirmasi',
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

  ManualSubmission? get todayManualSubmission => _todayManualSubmission;
  bool get hasManualSubmitted => _todayManualSubmission != null || (_dbTodayStatus != null && (_dbTodayStatus!.toLowerCase().contains('izin') || _dbTodayStatus!.toLowerCase().contains('sakit')));

  AutomaticAttendance? get todayAutomaticAttendance => _todayAutomaticAttendance;
  bool get hasAutomaticSubmitted => _todayAutomaticAttendance != null || (_dbTodayStatus != null && (_dbTodayStatus!.toLowerCase() == 'hadir' || _dbTodayStatus!.toLowerCase() == 'terlambat'));

  bool get isAlreadyCheckedInToday => hasAutomaticSubmitted || hasManualSubmitted;

  String get todayStatusLabel {
    if (_todayAutomaticAttendance != null) return 'Hadir';
    if (_todayManualSubmission != null) return _todayManualSubmission!.type;
    if (_dbTodayStatus != null && _dbTodayStatus!.isNotEmpty) {
      final s = _dbTodayStatus!.toLowerCase();
      if (s == 'hadir') return 'Hadir';
      if (s == 'terlambat') return 'Terlambat';
      if (s == 'izin') return 'Izin';
      if (s == 'sakit') return 'Sakit';
      return _dbTodayStatus!;
    }
    return 'Belum Absen';
  }

  /// Sync today's attendance status directly from Supabase
  Future<void> syncTodayAttendance([String? userId]) async {
    final uid = userId ?? AuthService().currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    final att = await SupabaseService().getTodayStudentAttendance(uid);
    if (att != null) {
      _dbTodayStatus = att['status']?.toString();
    } else {
      _dbTodayStatus = null;
    }
    notifyListeners();
  }

  void submitManual({
    required String type,
    required String reason,
    Uint8List? fileBytes,
    String? fileName,
  }) {
    _todayManualSubmission = ManualSubmission(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      reason: reason,
      submissionTime: DateTime.now(),
    );
    _dbTodayStatus = type;
    notifyListeners();

    // Async record to Supabase
    final currentUser = AuthService().currentUser;
    final userId = currentUser?.id ?? '';
    SupabaseService().submitManualAttendance(
      siswaId: userId,
      type: type,
      reason: reason,
      date: DateTime.now(),
      fileBytes: fileBytes,
      fileName: fileName,
    );
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
    final isLate = time.hour > 7 || (time.hour == 7 && time.minute > 0);
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
