import 'package:app_task/features/agenda/domain/entities/teacher_agenda_item.dart';
import 'package:app_task/shared/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/presentation/controllers/teacher_agenda_controller.dart';
import '../../../teacher/presentation/pages/teacher_create_communication_page.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import 'package:app_task/features/auth/domain/entities/user.dart';

// (opcional) Importar un provider que maneje la lista de notificaciones/tareas

class TeacherAgendaContent extends ConsumerStatefulWidget {
  const TeacherAgendaContent({Key? key}) : super(key: key);

  @override
  ConsumerState<TeacherAgendaContent> createState() => _TeacherAgendaContentState();
}

class _TeacherAgendaContentState extends ConsumerState<TeacherAgendaContent> {
  // Variables de estado para el filtro
  String? _selectedCourse;   // Ej: "1A", "2B", etc.
  String? _selectedSubject;  // Ej: "Matemáticas", "Lengua", etc.
  String? _selectedStudentId; // ID del estudiante específico

  @override
  Widget build(BuildContext context) {

    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    // Validamos que el user sea un docente
    if (user == null || user.role != UserRole.docente) {
      return const Center(child: Text('No tienes permisos de docente'));
    }

    // Observamos la información de la agenda
    // (aquí un provider hipotético teacherAgendaProvider)
    final agendaState = ref.watch(teacherAgendaProvider(
      TeacherAgendaFilter(
        course: _selectedCourse,
        subject: _selectedSubject,
        studentId: _selectedStudentId,
      ),
    ));

    debugPrint('TeacherAgendaContent -> Filtros: '
    'course=$_selectedCourse, subject=$_selectedSubject, studentId=$_selectedStudentId');


    return Stack(
        children: [
          // Fondo gradiente
          const BackgroundGradient(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Encabezado con botones
                _buildHeader(context),

                // Expanded para la lista
                Expanded(
                  child: agendaState.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(child: Text('No hay notificaciones/tareas.'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _AgendaItemCard(item: item);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ),
        ],
      );


  }

  // Encabezado con "Nuevo Comunicado" y "Filtrar"
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black87,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCommunicationPage()),
                );
              },
              child: const Text('Nuevo Comunicado'),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.black87,
            ),
            onPressed: _openFilterDialog,
            icon: const Icon(Icons.filter_list),
            label: const Text('Filtrar'),
          ),
        ],
      ),
    );
  }

  
  

  void _openFilterDialog() async {
    final result = await showDialog<_FilterResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Filtrar'),
      content: _FilterDialogContent(
          initialCourse: _selectedCourse,
          initialSubject: _selectedSubject,
          initialStudentId: _selectedStudentId,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCourse = result.course;
        _selectedSubject = result.subject;
        _selectedStudentId = result.studentId;

        debugPrint('Filtro aplicado: course=$_selectedCourse, subject=$_selectedSubject, studentId=$_selectedStudentId');
      });
    }
  }

}

// Card para mostrar cada ítem de la agenda
class _AgendaItemCard extends StatelessWidget {
  final AgendaItem item;
  const _AgendaItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_buildSubtitle(item)),
      ),
    );
  }

  String _buildSubtitle(AgendaItem item) {
    final buffer = StringBuffer();
    if (item.course != null) {
      buffer.write('Curso: ${item.course}');
      if (item.entireCourse) {
        buffer.write(' (todo el curso)');
      }
    }
    if (item.subject != null) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('Materia: ${item.subject}');
    }
    if (item.studentId != null) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('Estudiante: ${item.studentId}');
    }
    return buffer.isEmpty ? 'Sin destinatario específico' : buffer.toString();
  }
}

// Modelo interno para guardar resultado del diálogo
class _FilterResult {
  final String? course;
  final String? subject;
  final String? studentId;

  _FilterResult({this.course, this.subject, this.studentId});
}

// Contenido del diálogo de filtro
class _FilterDialogContent extends StatefulWidget {
  final String? initialCourse;
  final String? initialSubject;
  final String? initialStudentId;

  const _FilterDialogContent({
    Key? key,
    this.initialCourse,
    this.initialSubject,
    this.initialStudentId,
  }) : super(key: key);

  @override
  _FilterDialogContentState createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<_FilterDialogContent> {
  String? course;
  String? subject;
  String? studentId;

  @override
  void initState() {
    super.initState();
    course = widget.initialCourse;
    subject = widget.initialSubject;
    studentId = widget.initialStudentId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: course,
          decoration: const InputDecoration(labelText: 'Curso'),
          items: const [
            DropdownMenuItem(child: Text('1A'), value: '1A'),
            DropdownMenuItem(child: Text('1B'), value: '1B'),
            DropdownMenuItem(child: Text('2A'), value: '2A'),
            // etc.
          ],
          onChanged: (value) => setState(() => course = value),
        ),
        const SizedBox(height: 8),
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
        TextFormField(
          initialValue: studentId,
          decoration: const InputDecoration(labelText: 'ID de Estudiante'),
          onChanged: (value) => studentId = value,
        ),
        const SizedBox(height: 16),
      // Botón de "Limpiar Filtro"
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _FilterResult(
              course: null,
              subject: null,
              studentId: null,
            ));

            },
            child: const Text('Limpiar Filtro', style: TextStyle(color: Color(0xff192f6a),)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _FilterResult(
                course: course,
                subject: subject,
                studentId: studentId,
              ));
            },
            child: const Text('Aplicar', style: TextStyle(color: Color(0xff192f6a),)),
          ),
        ],
      )
          

      ],
    );
  }
}
