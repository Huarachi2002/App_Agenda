import 'dart:math';

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
  // Aquí podrías inyectar por constructor un cliente http o servicios de Firebase
  // final FirebaseAuth _auth;
  // etc.
  /// Lista de usuarios de prueba en memoria
  static final List<UserModel> _testUsers = [
    UserModel(
      id: '001',
      name: 'Juan Estudiante',
      email: 'student@demo.com',
      role: UserRole.student,
      password: '123456', // Para la demo
    ),
    UserModel(
      id: '002',
      name: 'María Docente',
      email: 'teacher@demo.com',
      role: UserRole.teacher,
      password: 'teacher123',
    ),
    UserModel(
      id: '003',
      name: 'Carlos Padre',
      email: 'parent@demo.com',
      role: UserRole.parent,
      password: 'parent123',
    ),
    UserModel(
      id: '004',
      name: 'Ana Administradora',
      email: 'admin@demo.com',
      role: UserRole.admin,
      password: 'admin123',
    ),
  ];

  /// Variable estática que mantiene en memoria el usuario actual logueado
  static UserModel? _currentUser;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Simulamos un pequeño retraso
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscamos si hay un usuario que coincida con el email y password
    final user = _testUsers.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception('Credenciales inválidas'),
    );

    // Si lo encontramos, lo guardamos como usuario actual y lo retornamos
    _currentUser = user;
    return user;
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
      password: password,
    );

    // Lo agregamos a la lista en memoria
    _testUsers.add(newUser);
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
