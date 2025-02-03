import '../../domain/entities/user.dart';

class UserModel extends UserEntity {

  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: _stringToUserRole(map['role'] as String),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
    };
  }

  static UserRole _stringToUserRole(String roleString) {
    switch (roleString) {
      case 'alumno':
        return UserRole.alumno;
      case 'docente':
        return UserRole.docente;
      case 'tutor':
        return UserRole.tutor;
      case 'admin':
        return UserRole.admin;
      default:
        throw Exception('Rol desconocido: $roleString');
    }
  }
}
