
import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';

class CommunicationModel extends CommunicationEntity {
  const CommunicationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.recipients,
  });

  // De JSON a Modelo
  factory CommunicationModel.fromMap(Map<String, dynamic> map) {
    return CommunicationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      recipients: List<String>.from(map['recipients'] ?? []),
    );
  }

  // De Modelo a JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'recipients': recipients,
    };
  }
}
