class StudentAttendanceEntity {
  final String studentId;
  final String fullName;
  bool isPresent;

  StudentAttendanceEntity({
    required this.studentId,
    required this.fullName,
    this.isPresent = false,
  });
}
