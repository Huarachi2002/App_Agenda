import 'package:app_task/features/attendance/domain/entities/course_entity.dart';
import 'package:app_task/features/attendance/domain/entities/student_attendance_entity.dart';
import 'package:app_task/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherAttendanceState {
  final List<CourseEntity> courses;
  final List<StudentAttendanceEntity> students;
  final bool isLoading;
  final String? error;
  final CourseEntity? selectedCourse;

  TeacherAttendanceState({
    this.courses = const [],
    this.students = const [],
    this.isLoading = false,
    this.error,
    this.selectedCourse,
  });

  TeacherAttendanceState copyWith({
    List<CourseEntity>? courses,
    List<StudentAttendanceEntity>? students,
    bool? isLoading,
    String? error,
    CourseEntity? selectedCourse,
  }) {
    return TeacherAttendanceState(
      courses: courses ?? this.courses,
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }
}

class TeacherAttendanceNotifier extends StateNotifier<TeacherAttendanceState> {
  final AttendanceRepository repository;

  TeacherAttendanceNotifier(this.repository) : super(TeacherAttendanceState());

  // Obtener cursos del profesor
  Future<void> loadCourses(String teacherId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final courses = await repository.getTeacherCourses(teacherId);
      state = state.copyWith(courses: courses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Seleccionar curso y cargar estudiantes
  Future<void> selectCourseAndLoad(String courseId) async {
    state = state.copyWith(isLoading: true, error: null);
    final course = state.courses.firstWhere((c) => c.courseId == courseId);
    try {
      final students = await repository.getStudentsByCourse(courseId);
      state = state.copyWith(
        selectedCourse: course,
        students: students,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Marcar o desmarcar asistencia de un estudiante
  void toggleAttendance(String studentId) {
    final updatedStudents = state.students.map((s) {
      if (s.studentId == studentId) {
        return StudentAttendanceEntity(
          studentId: s.studentId,
          fullName: s.fullName,
          isPresent: !s.isPresent,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(students: updatedStudents);
  }

  // Guardar asistencia en el backend
  Future<void> saveAttendance() async {
    if (state.selectedCourse == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.saveAttendance(state.selectedCourse!.courseId, state.students);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  throw UnimplementedError();
});

final teacherAttendanceProvider =
    StateNotifierProvider<TeacherAttendanceNotifier, TeacherAttendanceState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return TeacherAttendanceNotifier(repo);
});
