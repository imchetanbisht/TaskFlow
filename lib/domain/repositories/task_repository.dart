import '../entities/comment.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasksByOrg(String orgId, {bool forceRefresh = false});
  Future<List<TaskItem>> getTasksByProject(String projectId);
  Future<TaskItem?> getTaskById(String taskId);
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
  Future<void> deleteTask(String taskId);
  Future<List<CommentItem>> getComments(String taskId);
  Future<CommentItem> addComment(CommentItem comment);
}
