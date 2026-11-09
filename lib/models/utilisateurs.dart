enum UserRole { admin, standard }

class AppUser {
  final String id;
  final String username;
  final String password;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStandard => role == UserRole.standard;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.name,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.standard,
      ),
    );
  }

  AppUser copyWith({
    String? id,
    String? username,
    String? password,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  static AppUser createDefaultAdmin() {
    return const AppUser(
      id: 'admin-001',
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
    );
  }
}
