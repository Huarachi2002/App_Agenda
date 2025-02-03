import 'package:app_task/features/attendance/presentation/pages/select_course_page.dart';
import 'package:app_task/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formats.dart';
import '../controllers/teacher_attendance_controller.dart';

class TeacherAttendanceContent extends ConsumerStatefulWidget {
  final String teacherId; // <-- Recibimos la ID aquí
   const TeacherAttendanceContent({Key? key, required this.teacherId}) : super(key: key);

  @override
  ConsumerState<TeacherAttendanceContent> createState() => _TeacherAttendanceContentState();
}

class _TeacherAttendanceContentState extends ConsumerState<TeacherAttendanceContent> {
  String? _selectedCourse;
  String? _selectedSubject;
  String? _selectedStudentId;
  DateTime? _startDate;
  DateTime? _endDate;
  

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(
      teacherAttendanceProvider(
        TeacherAttendanceFilter(
          course: _selectedCourse,
          subject: _selectedSubject,
          studentId: _selectedStudentId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de filtros
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SelectCoursePage(teacherId: widget.teacherId)), //TODO: Crear Lista de Asistencia
                  );
                },
                child: const Text('Crear Registro de Asistencia',style: TextStyle(color: Color(0xff192f6a)),),
              ),
            ),
            const SizedBox(width: 12),
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
        Expanded(
          child: attendanceState.when(
            data: (records) {
              if (records.isEmpty) {
                return const Center(child: Text('No hay registros de asistencia.'));
              }
              return ListView.builder(
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
            error: (err, st) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
  
  void _openFilterDialog() async {
    final result = await showDialog<_TeacherAttendanceFilterResult>(
      context: context,
      builder: (ctx) => _TeacherFilterDialog(
        initialCourse: _selectedCourse,
        initialSubject: _selectedSubject,
        initialStudentId: _selectedStudentId,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCourse = result.course;
        _selectedSubject = result.subject;
        _selectedStudentId = result.studentId;
        _startDate = result.startDate;
        _endDate = result.endDate;
      });
    }
  }
}

/// Resultado que regresa el diálogo de filtro
class _TeacherAttendanceFilterResult {
  final String? course;
  final String? subject;
  final String? studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  _TeacherAttendanceFilterResult({
    this.course,
    this.subject,
    this.studentId,
    this.startDate,
    this.endDate,
  });
}

class _TeacherFilterDialog extends StatefulWidget {
  final String? initialCourse;
  final String? initialSubject;
  final String? initialStudentId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const _TeacherFilterDialog({
    Key? key,
    this.initialCourse,
    this.initialSubject,
    this.initialStudentId,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  _TeacherFilterDialogState createState() => _TeacherFilterDialogState();
}

class _TeacherFilterDialogState extends State<_TeacherFilterDialog> {
  String? course;
  String? subject;
  String? studentId;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    course = widget.initialCourse;
    subject = widget.initialSubject;
    studentId = widget.initialStudentId;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Asistencia'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Curso
            DropdownButtonFormField<String>(
              value: course,
              decoration: const InputDecoration(labelText: 'Curso'),
              items: const [
                DropdownMenuItem(child: Text('1A'), value: '1A'),
                DropdownMenuItem(child: Text('1B'), value: '1B'),
                DropdownMenuItem(child: Text('2A'), value: '2A'),
              ],
              onChanged: (value) => setState(() => course = value),
            ),
            const SizedBox(height: 8),
            // Materia
            DropdownButtonFormField<String>(
              value: subject,
              decoration: const InputDecoration(labelText: 'Materia'),
              items: const [
                DropdownMenuItem(child: Text('Matemáticas'), value: 'Matemáticas'),
                DropdownMenuItem(child: Text('Lengua'), value: 'Lengua'),
                DropdownMenuItem(child: Text('Historia'), value: 'Historia'),
              ],
              onChanged: (value) => setState(() => subject = value),
            ),
            const SizedBox(height: 8),
            // Estudiante (ID)
            TextFormField(
              initialValue: studentId,
              decoration: const InputDecoration(labelText: 'ID de Estudiante'),
              onChanged: (value) => studentId = value,
            ),
            const SizedBox(height: 8),
            // Fecha inicial
            Row(
              children: [
                Expanded(
                  child: Text(startDate == null
                      ? 'Fecha inicio: ---'
                      : 'Fecha inicio: ${formatDate(startDate!)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
              ],
            ),
            // Fecha final
            Row(
              children: [
                Expanded(
                  child: Text(endDate == null
                      ? 'Fecha fin: ---'
                      : 'Fecha fin: ${formatDate(endDate!)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Botón de Limpiar
        TextButton(
          onPressed: () {
            Navigator.pop(context, _TeacherAttendanceFilterResult());
          },
          child: const Text('Limpiar'),
        ),
        // Botón de Cancelar
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // Botón de Aplicar
        TextButton(
          onPressed: () {
            Navigator.pop<_TeacherAttendanceFilterResult>(
              context,
              _TeacherAttendanceFilterResult(
                course: course,
                subject: subject,
                studentId: studentId,
                startDate: startDate,
                endDate: endDate,
              ),
            );
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  String formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';
}

