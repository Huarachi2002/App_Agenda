import 'dart:async';
import 'package:app_task/features/auth/data/repositories/user_repository.dart';
import 'package:app_task/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Este provider global inyectará la dependencia UserRepository.
/// Lo ideal es crearlo en un archivo de "injection" separado, 
/// pero aquí lo hacemos todo junto para ejemplo.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('Debe proveer una implementación de UserRepository');
});

/// Controller con estado AsyncValue<UserEntity?> 
/// para representar el usuario actual (o null si no hay).
class UserController extends AsyncNotifier<User?> {
  late final UserRepository _repository;

  @override
  FutureOr<User?> build() async {
    // Este método build se llama al inicializar el controlador
    // y retorna el user actual (o null). 
    // Se setea el estado en loading y luego en data/error automáticamente.

    _repository = ref.read(userRepositoryProvider);
    final currentUser = await _repository.getCurrentUser();
    return currentUser;
  }

  Future<void> signIn(String email, String password) async {
    // Cambiamos a estado loading
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signIn(email: email, password: password);
      // Actualizamos el estado con el usuario
      state = AsyncValue.data(user);
    } catch (e, st) {
      // Si ocurre error, lo guardamos en el estado
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null); 
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newUser = await _repository.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = AsyncValue.data(newUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider que expone la instancia de UserController
final userControllerProvider =
    AsyncNotifierProvider<UserController, User?>(() {
  return UserController();
});
