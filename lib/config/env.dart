import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Base Supabase URL (Omit any trailing /rest/v1/)
  static String get supabaseUrl {
    final rawUrl = dotenv.env['SUPABASE_URL'] ?? 'https://egofzifadvxlzegznmsv.supabase.co';
    // Clean up if it ends with /rest/v1 or trailing slash
    return rawUrl
        .replaceAll(RegExp(r'/rest/v1/?$'), '')
        .replaceAll(RegExp(r'/$'), '');
  }

  /// Supabase Anon Public Key (Safe for client usage)
  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnb2Z6aWZhZHZ4bHplZ3pubXN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1MzkwMjIsImV4cCI6MjEwODExNTAyMn0.kVCU-Dvud_IY9r73wzTEQpYyoQB2l0V6E8YXj3rgBiU';
  }
}

/// Helper class to provide safe, user-friendly Indonesian error messages
/// without ever exposing internal URLs, stack traces, or credentials.
class SafeErrorHandler {
  static String getFriendlyMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan pada sistem.';
    final str = error.toString().toLowerCase();

    if (str.contains('socketexception') ||
        str.contains('network') ||
        str.contains('connection') ||
        str.contains('failed host lookup') ||
        str.contains('timed out') ||
        str.contains('clientexception') ||
        str.contains('handshakeexception')) {
      return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
    }

    if (str.contains('401') ||
        str.contains('invalid login') ||
        str.contains('unauthorized')) {
      return 'Nama pengguna atau kata sandi tidak cocok.';
    }

    if (str.contains('duplicate') || str.contains('already exists')) {
      return 'Data sudah terdaftar di sistem.';
    }

    return 'Terjadi kesalahan pada sistem. Silakan coba beberapa saat lagi.';
  }
}

