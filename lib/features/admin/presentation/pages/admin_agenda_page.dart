import 'package:app_task/features/admin/presentation/controller/admin_agenda_controller.dart';
import 'package:app_task/features/admin/presentation/controller/admin_agenda_provider.dart';
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: agendaState.when(
        data: (communications) {
          if (communications.isEmpty) {
            return const Center(child: Text('No hay comunicados.'));
          }
          return ListView.builder(
            itemCount: communications.length,
            itemBuilder: (context, index) {
              final comm = communications[index];
              return ListTile(
                title: Text(comm.title),
                subtitle: Text(_buildSubtitle(comm)),
                onTap: () {
                  // Podrías mostrar detalles, editar, etc.
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _buildSubtitle(CommunicationEntity comm) {
    final dateStr = '${comm.createdAt.day}/${comm.createdAt.month}/${comm.createdAt.year}';
    return 'Creado el $dateStr, Destinatarios: ${comm.recipients.join(', ')}';
  }

  void _openFilterDialog() async {
    // showDialog o showModalBottomSheet
    // Pide al usuario que seleccione course/subject/student y un rango de fecha
    // Luego setState con las selecciones
  }
}
