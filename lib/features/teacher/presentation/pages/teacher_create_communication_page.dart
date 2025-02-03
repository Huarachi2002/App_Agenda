import 'package:app_task/shared/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/notifier/create_communication_notifier.dart';

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
      body: Stack(
        children:
        [
          const BackgroundGradient(),
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField('Título', _titleCtrl),
                  const SizedBox(height: 16),
                  _buildTextField('Contenido', _contentCtrl, maxLines: 4),
                  const SizedBox(height: 16),

                  // Botones o checkboxes para seleccionar cursos
                  _buildMultiSelect(
                    title: 'Cursos',
                    items: _availableCourses,
                    selectedItems: _selectedCourses,
                    onChanged: _toggleSelection,
                  ),
                  const SizedBox(height: 16),

                  _buildMultiSelect(
                    title: 'Materias',
                    items: _availableSubjects,
                    selectedItems: _selectedSubjects,
                    onChanged: _toggleSelection,
                  ),
                  const SizedBox(height: 16),

                  _buildMultiSelect(
                    title: 'Estudiantes',
                    items: _availableStudents,
                    selectedItems: _selectedStudents,
                    onChanged: _toggleSelection,
                  ),
                  const SizedBox(height: 24),

                  _buildCreateButton(createState, context),

                ],
              ),
            ),
          ),
        ),
        ]
    ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildMultiSelect({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8.0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return ChoiceChip(
              label: Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xff4c669f),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xff4c669f),
              backgroundColor: Colors.white.withOpacity(0.8),
              onSelected: (_) => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleSelection(String value) {
    setState(() {
      if (_selectedCourses.contains(value)) {
        _selectedCourses.remove(value);
      } else if (_availableCourses.contains(value)) {
        _selectedCourses.add(value);
      } else if (_selectedSubjects.contains(value)) {
        _selectedSubjects.remove(value);
      } else if (_availableSubjects.contains(value)) {
        _selectedSubjects.add(value);
      } else if (_selectedStudents.contains(value)) {
        _selectedStudents.remove(value);
      } else if (_availableStudents.contains(value)) {
        _selectedStudents.add(value);
      }
    });
  }


  Widget _buildCreateButton(AsyncValue createState, BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff4c669f),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: createState.isLoading ? null : () => _onCreate(context),
      icon: createState.isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
          : const Icon(Icons.send, color: Colors.white),
      label: const Text('Crear Comunicado', style: TextStyle(color: Colors.white)),
    );
  }


  // Botón de confirmar la creación
  Future<void> _onCreate(BuildContext context) async {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Comunicado creado correctamente'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }



}
