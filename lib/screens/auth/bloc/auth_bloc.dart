import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthService? authService})
    : _authService = authService ?? AuthService(),
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthInFlightDismissed>(_onAuthInFlightDismissed);

    _userSubscription = _authService.authStateChanges.listen((user) {
      add(_AuthUserChanged(user));
    });
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _userSubscription;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authService.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    if (!result.isSuccess) {
      emit(AuthError(result.errorMessage!));
      emit(Unauthenticated());
      return;
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final displayName =
        [
          event.firstname?.trim() ?? '',
          event.lastname?.trim() ?? '',
        ].where((s) => s.isNotEmpty).join(' ').trim();

    final result = await _authService.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
      displayName: displayName.isEmpty ? null : displayName,
    );
    if (!result.isSuccess) {
      emit(AuthError(result.errorMessage!));
      emit(Unauthenticated());
      return;
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authService.signOut();
    if (!result.isSuccess) {
      emit(AuthError(result.errorMessage!));
      final user = _authService.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
      return;
    }
    emit(Unauthenticated());
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authService.sendPasswordResetEmail(event.email);
    if (!result.isSuccess) {
      emit(AuthError(result.errorMessage!));
      emit(Unauthenticated());
      return;
    }
    emit(
      const AuthPasswordResetEmailSent(
        'If an account exists for this email, you will receive reset instructions shortly.',
      ),
    );
    emit(Unauthenticated());
  }

  void _onAuthInFlightDismissed(
    AuthInFlightDismissed event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthLoading) {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
