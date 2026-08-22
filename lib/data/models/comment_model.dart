import '../../domain/entities/comment.dart';

class CommentModel extends CommentItem {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.authorId,
    required super.body,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      authorId: json['author_id'] as String,
      body: json['body'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'author_id': authorId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromEntity(CommentItem entity) {
    return CommentModel(
      id: entity.id,
      taskId: entity.taskId,
      authorId: entity.authorId,
      body: entity.body,
      createdAt: entity.createdAt,
    );
  }
}
