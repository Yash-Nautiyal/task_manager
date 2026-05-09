import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../core/error/messages/execption_messages.dart';

class AuthOperationResult {
  const AuthOperationResult({this.user, this.errorMessage});

  final User? user;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;

  factory AuthOperationResult.success([User? user]) =>
      AuthOperationResult(user: user);

  factory AuthOperationResult.failure(String message) =>
      AuthOperationResult(errorMessage: message);
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, Duration? requestTimeout})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _requestTimeout = requestTimeout ?? const Duration(seconds: 30);

  final FirebaseAuth _auth;
  final Duration _requestTimeout;

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(
      _requestTimeout,
      onTimeout: () => throw TimeoutException('firebase_auth', _requestTimeout),
    );
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AuthOperationResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _withTimeout(
        _auth.createUserWithEmailAndPassword(email: email, password: password),
      );
      final user = credential.user;
      if (user != null &&
          displayName != null &&
          displayName.trim().isNotEmpty) {
        await _withTimeout(user.updateDisplayName(displayName.trim()));
        await _withTimeout(user.reload());
      }
      return AuthOperationResult.success(_auth.currentUser ?? user);
    } on TimeoutException {
      return AuthOperationResult.failure(AuthExceptionMessages.requestTimedOut);
    } on FirebaseAuthException catch (e) {
      return AuthOperationResult.failure(
        AuthExceptionMessages.messageForCode(e.code),
      );
    } catch (_) {
      return AuthOperationResult.failure(AuthExceptionMessages.unexpectedError);
    }
  }

  Future<AuthOperationResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _withTimeout(
        _auth.signInWithEmailAndPassword(email: email, password: password),
      );
      return AuthOperationResult.success(credential.user);
    } on TimeoutException {
      return AuthOperationResult.failure(AuthExceptionMessages.requestTimedOut);
    } on FirebaseAuthException catch (e) {
      return AuthOperationResult.failure(
        AuthExceptionMessages.messageForCode(e.code),
      );
    } catch (_) {
      return AuthOperationResult.failure(AuthExceptionMessages.unexpectedError);
    }
  }

  Future<AuthOperationResult> signOut() async {
    try {
      await _withTimeout(_auth.signOut());
      return AuthOperationResult.success();
    } on TimeoutException {
      return AuthOperationResult.failure(AuthExceptionMessages.requestTimedOut);
    } on FirebaseAuthException catch (e) {
      return AuthOperationResult.failure(
        AuthExceptionMessages.messageForCode(e.code),
      );
    } catch (_) {
      return AuthOperationResult.failure(AuthExceptionMessages.unexpectedError);
    }
  }

  Future<AuthOperationResult> sendPasswordResetEmail(String email) async {
    try {
      await _withTimeout(_auth.sendPasswordResetEmail(email: email.trim()));
      return AuthOperationResult.success();
    } on TimeoutException {
      return AuthOperationResult.failure(AuthExceptionMessages.requestTimedOut);
    } on FirebaseAuthException catch (e) {
      return AuthOperationResult.failure(
        AuthExceptionMessages.messageForCode(e.code),
      );
    } catch (_) {
      return AuthOperationResult.failure(AuthExceptionMessages.unexpectedError);
    }
  }
}
