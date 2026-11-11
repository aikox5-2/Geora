// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import '../models/model_user.dart';

class SessionPlatformHelper {
  static const String _cookieKey = 'geora_session';
  static const String _storageKey = 'geora_session_user';
  static const String _expiryKey = 'geora_session_expiry';

  static Future<void> saveSession(UserModel user, int durationMs) async {
    final expiryTime = DateTime.now().millisecondsSinceEpoch + durationMs;
    final userJson = jsonEncode(user.toJson());

    // 1. Simpan ke window.localStorage
    try {
      html.window.localStorage[_storageKey] = userJson;
      html.window.localStorage[_expiryKey] = expiryTime.toString();
    } catch (_) {}

    // 2. Simpan juga ke document.cookie selama 3 jam (10800 detik)
    try {
      final maxAgeSeconds = durationMs ~/ 1000;
      final encodedUser = Uri.encodeComponent(userJson);
      html.document.cookie =
          '$_cookieKey=$encodedUser; max-age=$maxAgeSeconds; path=/; SameSite=Lax';
    } catch (_) {}
  }

  static Future<UserModel?> getSession() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Periksa localStorage dulu
    try {
      final expiryStr = html.window.localStorage[_expiryKey];
      final userJson = html.window.localStorage[_storageKey];

      if (expiryStr != null && userJson != null) {
        final expiry = int.tryParse(expiryStr) ?? 0;
        if (now < expiry) {
          final map = jsonDecode(userJson) as Map<String, dynamic>;
          return UserModel.fromJson(map);
        } else {
          // Sudah expired lebih dari 3 jam, hapus
          clearSession();
          return null;
        }
      }
    } catch (_) {}

    // 2. Fallback periksa document.cookie
    try {
      final rawCookie = html.document.cookie ?? '';
      final cookies = rawCookie.split(';');
      for (var c in cookies) {
        final parts = c.trim().split('=');
        if (parts.length >= 2 && parts[0] == _cookieKey) {
          final val = Uri.decodeComponent(parts.sublist(1).join('='));
          final map = jsonDecode(val) as Map<String, dynamic>;
          return UserModel.fromJson(map);
        }
      }
    } catch (_) {}

    return null;
  }

  static Future<void> clearSession() async {
    try {
      html.window.localStorage.remove(_storageKey);
      html.window.localStorage.remove(_expiryKey);
    } catch (_) {}

    try {
      html.document.cookie =
          '$_cookieKey=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; SameSite=Lax';
    } catch (_) {}
  }
}

