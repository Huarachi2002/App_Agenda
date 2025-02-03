import '../../domain/entities/user.dart';

abstract class UserRepository {
  /// Autentica al usuario con [email] y [password].
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Cierra sesión del usuario (si aplica).
  Future<void> signOut();

  /// Crea un usuario (registro).
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Obtiene al usuario actualmente autenticado (si existe sesión).
  Future<UserEntity?> getCurrentUser();

  Future<List<Map<String, dynamic>>> getAgenda(String userId);

  Future<List<Map<String, dynamic>>> getCursos(String userId, String userType);



}
