import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_record.dart';

// Lista simulada de registros de asistencia
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

/// Provider que retorna la lista de asistencias para un [userId] dado.
final attendanceProvider = FutureProvider.family<List<AttendanceRecord>, String>(
  (ref, userId) async {
    // Simula pequeña latencia
    await Future.delayed(const Duration(milliseconds: 500));
    // Filtra solo los registros que correspondan a ese userId
    return _mockAttendanceRecords
        .where((record) => record.userId == userId)
        .toList();
  },
);
