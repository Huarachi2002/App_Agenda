class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role; // Enum con {alumno, docente, tutor, admin}

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

// Podrías tener un enum para los roles
enum UserRole { alumno, docente, tutor, admin }