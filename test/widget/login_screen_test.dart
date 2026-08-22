import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/storage/local_storage_service.dart';
import 'package:taskflow/core/storage/secure_storage_service.dart';
import 'package:taskflow/data/datasources/local_cache_data_source.dart';
import 'package:taskflow/data/datasources/mock_data_source.dart';
import 'package:taskflow/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/presentation/providers/app_providers.dart';
import 'package:taskflow/presentation/screens/auth/login_screen.dart';

import '../test_mock_data.dart';

void main() {
  testWidgets('LoginScreen renders fields and quick-fill chips', (tester) async {
    final mockDataSource = MockDataSource();
    await mockDataSource.initialize(rawJson: testMockDataJson);
    final secureStorage = InMemorySecureStorageService();
    final localStorage = InMemoryLocalStorageService();
    final cacheDataSource = LocalCacheDataSource(
      localStorage: localStorage,
      secureStorage: secureStorage,
    );
    final authRepo = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      cacheDataSource: cacheDataSource,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          localStorageServiceProvider.overrideWithValue(localStorage),
          mockDataSourceProvider.overrideWithValue(mockDataSource),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to TaskFlow'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Org A: Admin (Ava)'), findsOneWidget);
    expect(find.text('Org B: Member (Elena)'), findsOneWidget);
  });
}
