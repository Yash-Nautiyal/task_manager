import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/error/failures.dart';
import 'package:task_app/core/utils/result.dart';

import '../core/error/messages/execption_messages.dart';

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

  Future<Result<User?>> signUpWithEmailAndPassword({
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
      return Result.success(_auth.currentUser ?? user);
    } on TimeoutException {
      return Result.failure(const TimeoutFailure());
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(AuthExceptionMessages.messageForCode(e.code)),
      );
    } catch (_) {
      return Result.failure(
        const AuthFailure(AuthExceptionMessages.unexpectedError),
      );
    }
  }

  Future<Result<User?>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _withTimeout(
        _auth.signInWithEmailAndPassword(email: email, password: password),
      );
      return Result.success(credential.user);
    } on TimeoutException {
      return Result.failure(const TimeoutFailure());
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(AuthExceptionMessages.messageForCode(e.code)),
      );
    } catch (_) {
      return Result.failure(
        const AuthFailure(AuthExceptionMessages.unexpectedError),
      );
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _withTimeout(_auth.signOut());
      return Result.success(null);
    } on TimeoutException {
      return Result.failure(const TimeoutFailure());
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(AuthExceptionMessages.messageForCode(e.code)),
      );
    } catch (_) {
      return Result.failure(
        const AuthFailure(AuthExceptionMessages.unexpectedError),
      );
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _withTimeout(_auth.sendPasswordResetEmail(email: email.trim()));
      return Result.success(null);
    } on TimeoutException {
      return Result.failure(const TimeoutFailure());
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(AuthExceptionMessages.messageForCode(e.code)),
      );
    } catch (_) {
      return Result.failure(
        const AuthFailure(AuthExceptionMessages.unexpectedError),
      );
    }
  }
}
