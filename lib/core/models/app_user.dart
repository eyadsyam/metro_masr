import 'package:equatable/equatable.dart';

/// Unified User Model
/// Represents both authenticated users (Google) and guest users
class AppUser extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isGuest;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.isGuest,
    this.createdAt,
  });

  /// Factory for Guest User
  factory AppUser.guest({required String name}) {
    return AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  /// Factory for Authenticated User (from Supabase)
  factory AppUser.authenticated({
    required String id,
    required String name,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isGuest: false,
      createdAt: DateTime.now(),
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from JSON (local storage)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isGuest: json['isGuest'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Create from Supabase Profile
  factory AppUser.fromSupabaseProfile(Map<String, dynamic> profile) {
    return AppUser.authenticated(
      id: profile['id'] as String,
      name: profile['full_name'] as String? ?? 'User',
      email: profile['email'] as String?,
      avatarUrl: profile['avatar_url'] as String?,
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isGuest,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isGuest, createdAt];

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, isGuest: $isGuest)';
  }
}
