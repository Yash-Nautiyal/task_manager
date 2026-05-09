import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/error/failures.dart';
import 'package:task_app/models/task_model.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  String _getCurrentUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw const FirestoreFailure(
        'Authentication required. Please sign in to continue.',
      );
    }
    return userId;
  }

  Future<DocumentReference<Map<String, dynamic>>> _getScopedTaskRef(
    String taskId,
    String userId,
  ) async {
    final taskRef = _tasksCollection.doc(taskId);
    final taskSnapshot = await taskRef.get();

    if (!taskSnapshot.exists) {
      throw const FirestoreFailure('Task not found.');
    }

    final data = taskSnapshot.data();
    final ownerId = data?['userId'] as String?;
    if (ownerId != userId) {
      throw const FirestoreFailure(
        'You are not allowed to modify this task.',
      );
    }

    return taskRef;
  }

  Future<void> addTask(Task task) async {
    final userId = _getCurrentUserId();
    try {
      final taskRef = _tasksCollection.doc();
      final taskWithId = task.copyWith(id: taskRef.id);
      final payload = <String, dynamic>{
        ...taskWithId.toJson(),
        'userId': userId,
      };
      await taskRef.set(payload);
    } on FirebaseException {
      throw const FirestoreFailure(
        'Failed to add task. Please check your connection.',
      );
    }
  }

  Future<void> editTask(Task task) async {
    final userId = _getCurrentUserId();
    try {
      final taskRef = await _getScopedTaskRef(task.id, userId);
      final payload = <String, dynamic>{
        ...task.toJson(),
        'userId': userId,
      };
      await taskRef.update(payload);
    } on FirestoreFailure {
      rethrow;
    } on FirebaseException {
      throw const FirestoreFailure(
        'Failed to update task. Please check your connection.',
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    final userId = _getCurrentUserId();
    try {
      final taskRef = await _getScopedTaskRef(taskId, userId);
      await taskRef.delete();
    } on FirestoreFailure {
      rethrow;
    } on FirebaseException {
      throw const FirestoreFailure(
        'Failed to delete task. Please check your connection.',
      );
    }
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    final userId = _getCurrentUserId();
    try {
      final taskRef = await _getScopedTaskRef(taskId, userId);
      await taskRef.update({
        'status': TaskStatus.completed.name,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } on FirestoreFailure {
      rethrow;
    } on FirebaseException {
      throw const FirestoreFailure(
        'Failed to mark task as completed. Please check your connection.',
      );
    }
  }

  Stream<List<Task>> getTasksStream(String userId) {
    try {
      return _tasksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              final taskJson = <String, dynamic>{
                ...data,
                'id': (data['id'] as String?) ?? doc.id,
              };
              return Task.fromJson(taskJson);
            }).toList();
          });
    } on FirebaseException {
      throw const FirestoreFailure(
        'Failed to load tasks. Please check your connection.',
      );
    }
  }
}
