class AdminAgendaFilter {
  final String? course;
  final String? subject;
  final String? studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdminAgendaFilter({
    this.course,
    this.subject,
    this.studentId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAgendaFilter &&
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
