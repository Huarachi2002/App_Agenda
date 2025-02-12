import 'package:app_task/features/agenda/presentation/pages/admin_agenda_page.dart';
import 'package:app_task/features/auth/domain/entities/user.dart';
import 'package:app_task/features/agenda/presentation/pages/teacher_agenda_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../agenda/presentation/pages/agenda_page.dart';
import '../controllers/user_controller.dart';
import '../../../../shared/widgets/app_drawer.dart';

// Esta clase asume que "Home" es la página principal
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Si el rol es padre y hay varios hijos, guardamos el "hijo" seleccionado
  // Para demo, supongamos que tenemos un dropdown
  String? _selectedChildId;

  // Demo: supongamos que estos son los hijos del padre
  // En un caso real, esto vendría de una llamada a la base de datos
  // o de un provider que maneje la lista de hijos
  final List<Map<String, String>> _mockChildren = [
    {'id': 'child1', 'name': 'Hijo 1'},
    {'id': 'child2', 'name': 'Hijo 2'},
  ];

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    // Pantalla de carga o error
    if (userState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userState.hasError || user == null) {
      return const Scaffold(body: Center(child: Text('Error o sin sesión')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContentForUser(user),
        ),
      ),
    );
  }

  Widget _buildContentForUser(UserEntity user) {
    switch (user.role) {
      case UserRole.student:
        // Mostramos directamente la Agenda del estudiante
        return AgendaPage(selectedUserId: user.id);

      case UserRole.parent:
        // Mostramos selección de hijo (si hay varios)
        // o directamente la agenda si solo hay uno
        final hijosCount = _mockChildren.length;
        if (hijosCount == 1) {
          // Si solo tiene 1 hijo, mostramos la agenda de ese hijo
          return AgendaPage(selectedUserId: _mockChildren.first['id']);
        } else {
          // Si tiene varios, mostramos un dropdown
          // y cuando seleccione uno, mostramos la agenda
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seleccione un hijo para ver su agenda:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  child: AgendaPage(selectedUserId: _selectedChildId),
                ),
            ],
          );
        }

      case UserRole.teacher:
        return const TeacherAgendaContent();

      case UserRole.admin:
        return const AdminAgendaPage();
    }
  }
}
