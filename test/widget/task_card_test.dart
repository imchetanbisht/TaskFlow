import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/entities/task.dart';
import 'package:taskflow/domain/entities/user.dart';
import 'package:taskflow/presentation/widgets/priority_chip.dart';
import 'package:taskflow/presentation/widgets/status_chip.dart';
import 'package:taskflow/presentation/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard renders title, status chip, priority chip and assignee',
      (tester) async {
    final task = TaskItem(
      id: 'task_1',
      projectId: 'proj_1',
      title: 'Build user dashboard',
      description: 'Implement modern widget layout',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      assigneeId: 'u1',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now(),
    );

    const user = User(
      id: 'u1',
      name: 'Marcus Lee',
      email: 'marcus@test.com',
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            assignee: user,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Build user dashboard'), findsOneWidget);
    expect(find.text('Implement modern widget layout'), findsOneWidget);
    expect(find.byType(StatusChip), findsOneWidget);
    expect(find.byType(PriorityChip), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Marcus Lee'), findsOneWidget);

    await tester.tap(find.byType(TaskCard));
    expect(tapped, true);
  });
}
