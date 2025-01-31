import '../../domain/entities/student_attendance_entity.dart';

class StudentAttendanceModel extends StudentAttendanceEntity {
  StudentAttendanceModel({
    required String studentId,
    required String fullName,
    bool isPresent = false,
  }) : super(
          studentId: studentId,
          fullName: fullName,
          isPresent: isPresent,
        );

  factory StudentAttendanceModel.fromMap(Map<String, dynamic> map) {
    return StudentAttendanceModel(
      studentId: map['studentId'],
      fullName: map['fullName'],
      isPresent: map['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'isPresent': isPresent,
    };
  }
}
