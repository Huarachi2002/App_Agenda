import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SpeechToTextService {
  final String apiKey;

  SpeechToTextService(this.apiKey);

  /// Convierte un archivo de audio en texto usando Google Speech-to-Text API.
  Future<String> convertAudioToText(String audioFilePath) async {
    final file = File(audioFilePath);
    final audioBytes = file.readAsBytesSync();
    final base64Audio = base64Encode(audioBytes);

    final url = Uri.parse(
        'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey');

    final requestBody = {
      "config": {
        "encoding": "LINEAR16", // o AAC si usas ese formato
        "sampleRateHertz": 16000, // Tasa de muestreo
        "languageCode": "es-ES", // Ajusta al idioma deseado
      },
      "audio": {
        "content": base64Audio,
      }
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    print('========== RESPONSE Service Speech text ============');
    print('status code: '+ response.statusCode.toString());
    print('body: '+ response.body);	
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('responseData: '+ responseData.toString());
      final text = responseData['results'][0]['alternatives'][0]['transcript'];
      return text;
    } else {
      throw Exception('Error al convertir audio a texto: ${response.body}');
    }
  }

  Future<void> sendTextToBackend(String text) async {
    final url = Uri.parse('https://tu-backend.com/api/class-summary'); //TODO: ajusta la URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar texto al backend: ${response.body}');
    }
  }
}
