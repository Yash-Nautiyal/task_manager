enum TaskPriority { low, medium, high }

enum TaskStatus { todo, completed, overdue }

extension TaskStatusExtension on TaskStatus {
  static TaskStatus fromString(String statusStr) {
    final cleanStr = statusStr.trim().toLowerCase();

    switch (cleanStr) {
      case 'completed':
        return TaskStatus.completed;
      case 'pending':
      case 'overdue':
        return TaskStatus.overdue;
      case 'todo':
      default:
        return TaskStatus.todo;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  TaskStatus status;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.completedAt,
    this.status = TaskStatus.todo,
  });

  bool get isOverdue {
    if (status == TaskStatus.completed) return false;

    return dueDate.isBefore(DateTime.now());
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'completedAt': completedAt?.toUtc().toIso8601String(),
      'status': status.name,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String).toLocal(),
      completedAt:
          (json['completedAt'] == null ||
                  (json['completedAt'] is String &&
                      json['completedAt'].isEmpty))
              ? null
              : DateTime.parse(json['completedAt'] as String).toLocal(),
      status: TaskStatusExtension.fromString(json['status'] as String),
    );
  }
}
