import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/task.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final TaskItem? task;
  final String? defaultProjectId;

  const TaskFormScreen({
    super.key,
    this.task,
    this.defaultProjectId,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _selectedProjectId;
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _selectedProjectId = t?.projectId ?? widget.defaultProjectId;
    _selectedStatus = t?.status ?? TaskStatus.todo;
    _selectedPriority = t?.priority ?? TaskPriority.medium;
    _selectedAssigneeId = t?.assigneeId;
    _selectedDueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.task!.copyWith(
          projectId: _selectedProjectId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          assigneeId: _selectedAssigneeId,
          clearAssignee: _selectedAssigneeId == null,
          dueDate: _selectedDueDate,
          clearDueDate: _selectedDueDate == null,
        );
        await ref.read(tasksNotifierProvider.notifier).updateTask(updated);
      } else {
        await ref.read(tasksNotifierProvider.notifier).createTask(
              projectId: _selectedProjectId!,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              status: _selectedStatus,
              priority: _selectedPriority,
              assigneeId: _selectedAssigneeId,
              dueDate: _selectedDueDate,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Task updated successfully' : 'Task created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsAsync = ref.watch(projectsNotifierProvider);
    final membersAsync = ref.watch(orgMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Project Selection
                Text(
                  'Project',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                projectsAsync.when(
                  data: (projects) {
                    if (_selectedProjectId == null && projects.isNotEmpty) {
                      _selectedProjectId = projects.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedProjectId,
                      decoration: const InputDecoration(
                        hintText: 'Select a project',
                      ),
                      items: projects
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedProjectId = val),
                      validator: (val) => val == null ? 'Project is required' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const Text('Failed to load projects'),
                ),
                const SizedBox(height: 18),

                // Task Title
                AppTextField(
                  label: 'Task Title',
                  hint: 'e.g. Implement user authentication',
                  controller: _titleController,
                  validator: (val) => Validators.validateRequired(val, 'Title'),
                ),
                const SizedBox(height: 18),

                // Description
                AppTextField(
                  label: 'Description',
                  hint: 'Detailed steps or notes for this task...',
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 18),

                // Status & Priority Row
                Row(
                  children: [
                    // Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskStatus>(
                            initialValue: _selectedStatus,
                            decoration: const InputDecoration(),
                            items: TaskStatus.values
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.label),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Priority
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskPriority>(
                            initialValue: _selectedPriority,
                            decoration: const InputDecoration(),
                            items: TaskPriority.values
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.label),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPriority = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Assignee Selection
                Text(
                  'Assignee',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                membersAsync.when(
                  data: (members) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedAssigneeId,
                      decoration: const InputDecoration(
                        hintText: 'Assign to a team member',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...members.map((m) => DropdownMenuItem<String?>(
                              value: m.id,
                              child: Text(m.name),
                            )),
                      ],
                      onChanged: (val) => setState(() => _selectedAssigneeId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const SizedBox(),
                ),
                const SizedBox(height: 18),

                // Due Date Picker
                Text(
                  'Due Date',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedDueDate != null
                                  ? DateFormatter.formatDate(_selectedDueDate)
                                  : 'No due date chosen',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedDueDate != null
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                                    : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedDueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedDueDate = null),
                            child: const Icon(Icons.close, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Task',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                  variant: AppButtonVariant.primary,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
