import 'package:app_task/features/auth/data/repositories/user_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.signIn(email: email, password: password);
    return userModel; 
  }

  @override
  Future<void> signOut() async {
    return remoteDataSource.signOut();
  }

  @override
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final userModel = await remoteDataSource.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    return userModel; 
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await remoteDataSource.getCurrentUser();
    return userModel; 
  }
}
