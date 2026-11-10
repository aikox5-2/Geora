import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../models/model_user.dart';
import 'supabase_service.dart';

enum LoginFailureType {
  emptyFields,
  userNotFound,
  wrongPassword,
  networkError,
}

class LoginResult {
  final bool isSuccess;
  final UserModel? user;
  final LoginFailureType? failureType;
  final String message;

  const LoginResult({
    required this.isSuccess,
    this.user,
    this.failureType,
    required this.message,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Login validation with Supabase database & safe Indonesian error messages
  Future<LoginResult> login(String identifier, String password) async {
    final cleanId = identifier.trim();
    final cleanPass = password.trim();

    if (cleanId.isEmpty) {
      return const LoginResult(
        isSuccess: false,
        failureType: LoginFailureType.emptyFields,
        message: 'Silakan masukkan NISN atau email Anda.',
      );
    }

    if (cleanPass.isEmpty) {
      return const LoginResult(
        isSuccess: false,
        failureType: LoginFailureType.emptyFields,
        message: 'Silakan masukkan kata sandi akun Anda.',
      );
    }

    try {
      final result = await SupabaseService().login(cleanId, cleanPass);
      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
      }
      return result;
    } catch (e) {
      final friendlyMsg = SafeErrorHandler.getFriendlyMessage(e);
      return LoginResult(
        isSuccess: false,
        failureType: LoginFailureType.networkError,
        message: friendlyMsg,
      );
    }
  }

  /// Change password logic
  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    if (_currentUser!.password != oldPassword.trim()) return false;

    final updatedUser = _currentUser!.copyWith(
      password: newPassword.trim(),
    );

    _currentUser = updatedUser;
    notifyListeners();

    // Sync to Supabase directly
    await SupabaseService().updatePassword(
      updatedUser.id,
      oldPassword,
      newPassword,
      username: updatedUser.email,
    );

    return true;
  }

  /// Update current user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
      email: email ?? _currentUser!.email,
      address: address ?? _currentUser!.address,
    );
    notifyListeners();

    // Sync to Supabase directly
    await SupabaseService().updateUserProfile(
      userId: _currentUser!.id,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      email: _currentUser!.email,
      address: _currentUser!.address,
      role: _currentUser!.role.name,
    );
  }

  /// Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
