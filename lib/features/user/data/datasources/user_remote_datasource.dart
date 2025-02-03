import 'dart:convert';
import 'dart:math';
import 'package:app_task/core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';

abstract class UserRemoteDataSource {
  /// Retorna un [UserModel] tras hacer login
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Crea un usuario y lo retorna.
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Retorna el usuario actualmente autenticado (o null si no hay sesión).
  Future<UserModel?> getCurrentUser();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  static const String baseUrl = API_URL + "/web/session/authenticate";
  // Aquí podrías inyectar por constructor un cliente http o servicios de Firebase
  // final FirebaseAuth _auth;
  // etc.
  /// Variable estática para mantener la sesión del usuario
  static UserModel? _currentUser;
  static String? _sessionId; // Guardará la cookie de sesión si Odoo la devuelve

  @override
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


  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Cache-Control": "no-cache",
        "User-Agent": "Flutter-App/1.0",
        "Connection": "keep-alive"
      },
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

      if (data.containsKey("result")) {
        final userData = data["result"];

        // Guardamos la cookie de sesión si está presente en los headers
        _sessionId = response.headers['set-cookie'];

        // Creamos una instancia de UserModel
        _currentUser = UserModel(
          id: userData["uid"].toString(),
          name: userData["name"] ?? "Sin Nombre",
          email: email,
          role: UserRole.alumno
        );

        return _currentUser!;
      } else {
        throw Exception("Error en la autenticación: ${data['error']['message']}");
      }
    } else {
      throw Exception("Error de conexión con Odoo: Código ${response.statusCode}");
    }

  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Llamada real para crear el usuario en el servidor/Firebase
    await Future.delayed(const Duration(seconds: 1));
    final newId = Random().nextInt(10000).toString();

    final newUser = UserModel(
      id: newId,
      name: name,
      email: email,
      role: role,
    );

    // Lo agregamos a la lista en memoria
    // _testUsers.add(newUser);
    // Simulamos que este usuario recién creado es el current user
    _currentUser = newUser;

    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }
}
