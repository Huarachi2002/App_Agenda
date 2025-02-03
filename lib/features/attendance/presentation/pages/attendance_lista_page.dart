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
        title: Text('Asistencia - ${state.selectedCourse?.courseName ?? "Curso"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(state, ref, context),
      ),

    );
  }

  /// Construcción del cuerpo según estado
  Widget _buildBody(TeacherAttendanceState state, WidgetRef ref, BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(state.error!, ref);
    }

    if (state.selectedCourse == null) {
      return _buildNoCourseSelected();
    }

    return Column(
      children: [
        _buildAttendanceStatus(state), // Mostrar estado general de asistencia
        const SizedBox(height: 12),
        Expanded(child: _buildStudentList(state, ref)),
        const SizedBox(height: 16),
        _buildSaveButton(ref, context), // Botón de guardar asistencia
      ],
    );
  }

  /// UI para mostrar error con opción de reintentar
  Widget _buildError(String error, WidgetRef ref) {
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
              ref.read(teacherAttendanceProvider.notifier).loadCourses("teacherId");
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

  /// UI para cuando no hay curso seleccionado
  Widget _buildNoCourseSelected() {
    return const Center(
      child: Text(
        'Ningún curso seleccionado.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }


  /// Muestra el estado de asistencia
  Widget _buildAttendanceStatus(TeacherAttendanceState state) {
    final totalStudents = state.students.length;
    final presentCount = state.students.where((s) => s.isPresent).length;
    final absentCount = totalStudents - presentCount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Asistencia: $presentCount / $totalStudents',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Chip(
              backgroundColor: Colors.green.withOpacity(0.2),
              label: Text(
                'Faltas: $absentCount',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de estudiantes con mejor UI
  Widget _buildStudentList(TeacherAttendanceState state, WidgetRef ref) {
    return ListView.separated(
      itemCount: state.students.length,
      separatorBuilder: (_, __) => const Divider(thickness: 1),
      itemBuilder: (context, index) {
        final alumno = state.students[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: alumno.isPresent ? Colors.green : Colors.red,
              child: Text(
                alumno.fullName[0], // Primera letra del nombre
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              alumno.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: Switch(
              value: alumno.isPresent,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              onChanged: (value) {
                ref.read(teacherAttendanceProvider.notifier).toggleAttendance(alumno.studentId);
              },
            ),
          ),
        );
      },
    );
  }


  /// Botón para guardar asistencia
  Widget _buildSaveButton(WidgetRef ref, BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff4c669f),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        await ref.read(teacherAttendanceProvider.notifier).saveAttendance();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Asistencia guardada'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      },
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text('Guardar Asistencia', style: TextStyle(color: Colors.white)),
    );
  }
}
