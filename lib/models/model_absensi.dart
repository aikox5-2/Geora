class StudentAttendanceItem {
  final String? id;
  final String initials;
  final String name;
  final String time;
  final String className;
  final String status;
  final String nisn;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? method;
  final String? keterangan;

  const StudentAttendanceItem({
    this.id,
    required this.initials,
    required this.name,
    required this.time,
    this.className = 'XII RPL D',
    this.status = 'Hadir',
    this.nisn = '0000000000',
    this.location,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.method,
    this.keterangan,
  });
}
