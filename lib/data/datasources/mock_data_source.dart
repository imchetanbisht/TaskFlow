import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/debug/debug_simulation_service.dart';
import '../../core/errors/app_exception.dart';
import '../models/auth_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/organization_member_model.dart';
import '../models/organization_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class MockDataSource {
  final DebugSimulationService _debugSimulation;
  
  bool _isInitialized = false;
  final List<OrganizationModel> _organizations = [];
  final List<UserModel> _users = [];
  final List<OrganizationMemberModel> _orgMembers = [];
  final List<ProjectModel> _projects = [];
  final List<TaskModel> _tasks = [];
  final List<CommentModel> _comments = [];
  final List<NotificationModel> _notifications = [];
  final List<TestCredentialModel> _testCredentials = [];
  MockLoginResponseModel? _mockLoginResponse;

  MockDataSource({DebugSimulationService? debugSimulation})
      : _debugSimulation = debugSimulation ?? DebugSimulationService();

  DebugSimulationService get debugSimulation => _debugSimulation;
  bool get isInitialized => _isInitialized;

  /// Loads JSON asset or raw JSON string
  Future<void> initialize({String? rawJson}) async {
    if (_isInitialized && rawJson == null) return;

    String jsonString;
    if (rawJson != null) {
      jsonString = rawJson;
    } else {
      try {
        jsonString = await rootBundle.loadString(AssetPaths.mockDataJson);
      } catch (_) {
        jsonString = await rootBundle.loadString(AssetPaths.taskFlowMockDataJson);
      }
    }

    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    _loadFromMap(data);
    _isInitialized = true;
  }

  void _loadFromMap(Map<String, dynamic> data) {
    _organizations.clear();
    _users.clear();
    _orgMembers.clear();
    _projects.clear();
    _tasks.clear();
    _comments.clear();
    _notifications.clear();
    _testCredentials.clear();

    if (data['organizations'] is List) {
      for (final item in data['organizations']) {
        _organizations.add(OrganizationModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['users'] is List) {
      for (final item in data['users']) {
        _users.add(UserModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['org_members'] is List) {
      for (final item in data['org_members']) {
        _orgMembers.add(OrganizationMemberModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['projects'] is List) {
      for (final item in data['projects']) {
        _projects.add(ProjectModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['tasks'] is List) {
      for (final item in data['tasks']) {
        _tasks.add(TaskModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['comments'] is List) {
      for (final item in data['comments']) {
        _comments.add(CommentModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['notifications'] is List) {
      for (final item in data['notifications']) {
        _notifications.add(NotificationModel.fromJson(item as Map<String, dynamic>));
      }
    }

    if (data['auth_mock'] is Map<String, dynamic>) {
      final authMock = data['auth_mock'] as Map<String, dynamic>;
      if (authMock['test_credentials'] is List) {
        for (final cred in authMock['test_credentials']) {
          _testCredentials.add(TestCredentialModel.fromJson(cred as Map<String, dynamic>));
        }
      }
      if (authMock['mock_login_response'] is Map<String, dynamic>) {
        _mockLoginResponse = MockLoginResponseModel.fromJson(
          authMock['mock_login_response'] as Map<String, dynamic>,
        );
      }
    }
  }

  // Auth queries
  List<TestCredentialModel> getTestCredentials() => List.unmodifiable(_testCredentials);
  MockLoginResponseModel? getMockLoginResponse() => _mockLoginResponse;

  Future<TestCredentialModel?> findCredential(String email, String password) async {
    await _debugSimulation.applySimulation();
    try {
      return _testCredentials.firstWhere(
        (c) => c.email.toLowerCase() == email.trim().toLowerCase() && c.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // Organizations & Users
  Future<List<OrganizationModel>> getOrganizations() async {
    await _debugSimulation.applySimulation();
    return List.unmodifiable(_organizations);
  }

  Future<OrganizationModel?> getOrganizationById(String orgId) async {
    await _debugSimulation.applySimulation(entityId: orgId);
    try {
      return _organizations.firstWhere((o) => o.id == orgId);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> getUsers() async {
    await _debugSimulation.applySimulation();
    return List.unmodifiable(_users);
  }

  Future<UserModel?> getUserById(String userId) async {
    await _debugSimulation.applySimulation(entityId: userId);
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<List<OrganizationMemberModel>> getOrgMembers(String orgId) async {
    await _debugSimulation.applySimulation(entityId: orgId);
    return _orgMembers.where((m) => m.orgId == orgId).toList();
  }

  // Projects CRUD
  Future<List<ProjectModel>> getProjectsByOrg(String orgId) async {
    await _debugSimulation.applySimulation(entityId: orgId);
    final projects = _projects.where((p) => p.orgId == orgId).toList();
    // Update task_count dynamically based on current tasks
    return projects.map((p) {
      final count = _tasks.where((t) => t.projectId == p.id).length;
      return ProjectModel(
        id: p.id,
        orgId: p.orgId,
        name: p.name,
        description: p.description,
        taskCount: count,
        status: p.status,
        createdAt: p.createdAt,
      );
    }).toList();
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    await _debugSimulation.applySimulation(entityId: projectId);
    try {
      final p = _projects.firstWhere((proj) => proj.id == projectId);
      final count = _tasks.where((t) => t.projectId == p.id).length;
      return ProjectModel(
        id: p.id,
        orgId: p.orgId,
        name: p.name,
        description: p.description,
        taskCount: count,
        status: p.status,
        createdAt: p.createdAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    await _debugSimulation.applySimulation();
    _projects.add(project);
    return project;
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    await _debugSimulation.applySimulation(entityId: project.id);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      throw NotFoundException('Project ${project.id} not found.');
    }
    _projects[index] = project;
    return project;
  }

  Future<void> deleteProject(String projectId) async {
    await _debugSimulation.applySimulation(entityId: projectId);
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) {
      throw NotFoundException('Project $projectId not found.');
    }
    _projects.removeAt(index);
    // Also delete associated tasks & comments
    final taskIdsToDelete = _tasks.where((t) => t.projectId == projectId).map((t) => t.id).toSet();
    _tasks.removeWhere((t) => t.projectId == projectId);
    _comments.removeWhere((c) => taskIdsToDelete.contains(c.taskId));
  }

  // Tasks CRUD
  Future<List<TaskModel>> getTasksByOrg(String orgId) async {
    await _debugSimulation.applySimulation(entityId: orgId);
    final orgProjectIds = _projects.where((p) => p.orgId == orgId).map((p) => p.id).toSet();
    return _tasks.where((t) => orgProjectIds.contains(t.projectId)).toList();
  }

  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    await _debugSimulation.applySimulation(entityId: projectId);
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    await _debugSimulation.applySimulation(entityId: taskId);
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    await _debugSimulation.applySimulation();
    _tasks.add(task);
    return task;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    await _debugSimulation.applySimulation(entityId: task.id);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw NotFoundException('Task ${task.id} not found.');
    }
    _tasks[index] = task;
    return task;
  }

  Future<void> deleteTask(String taskId) async {
    await _debugSimulation.applySimulation(entityId: taskId);
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw NotFoundException('Task $taskId not found.');
    }
    _tasks.removeAt(index);
    _comments.removeWhere((c) => c.taskId == taskId);
  }

  // Comments
  Future<List<CommentModel>> getCommentsByTask(String taskId) async {
    await _debugSimulation.applySimulation(entityId: taskId);
    return _comments.where((c) => c.taskId == taskId).toList();
  }

  Future<CommentModel> addComment(CommentModel comment) async {
    await _debugSimulation.applySimulation();
    _comments.add(comment);
    return comment;
  }

  // Notifications
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    await _debugSimulation.applySimulation(entityId: userId);
    return _notifications.where((n) => n.userId == userId).toList();
  }

  Future<void> markNotificationAsRead(String notifId) async {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      final notif = _notifications[index];
      _notifications[index] = NotificationModel(
        id: notif.id,
        userId: notif.userId,
        type: notif.type,
        taskId: notif.taskId,
        message: notif.message,
        read: true,
        createdAt: notif.createdAt,
      );
    }
  }
}
