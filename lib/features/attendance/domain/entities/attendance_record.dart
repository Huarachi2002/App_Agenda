class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime date;
  final String subject;
  final String course;
  final bool attended;

  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.subject,
    required this.course,
    required this.attended,
  });
}
