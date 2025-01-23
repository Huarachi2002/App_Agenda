import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';

abstract class CommunicationRepository {
  /// Crea un nuevo comunicado y lo retorna con el ID asignado
  Future<CommunicationEntity> createCommunication({
    required String title,
    required String content,
    required DateTime createdAt,
    required List<String> recipients,
  });

  Future<List<CommunicationEntity>> getCommunications({Map<String, dynamic>? filters});
}
