import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/course_model.dart';
import '../models/student_attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<CourseModel>> getTeacherCourses(String teacherId);
  Future<List<StudentAttendanceModel>> getStudentsByCourse(String courseId);
  Future<void> saveAttendance(String courseId, List<StudentAttendanceModel> attendanceList);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final http.Client client;
  AttendanceRemoteDataSourceImpl(this.client);

  @override
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    // Ejemplo de llamada GET
    final url = Uri.parse('https://backend.com/api/docente/$teacherId/courses');
    final response = await client.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CourseModel.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener cursos');
    }
  }

  @override
  Future<List<StudentAttendanceModel>> getStudentsByCourse(String courseId) async {
    final url = Uri.parse('https://backend.com/api/courses/$courseId/students');
    final response = await client.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => StudentAttendanceModel.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener estudiantes');
    }
  }

  @override
  Future<void> saveAttendance(String courseId, List<StudentAttendanceModel> attendanceList) async {
    final url = Uri.parse('https://backend.com/api/courses/$courseId/attendance');
    final body = attendanceList.map((alumno) => alumno.toMap()).toList();
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al guardar asistencia');
    }
  }
}
