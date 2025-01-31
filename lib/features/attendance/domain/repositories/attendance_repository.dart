import 'package:app_task/features/attendance/domain/entities/student_attendance_entity.dart';
import 'package:app_task/features/attendance/domain/entities/course_entity.dart';

abstract class AttendanceRepository {
  /// Devuelve los cursos asignados a un docente por su [teacherId].
  Future<List<CourseEntity>> getTeacherCourses(String teacherId);

  /// Devuelve la lista de estudiantes en un [courseId], cada uno con isPresent = false.
  Future<List<StudentAttendanceEntity>> getStudentsByCourse(String courseId);

  /// Guarda la asistencia para el curso [courseId].
  /// Recibe la lista de [StudentAttendanceEntity] con su isPresent true/false.
  Future<void> saveAttendance(String courseId, List<StudentAttendanceEntity> attendanceList);
}
