import 'package:app_task/features/attendance/presentation/controllers/student_attendance_controller.dart';
import 'package:app_task/features/attendance/presentation/models/filter_result.dart';
import 'package:app_task/features/attendance/presentation/pages/teacher_attendance_content.dart';
import 'package:app_task/features/attendance/presentation/widgets/FilterDialog.dart';
import 'package:app_task/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import 'package:app_task/features/attendance/presentation/controllers/student_attendance_controller.dart' as student;

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  // Simulemos hijos del padre
  final List<Map<String, String>> _mockChildren = [
    {'id': 'child1', 'name': 'Hijo 1'},
    {'id': 'child2', 'name': 'Hijo 2'},
  ];
  String? _selectedChildId; // para cuando es padre
  String? _selectedSubject;    // Materia seleccionada
  DateTime? _startDate;        // Fecha de inicio
  DateTime? _endDate;          // Fecha de fin
  

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    // Estado de carga o error
    if (userState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (userState.hasError || user == null) {
      return const Scaffold(
        body: Center(child: Text('Error o sin sesión')),
      );
    }

    // Si es estudiante, mostramos directo su asistencia
    if (user.role == UserRole.student) {
      return _buildScaffold(
        context,
        body: _buildAttendanceList(user.id),
      );
    }

    // Si es padre
    if (user.role == UserRole.parent) {
      // Verificamos cuantos hijos hay
      final hijoCount = _mockChildren.length;
      if (hijoCount == 1) {
        // Si solo tiene 1 hijo, mostrar directo
        final childId = _mockChildren.first['id']!;
        return _buildScaffold(
          context,
          body: _buildAttendanceList(childId),
        );
      } else {
        // Si tiene varios, selección
        return _buildScaffold(
          context,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccione un hijo para ver la asistencia:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                hint: const Text('Seleccionar hijo'),
                value: _selectedChildId,
                items: _mockChildren.map((child) {
                  return DropdownMenuItem<String>(
                    value: child['id'],
                    child: Text(child['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              // Si ya seleccionó uno
              
              if (_selectedChildId != null)
                Expanded(
                  child: _buildAttendanceList(_selectedChildId!),
              ),
            ],
          ),
        );
      }
    }

    // Si es otro rol (teacher/admin), de momento no mostramos nada
    return _buildScaffold(
      context,
      body: TeacherAttendanceContent(teacherId: userState.value!.id),
    );
  }

  void _openFilterDialog() async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder: (ctx) => FilterDialog(
        initialSubject: _selectedSubject,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSubject = result.subject;
        _startDate = result.startDate;
        _endDate = result.endDate;
      });
    }
  }

  
  /// Construye el Scaffold con AppBar (si lo deseas)
  Widget _buildScaffold(BuildContext ctx, {required Widget body}) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
    );
  }

  /// Crea la lista de asistencias para un userId concreto
  Widget _buildAttendanceList(String userId) {
    final attendanceState = ref.watch(
      student.attendanceProvider(
        StudentAttendanceFilter(
          userId: userId,
          subject: _selectedSubject,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    return attendanceState.when(
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No hay registros de asistencia.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón de filtro
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrar'),
                  onPressed: _openFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Lista de asistencia
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    title: Text(
                      '${_formatDateTime(record.date)} - ${record.subject}',
                    ),
                    subtitle: Text(record.attended
                        ? 'Asistió'
                        : 'Falta'),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  String _formatDateTime(DateTime dt) {
    // Ejemplo simplificado: "2023-09-05 07:30"
    final dateString = '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)}';
    final timeString = '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
    return '$dateString $timeString';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';
}

