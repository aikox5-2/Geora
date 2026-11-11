import 'dart:convert';
import '../models/model_user.dart';

class SessionPlatformHelper {
  static String? _inMemoryData;
  static int? _inMemoryExpiry;

  static Future<void> saveSession(UserModel user, int durationMs) async {
    _inMemoryExpiry = DateTime.now().millisecondsSinceEpoch + durationMs;
    final map = {
      'user': user.toJson(),
      'expiresAt': _inMemoryExpiry,
    };
    _inMemoryData = jsonEncode(map);
  }

  static Future<UserModel?> getSession() async {
    if (_inMemoryData == null || _inMemoryExpiry == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= _inMemoryExpiry!) {
      _inMemoryData = null;
      _inMemoryExpiry = null;
      return null;
    }
    try {
      final map = jsonDecode(_inMemoryData!) as Map<String, dynamic>;
      final userMap = map['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        return UserModel.fromJson(userMap);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearSession() async {
    _inMemoryData = null;
    _inMemoryExpiry = null;
  }
}

