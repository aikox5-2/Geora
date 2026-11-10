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
  final String? phone;
  final String? address;
  final String? status;

  const UserModel({
    required this.id,
    required this.email,
    this.aliases = const [],
    required this.password,
    required this.name,
    required this.role,
    this.info,
    required this.avatarInitials,
    this.phone = '+62 812-3456-7890',
    this.address = 'Jl. Pendidikan No. 10, Blitar',
    this.status = 'aktif',
  });

  String get userPhone => (phone != null && phone!.isNotEmpty) ? phone! : '+62 812-3456-7890';
  String get userAddress => (address != null && address!.isNotEmpty) ? address! : 'Jl. Pendidikan No. 10, Blitar';
  String get userStatus => (status != null && status!.isNotEmpty) ? status! : 'aktif';

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

  UserModel copyWith({
    String? id,
    String? email,
    List<String>? aliases,
    String? password,
    String? name,
    UserRole? role,
    String? info,
    String? avatarInitials,
    String? phone,
    String? address,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      aliases: aliases ?? this.aliases,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      info: info ?? this.info,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
}
