import 'package:app_task/features/attendance/presentation/controllers/notifier/create_list_attendance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceListPage extends ConsumerWidget {
  const AttendanceListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherAttendanceProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }
    if (state.selectedCourse == null) {
      return Scaffold(body: Center(child: Text('Ningún curso seleccionado.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia - ${state.selectedCourse!.courseName}'),
      ),
      body: ListView.builder(
        itemCount: state.students.length,
        itemBuilder: (context, index) {
          final student = state.students[index];
          return CheckboxListTile(
            title: Text(student.fullName),
            value: student.isPresent,
            onChanged: (value) {
              ref
                  .read(teacherAttendanceProvider.notifier)
                  .toggleAttendance(student.studentId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          // Guardar asistencia
          await ref.read(teacherAttendanceProvider.notifier).saveAttendance();
          // Podemos mostrar un Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asistencia guardada')),
          );
          Navigator.pop(context); // Regresa a la pantalla previa
        },
      ),
    );
  }
}
