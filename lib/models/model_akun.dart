String calculateInitials(String text) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return 'U';
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

class StudentAccount {
  final String id; // id_siswa or fallback
  final String? userId;
  String? classId;
  String name;
  String className;
  String nisn;
  String? nis;
  String? username;
  String? phone;
  String? address;
  String? gender;
  String? birthDate;
  String? status;
  String initials;

  StudentAccount({
    required this.id,
    this.userId,
    this.classId,
    required this.name,
    required this.className,
    required this.nisn,
    this.nis,
    this.username,
    this.phone,
    this.address,
    this.gender,
    this.birthDate,
    this.status = 'aktif',
    String? initials,
  }) : initials = initials ?? calculateInitials(name);

  String get currentStatus => (status != null && status!.isNotEmpty) ? status! : 'aktif';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_siswa': name,
      'nisn': nisn,
      'nis': nis,
      'username': username,
      'no_hp': phone,
      'alamat': address,
      'jenis_kelamin': gender,
      'status': currentStatus,
    };
  }
}

class TeacherAccount {
  final String id;
  final String? userId;
  String name;
  String subject;
  String nip;
  String? username;
  String? email;
  String? phone;
  String? position;
  String? status;
  String initials;

  TeacherAccount({
    required this.id,
    this.userId,
    required this.name,
    required this.subject,
    required this.nip,
    this.username,
    this.email,
    this.phone,
    this.position = 'Guru Pengajar',
    this.status = 'aktif',
    String? initials,
  }) : initials = initials ?? calculateInitials(name);

  String get currentStatus => (status != null && status!.isNotEmpty) ? status! : 'aktif';
  String get mapel => subject;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': name,
      'mapel': subject,
      'nip': nip,
      'username': username,
      'email': email,
      'no_hp': phone,
      'jabatan': position,
      'status': currentStatus,
    };
  }
}

class AdminAccount {
  final String id;
  String name;
  String roleTitle;
  String adminId;
  String? username;
  String? email;
  String? phone;
  String? address;
  String? status;
  String initials;

  AdminAccount({
    required this.id,
    required this.name,
    this.roleTitle = 'Administrator',
    required this.adminId,
    this.username,
    this.email,
    this.phone,
    this.address,
    this.status = 'aktif',
    String? initials,
  }) : initials = initials ?? calculateInitials(name);

  String get currentStatus => (status != null && status!.isNotEmpty) ? status! : 'aktif';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': name,
      'roleTitle': roleTitle,
      'adminId': adminId,
      'username': username,
      'email': email,
      'no_hp': phone,
      'alamat': address,
      'status': currentStatus,
    };
  }
}
