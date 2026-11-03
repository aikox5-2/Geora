class StudentAttendanceItem {
  final String initials;
  final String name;
  final String time;
  final String className;

  const StudentAttendanceItem({
    required this.initials,
    required this.name,
    required this.time,
    this.className = 'XII RPL D',
  });
}

