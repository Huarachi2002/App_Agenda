import 'package:app_task/features/attendance/presentation/controllers/student_attendance_controller.dart';
import 'package:app_task/features/attendance/presentation/models/filter_result.dart';
import 'package:app_task/features/attendance/presentation/pages/parent_attendance_content.dart';
import 'package:app_task/features/attendance/presentation/pages/teacher_attendance_content.dart';
import 'package:app_task/features/attendance/presentation/widgets/FilterDialog.dart';
import 'package:app_task/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formats.dart';
import '../../../../shared/widgets/background_gradient.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import 'package:app_task/features/attendance/presentation/controllers/student_attendance_controller.dart' as alumno;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const BackgroundGradient(), // Fondo degradado
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContentForUser(user),
            ),
          ),
        ],
      ),
    );


    // Si es estudiante, mostramos directo su asistencia
    if (user.role == UserRole.alumno) {
      return _buildScaffold(
        context,
        body: _buildAttendanceList(user.id),
      );
    }

    // Si es padre
    if (user.role == UserRole.tutor) {
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

    // Si es otro rol (docente/admin), de momento no mostramos nada
    return _buildScaffold(
      context,
      body: TeacherAttendanceContent(teacherId: userState.value!.id),
    );
  }

  Widget _buildContentForUser(UserEntity user) {
    if (user.role == UserRole.alumno) {
      return _buildAttendanceList(user.id);
    } else if (user.role == UserRole.tutor) {
      final hijoCount = _mockChildren.length;
      if (hijoCount == 1) {
        return _buildAttendanceList(_mockChildren.first['id']!);
      } else {
        return Stack(
          children: [
            const BackgroundGradient(),
            SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Seleccione un hijo para ver su agenda:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          dropdownColor: Colors.white,
                          hint: const Text(
                            'Seleccionar hijo',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: _selectedChildId,
                          items: _mockChildren.map((child) {
                            return DropdownMenuItem<String>(
                              value: child['id'],
                              child: Text(
                                child['name'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedChildId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedChildId != null)
                         Expanded(child: ParentAttendanceContent(selectedUserId: _selectedChildId,mockChildren: _mockChildren,)),
                    ],
                  ),
                )
            )
          ]

        );
      }
    }else if (user.role == UserRole.docente){
      return  TeacherAttendanceContent(teacherId: user.id);
    }else {
      return Container();
    }
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
      alumno.attendanceProvider(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black87,
                  ),
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
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      title: Text(
                        '${formatDateTime(record.date)} - ${record.subject}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        record.attended ? 'Asistió' : 'Falta',
                        style: TextStyle(
                          color: record.attended ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

}

