import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/teacher_agenda_item.dart';

/// Clase para contener los criterios de filtro
class TeacherAgendaFilter {
  final String? course;
  final String? subject;
  final String? studentId;

  const TeacherAgendaFilter({
    this.course,
    this.subject,
    this.studentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAgendaFilter &&
          runtimeType == other.runtimeType &&
          course == other.course &&
          subject == other.subject &&
          studentId == other.studentId;

  @override
  int get hashCode =>
      course.hashCode ^ subject.hashCode ^ studentId.hashCode;
}

// Lista mock de items para simular la agenda del docente
final List<TeacherAgendaItem> _mockTeacherItems = [
  TeacherAgendaItem(
    id: '1',
    title: 'Comunicado general para 1A',
    course: '1A',
    entireCourse: true,
  ),
  TeacherAgendaItem(
    id: '2',
    title: 'Tarea de Matemáticas #2',
    course: '1A',
    subject: 'Matemáticas',
    entireCourse: false,
  ),
  TeacherAgendaItem(
    id: '3',
    title: 'Notificación para estudiante st001 en 2B - Lengua',
    course: '2B',
    subject: 'Lengua',
    studentId: 'st001',
  ),
  TeacherAgendaItem(
    id: '4',
    title: 'Aviso general para 2B',
    course: '2B',
    entireCourse: true,
  ),
  TeacherAgendaItem(
    id: '5',
    title: 'Tarea de Historia #1 para 1B',
    course: '1B',
    subject: 'Historia',
  ),
];

// Este provider es un FutureProvider.family que filtra la lista mock.
final teacherAgendaProvider =
  FutureProvider.family<List<TeacherAgendaItem>, TeacherAgendaFilter>(
    (ref, filter) async {
      // Para debug, imprime algo al entrar
      // (Te asegura que el provider se está ejecutando)
      // Simulamos un delay de red
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
    },
  );