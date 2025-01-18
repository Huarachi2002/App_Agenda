import '../../domain/entities/user.dart';

abstract class UserRepository {
  /// Autentica al usuario con [email] y [password].
  Future<User> signIn({
    required String email,
    required String password,
  });

  /// Cierra sesión del usuario (si aplica).
  Future<void> signOut();

  /// Crea un usuario (registro).
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Obtiene al usuario actualmente autenticado (si existe sesión).
  Future<User?> getCurrentUser();
}
