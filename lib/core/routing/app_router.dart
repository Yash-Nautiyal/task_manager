import 'package:flutter/material.dart';
import 'package:task_app/screens/auth/pages/auth_view.dart';
import 'package:task_app/screens/auth/widgets/signup_page.dart';
import 'package:task_app/screens/home/pages/home_view.dart';
import 'package:task_app/screens/root/root_screen.dart';
import 'package:task_app/services/auth_service.dart';
import 'package:task_app/widgets/header/profile.dart';
import 'package:task_app/widgets/header/settings/settings.dart';

import 'app_routes.dart';

abstract final class AppRouter {
  AppRouter._();
  static final AuthService _authService = AuthService();

  static bool get _isAuthenticated => _authService.currentUser != null;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeView(),
          settings: settings,
        );
      case AppRoutes.auth:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthView(),
          settings: settings,
        );
      case AppRoutes.layout:
        return MaterialPageRoute<void>(
          builder: (_) => RootScreen(user: _authService.currentUser!),
          settings: const RouteSettings(name: AppRoutes.auth),
        );

      case AppRoutes.signup:
        return MaterialPageRoute<void>(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      // case AppRoutes.forgotPassword:
      //   return MaterialPageRoute<void>(
      //     builder: (_) => const ForgotPassword(),
      //     settings: settings,
      //   );
      // case AppRoutes.resetPassword:
      //   return MaterialPageRoute<void>(
      //     builder: (_) => const ResetPasswordPage(),
      //     settings: settings,
      //   );
      // case AppRoutes.confirm:
      //   return MaterialPageRoute<void>(
      //     builder: (_) => const ConfirmPage(),
      //     settings: settings,
      //   );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _UnknownRouteScreen(),
          settings: settings,
        );
    }
  }

  static Future<T?> pushAuth<T extends Object?>(BuildContext context) {
    if (_isAuthenticated) {
      return Navigator.of(context).pushNamed<T>(AppRoutes.layout);
    }
    return Navigator.of(context).pushNamed<T>(AppRoutes.auth);
  }

  static Future<T?> pushDashboardAndRemoveUntil<T extends Object?>(
    BuildContext context,
  ) {
    if (_isAuthenticated) {
      return Navigator.of(
        context,
      ).pushNamedAndRemoveUntil<T>(AppRoutes.layout, (route) => false);
    }
    return Navigator.of(
      context,
    ).pushNamedAndRemoveUntil<T>(AppRoutes.auth, (route) => false);
  }

  static Future<T?> pushSignup<T extends Object?>(BuildContext context) =>
      Navigator.of(context).pushNamed<T>(AppRoutes.signup);

  // static Future<T?> pushForgotPassword<T extends Object?>(
  //   BuildContext context,
  // ) => Navigator.of(context).pushNamed<T>(AppRoutes.forgotPassword);

  // static Future<T?> pushResetPassword<T extends Object?>(
  //   BuildContext context,
  // ) => Navigator.of(context).pushNamed<T>(AppRoutes.resetPassword);

  // static Future<T?> pushConfirm<T extends Object?>(BuildContext context) =>
  //     Navigator.of(context).pushNamed<T>(AppRoutes.confirm);

  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static Future<T?> showSettingsModal<T extends Object?>(BuildContext context) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        settings: const RouteSettings(name: AppRoutes.settingsModal),
        opaque: false,
        barrierColor: Colors.black38,
        pageBuilder: (context, _, __) => const SettingsDialog(),
      ),
    );
  }

  static Future<T?> showProfileModal<T extends Object?>(
    BuildContext context, {
    required ThemeData theme,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        settings: const RouteSettings(name: AppRoutes.profileModal),
        opaque: false,
        barrierColor: Colors.black38,
        pageBuilder: (context, _, __) => ProfileDialog(theme: theme),
      ),
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('This route is not registered.')),
    );
  }
}
