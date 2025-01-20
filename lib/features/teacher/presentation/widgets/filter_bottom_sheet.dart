import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCourse;
  final String? initialSubject;
  final String? initialStudentId;
  final Function(String?, String?, String?) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialCourse,
    this.initialSubject,
    this.initialStudentId,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _course;
  String? _subject;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _course = widget.initialCourse;
    _subject = widget.initialSubject;
    _studentId = widget.initialStudentId;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta la altura al contenido
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Curso
            DropdownButtonFormField<String>(
              value: _course,
              decoration: const InputDecoration(labelText: 'Curso'),
              items: const [
                DropdownMenuItem(child: Text('1A'), value: '1A'),
                DropdownMenuItem(child: Text('1B'), value: '1B'),
                DropdownMenuItem(child: Text('2A'), value: '2A'),
                // etc.
              ],
              onChanged: (value) => setState(() => _course = value),
            ),

            // Materia
            DropdownButtonFormField<String>(
              value: _subject,
              decoration: const InputDecoration(labelText: 'Materia'),
              items: const [
                DropdownMenuItem(child: Text('Matemáticas'), value: 'Matemáticas'),
                DropdownMenuItem(child: Text('Lengua'), value: 'Lengua'),
                DropdownMenuItem(child: Text('Historia'), value: 'Historia'),
                // etc.
              ],
              onChanged: (value) => setState(() => _subject = value),
            ),

            // Estudiante
            TextFormField(
              initialValue: _studentId,
              decoration: const InputDecoration(labelText: 'ID de Estudiante'),
              onChanged: (value) => _studentId = value,
            ),

            const SizedBox(height: 16),
             
            ElevatedButton(
              onPressed: () {
                // Al aplicar, retornamos al caller
                widget.onApply(_course, _subject, _studentId);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
