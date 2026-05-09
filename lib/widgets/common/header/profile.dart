import 'package:flutter/material.dart';

import '../dialog/slide_dialog.dart';

class ProfileDialog extends StatelessWidget {
  final ThemeData theme;

  const ProfileDialog({super.key, required this.theme});

  String _buildInitials({required String displayName, required String email}) {
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

    return 'P';
  }

  @override
  Widget build(BuildContext context) {
    String name = '';
    String email = '';

    final initials = _buildInitials(displayName: name, email: email);

    return SlideDialog(
      theme: theme,
      title: "Profile",
      isProfile: true,
      onDeleteAccount: () async {},
      onDeleteSuccess: () => {},
      child: Column(
        children: [
          const SizedBox(height: 60),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 85,
                height: 85,
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
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.scaffoldBackgroundColor,
                radius: 41,
                child: CircleAvatar(
                  radius: 39,
                  child: Text(
                    initials,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(),
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
