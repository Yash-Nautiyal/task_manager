// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:task_app/core/constants/app_icons.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/popup/popup.dart';
import 'package:task_app/widgets/popup/responsive_popup.dart';
import 'package:task_app/widgets/popup/responsive_popup_item.dart';

class TaskCardHeader extends StatelessWidget {
  final TaskStatus status;
  final String title;
  final ThemeData theme;
  final GlobalKey popupAnchorKey;
  final LayerLink layerLink;
  final ResponsivePopupController popupController;
  final VoidCallback onEdit;
  final Function(bool) onCompleteTask;
  final VoidCallback onDelete;

  const TaskCardHeader({
    super.key,
    required this.status,
    required this.title,
    required this.theme,
    required this.popupAnchorKey,
    required this.layerLink,
    required this.popupController,
    required this.onEdit,
    required this.onCompleteTask,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = status == TaskStatus.completed;

    final titleColor =
        isCompleted
            ? (isDark
                ? AppPallete.successMain.withOpacity(0.65)
                : AppPallete.successMain)
            : (isDark
                ? Colors.white.withOpacity(0.88)
                : theme.colorScheme.onSurface);

    final moreIconColor =
        isDark
            ? Colors.white.withOpacity(0.38)
            : Colors.black.withOpacity(0.30);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 0.88,
            child: Checkbox(
              value: isCompleted,
              activeColor: AppPallete.successMain,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.28)
                        : Colors.black.withOpacity(0.22),
                width: 1.5,
              ),
              onChanged: (value) => onCompleteTask(value!),
            ),
          ),

          Expanded(
            child: Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
                height: 1.3,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: AppPallete.successMain.withOpacity(0.65),
                decorationThickness: 1.8,
              ),
            ),
          ),

          Popup(
            popupAnchorKey: popupAnchorKey,
            layerLink: layerLink,
            icon: Icon(Icons.more_vert, size: 20, color: moreIconColor),
            popupController: popupController,
            manualOffset: const Offset(-16, 0),
            arrowOffset: 0.75,
            preferredPosition: PopupPreferredPosition.bottom,
            items: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ResponsivePopupItem(
                  title: 'Edit',
                  svgIcon: AppIcons.penBoldIcon,
                  onTap: () {
                    popupController.hide();
                    onEdit();
                  },
                  color: theme.colorScheme.tertiary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: DestructivePopupItem(
                  onTap: onDelete,
                  popupController: popupController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
