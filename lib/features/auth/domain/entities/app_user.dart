class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['user_metadata']?['full_name'] as String?,
      photoUrl: json['user_metadata']?['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
