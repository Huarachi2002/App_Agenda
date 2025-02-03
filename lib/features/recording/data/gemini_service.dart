import 'package:app_task/core/constants/api_endpoints.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = API_OPEN_IA; // 🔹 Reemplázalo con tu API Key de Gemini

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro', // 🔹 Usa 'gemini-pro' para texto o 'gemini-pro-vision' si necesitas imágenes
    apiKey: apiKey,
  );

  /// Envía el texto de la clase y obtiene un resumen con subtítulos.
  Future<String?> getSummary(String transcript) async {
    try {
      final content = [
        Content.text(
            "Resume estrictamente el siguiente texto sin agregar información adicional ni modificar el significado original. "
                "Estructura el resumen en formato de puntos clave, organizándolo con subtítulos representativos según los temas mencionados. "
                "No agregues contenido extra ni reformules el texto de manera creativa. "
                "Mantén el resumen fiel al contenido original y enfocado en los puntos más importantes.\n\n"
                "Texto a resumir:\n---\n$transcript"
        )
      ];

      print("========= RESPONE getSummary ==========");
      final response = await _model.generateContent(content);
      print("response: " + response.toString());
      return response.text; // 🔹 Retorna el resumen generado por Gemini
    } catch (e) {
      print("Error en Gemini: $e");
      return null;
    }
  }
}
