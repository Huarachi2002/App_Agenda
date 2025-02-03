import 'package:flutter/material.dart';

class ParentAgendaContent extends StatelessWidget {
  final String? selectedUserId; 
  // este campo podría indicar para qué usuario (estudiante) se muestra la agenda
  // si es un estudiante, "selectedUserId" es su propio id
  // si es un padre, "selectedUserId" es el id del hijo seleccionado

  const ParentAgendaContent({Key? key, this.selectedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí consultarías las tareas/comunicados a partir de selectedUserId
    // Por ahora, mostraremos un layout simulado
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de Pendientes
          const Text(
            'Pendientes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texto sobre fondo oscuro
            ),
          ),
          const SizedBox(height: 8),
        
          // Card con la lista de pendientes
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              children: const [
                ListTile(title: Text('Tarea de matemáticas')),
                ListTile(title: Text('Comunicado: Reunión de padres')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        
          // Sección de Leídas
          const Text(
            'Leídas / Finalizadas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        
          // Card con la lista de leídas
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              children: const [
                ListTile(title: Text('Citaciones pasadas')),
                ListTile(title: Text('Tarea ya entregada')),
              ],
            ),
          ),
        ],
      ),
    );
  
  }

  Widget _buildHeader() {
    // Si deseas un texto referente al usuario/hijo seleccionado, podrías
    // mostrar: "Agenda de $selectedUserId" o algo similar.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        selectedUserId == null
            ? 'Agenda'
            : 'Agenda de $selectedUserId',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

}
