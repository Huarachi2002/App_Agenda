import 'package:app_task/features/agenda/presentation/pages/admin_agenda_page.dart';
import 'package:app_task/features/agenda/presentation/pages/parent_agenda_content.dart';
import 'package:app_task/features/auth/domain/entities/user.dart';
import 'package:app_task/features/agenda/presentation/pages/teacher_agenda_content.dart';
import 'package:app_task/shared/widgets/background_gradient.dart';
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
        child: _buildContentForUser(user),
      ),
    );
  }

  Widget _buildContentForUser(UserEntity user) {
    switch (user.role) {
      case UserRole.alumno:
        // Mostramos directamente la Agenda del estudiante
        return AgendaPage(selectedUserId: user.id);

      case UserRole.tutor:
        // Mostramos selección de hijo (si hay varios)
        // o directamente la agenda si solo hay uno
        final hijosCount = _mockChildren.length;
        if (hijosCount == 1) {
          // Si solo tiene 1 hijo, mostramos la agenda de ese hijo
          return AgendaPage(selectedUserId: _mockChildren.first['id']);
        } else {
          // Si tiene varios, mostramos un dropdown
          // y cuando seleccione uno, mostramos la agenda
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
                      Expanded(
                        child: ParentAgendaContent(selectedUserId: _selectedChildId)
                      ),
                    ],
                  ),
                )
              )
            ],
          );
          
          
        }

      case UserRole.docente:
        return const TeacherAgendaContent();

      case UserRole.admin:
        return const AdminAgendaPage();
    }
  }
}
