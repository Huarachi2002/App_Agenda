import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  final String password;

  const UserModel({
    required this.password,
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
      password: map['password'] as String? ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'password': password,
    };
  }

  static UserRole _stringToUserRole(String roleString) {
    switch (roleString) {
      case 'student':
        return UserRole.student;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      default:
        throw Exception('Rol desconocido: $roleString');
    }
  }
}
