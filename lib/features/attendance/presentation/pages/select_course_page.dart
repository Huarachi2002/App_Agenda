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
      body: ListView.builder(
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          return ListTile(
            title: Text(course.courseName),
            onTap: () {
              ref
                  .read(teacherAttendanceProvider.notifier)
                  .selectCourseAndLoad(course.courseId);
              // Navegamos a la pantalla de lista de estudiantes
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceListPage()),
              );
            },
          );
        },
      ),
    );
  }
}
