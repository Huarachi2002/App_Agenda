import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_task/features/attendance/presentation/controllers/student_attendance_controller.dart' as alumno;

import '../../../../core/utils/formats.dart';
import '../controllers/student_attendance_controller.dart';
import '../models/filter_result.dart';
import '../widgets/FilterDialog.dart';


class ParentAttendanceContent extends ConsumerStatefulWidget {
  final String? selectedUserId;
  final List<Map<String, String>> mockChildren;
  // este campo podría indicar para qué usuario (estudiante) se muestra la agenda
  // si es un estudiante, "selectedUserId" es su propio id
  // si es un padre, "selectedUserId" es el id del hijo seleccionado

  const ParentAttendanceContent({Key? key, this.selectedUserId, required this.mockChildren}) : super(key: key);

  @override
  ConsumerState<ParentAttendanceContent> createState() => _ParentAttendanceContentState();
}

class _ParentAttendanceContentState extends ConsumerState<ParentAttendanceContent> {
  String? _selectedSubject;    // Materia seleccionada
  DateTime? _startDate;        // Fecha de inicio
  DateTime? _endDate;          // Fecha de fin

  @override
  Widget build(BuildContext context) {
    // Aquí consultarías las tareas/comunicados a partir de selectedUserId
    // Por ahora, mostraremos un layout simulado
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _buildAttendanceList(widget.selectedUserId!),
      ],
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

    return Expanded(
      child: attendanceState.when(
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No hay registros de asistencia.'));
          }
          return
              // Lista de asistencia
              ListView.builder(
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
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHeader() {
    // Si deseas un texto referente al usuario/hijo seleccionado, podrías
    // mostrar: "Agenda de $selectedUserId" o algo similar.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        widget.selectedUserId == null
            ? 'Agenda'
            : 'Agenda de ${widget.selectedUserId}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
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
}
