import '../models/user_model.dart';
import '../../domain/entities/user.dart';

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
  // Aquí podrías inyectar por constructor un cliente http o servicios de Firebase
  // final FirebaseAuth _auth;
  // etc.

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Aquí iría la lógica real para signIn (API o Firebase).
    // Ejemplo "simulado":
    await Future.delayed(const Duration(seconds: 1));
    // Digamos que devolvemos un user "falso"
    return UserModel(
      id: '123',
      name: 'Fulano de Tal',
      email: email,
      role: UserRole.student,
    );
  }

  @override
  Future<void> signOut() async {
    // Aquí la llamada real para signOut.
    await Future.delayed(const Duration(milliseconds: 500));
    return;
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
    return UserModel(
      id: 'newId-456',
      name: name,
      email: email,
      role: role,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Aquí la llamada real para obtener usuario actual
    // Retorna null si no está autenticado
    await Future.delayed(const Duration(milliseconds: 500));
    // Simular que no hay user o uno default
    return null;
  }
}
