// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../../../core/constants/app_icons.dart' show AppIcons;
// import '../../../widgets/common/dialog/snackbar_dialog.dart';
// import '../../../widgets/common/button/custom_textbutton.dart';
// import '../../../widgets/common/inputField/custom_textfield.dart';
// import '../bloc/auth_bloc.dart';

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   final emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     emailController.dispose();
//     super.dispose();
//   }

//   void _sendResetRequest() {
//     if (!_formKey.currentState!.validate()) return;
//     FocusScope.of(context).unfocus();
//     context.read<AuthBloc>().add(
//       AuthResetPasswordRequested(email: emailController.text.trim()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authBloc = context.read<AuthBloc>();

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) {
//           authBloc.add(const AuthInFlightDismissed());
//         }
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: theme.scaffoldBackgroundColor,
//         appBar: AppBar(),
//         body: BlocListener<AuthBloc, AuthState>(
//         listenWhen:
//             (previous, current) =>
//                 current is AuthError || current is AuthPasswordResetEmailSent,
//         listener: (context, state) {
//           if (state is AuthPasswordResetEmailSent) {
//             showAnimatedSnackbar(
//               context,
//               state.message,
//               SnackbarType.success,
//             );
//           } else if (state is AuthError) {
//             showAnimatedSnackbar(context, state.message, SnackbarType.error);
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Align(
//                   alignment: Alignment.center,
//                   child: SvgPicture.asset(
//                     AppIcons.forgotPasswordIllustration,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Forgot your Password?",
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 Text(
//                   "Please enter the email address associated with your account and we'll email you a link to reset your password.",
//                   style: theme.textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 25),
//                 CustomTextfield(
//                   controller: emailController,
//                   theme: theme,
//                   hintText: "",
//                   labelText: "Email Address",
//                   onchange: (text) {},
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return "Enter your email";
//                     }
//                     final emailRegex = RegExp(
//                       r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
//                     );
//                     if (!emailRegex.hasMatch(value)) {
//                       return "Enter a valid email";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Expanded(
//                       child: BlocBuilder<AuthBloc, AuthState>(
//                         builder: (context, state) {
//                           final isLoading = state is AuthLoading;
//                           return CustomTextButton(
//                             onClick: isLoading ? () {} : _sendResetRequest,
//                             backgroundColor:
//                                 isLoading
//                                     ? theme.dividerColor.withAlpha(150)
//                                     : theme.colorScheme.tertiary,
//                             child:
//                                 isLoading
//                                     ? SizedBox(
//                                       height: 22,
//                                       width: 22,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color:
//                                             theme.scaffoldBackgroundColor,
//                                       ),
//                                     )
//                                     : Text(
//                                       "Send Request",
//                                       style: theme.textTheme.labelLarge
//                                           ?.copyWith(
//                                             color:
//                                                 theme.scaffoldBackgroundColor,
//                                             fontSize: 16,
//                                           ),
//                                     ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.arrow_back_rounded, size: 20),
//                       const SizedBox(width: 10),
//                       Text(
//                         "Return to sign in",
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//     );
//   }
// }
