import 'package:flutter/foundation.dart';
import '../models/model_user.dart';

enum LoginFailureType {
  emptyFields,
  userNotFound,
  wrongPassword,
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

  // Dummy user database with convenient aliases
  static final List<UserModel> _dummyUsers = [
    const UserModel(
      id: 'usr_admin_1',
      email: 'admin@gmail.com',
      aliases: ['admin', 'admin@gmail.com', 'administrator', 'adm-001'],
      password: '12345',
      name: 'Ahmad Admin',
      role: UserRole.admin,
      info: 'Super Administrator',
      avatarInitials: 'AA',
    ),
    const UserModel(
      id: 'usr_siswa_1',
      email: 'iko@gmail.com',
      aliases: [
        'iko',
        'iko@gmail.com',
        '0051283921',
        'budiono',
        'budiono siregar',
        'ahmad siswa',
        '0000000000',
      ],
      password: '12345',
      name: 'Budiono Siregar',
      role: UserRole.siswa,
      info: 'XII RPL D • Rekayasa Perangkat Lunak',
      avatarInitials: 'BS',
    ),
    const UserModel(
      id: 'usr_guru_1',
      email: 'yudi@gmail.com',
      aliases: ['yudi', 'yudi@gmail.com', '198503122010011005', 'bu guru', 'pak guru'],
      password: '12345',
      name: 'Yudi Guru',
      role: UserRole.guru,
      info: 'Guru Matematika • 198503122010011005',
      avatarInitials: 'YG',
    ),
  ];

  /// Login validation with dummy data and specific error reporting
  Future<LoginResult> login(String identifier, String password) async {
    // Artificial small delay for realistic smooth feel
    await Future.delayed(const Duration(milliseconds: 300));

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

    // Check if user exists by email, username, NISN or alias
    final matchingUser = _dummyUsers.cast<UserModel?>().firstWhere(
      (u) => u!.matchesIdentifier(cleanId),
      orElse: () => null,
    );

    if (matchingUser == null) {
      return const LoginResult(
        isSuccess: false,
        failureType: LoginFailureType.userNotFound,
        message: 'Username / NISN tidak terdaftar! Periksa kembali akun sekolah Anda.',
      );
    }

    // Check password
    if (matchingUser.password != cleanPass) {
      return const LoginResult(
        isSuccess: false,
        failureType: LoginFailureType.wrongPassword,
        message: 'Kata sandi salah! Silakan coba lagi atau hubungi admin.',
      );
    }

    // Success
    _currentUser = matchingUser;
    notifyListeners();
    return LoginResult(
      isSuccess: true,
      user: matchingUser,
      message: 'Login berhasil!',
    );
  }

  /// Change password logic
  bool updatePassword(String oldPassword, String newPassword) {
    if (_currentUser == null) return false;
    if (_currentUser!.password != oldPassword.trim()) return false;

    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      aliases: _currentUser!.aliases,
      password: newPassword.trim(),
      name: _currentUser!.name,
      role: _currentUser!.role,
      info: _currentUser!.info,
      avatarInitials: _currentUser!.avatarInitials,
    );

    final idx = _dummyUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      _dummyUsers[idx] = updatedUser;
    }

    _currentUser = updatedUser;
    notifyListeners();
    return true;
  }

  /// Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
