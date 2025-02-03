import 'dart:convert';
import 'package:app_task/core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;

class OdooAuthService {
  String? _sessionId;

  /// Autenticación con Odoo
  Future<int> authenticate(String email, String password) async {
    final String baseUrl = API_URL + '/web/session/authenticate';
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "db": "odoo",
          "login": email,
          "password": password
        },
        "id": 1
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.headers.containsKey('set-cookie')) {
        List<String> cookies = response.headers['set-cookie']!.split(',');
        for (String cookie in cookies) {
          if (cookie.trim().startsWith("session_id=")) {
            _sessionId = cookie.split(";")[0].trim(); // Solo tomamos `session_id`
            print("✅ Sesión de Odoo guardada: $_sessionId");
            break;
          }
        }
      }


      // _sessionId = response.headers['set-cookie'];
      if (data.containsKey("result")) {
        return data["result"]["uid"]; // Devuelve los datos del usuario autenticado
      } else {
        throw Exception("Error en la autenticación: ${data['error']['message']}");
      }
    } else {
      throw Exception("Error de conexión con Odoo: Código ${response.statusCode}");
    }
  }

  /// 🔹 **Obtener Datos de Otro Usuario usando el `user_id`**
  Future<Map<String, dynamic>> getUserData(int userId) async {

    if (_sessionId == null) throw Exception("Sesión de Odoo no encontrada");
    final String baseUrl = API_URL + '/web/dataset/call_kw';
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Cookie": _sessionId!, // 🔹 Usamos la cookie de la primera autenticación
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "school.usuario",
          "method": "search_read",
          "args": [
            [
              ["user_id", "=", userId]  // Buscamos con el user_id de Odoo
            ],
            ["id", "correo", "ci", "tipo_usuario", "name"]
          ],
          "kwargs": {
            "limit": 1
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey("result") && (data["result"] as List).isNotEmpty) {
        return data["result"][0]; // Retornamos la información del usuario
      } else {
        throw Exception("No se encontraron datos para el usuario.");
      }
    } else {
      throw Exception("Error al obtener datos del usuario: Código ${response.statusCode}");
    }
  }

  /// Envía el token FCM al servidor Odoo
  Future<void> sendFCMTokenToServer(int userId, String fcmToken) async {
    final url = Uri.parse('$API_URL/api/guardar_fcm_token');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Cookie": _sessionId!, // Incluir la cookie de sesión
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "user_id": userId,
          "fcm_token": fcmToken,
        }
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data["result"]["status"] == "success") {
        print("✅ Token FCM guardado exitosamente en Odoo");
      } else {
        print("⚠️ Error al guardar el token FCM: ${data['result']['message']}");
      }
    } else {
      print("❌ Error de conexión con Odoo: Código ${response.statusCode}");
    }
  }


  Future<List<Map<String, dynamic>>> getAgenda(String userId) async {
    final response = await http.post(
      Uri.parse(API_URL + "/web/dataset/call_kw"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Cookie": _sessionId!, // Importante para mantener la sesión
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "school.agenda",
          "method": "search_read",
          "args": [
            [["id_usuario", "=", int.parse(userId)]], // Filtra por usuario
            ["id_comunicado", "id_usuario", "leido"]
          ],
          "kwargs": {
            "limit": 10
          }
        },
        "id": 1
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("result")) {
        return List<Map<String, dynamic>>.from(data["result"]);
      } else {
        throw Exception("Error en la respuesta: ${data['error']['message']}");
      }
    } else {
      throw Exception("Error de conexión con Odoo: Código ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getCursos(String userId, String userType) async {
    String model;
    List<String> fields;

    model = "school.horario_dia";
    fields = ["id_curso"];


    final response = await http.post(
      Uri.parse(API_URL + "/web/dataset/call_kw"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Cookie": "session_id=$_sessionId", // Mantener la sesión activa
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": model,
          "method": "search_read",
          "args": [
            [["id_usuario_docente", "=", int.parse(userId)]], // Filtra por usuario
            fields
          ]
        },
        "id": 1
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("result")) {
        return List<Map<String, dynamic>>.from(data["result"]);
      } else {
        throw Exception("Error en la respuesta: ${data['error']['message']}");
      }
    } else {
      throw Exception("Error de conexión con Odoo: Código ${response.statusCode}");
    }
  }



}
