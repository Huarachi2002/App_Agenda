class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role; // Enum con {student, teacher, parent, admin}

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

// Podrías tener un enum para los roles
enum UserRole { student, teacher, parent, admin }