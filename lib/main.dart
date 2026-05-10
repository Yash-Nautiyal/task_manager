import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/core/theme/bloc/theme_bloc.dart';
import 'package:task_app/firebase_options.dart';
import 'package:task_app/screens/auth/bloc/auth_bloc.dart';
import 'package:task_app/screens/root/root_screen.dart';
import 'package:task_app/services/auth_service.dart';
import 'package:task_app/widgets/common/loader/custom_loader.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/pages/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final themeBloc = await ThemeBloc.create();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeBloc),

        BlocProvider<AuthBloc>(
          create:
              (_) =>
                  AuthBloc(authService: AuthService())
                    ..add(AuthCheckRequested()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AnimatedTheme(
          data: buildTheme(brightness: state.brightness),
          child: MaterialApp(
            title: 'Sankar Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthInitial || state is AuthLoading) {
                  return const Scaffold(body: CustomLoader());
                }

                if (state is Authenticated) {
                  return RootScreen(user: state.user);
                }

                return const HomeView();
              },
            ),
          ),
        );
      },
    );
  }
}
