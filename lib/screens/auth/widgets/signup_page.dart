import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/core/routing/app_router.dart';
import 'package:task_app/widgets/common/dialog/snackbar_dialog.dart';
import 'package:task_app/widgets/common/inputField/custom_textfield.dart';
import '../../../widgets/common/button/custom_textbutton.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authBloc = context.read<AuthBloc>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          authBloc.add(const AuthInFlightDismissed());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(),
        body: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            if (current is AuthError) return true;
            if (current is Authenticated && previous is AuthLoading) {
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
                'Account created. You are signed in.',
                SnackbarType.success,
              );
              AppRouter.pushDashboardAndRemoveUntil(context);
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Get started absolutely free",
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    CustomTextfield(
                      controller: firstnameController,
                      theme: theme,
                      hintText: "",
                      labelText: "First Name",
                      onchange: (text) {},
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter your first name";
                        }
                        if (value.length < 2) return "Name too short";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      controller: lastnameController,
                      theme: theme,
                      hintText: "",
                      labelText: "Last Name",
                      onchange: (text) {},
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter your last name";
                        }
                        if (value.length < 2) return "Name too short";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      controller: emailController,
                      theme: theme,
                      hintText: "",
                      labelText: "Email Address",
                      onchange: (text) {},
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter your email";
                        }
                        final emailRegex = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      isPasswordVisible: isPasswordVisible,
                      onchange: (text) {},
                      theme: theme,
                      hintText: "Password",
                      labelText: "6+ characters",
                      onClickPasswordVisisble: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
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
                    const SizedBox(height: 30),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              return CustomTextButton(
                                onClick: () {
                                  if (isLoading) return;
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  FocusScope.of(context).unfocus();
                                  context.read<AuthBloc>().add(
                                    AuthSignUpRequested(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      firstname:
                                          firstnameController.text.trim(),
                                      lastname: lastnameController.text.trim(),
                                    ),
                                  );
                                },
                                backgroundColor:
                                    isLoading
                                        ? theme.disabledColor.withAlpha(150)
                                        : theme.colorScheme.tertiary,
                                child:
                                    isLoading
                                        ? SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                theme.scaffoldBackgroundColor,
                                          ),
                                        )
                                        : Text(
                                          "Sign Up",
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .scaffoldBackgroundColor,
                                                fontSize: 16,
                                              ),
                                        ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By signing up, I agree to ",
                            style: theme.textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: "Terms of service ",
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: "and ",
                            style: theme.textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: "Privacy policy.",
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }
}
