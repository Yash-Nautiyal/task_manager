part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstname;
  final String? lastname;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.firstname,
    this.lastname,
  });

  @override
  List<Object?> get props => [email, password, firstname, lastname];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthInFlightDismissed extends AuthEvent {
  const AuthInFlightDismissed();
}
