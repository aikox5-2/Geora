import 'package:flutter/foundation.dart';

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

  ManualSubmission? get todayManualSubmission => _todayManualSubmission;
  bool get hasManualSubmitted => _todayManualSubmission != null;

  AutomaticAttendance? get todayAutomaticAttendance => _todayAutomaticAttendance;
  bool get hasAutomaticSubmitted => _todayAutomaticAttendance != null;

  String get todayStatusLabel {
    if (_todayAutomaticAttendance != null) return 'Hadir';
    if (_todayManualSubmission != null) return _todayManualSubmission!.type;
    return 'Belum Absen';
  }

  void submitManual({
    required String type,
    required String reason,
  }) {
    _todayManualSubmission = ManualSubmission(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      reason: reason,
      submissionTime: DateTime.now(),
    );
    notifyListeners();
  }

  void updateManualReason(String newReason) {
    if (_todayManualSubmission != null) {
      _todayManualSubmission!.reason = newReason;
      notifyListeners();
    }
  }

  void cancelManualSubmission() {
    _todayManualSubmission = null;
    notifyListeners();
  }

  void submitAutomatic({
    required DateTime time,
    required String location,
    required double latitude,
    required double longitude,
    Uint8List? photoBytes,
    String? photoPath,
  }) {
    _todayAutomaticAttendance = AutomaticAttendance(
      time: time,
      location: location,
      latitude: latitude,
      longitude: longitude,
      photoBytes: photoBytes,
      photoPath: photoPath,
    );
    notifyListeners();
  }

  void resetToday() {
    _todayManualSubmission = null;
    _todayAutomaticAttendance = null;
    notifyListeners();
  }
}

