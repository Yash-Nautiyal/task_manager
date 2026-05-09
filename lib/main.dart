import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/firebase_options.dart';
import 'package:task_app/screens/auth/bloc/auth_bloc.dart';
import 'package:task_app/services/auth_service.dart';

import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
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
    final isAuthenticated = AuthService().currentUser != null;

    return MaterialApp(
      title: 'Sankar Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: isAuthenticated ? AppRoutes.dashboard : AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
