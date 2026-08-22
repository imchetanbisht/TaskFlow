import 'dart:convert';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/auth_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class LocalCacheDataSource {
  final ILocalStorageService _localStorage;
  final ISecureStorageService _secureStorage;

  static const String _sessionKey = 'taskflow_auth_session';
  static const String _projectsCacheKeyPrefix = 'taskflow_projects_cache_';
  static const String _tasksCacheKeyPrefix = 'taskflow_tasks_cache_';

  LocalCacheDataSource({
    required ILocalStorageService localStorage,
    required ISecureStorageService secureStorage,
  })  : _localStorage = localStorage,
        _secureStorage = secureStorage;

  // Session persistence
  Future<void> saveSession(StoredSessionModel session) async {
    final jsonStr = jsonEncode(session.toJson());
    await _secureStorage.write(key: _sessionKey, value: jsonStr);
  }

  Future<StoredSessionModel?> getSession() async {
    final jsonStr = await _secureStorage.read(key: _sessionKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StoredSessionModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionKey);
  }

  // Projects cache
  Future<void> cacheProjects(String orgId, List<ProjectModel> projects) async {
    final list = projects.map((p) => p.toJson()).toList();
    await _localStorage.setString('$_projectsCacheKeyPrefix$orgId', jsonEncode(list));
  }

  Future<List<ProjectModel>> getCachedProjects(String orgId) async {
    final jsonStr = _localStorage.getString('$_projectsCacheKeyPrefix$orgId');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Tasks cache
  Future<void> cacheTasks(String orgId, List<TaskModel> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await _localStorage.setString('$_tasksCacheKeyPrefix$orgId', jsonEncode(list));
  }

  Future<List<TaskModel>> getCachedTasks(String orgId) async {
    final jsonStr = _localStorage.getString('$_tasksCacheKeyPrefix$orgId');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
