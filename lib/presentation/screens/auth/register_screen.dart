import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = authState is AuthError ? authState.message : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join TaskFlow',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create your account to start managing projects',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.errorText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AppTextField(
                      label: 'Full Name',
                      hint: 'Alex Morgan',
                      controller: _nameController,
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: (val) => Validators.validateRequired(val, 'Full Name'),
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Email address',
                      hint: 'alex@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Confirm Password',
                      hint: 'Repeat your password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: (val) => Validators.validateConfirmPassword(
                        val,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      label: 'Create Account',
                      onPressed: isLoading ? null : _handleRegister,
                      isLoading: isLoading,
                      variant: AppButtonVariant.primary,
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
