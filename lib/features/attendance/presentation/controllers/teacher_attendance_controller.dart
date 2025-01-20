import 'package:app_task/features/attendance/domain/entities/attendance_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherAttendanceFilter {
  final String? course;       // ej: "1A", "2B"
  final String? subject;      // ej: "Matemáticas"
  final String? studentId;    // ej: "stu001"
  final DateTime? startDate;  // inicio de rango
  final DateTime? endDate;    // fin de rango

  const TeacherAttendanceFilter({
    this.course,
    this.subject,
    this.studentId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAttendanceFilter &&
          runtimeType == other.runtimeType &&
          course == other.course &&
          subject == other.subject &&
          studentId == other.studentId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      course.hashCode ^
      subject.hashCode ^
      studentId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
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

final teacherAttendanceProvider = FutureProvider.family<List<AttendanceRecord>, TeacherAttendanceFilter>(
  (ref, filter) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulamos latencia

    return _mockAttendanceRecords.where((record) {
      // Filtrar por curso
      if (filter.course != null && filter.course!.isNotEmpty) {
        if (record.course != filter.course) return false;
      }

      // Filtrar por materia
      if (filter.subject != null && filter.subject!.isNotEmpty) {
        if (record.subject != filter.subject) return false;
      }

      // Filtrar por estudiante (userId)
      if (filter.studentId != null && filter.studentId!.isNotEmpty) {
        if (record.userId != filter.studentId) return false;
      }

      // Filtrar por rango de fechas
      if (filter.startDate != null) {
        if (record.date.isBefore(filter.startDate!)) return false;
      }
      if (filter.endDate != null) {
        // La fecha debe ser <= endDate
        if (record.date.isAfter(filter.endDate!.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)))) {
          return false;
        }
      }

      return true; // Pasa todos los filtros
    }).toList();
  },
);


