String calculateInitials(String text) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return 'U';
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

class StudentAccount {
  final String id;
  String name;
  String className;
  String nisn;
  String initials;

  StudentAccount({
    required this.id,
    required this.name,
    required this.className,
    required this.nisn,
    String? initials,
  }) : initials = initials ?? calculateInitials(name);
}

class TeacherAccount {
  final String id;
  String name;
  String subject;
  String nip;
  String initials;

  TeacherAccount({
    required this.id,
    required this.name,
    required this.subject,
    required this.nip,
    String? initials,
  }) : initials = initials ?? calculateInitials(name);
}

class AdminAccount {
  final String id;
  String name;
  String roleTitle;
  String adminId;
  String initials;

  AdminAccount({
    required this.id,
    required this.name,
    this.roleTitle = 'Administrator',
    required this.adminId,
    String? initials,
  }) : initials = initials ?? calculateInitials(name);
}
