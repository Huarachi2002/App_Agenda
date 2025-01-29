import 'package:app_task/features/teacher/presentation/controllers/notifier/create_communication_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunicationPage extends ConsumerStatefulWidget {
  const CreateCommunicationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCommunicationPage> createState() => _CreateCommunicationPageState();
}

class _CreateCommunicationPageState extends ConsumerState<CreateCommunicationPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // Listas de opciones (cursos, materias, estudiantes) para demo
  final _availableCourses = ['1A', '1B', '2A'];
  final _availableSubjects = ['Matemáticas', 'Lengua', 'Historia'];
  final _availableStudents = ['stu001', 'stu002', 'stu003'];

  // Selecciones del usuario
  List<String> _selectedCourses = [];
  List<String> _selectedSubjects = [];
  List<String> _selectedStudents = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCommunicationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Comunicado')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
              const SizedBox(height: 16),

              // Botones o checkboxes para seleccionar cursos
              _buildMultiSelect(
                title: 'Cursos',
                items: _availableCourses,
                selectedItems: _selectedCourses,
                onChanged: (value) {
                  setState(() {
                    if (_selectedCourses.contains(value)) {
                      _selectedCourses.remove(value);
                    } else {
                      _selectedCourses.add(value);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Seleccionar materias
              _buildMultiSelect(
                title: 'Materias',
                items: _availableSubjects,
                selectedItems: _selectedSubjects,
                onChanged: (value) {
                  setState(() {
                    if (_selectedSubjects.contains(value)) {
                      _selectedSubjects.remove(value);
                    } else {
                      _selectedSubjects.add(value);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Seleccionar estudiantes
              _buildMultiSelect(
                title: 'Estudiantes',
                items: _availableStudents,
                selectedItems: _selectedStudents,
                onChanged: (value) {
                  setState(() {
                    if (_selectedStudents.contains(value)) {
                      _selectedStudents.remove(value);
                    } else {
                      _selectedStudents.add(value);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: createState.isLoading ? null : _onCreate,
                child: createState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear Comunicado'),
              ),

              createState.when(
                data: (comm) {
                  if (comm == null) return const SizedBox();
                  return Text('Comunicado creado con ID: ${comm.id}');
                },
                loading: () => const SizedBox(),
                error: (err, st) => Text('Error: $err'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Botón de confirmar la creación
  Future<void> _onCreate() async {
    // Combina los destinatarios: cursos + materias + estudiantes
    // Podrías preferir guardarlos en campos separados en el backend
    final recipients = <String>[
      ..._selectedCourses.map((c) => 'course_$c'),
      ..._selectedSubjects.map((s) => 'subject_$s'),
      ..._selectedStudents.map((st) => 'student_$st'),
    ];

    await ref.read(createCommunicationProvider.notifier).createCommunication(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      recipients: recipients,
    );
  }

  // Widget helper para multi-selección (demo)
  Widget _buildMultiSelect({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (_) => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
