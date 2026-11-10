import 'package:flutter/foundation.dart';
import '../models/model_akun.dart';
import 'supabase_service.dart';

class DummyDataService extends ChangeNotifier {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal() {
    refreshFromDatabase();
  }

  // Dashboard Stats - defaults to 0 (No dummy data)
  int totalStudents = 0;
  int totalTeachers = 0;
  int attendedToday = 0;
  int absentToday = 0;

  // Student accounts
  final List<StudentAccount> _students = [];
  List<StudentAccount> get students => List.unmodifiable(_students);

  // Teacher accounts
  final List<TeacherAccount> _teachers = [];
  List<TeacherAccount> get teachers => List.unmodifiable(_teachers);

  // Admin accounts
  final List<AdminAccount> _admins = [];
  List<AdminAccount> get admins => List.unmodifiable(_admins);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch real data from Supabase
  Future<void> refreshFromDatabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      final supa = SupabaseService();

      // 1. Fetch real students
      final realStudents = await supa.getStudents();
      if (realStudents.isNotEmpty) {
        _students.clear();
        _students.addAll(realStudents);
        totalStudents = _students.length;
      }

      // 2. Fetch real teachers
      final realTeachers = await supa.getTeachers();
      if (realTeachers.isNotEmpty) {
        _teachers.clear();
        _teachers.addAll(realTeachers);
        totalTeachers = _teachers.length;
      }

      // 3. Fetch real admins
      final realAdmins = await supa.getAdmins();
      if (realAdmins.isNotEmpty) {
        _admins.clear();
        _admins.addAll(realAdmins);
      }

      // 4. Fetch dashboard stats
      final stats = await supa.getDashboardStats();
      totalStudents = stats['totalStudents'] ?? _students.length;
      totalTeachers = stats['totalTeachers'] ?? _teachers.length;
      attendedToday = stats['attendedToday'] ?? 0;
      absentToday = stats['absentToday'] ?? (totalStudents > attendedToday ? totalStudents - attendedToday : 0);
    } catch (_) {
      // Safe fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Student operations ---
  Future<void> addStudent(StudentAccount student, {String password = 'Password123'}) async {
    _students.insert(0, student);
    totalStudents++;
    notifyListeners();
    try {
      await SupabaseService().addStudent(student, password: password);
      await refreshFromDatabase();
    } catch (_) {}
  }

  Future<void> updateStudent(
    String id,
    String name,
    String className,
    String nisn, {
    String? status,
    String? phone,
    String? address,
    String? gender,
    String? nis,
  }) async {
    final idx = _students.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _students[idx].name = name;
      _students[idx].className = className;
      _students[idx].nisn = nisn;
      _students[idx].initials = calculateInitials(name);
      if (status != null) _students[idx].status = status;
      if (phone != null) _students[idx].phone = phone;
      if (address != null) _students[idx].address = address;
      if (gender != null) _students[idx].gender = gender;
      if (nis != null) _students[idx].nis = nis;
      notifyListeners();
    }
    try {
      await SupabaseService().updateStudent(id, name, className, nisn);
    } catch (_) {}
  }

  Future<void> deleteStudent(String id) async {
    _students.removeWhere((s) => s.id == id);
    totalStudents = (totalStudents > 0) ? totalStudents - 1 : 0;
    notifyListeners();
    try {
      await SupabaseService().deleteStudent(id);
    } catch (_) {}
  }

  // --- Teacher operations ---
  Future<void> addTeacher(TeacherAccount teacher, {String password = 'Password123'}) async {
    _teachers.insert(0, teacher);
    totalTeachers++;
    notifyListeners();
    try {
      await SupabaseService().addTeacher(teacher, password: password);
      await refreshFromDatabase();
    } catch (_) {}
  }

  Future<void> updateTeacher(
    String id,
    String name,
    String subject,
    String nip, {
    String? status,
    String? phone,
    String? email,
    String? position,
  }) async {
    final idx = _teachers.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _teachers[idx].name = name;
      _teachers[idx].subject = subject;
      _teachers[idx].nip = nip;
      _teachers[idx].initials = calculateInitials(name);
      if (status != null) _teachers[idx].status = status;
      if (phone != null) _teachers[idx].phone = phone;
      if (email != null) _teachers[idx].email = email;
      if (position != null) _teachers[idx].position = position;
      notifyListeners();
    }
    try {
      await SupabaseService().updateTeacher(id, name, subject, nip);
    } catch (_) {}
  }

  Future<void> deleteTeacher(String id) async {
    _teachers.removeWhere((t) => t.id == id);
    totalTeachers = (totalTeachers > 0) ? totalTeachers - 1 : 0;
    notifyListeners();
    try {
      await SupabaseService().deleteTeacher(id);
    } catch (_) {}
  }

  // --- Admin operations ---
  Future<void> addAdmin(AdminAccount admin, {String password = 'Password123'}) async {
    _admins.insert(0, admin);
    notifyListeners();
    try {
      await SupabaseService().addAdmin(admin, password: password);
      await refreshFromDatabase();
    } catch (_) {}
  }

  Future<void> updateAdmin(
    String id,
    String name,
    String roleTitle,
    String adminId, {
    String? status,
    String? phone,
    String? email,
    String? address,
  }) async {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _admins[idx].name = name;
      _admins[idx].roleTitle = roleTitle;
      _admins[idx].adminId = adminId;
      _admins[idx].initials = calculateInitials(name);
      if (status != null) _admins[idx].status = status;
      if (phone != null) _admins[idx].phone = phone;
      if (email != null) _admins[idx].email = email;
      if (address != null) _admins[idx].address = address;
      notifyListeners();
    }
    try {
      await SupabaseService().updateAdmin(id, name, roleTitle, adminId);
    } catch (_) {}
  }

  Future<void> resetPassword(String id, String newPassword) async {
    try {
      await SupabaseService().resetUserPassword(id, newPassword);
    } catch (_) {}
  }

  Future<void> deleteAdmin(String id) async {
    _admins.removeWhere((a) => a.id == id);
    notifyListeners();
    try {
      await SupabaseService().deleteAdmin(id);
    } catch (_) {}
  }
}
