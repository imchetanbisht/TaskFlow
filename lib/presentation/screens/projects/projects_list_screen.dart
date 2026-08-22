import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/project_card.dart';
import 'project_details_screen.dart';
import 'project_form_screen.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    final session = authState.session;
    final projectsAsync = ref.watch(projectsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          if (session.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'New Project',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProjectFormScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppTextField(
              hint: 'Search projects...',
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Projects List
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                final filtered = projects.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  final query = _searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      p.description.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No matching projects',
                      description: 'Try searching with different keywords.',
                    );
                  }
                  return EmptyStateView(
                    icon: Icons.folder_open_rounded,
                    title: 'No projects yet',
                    description: 'Create your first project to start tracking tasks.',
                    actionLabel: session.isAdmin ? 'Create Project' : null,
                    onAction: session.isAdmin
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProjectFormScreen(),
                              ),
                            );
                          }
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(projectsNotifierProvider.notifier)
                      .loadProjects(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final proj = filtered[index];
                      return ProjectCard(
                        project: proj,
                        canManage: session.isAdmin,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(projectId: proj.id),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectFormScreen(project: proj),
                            ),
                          );
                        },
                        onDelete: () {
                          ConfirmationDialog.show(
                            context: context,
                            title: 'Delete project?',
                            message:
                                'Are you sure you want to delete "${proj.name}"? All associated tasks will also be removed. This action cannot be undone.',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                            onConfirm: () async {
                              try {
                                await ref
                                    .read(projectsNotifierProvider.notifier)
                                    .deleteProject(proj.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Project deleted successfully'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to delete: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => ListView(
                children: const [
                  ProjectCardSkeleton(),
                  ProjectCardSkeleton(),
                  ProjectCardSkeleton(),
                ],
              ),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref
                    .read(projectsNotifierProvider.notifier)
                    .loadProjects(forceRefresh: true),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: session.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProjectFormScreen(),
                  ),
                );
              },
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
