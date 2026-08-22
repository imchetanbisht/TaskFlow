class CommentItem {
  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime createdAt;

  const CommentItem({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  CommentItem copyWith({
    String? id,
    String? taskId,
    String? authorId,
    String? body,
    DateTime? createdAt,
  }) {
    return CommentItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
