class CommunicationEntity {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> recipients; 
  // lista de identificadores (pueden ser IDs de curso, materia o estudiantes).
  // O podrías separar en fields por tipo, si lo prefieres.

  const CommunicationEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.recipients,
  });
}

