abstract class TeacherRecordRepository {
  /// Envía un [audioFilePath] al backend para transcribir y resumir.
  /// Retorna el texto resumido de la clase.
  Future<String> sendAudioAndGetSummary(String audioFilePath);
}
