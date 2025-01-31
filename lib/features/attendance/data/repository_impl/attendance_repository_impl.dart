import 'package:app_task/features/attendance/data/datasource/attendance_remote_datasource.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/student_attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/student_attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CourseEntity>> getTeacherCourses(String teacherId) async {
    final courses = await remoteDataSource.getTeacherCourses(teacherId);
    return courses; // Se devuelven como CourseModel (hereda de CourseEntity)
  }

  @override
  Future<List<StudentAttendanceEntity>> getStudentsByCourse(String courseId) async {
    final students = await remoteDataSource.getStudentsByCourse(courseId);
    return students;
  }

  @override
  Future<void> saveAttendance(String courseId, List<StudentAttendanceEntity> attendanceList) async {
    // Convertimos StudentAttendanceEntity -> StudentAttendanceModel
    final listModel = attendanceList.map((e) => StudentAttendanceModel(
      studentId: e.studentId,
      fullName: e.fullName,
      isPresent: e.isPresent,
    )).toList();
    return remoteDataSource.saveAttendance(courseId, listModel);
  }
}
