import 'package:equatable/equatable.dart';

/// User State
/// Represents the current state of user authentication
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking authentication
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading state
class UserLoading extends UserState {
  const UserLoading();
}

/// User is authenticated (Google) or in guest mode
class UserAuthenticated extends UserState {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isGuest;

  const UserAuthenticated({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.isGuest,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isGuest];

  @override
  String toString() {
    return 'UserAuthenticated(name: $name, isGuest: $isGuest)';
  }
}

/// User is not authenticated
class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}

/// Error state
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
