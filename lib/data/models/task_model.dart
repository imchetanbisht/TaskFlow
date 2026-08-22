import '../../domain/entities/task.dart';

class TaskModel extends TaskItem {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    super.assigneeId,
    super.dueDate,
    super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.fromString(json['status'] as String?),
      priority: TaskPriority.fromString(json['priority'] as String?),
      assigneeId: json['assignee_id'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'assignee_id': assigneeId,
      'due_date': dueDate != null
          ? '${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
          : null,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskItem entity) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      priority: entity.priority,
      assigneeId: entity.assigneeId,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
    );
  }
}
