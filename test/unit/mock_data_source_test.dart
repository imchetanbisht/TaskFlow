import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/errors/app_exception.dart';
import 'package:taskflow/data/datasources/mock_data_source.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/domain/entities/task.dart';

import '../test_mock_data.dart';

void main() {
  late MockDataSource mockDataSource;

  setUp(() async {
    mockDataSource = MockDataSource();
    await mockDataSource.initialize(rawJson: testMockDataJson);
  });

  group('MockDataSource Unit Tests', () {
    test('Initializes and parses entities correctly', () async {
      final orgs = await mockDataSource.getOrganizations();
      expect(orgs.length, 2);

      final users = await mockDataSource.getUsers();
      expect(users.length, 5);

      final projects = await mockDataSource.getProjectsByOrg('org_a1b2c3');
      expect(projects.length, 1);
      expect(projects.first.name, 'Website Relaunch');
    });

    test('In-memory project CRUD mutations', () async {
      const newProj = ProjectModel(
        id: 'p_new',
        orgId: 'org_a1b2c3',
        name: 'New Test Project',
        description: 'Testing CRUD',
      );

      await mockDataSource.createProject(newProj);
      var projects = await mockDataSource.getProjectsByOrg('org_a1b2c3');
      expect(projects.any((p) => p.id == 'p_new'), true);

      final updated = newProj.copyWith(name: 'Updated Name');
      await mockDataSource.updateProject(ProjectModel.fromEntity(updated));
      final fetched = await mockDataSource.getProjectById('p_new');
      expect(fetched?.name, 'Updated Name');

      await mockDataSource.deleteProject('p_new');
      projects = await mockDataSource.getProjectsByOrg('org_a1b2c3');
      expect(projects.any((p) => p.id == 'p_new'), false);
    });

    test('In-memory task CRUD mutations', () async {
      const newTask = TaskModel(
        id: 't_new',
        projectId: 'proj_1001',
        title: 'New In-Memory Task',
        description: 'Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
      );

      await mockDataSource.createTask(newTask);
      var tasks = await mockDataSource.getTasksByProject('proj_1001');
      expect(tasks.any((t) => t.id == 't_new'), true);

      await mockDataSource.deleteTask('t_new');
      tasks = await mockDataSource.getTasksByProject('proj_1001');
      expect(tasks.any((t) => t.id == 't_new'), false);
    });

    test('Offline simulation throws OfflineException', () async {
      mockDataSource.debugSimulation.isOffline = true;

      expect(
        () => mockDataSource.getProjectsByOrg('org_a1b2c3'),
        throwsA(isA<OfflineException>()),
      );
    });

    test('Timeout simulation throws NetworkException', () async {
      mockDataSource.debugSimulation.simulateTimeout = true;

      expect(
        () => mockDataSource.getTasksByOrg('org_a1b2c3'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('Simulate 404 throws NotFoundException', () async {
      mockDataSource.debugSimulation.simulateNotFound = true;

      expect(
        () => mockDataSource.getProjectById('proj_1001'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
