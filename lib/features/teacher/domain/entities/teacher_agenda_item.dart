class TeacherAgendaItem {
  final String id;
  final String title;

  /// Curso al que va dirigido (ej. "1A", "2B", etc.)
  final String? course;

  /// Materia específica (ej. "Matemáticas", "Lengua"), si aplica.
  final String? subject;

  /// ID de estudiante específico, si aplica.
  final String? studentId;

  /// Indica si va para todo el curso (entero).
  final bool entireCourse;

  const TeacherAgendaItem({
    required this.id,
    required this.title,
    this.course,
    this.subject,
    this.studentId,
    this.entireCourse = false,
  });
}
