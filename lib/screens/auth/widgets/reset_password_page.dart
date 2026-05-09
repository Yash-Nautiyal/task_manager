import 'package:flutter/material.dart';

import '../../../widgets/common/button/custom_textbutton.dart';
import '../../../widgets/common/inputField/custom_textfield.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;


  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Enter a new password for your account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              CustomTextfield(
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                isPasswordVisible: _isPasswordVisible,
                onchange: (_) {},
                theme: theme,
                hintText: 'Password',
                labelText: '6+ characters',
                onClickPasswordVisisble: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your password';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextfield(
                keyboardType: TextInputType.visiblePassword,
                controller: _confirmPasswordController,
                isPasswordVisible: _isConfirmPasswordVisible,
                onchange: (_) {},
                theme: theme,
                hintText: 'Confirm password',
                labelText: 'Confirm password',
                onClickPasswordVisisble: () {
                  setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  );
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value.trim() != _passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomTextButton(
                  onClick: _isSubmitting ? () {} : _updatePassword,
                  backgroundColor:
                      _isSubmitting
                          ? theme.dividerColor.withAlpha(150)
                          : theme.colorScheme.tertiary,
                  child: Text(
                    _isSubmitting ? 'Updating...' : 'Update password',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.scaffoldBackgroundColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
