import 'package:app_task/features/admin/presentation/controller/admin_agenda_controller.dart';
import 'package:app_task/features/admin/presentation/controller/admin_agenda_provider.dart';
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
import 'package:app_task/features/agenda/domain/entities/teacher_agenda_item.dart';
import 'package:app_task/features/teacher/presentation/pages/teacher_create_communication_page.dart';
import 'package:app_task/shared/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAgendaPage extends ConsumerStatefulWidget {
  const AdminAgendaPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminAgendaPage> createState() => _AdminAgendaPageState();
}

class _AdminAgendaPageState extends ConsumerState<AdminAgendaPage> {
  String? _selectedCourse;
  String? _selectedSubject;
  String? _selectedStudentId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final agendaState = ref.watch(
      adminAgendaProvider(
        AdminAgendaFilter(
          course: _selectedCourse,
          subject: _selectedSubject,
          studentId: _selectedStudentId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    return  Stack(
      children: [
        // 1) Fondo gradiente
        const BackgroundGradient(),

        // 2) Contenido
        SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

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
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  loading: () => const Center(child: CircularProgressIndicator())
                )
              )
            ],
          )
          
        ),
      ],
    );
    

    
  }

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
