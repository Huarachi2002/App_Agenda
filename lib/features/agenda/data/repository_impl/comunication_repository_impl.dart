

import 'package:app_task/features/agenda/data/datasource/comunication_remote_datasource.dart';
import 'package:app_task/features/agenda/data/models/comunication_model.dart';
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
import 'package:app_task/features/agenda/domain/repository/comunication_repository.dart';

class CommunicationRepositoryImpl implements CommunicationRepository {
  final CommunicationRemoteDataSource remoteDataSource;

  CommunicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<CommunicationEntity> createCommunication({
    required String title,
    required String content,
    required DateTime createdAt,
    required List<String> recipients,
  }) async {
    final communicationModel = CommunicationModel(
      id: '', //TODO: el backend asignará el ID
      title: title,
      content: content,
      createdAt: createdAt,
      recipients: recipients,
    );
    final result = await remoteDataSource.createCommunication(communicationModel);
    return result; // Retorna CommunicationModel, que es subtipo de CommunicationEntity
  }

  @override
  Future<List<CommunicationEntity>> getCommunications({Map<String, dynamic>? filters}) async {
    return remoteDataSource.getCommunications(filters: filters);
  }
}
