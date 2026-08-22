import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../providers/notification_notifier.dart';
import '../providers/task_filter_notifier.dart';
import 'app_button.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TaskFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(taskFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(orgMembersProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Tasks',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const TaskFilter();
                    });
                  },
                  child: Text(
                    'Reset All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter
            Text(
              'Status',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((status) {
                final isSelected = _filter.selectedStatuses.contains(status);
                return StatusChip(
                  status: status,
                  isSelected: isSelected,
                  onTap: () {
                    final set = Set<TaskStatus>.from(_filter.selectedStatuses);
                    if (isSelected) {
                      set.remove(status);
                    } else {
                      set.add(status);
                    }
                    setState(() {
                      _filter = _filter.copyWith(selectedStatuses: set);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority Filter
            Text(
              'Priority',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                final isSelected = _filter.selectedPriorities.contains(priority);
                return PriorityChip(
                  priority: priority,
                  isSelected: isSelected,
                  onTap: () {
                    final set = Set<TaskPriority>.from(_filter.selectedPriorities);
                    if (isSelected) {
                      set.remove(priority);
                    } else {
                      set.add(priority);
                    }
                    setState(() {
                      _filter = _filter.copyWith(selectedPriorities: set);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Due Date Filter
            Text(
              'Due Date',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DueDateFilter.values.map((dueFilter) {
                final isSelected = _filter.dueDateFilter == dueFilter;
                return ChoiceChip(
                  label: Text(dueFilter.label),
                  selected: isSelected,
                  selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  onSelected: (val) {
                    setState(() {
                      _filter = _filter.copyWith(dueDateFilter: dueFilter);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Assignee Filter
            Text(
              'Assignee',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              data: (members) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter.selectedAssigneeId == null,
                      selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: _filter.selectedAssigneeId == null
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _filter = _filter.copyWith(clearAssignee: true);
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Unassigned'),
                      selected: _filter.selectedAssigneeId == 'unassigned',
                      selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: _filter.selectedAssigneeId == 'unassigned'
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _filter = _filter.copyWith(selectedAssigneeId: 'unassigned');
                        });
                      },
                    ),
                    ...members.map((m) {
                      final isSelected = _filter.selectedAssigneeId == m.id;
                      return ChoiceChip(
                        label: Text(m.name),
                        selected: isSelected,
                        selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                        labelStyle: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                        onSelected: (_) {
                          setState(() {
                            _filter = _filter.copyWith(selectedAssigneeId: m.id);
                          });
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => const SizedBox(),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Apply Filters',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      ref.read(taskFilterProvider.notifier).setFilter(_filter);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
