
// FutureProvider.family para pasar un filtro
import 'package:app_task/features/admin/presentation/controller/admin_agenda_controller.dart';
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
import 'package:app_task/features/teacher/presentation/controllers/notifier/create_communication_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminAgendaProvider = FutureProvider.family<List<CommunicationEntity>, AdminAgendaFilter>(
  (ref, filter) async {
    final repo = ref.watch(communicationRepositoryProvider);

    final filtersMap = <String, dynamic>{};
    if (filter.course != null) filtersMap['course'] = filter.course;
    if (filter.subject != null) filtersMap['subject'] = filter.subject;
    if (filter.studentId != null) filtersMap['studentId'] = filter.studentId;
    // etc. con startDate / endDate

    return await repo.getCommunications(filters: filtersMap);
  },
);
