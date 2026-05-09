import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/core/routing/app_router.dart';
import 'package:task_app/widgets/common/dialog/snackbar_dialog.dart';
import '../../../widgets/common/button/custom_textbutton.dart';
import '../../../widgets/common/inputField/custom_textfield.dart';
import '../bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        if (current is AuthError) return true;
        if (current is Authenticated &&
            (previous is AuthLoading ||
                previous is Unauthenticated ||
                previous is AuthInitial)) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is AuthError) {
          showAnimatedSnackbar(context, state.message, SnackbarType.error);
        } else if (state is Authenticated) {
          showAnimatedSnackbar(
            context,
            'Signed in successfully.',
            SnackbarType.success,
          );
          AppRouter.popToRoot(context);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign in to your account",
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => AppRouter.pushSignup(context),
                  child: Text(
                    "Sign up to Get started!",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextfield(
              controller: _emailController,
              theme: theme,
              hintText: "Email address",
              labelText: "Email Address",
              onchange: (text) {},
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter your email";
                }
                final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                if (!emailRegex.hasMatch(value)) return "Enter a valid email";
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextfield(
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              isPasswordVisible: _isPasswordVisible,
              onchange: (text) {},
              theme: theme,
              hintText: "Password",
              labelText: "6+ characters",
              onClickPasswordVisisble: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your password";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => AppRouter.pushForgotPassword(context),
                child: Text(
                  "Forgot password?",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return CustomTextButton(
                    onClick: isLoading ? () {} : _onLoginPressed,
                    backgroundColor:
                        isLoading
                            ? theme.dividerColor.withAlpha(150)
                            : theme.colorScheme.tertiary,
                    child:
                        isLoading
                            ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.scaffoldBackgroundColor,
                              ),
                            )
                            : Text(
                              "Sign in",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.scaffoldBackgroundColor,
                                fontSize: 16,
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
