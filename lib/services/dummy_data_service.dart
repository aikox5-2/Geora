import 'package:flutter/foundation.dart';
import '../models/model_akun.dart';

class DummyDataService extends ChangeNotifier {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal() {
    _initData();
  }

  // Dashboard Stats
  int totalStudents = 124;
  int totalTeachers = 8;
  int attendedToday = 98;
  int absentToday = 11;

  // Student accounts
  final List<StudentAccount> _students = [];
  List<StudentAccount> get students => List.unmodifiable(_students);

  // Teacher accounts
  final List<TeacherAccount> _teachers = [];
  List<TeacherAccount> get teachers => List.unmodifiable(_teachers);

  // Admin accounts
  final List<AdminAccount> _admins = [];
  List<AdminAccount> get admins => List.unmodifiable(_admins);

  void _initData() {
    // Siswa from screenshots
    _students.addAll([
      StudentAccount(
        id: 'std_1',
        name: 'Budiono Siregar',
        className: 'XII RPL D',
        nisn: '0051283921',
        initials: 'BS',
      ),
      StudentAccount(
        id: 'std_2',
        name: 'Chelsea Aqila Putri',
        className: 'XII RPL D',
        nisn: '0051283922',
        initials: 'CA',
      ),
      StudentAccount(
        id: 'std_3',
        name: 'Malika Aisyabila',
        className: 'XII RPL D',
        nisn: '0051283923',
        initials: 'MA',
      ),
      StudentAccount(
        id: 'std_4',
        name: 'Alya Putri',
        className: 'XII RPL D',
        nisn: '0051283924',
        initials: 'AP',
      ),
      StudentAccount(
        id: 'std_5',
        name: 'Fajar Adi',
        className: 'XII RPL D',
        nisn: '0051283925',
        initials: 'FA',
      ),
      StudentAccount(
        id: 'std_6',
        name: 'Ahmad Farhan',
        className: 'XII RPL D',
        nisn: '0051283926',
        initials: 'BS',
      ),
    ]);

    // Guru from screenshots
    _teachers.addAll([
      TeacherAccount(
        id: 'tch_1',
        name: 'Ahmad Guru',
        subject: 'Matematika',
        nip: '198205142008011003',
        initials: 'AG',
      ),
      TeacherAccount(
        id: 'tch_2',
        name: 'Rani Guru',
        subject: 'Bahasa Indonesia',
        nip: '198711202010012015',
        initials: 'RG',
      ),
      TeacherAccount(
        id: 'tch_3',
        name: 'Siti Guru',
        subject: 'Bahasa Inggris',
        nip: '199004052014022008',
        initials: 'SG',
      ),
    ]);

    // Admin from screenshots
    _admins.addAll([
      AdminAccount(
        id: 'adm_1',
        name: 'Ahmad Admin',
        roleTitle: 'Administrator',
        adminId: 'ADM-001',
        initials: 'AA',
      ),
      AdminAccount(
        id: 'adm_2',
        name: 'Rina Admin',
        roleTitle: 'Administrator',
        adminId: 'ADM-002',
        initials: 'RA',
      ),
      AdminAccount(
        id: 'adm_3',
        name: 'Budi Admin',
        roleTitle: 'Administrator',
        adminId: 'ADM-003',
        initials: 'BA',
      ),
    ]);
  }

  // --- Student operations ---
  void addStudent(StudentAccount student) {
    _students.insert(0, student);
    totalStudents++;
    notifyListeners();
  }

  void updateStudent(String id, String name, String className, String nisn) {
    final idx = _students.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _students[idx].name = name;
      _students[idx].className = className;
      _students[idx].nisn = nisn;
      _students[idx].initials = calculateInitials(name);
      notifyListeners();
    }
  }

  void deleteStudent(String id) {
    _students.removeWhere((s) => s.id == id);
    totalStudents = (totalStudents > 0) ? totalStudents - 1 : 0;
    notifyListeners();
  }

  // --- Teacher operations ---
  void addTeacher(TeacherAccount teacher) {
    _teachers.insert(0, teacher);
    totalTeachers++;
    notifyListeners();
  }

  void updateTeacher(String id, String name, String subject, String nip) {
    final idx = _teachers.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _teachers[idx].name = name;
      _teachers[idx].subject = subject;
      _teachers[idx].nip = nip;
      _teachers[idx].initials = calculateInitials(name);
      notifyListeners();
    }
  }

  void deleteTeacher(String id) {
    _teachers.removeWhere((t) => t.id == id);
    totalTeachers = (totalTeachers > 0) ? totalTeachers - 1 : 0;
    notifyListeners();
  }

  // --- Admin operations ---
  void addAdmin(AdminAccount admin) {
    _admins.insert(0, admin);
    notifyListeners();
  }

  void updateAdmin(String id, String name, String roleTitle, String adminId) {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _admins[idx].name = name;
      _admins[idx].roleTitle = roleTitle;
      _admins[idx].adminId = adminId;
      _admins[idx].initials = calculateInitials(name);
      notifyListeners();
    }
  }

  void deleteAdmin(String id) {
    _admins.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
