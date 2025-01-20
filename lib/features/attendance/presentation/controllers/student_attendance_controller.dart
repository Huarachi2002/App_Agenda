import 'package:app_task/features/attendance/domain/entities/attendance_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentAttendanceFilter {
  final String userId;          // El ID del estudiante
  final String? subject;        // Materia (opcional)
  final DateTime? startDate;    // Inicio del rango de fechas (opcional)
  final DateTime? endDate;      // Fin del rango de fechas (opcional)

  const StudentAttendanceFilter({
    required this.userId,
    this.subject,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAttendanceFilter &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          subject == other.subject &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      userId.hashCode ^ subject.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

final _mockAttendanceRecords = <AttendanceRecord>[
  AttendanceRecord(
    id: 'a1',
    userId: 'stu001',
    date: DateTime(2023, 9, 1, 8, 0),
    subject: 'Matemáticas',
    course: '1A',
    attended: true,
  ),
  AttendanceRecord(
    id: 'a2',
    userId: 'stu001',
    date: DateTime(2023, 9, 1, 10, 0),
    subject: 'Lengua',
    course: '1A',
    attended: false,
  ),
  AttendanceRecord(
    id: 'a3',
    userId: 'stu002',
    date: DateTime(2023, 9, 2, 9, 30),
    subject: 'Historia',
    course: '1B',
    attended: true,
  ),
  AttendanceRecord(
    id: 'a4',
    userId: 'stu003',
    date: DateTime(2023, 9, 5, 7, 30),
    subject: 'Física',
    course: '2A',
    attended: true,
  ),

  AttendanceRecord(
    id: 'a1',
    userId: 'child1',
    date: DateTime(2023, 9, 1, 8, 0),
    subject: 'Matemáticas',
    course: '2A',
    attended: true,
  ),
  AttendanceRecord(
    id: 'a2',
    userId: 'child1',
    date: DateTime(2023, 9, 1, 10, 0),
    subject: 'Lengua',
    course: '1B',
    attended: false,
  ),
  AttendanceRecord(
    id: 'a3',
    userId: 'child2',
    date: DateTime(2023, 9, 2, 9, 30),
    subject: 'Historia',
    course: '1A',
    attended: true,
  ),
  AttendanceRecord(
    id: 'a4',
    userId: '123', // Podría ser el ID de un estudiante real
    date: DateTime(2023, 9, 5, 7, 30),
    subject: 'Física',
    course: '1A',
    attended: true,
  ),
  // ...agrega más registros
];

final attendanceProvider = FutureProvider.family<List<AttendanceRecord>, StudentAttendanceFilter>(
  (ref, filter) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulación de latencia

    return _mockAttendanceRecords.where((record) {
      // Filtrar por usuario
      if (record.userId != filter.userId) return false;

      // Filtrar por materia
      if (filter.subject != null && filter.subject!.isNotEmpty) {
        if (record.subject != filter.subject) return false;
      }

      // Filtrar por rango de fechas (inclusivo)
      if (filter.startDate != null) {
        if (record.date.isBefore(filter.startDate!)) return false;
      }
      if (filter.endDate != null) {
        final inclusiveEnd = filter.endDate!.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
        if (record.date.isAfter(inclusiveEnd)) return false;
      }

      return true; // Pasa todos los filtros
    }).toList();
  },
);
