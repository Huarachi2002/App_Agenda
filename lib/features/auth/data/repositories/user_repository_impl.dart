import 'package:app_task/features/auth/data/repositories/user_repository.dart';
import 'package:app_task/features/auth/data/services/odoo_auth_service.dart';
import 'package:app_task/features/auth/domain/entities/user.dart';
import 'package:app_task/services/fcm_service.dart';

import '../../../user/data/datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final OdooAuthService _authService = OdooAuthService();
  final FCMService _fcmService = FCMService();


  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    try {
      final int userId  = await _authService.authenticate(email, password);

      final userData = await _authService.getUserData(userId); // 🔹 Segunda petición con user_id

      final fcmToken = await _fcmService.getFCMToken();

      await _authService.sendFCMTokenToServer(userId, fcmToken);

      return UserEntity(
        id: userData["id"].toString(),
        name: userData["correo"] ?? "Sin Nombre",
        email: userData["correo"] ?? email,
        role: _mapUserRole(userData["tipo_usuario"]),
      );
    } catch (e) {
      throw Exception("Error al iniciar sesión: $e");
    }
  }

  /// 🔹 Función auxiliar para mapear `tipo_usuario` a `UserRole`
  UserRole _mapUserRole(String tipoUsuario) {
    switch (tipoUsuario.toLowerCase()) {
      case "alumno":
        return UserRole.alumno;
      case "docente":
        return UserRole.docente;
      case "tutor":
        return UserRole.tutor;
      case "admin":
        return UserRole.admin;
      default:
        return UserRole.alumno;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAgenda(String userId) {
    return _authService.getAgenda(userId);
  }

  @override
  Future<void> signOut() async {
    // No hay un endpoint de logout en Odoo, pero podrías limpiar almacenamiento local si usas tokens.
  }

  @override
  Future<List<Map<String, dynamic>>> getCursos(String userId, String userType) {
    return _authService.getCursos(userId, userType);
  }

  @override
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    throw UnimplementedError("El registro de usuarios en Odoo se maneja desde el sistema.");
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return null; // 🔹 Si usas almacenamiento local, aquí podrías recuperar datos del usuario.
  }
}
