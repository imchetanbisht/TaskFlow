import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ava.admin@nimbusdigital.test');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
                    // Header Logo & Title
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 40,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to ${AppConstants.appName}',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to manage projects and collaborate with your team',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Error Box if any
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

                    // Email Field
                    AppTextField(
                      label: 'Email address',
                      hint: 'name@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    AppButton(
                      label: 'Sign In',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                      variant: AppButtonVariant.primary,
                      height: 50,
                    ),
                    const SizedBox(height: 24),

                    // Demo Credentials Selector Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.key_rounded,
                                size: 16,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Quick-Fill Demo Credentials',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _demoChip(
                                label: 'Org A: Admin (Ava)',
                                email: 'ava.admin@nimbusdigital.test',
                                password: 'Password123!',
                              ),
                              _demoChip(
                                label: 'Org A: Member (Marcus)',
                                email: 'marcus.member@nimbusdigital.test',
                                password: 'Password123!',
                              ),
                              _demoChip(
                                label: 'Org B: Admin (Daniel)',
                                email: 'daniel.admin@harborlightstudios.test',
                                password: 'Password123!',
                              ),
                              _demoChip(
                                label: 'Org B: Member (Elena)',
                                email: 'elena.member@harborlightstudios.test',
                                password: 'Password123!',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Don't have an account? Register link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Create Account'),
                        ),
                      ],
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

  Widget _demoChip({
    required String label,
    required String email,
    required String password,
  }) {
    final isSelected = _emailController.text == email;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      label: Text(label),
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        fontSize: 11,
      ),
      backgroundColor: isSelected
          ? (isDark ? AppColors.primaryLight : AppColors.primary)
          : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.primaryLight : AppColors.primary)
            : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
      ),
      onPressed: () => _fillCredentials(email, password),
    );
  }
}
