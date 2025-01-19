import 'package:flutter/material.dart';

class AgendaPage extends StatelessWidget {
  final String? selectedUserId; 
  // este campo podría indicar para qué usuario (estudiante) se muestra la agenda
  // si es un estudiante, "selectedUserId" es su propio id
  // si es un padre, "selectedUserId" es el id del hijo seleccionado

  const AgendaPage({Key? key, this.selectedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí consultarías las tareas/comunicados a partir de selectedUserId
    // Por ahora, mostraremos un layout simulado
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pendientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // TODO: Lista de pendientes
        Expanded(
          child: ListView(
            children: const [
              ListTile(title: Text('Tarea de matemáticas')),
              ListTile(title: Text('Comunicado: Reunión de padres')),
            ],
          ),
        ),
        const Divider(),
        const Text(
          'Leídas / Finalizadas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView(
            children: const [
              ListTile(title: Text('Citaciones pasadas')),
              ListTile(title: Text('Tarea ya entregada')),
            ],
          ),
        ),
      ],
    );
  }
}
