import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/storage/local_storage_service.dart';
import 'package:taskflow/main.dart';
import 'package:taskflow/presentation/providers/app_providers.dart';

void main() {
  testWidgets('App smoke test initializes TaskFlowApp', (tester) async {
    final localStorage = InMemoryLocalStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorage),
        ],
        child: const TaskFlowApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('TaskFlow'), findsWidgets);
  });
}
