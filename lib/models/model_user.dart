enum UserRole {
  admin,
  guru,
  siswa,
}

class UserModel {
  final String id;
  final String email;
  final List<String> aliases; // Alternative login identifiers (username, NISN, NIP)
  final String password;
  final String name;
  final UserRole role;
  final String? info;
  final String avatarInitials;

  const UserModel({
    required this.id,
    required this.email,
    this.aliases = const [],
    required this.password,
    required this.name,
    required this.role,
    this.info,
    required this.avatarInitials,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.guru:
        return 'Guru';
      case UserRole.siswa:
        return 'Siswa';
    }
  }

  /// Checks whether [identifier] matches this user's email, name, or any alias
  bool matchesIdentifier(String identifier) {
    final clean = identifier.trim().toLowerCase();
    if (email.toLowerCase() == clean) return true;
    for (final alias in aliases) {
      if (alias.toLowerCase() == clean) return true;
    }
    return false;
  }
}
