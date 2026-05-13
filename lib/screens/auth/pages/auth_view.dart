import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/appBar/home_appbar.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/signin_page.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

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
        appBar: HomeAppBar(theme: theme, signinPage: true),
        extendBody: true,
        body: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ).copyWith(top: 25),
              child: Column(children: [AuthPage()]),
            ),
          ),
        ),
      ),
    );
  }
}
