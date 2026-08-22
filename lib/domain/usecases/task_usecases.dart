import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../entities/auth_session.dart';
import '../entities/comment.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/user_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;
  GetTasksUseCase(this._repository);

  Future<List<TaskItem>> execute(String orgId, {bool forceRefresh = false}) async {
    return await _repository.getTasksByOrg(orgId, forceRefresh: forceRefresh);
  }
}

class FilterTasksUseCase {
  List<TaskItem> execute(List<TaskItem> tasks, TaskFilter filter) {
    return tasks.where((task) {
      // Search query
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase().trim();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }

      // Status filter
      if (filter.selectedStatuses.isNotEmpty) {
        if (!filter.selectedStatuses.contains(task.status)) return false;
      }

      // Priority filter
      if (filter.selectedPriorities.isNotEmpty) {
        if (!filter.selectedPriorities.contains(task.priority)) return false;
      }

      // Assignee filter
      if (filter.selectedAssigneeId != null) {
        if (filter.selectedAssigneeId == 'unassigned') {
          if (task.assigneeId != null) return false;
        } else if (task.assigneeId != filter.selectedAssigneeId) {
          return false;
        }
      }

      // Project filter
      if (filter.selectedProjectId != null) {
        if (task.projectId != filter.selectedProjectId) return false;
      }

      // Due date filter
      final isDone = task.status == TaskStatus.done;
      switch (filter.dueDateFilter) {
        case DueDateFilter.today:
          if (!DateFormatter.isToday(task.dueDate)) return false;
          break;
        case DueDateFilter.thisWeek:
          if (!DateFormatter.isThisWeek(task.dueDate)) return false;
          break;
        case DueDateFilter.overdue:
          if (!DateFormatter.isOverdue(task.dueDate, isDone)) return false;
          break;
        case DueDateFilter.all:
          break;
      }

      // Custom date range
      if (filter.customStartDate != null && task.dueDate != null) {
        if (task.dueDate!.isBefore(filter.customStartDate!)) return false;
      }
      if (filter.customEndDate != null && task.dueDate != null) {
        if (task.dueDate!.isAfter(filter.customEndDate!)) return false;
      }

      return true;
    }).toList();
  }
}

class CreateTaskUseCase {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;

  CreateTaskUseCase({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _userRepository = userRepository;

  Future<TaskItem> execute({
    required String projectId,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    String? assigneeId,
    DateTime? dueDate,
    required AuthSession session,
  }) async {
    if (title.trim().isEmpty) {
      throw const ValidationException(
        'Task title cannot be empty',
        fieldErrors: {'title': 'Task title is required'},
      );
    }

    // Verify project belongs to current organization
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null || project.orgId != session.organization.id) {
      throw const AuthorizationException(
        'Selected project does not belong to your organization.',
      );
    }

    // Verify assignee belongs to current organization if assigned
    if (assigneeId != null && assigneeId.isNotEmpty) {
      final members = await _userRepository.getOrganizationMembers(session.organization.id);
      final isMember = members.any((m) => m.id == assigneeId);
      if (!isMember) {
        throw const AuthorizationException(
          'Assigned user does not belong to your organization.',
        );
      }
    }

    final task = TaskItem(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    return await _taskRepository.createTask(task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;

  UpdateTaskUseCase({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _userRepository = userRepository;

  Future<TaskItem> execute({
    required TaskItem task,
    required AuthSession session,
  }) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationException(
        'Task title cannot be empty',
        fieldErrors: {'title': 'Task title is required'},
      );
    }

    final project = await _projectRepository.getProjectById(task.projectId);
    if (project == null || project.orgId != session.organization.id) {
      throw const AuthorizationException(
        'You cannot modify tasks outside your organization.',
      );
    }

    if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
      final members = await _userRepository.getOrganizationMembers(session.organization.id);
      final isMember = members.any((m) => m.id == task.assigneeId);
      if (!isMember) {
        throw const AuthorizationException(
          'Assigned user does not belong to your organization.',
        );
      }
    }

    return await _taskRepository.updateTask(task);
  }
}

class DeleteTaskUseCase {
  final TaskRepository _repository;
  DeleteTaskUseCase(this._repository);

  Future<void> execute(String taskId) async {
    await _repository.deleteTask(taskId);
  }
}

class AssignTaskUseCase {
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  AssignTaskUseCase({
    required TaskRepository taskRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _userRepository = userRepository;

  Future<TaskItem> execute({
    required String taskId,
    String? assigneeId,
    required AuthSession session,
  }) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found.');
    }

    if (assigneeId != null && assigneeId.isNotEmpty) {
      // Validate in business logic that the assignee is in the user's organization!
      final members = await _userRepository.getOrganizationMembers(session.organization.id);
      final isMember = members.any((m) => m.id == assigneeId);
      if (!isMember) {
        throw const AuthorizationException(
          'Cannot assign task: User does not belong to your organization.',
        );
      }
    }

    final updatedTask = task.copyWith(
      assigneeId: assigneeId,
      clearAssignee: assigneeId == null,
    );

    return await _taskRepository.updateTask(updatedTask);
  }
}

class UpdateTaskStatusUseCase {
  final TaskRepository _taskRepository;
  UpdateTaskStatusUseCase(this._taskRepository);

  Future<TaskItem> execute({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found.');
    }
    final updated = task.copyWith(status: newStatus);
    return await _taskRepository.updateTask(updated);
  }
}

class UpdateTaskPriorityUseCase {
  final TaskRepository _taskRepository;
  UpdateTaskPriorityUseCase(this._taskRepository);

  Future<TaskItem> execute({
    required String taskId,
    required TaskPriority newPriority,
  }) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found.');
    }
    final updated = task.copyWith(priority: newPriority);
    return await _taskRepository.updateTask(updated);
  }
}

class GetCommentsUseCase {
  final TaskRepository _taskRepository;
  GetCommentsUseCase(this._taskRepository);

  Future<List<CommentItem>> execute(String taskId) async {
    return await _taskRepository.getComments(taskId);
  }
}

class AddCommentUseCase {
  final TaskRepository _taskRepository;
  AddCommentUseCase(this._taskRepository);

  Future<CommentItem> execute({
    required String taskId,
    required String body,
    required AuthSession session,
  }) async {
    if (body.trim().isEmpty) {
      throw const ValidationException('Comment cannot be empty.');
    }

    final comment = CommentItem(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      authorId: session.user.id,
      body: body.trim(),
      createdAt: DateTime.now(),
    );

    return await _taskRepository.addComment(comment);
  }
}
