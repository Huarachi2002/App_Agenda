import 'dart:io';
import 'package:http/http.dart' as http;

import '../../domain/repositories/teacher_record_repository.dart';

class TeacherRecordRepositoryImpl implements TeacherRecordRepository {
  final http.Client client;

  TeacherRecordRepositoryImpl(this.client);

  @override
  Future<String> sendAudioAndGetSummary(String audioFilePath) async {
    final file = File(audioFilePath);

    // Supongamos que tu backend recibe el archivo en una key "audio"
    final uri = Uri.parse('https://tu-backend.com/api/recordings');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('audio', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Esperamos un JSON con { "summary": "texto resumido" }
      final data = response.body; // o jsonDecode si el backend retorna JSON
      // Suponiendo data es algo como {"summary": "..."}
      // final map = jsonDecode(data);
      // return map["summary"] as String;

      return data; // ajusta según la respuesta real
    } else {
      throw Exception('Error al enviar audio. Status: ${response.statusCode}');
    }
  }
}
