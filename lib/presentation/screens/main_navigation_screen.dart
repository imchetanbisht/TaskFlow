import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../providers/debug_notifier.dart';
import '../providers/project_notifier.dart';
import '../providers/task_notifier.dart';
import '../widgets/offline_banner.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'projects/projects_list_screen.dart';
import 'tasks/tasks_list_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final debugState = ref.watch(debugNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      DashboardScreen(
        onNavigateToProjects: () => setState(() => _currentIndex = 1),
        onNavigateToTasks: () => setState(() => _currentIndex = 2),
      ),
      const ProjectsListScreen(),
      const TasksListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Persistent Offline Banner when simulated offline mode is on
          if (debugState.isOffline)
            OfflineBanner(
              onRetry: () {
                ref.read(projectsNotifierProvider.notifier).loadProjects(forceRefresh: true);
                ref.read(tasksNotifierProvider.notifier).loadTasks(forceRefresh: true);
              },
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primary,
        unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline_rounded),
            activeIcon: Icon(Icons.check_circle_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
