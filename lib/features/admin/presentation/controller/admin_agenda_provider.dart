
// FutureProvider.family para pasar un filtro
import 'package:app_task/features/admin/presentation/controller/admin_agenda_controller.dart';
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
import 'package:app_task/features/agenda/domain/entities/teacher_agenda_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Lista mock de items para simular la agenda del docente
final List<AgendaItem> _mockTeacherItems = [
  AgendaItem(
    id: '1',
    title: 'Comunicado general para 1A',
    course: '1A',
    entireCourse: true,
  ),
  AgendaItem(
    id: '2',
    title: 'Tarea de Matemáticas #2',
    course: '1A',
    subject: 'Matemáticas',
    entireCourse: false,
  ),
  AgendaItem(
    id: '3',
    title: 'Notificación para estudiante st001 en 2B - Lengua',
    course: '2B',
    subject: 'Lengua',
    studentId: 'st001',
  ),
  AgendaItem(
    id: '4',
    title: 'Aviso general para 2B',
    course: '2B',
    entireCourse: true,
  ),
  AgendaItem(
    id: '5',
    title: 'Tarea de Historia #1 para 1B',
    course: '1B',
    subject: 'Historia',
  ),
];

final adminAgendaProvider = FutureProvider.family<List<AgendaItem>, AdminAgendaFilter>(
  (ref, filter) async {

    await Future.delayed(const Duration(milliseconds: 500));

      // Aplica el filtro
      final result = _mockTeacherItems.where((item) {
        debugPrint('Aplicando filtro: course=${filter.course}, subject=${filter.subject}, studentId=${filter.studentId}');

        // Filtrar por curso
        if (filter.course != null && filter.course!.isNotEmpty) {
          if (item.course != filter.course) return false;
        }
        // Filtrar por materia
        if (filter.subject != null && filter.subject!.isNotEmpty) {
          if (item.subject != filter.subject) return false;
        }
        // Filtrar por estudiante
        if (filter.studentId != null && filter.studentId!.isNotEmpty) {
          if (item.studentId != filter.studentId) return false;
        }
        return true;
      }).toList();

      // Retorna la lista
      return result;
    // final repo = ref.watch(communicationRepositoryProvider);

    // final filtersMap = <String, dynamic>{};
    // if (filter.course != null) filtersMap['course'] = filter.course;
    // if (filter.subject != null) filtersMap['subject'] = filter.subject;
    // if (filter.studentId != null) filtersMap['studentId'] = filter.studentId;
    // // etc. con startDate / endDate

    // return await repo.getCommunications(filters: filtersMap);
  },
);
