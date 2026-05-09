class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirestoreFailure extends AppFailure {
  const FirestoreFailure(super.message);
}
