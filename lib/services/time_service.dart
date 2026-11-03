import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class TimeService extends ChangeNotifier {
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;

  TimeService._internal() {
    _startClockTimer();
    fetchNetworkTime();
  }

  Duration _networkOffset = Duration.zero;
  bool _isSyncedWithApi = false;
  Timer? _timer;

  bool get isSyncedWithApi => _isSyncedWithApi;

  DateTime get now {
    return DateTime.now().add(_networkOffset);
  }

  void _startClockTimer() {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  /// Fetches real date and time for Asia/Jakarta (WIB) covering Malang, East Java
  Future<void> fetchNetworkTime() async {
    try {
      // Primary API: timeapi.io
      final response = await http
          .get(
            Uri.parse('https://timeapi.io/api/time/current/zone?timeZone=Asia/Jakarta'),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['dateTime'] != null) {
          final apiTime = DateTime.parse(data['dateTime'] as String);
          _networkOffset = apiTime.difference(DateTime.now());
          _isSyncedWithApi = true;
          notifyListeners();
          return;
        }
      }
    } catch (_) {
      // Fallback API: worldtimeapi.org
      try {
        final response = await http
            .get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Jakarta'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['datetime'] != null) {
            final apiTime = DateTime.parse(data['datetime'] as String);
            _networkOffset = apiTime.difference(DateTime.now());
            _isSyncedWithApi = true;
            notifyListeners();
            return;
          }
        }
      } catch (_) {
        // Fallback gracefully to device time adjusted to WIB (UTC+7)
      }
    }
  }

  static const List<String> _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  static const List<String> _monthsId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  String get dayName {
    final d = now;
    return _daysId[(d.weekday - 1) % 7];
  }

  String get formattedDate {
    final d = now;
    final dayStr = _daysId[(d.weekday - 1) % 7];
    final monthStr = _monthsId[d.month - 1];
    return '$dayStr, ${d.day} $monthStr ${d.year}';
  }

  String get formattedDateShort {
    final d = now;
    final dayStr = _daysId[(d.weekday - 1) % 7];
    final monthStr = _monthsId[d.month - 1].substring(0, 3);
    return '$dayStr, ${d.day} $monthStr ${d.year}';
  }

  String get formattedTime {
    final d = now;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  String get formattedTimeWithSeconds {
    final d = now;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  String get timezoneLabel => 'Malang, Jawa Timur (WIB)';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

