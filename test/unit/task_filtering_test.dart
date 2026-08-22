import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/entities/task.dart';
import 'package:taskflow/domain/entities/task_filter.dart';
import 'package:taskflow/domain/usecases/task_usecases.dart';

void main() {
  late FilterTasksUseCase filterUseCase;
  late List<TaskItem> sampleTasks;

  setUp(() {
    filterUseCase = FilterTasksUseCase();
    sampleTasks = [
      TaskItem(
        id: 't1',
        projectId: 'p1',
        title: 'Design landing page hero',
        description: 'Create Figma component and export assets',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        assigneeId: 'u1',
        dueDate: DateTime.now().subtract(const Duration(days: 2)), // Overdue
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      TaskItem(
        id: 't2',
        projectId: 'p1',
        title: 'Implement API client',
        description: 'Connect REST repository',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        assigneeId: 'u2',
        dueDate: DateTime.now(), // Today
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TaskItem(
        id: 't3',
        projectId: 'p2',
        title: 'Write test cases',
        description: 'Add widget and unit tests',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        assigneeId: null, // Unassigned
        dueDate: DateTime.now().add(const Duration(days: 2)), // This week
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  });

  group('Task Filtering Unit Tests', () {
    test('Search query matches title or description', () {
      final filter = const TaskFilter(searchQuery: 'landing');
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 1);
      expect(results.first.id, 't1');

      final filterDesc = const TaskFilter(searchQuery: 'widget');
      final descResults = filterUseCase.execute(sampleTasks, filterDesc);
      expect(descResults.length, 1);
      expect(descResults.first.id, 't3');
    });

    test('Filter by single status', () {
      final filter = const TaskFilter(selectedStatuses: {TaskStatus.done});
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 1);
      expect(results.first.id, 't1');
    });

    test('Filter by multiple statuses', () {
      final filter = const TaskFilter(
        selectedStatuses: {TaskStatus.inProgress, TaskStatus.todo},
      );
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 2);
      expect(results.map((t) => t.id), containsAll(['t2', 't3']));
    });

    test('Filter by priority', () {
      final filter = const TaskFilter(
        selectedPriorities: {TaskPriority.urgent},
      );
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 1);
      expect(results.first.id, 't2');
    });

    test('Filter by assignee and unassigned', () {
      final filterUser = const TaskFilter(selectedAssigneeId: 'u1');
      final userResults = filterUseCase.execute(sampleTasks, filterUser);
      expect(userResults.length, 1);
      expect(userResults.first.id, 't1');

      final filterUnassigned = const TaskFilter(selectedAssigneeId: 'unassigned');
      final unassignedResults = filterUseCase.execute(sampleTasks, filterUnassigned);
      expect(unassignedResults.length, 1);
      expect(unassignedResults.first.id, 't3');
    });

    test('Filter by project ID', () {
      final filter = const TaskFilter(selectedProjectId: 'p1');
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 2);
      expect(results.map((t) => t.id), containsAll(['t1', 't2']));
    });

    test('Filter by Due Date: Today', () {
      final filter = const TaskFilter(dueDateFilter: DueDateFilter.today);
      final results = filterUseCase.execute(sampleTasks, filter);
      expect(results.length, 1);
      expect(results.first.id, 't2');
    });

    test('Filter by Due Date: Overdue (ignores done tasks)', () {
      // Create an incomplete overdue task
      final overdueIncomplete = TaskItem(
        id: 't4',
        projectId: 'p1',
        title: 'Overdue task',
        description: '',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      final list = [...sampleTasks, overdueIncomplete];

      final filter = const TaskFilter(dueDateFilter: DueDateFilter.overdue);
      final results = filterUseCase.execute(list, filter);
      expect(results.length, 1);
      expect(results.first.id, 't4');
    });
  });
}
