import '../models/model_user.dart';
import 'session_service_stub.dart'
    if (dart.library.html) 'session_service_web.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  /// Durasi sesi login: 3 Jam (10800 detik / 10800000 ms)
  static const int sessionDurationMs = 3 * 60 * 60 * 1000;

  /// Simpan sesi user ke cookie / localStorage selama 3 jam
  Future<void> saveSession(UserModel user) async {
    await SessionPlatformHelper.saveSession(user, sessionDurationMs);
  }

  /// Ambil sesi user jika belum lewat 3 jam
  Future<UserModel?> getSession() async {
    return await SessionPlatformHelper.getSession();
  }

  /// Hapus sesi (dipanggil saat logout)
  Future<void> clearSession() async {
    await SessionPlatformHelper.clearSession();
  }
}

