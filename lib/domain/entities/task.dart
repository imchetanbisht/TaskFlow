enum TaskStatus {
  todo('todo', 'To Do'),
  inProgress('in_progress', 'In Progress'),
  review('review', 'In Review'),
  done('done', 'Completed');

  final String value;
  final String label;
  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String? val) {
    if (val == null) return TaskStatus.todo;
    switch (val.toLowerCase().trim()) {
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'review':
      case 'in review':
        return TaskStatus.review;
      case 'done':
      case 'completed':
        return TaskStatus.done;
      case 'todo':
      case 'to do':
      default:
        return TaskStatus.todo;
    }
  }
}

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  final String value;
  final String label;
  const TaskPriority(this.value, this.label);

  static TaskPriority fromString(String? val) {
    if (val == null) return TaskPriority.medium;
    switch (val.toLowerCase().trim()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

class TaskItem {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime? createdAt;

  const TaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
    this.createdAt,
  });

  TaskItem copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    bool clearAssignee = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
