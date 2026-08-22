import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/project.dart';
import '../../providers/project_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.project!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await ref.read(projectsNotifierProvider.notifier).updateProject(updated);
      } else {
        await ref.read(projectsNotifierProvider.notifier).createProject(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Project updated successfully'
                  : 'Project created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Project Name',
                  hint: 'e.g. Mobile App Redesign',
                  controller: _nameController,
                  validator: (val) => Validators.validateRequired(val, 'Project Name'),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Description',
                  hint: 'Brief summary of the project goals...',
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: _isEditing ? 'Save Changes' : 'Create Project',
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
