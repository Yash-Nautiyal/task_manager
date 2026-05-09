import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_app/core/routing/app_router.dart';

import '../../../core/constants/app_icons.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final bool signinPage;
  final bool dashboardPage;
  final bool landingPage;
  final Function? onPressed;
  final int currentIndex;
  final Function(int, String?)? onPageChanged;
  const HomeAppBar({
    super.key,
    required this.theme,
    this.signinPage = false,
    this.dashboardPage = false,
    this.landingPage = false,
    this.onPressed,
    this.currentIndex = 0,
    this.onPageChanged,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat();

  late User? user;
  final Tween<double> turnsTween = Tween<double>(begin: 0, end: 1);

  String _extractInitials() {
    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';
    final display = displayName.trim();
    if (display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      final list = parts.toList();
      if (list.length >= 2) {
        return '${list.first[0]}${list.last[0]}'.toUpperCase();
      }
      return list.first[0].toUpperCase();
    }
    final safeEmail = email.trim();
    if (safeEmail.isNotEmpty) {
      return safeEmail[0].toUpperCase();
    }
    return 'U';
  }

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('User display name: ${user!.displayName}');
      debugPrint('User email: ${user!.email}');
    } else {
      debugPrint('No user is currently signed in.');
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: widget.landingPage || widget.dashboardPage ? 90 : null,
      leading:
          Navigator.canPop(context)
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: widget.theme.iconTheme.color,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
              : null,
      titleSpacing: 0,
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.scaffoldBackgroundColor.withValues(
                alpha: 0.9,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                  widget.theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 8),
      actions: [
        if (widget.dashboardPage) ...[
          IconButton(
            onPressed: () => widget.onPageChanged?.call(0, null),
            icon: SvgPicture.asset(
              AppIcons.homeIcon,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 0
                    ? widget.theme.colorScheme.primaryContainer
                    : widget.theme.disabledColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () => widget.onPageChanged?.call(1, null),
            icon: SvgPicture.asset(
              AppIcons.listBoldDuotoneIcon,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 1
                    ? widget.theme.colorScheme.primaryContainer
                    : widget.theme.disabledColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
        ],

        IconButton(
          icon: RotationTransition(
            turns: turnsTween.animate(_controller),
            child: SvgPicture.asset(
              AppIcons.settingIcon,
              colorFilter: ColorFilter.mode(
                widget.theme.disabledColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
          onPressed: () => AppRouter.showSettingsModal(context),
        ),
        if (widget.dashboardPage)
          GestureDetector(
            onTap:
                () => AppRouter.showProfileModal(context, theme: widget.theme),
            child: AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) => Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        center: Alignment.center,
                        startAngle: 0.0,
                        endAngle: 6.28319,
                        colors: const [
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.blue,
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                        transform: GradientRotation(
                          _controller.value * 6.28319,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: widget.theme.scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 14,
                          child: Text(
                            _extractInitials(),
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        if (widget.landingPage)
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () => widget.onPressed?.call(),
              child: Text(
                'Sign In',
                style: widget.theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
              ),
            ),
          ),
      ],
    );
  }
}
