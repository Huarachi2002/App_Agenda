import 'package:app_task/features/attendance/presentation/controllers/notifier/create_list_attendance_notifier.dart';
import 'package:app_task/features/attendance/presentation/pages/attendance_lista_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectCoursePage extends ConsumerStatefulWidget {
  final String teacherId;
  const SelectCoursePage({Key? key, required this.teacherId}) : super(key: key);

  @override
  ConsumerState<SelectCoursePage> createState() => _SelectCoursePageState();
}

class _SelectCoursePageState extends ConsumerState<SelectCoursePage> {
  @override
  void initState() {
    super.initState();
    // Cargamos cursos del profesor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherAttendanceProvider.notifier).loadCourses(widget.teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherAttendanceProvider);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(state),
      ),

    );
  }

  /// Construcción del contenido según el estado de carga, error o datos.
  Widget _buildBody(TeacherAttendanceState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(state.error!);
    }

    if (state.courses.isEmpty) {
      return _buildNoCourses();
    }

    return _buildCourseList(state);
  }

  /// UI para mostrar error con opción de reintentar.
  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(teacherAttendanceProvider.notifier).loadCourses(widget.teacherId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4c669f),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  /// UI para mostrar cuando no hay cursos disponibles.
  Widget _buildNoCourses() {
    return const Center(
      child: Text(
        'No hay cursos disponibles',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Lista de cursos con mejor diseño.
  Widget _buildCourseList(TeacherAttendanceState state) {
    return ListView.separated(
      itemCount: state.courses.length,
      separatorBuilder: (_, __) => const Divider(thickness: 1),
      itemBuilder: (context, index) {
        final course = state.courses[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onCourseSelected(course.courseId),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff192f6a),
                    child: Text(
                      course.courseName[0], // Primera letra del curso
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.courseName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Manejar selección del curso y navegar a la lista de asistencia.
  void _onCourseSelected(String courseId) {
    ref.read(teacherAttendanceProvider.notifier).selectCourseAndLoad(courseId);

    // Transición más fluida con PageRouteBuilder
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AttendanceListPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

}
