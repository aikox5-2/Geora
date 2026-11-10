class StudentAttendanceItem {
  final String initials;
  final String name;
  final String time;
  final String className;
  final String status;

  const StudentAttendanceItem({
    required this.initials,
    required this.name,
    required this.time,
    this.className = 'XII RPL D',
    this.status = 'Hadir',
  });
}
