import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/entities/project.dart';
import 'package:taskflow/presentation/widgets/project_card.dart';

void main() {
  testWidgets('ProjectCard renders name, description and task count', (tester) async {
    const project = Project(
      id: 'proj_1',
      orgId: 'org_1',
      name: 'Mobile App Redesign',
      description: 'Second generation cross-platform app',
      taskCount: 8,
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCard(
            project: project,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Mobile App Redesign'), findsOneWidget);
    expect(find.text('Second generation cross-platform app'), findsOneWidget);
    expect(find.text('8 tasks'), findsOneWidget);

    await tester.tap(find.byType(ProjectCard));
    expect(tapped, true);
  });
}
