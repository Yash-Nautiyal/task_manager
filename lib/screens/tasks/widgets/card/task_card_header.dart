import 'package:flutter/material.dart';
import 'package:task_app/core/constants/app_icons.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/common/popup/popup.dart';
import 'package:task_app/widgets/common/popup/responsive_popup.dart';
import 'package:task_app/widgets/common/popup/responsive_popup_item.dart';

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
    return Padding(
      padding: EdgeInsets.only(right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: status == TaskStatus.completed,
            activeColor: AppPallete.successMain,
            checkColor: AppPallete.white,
            onChanged: (value) {
              onCompleteTask(value!);
            },
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: theme.textTheme.titleMedium?.copyWith(
                decoration:
                    status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                color:
                    status == TaskStatus.completed
                        ? AppPallete.successMain
                        : null,
              ),
            ),
          ),

          Popup(
            popupAnchorKey: popupAnchorKey,
            layerLink: layerLink,
            icon: const Icon(Icons.more_vert),
            popupController: popupController,
            manualOffset: Offset(-16, 0),
            arrowOffset: 0.75,
            preferredPosition: PopupPreferredPosition.bottom,
            items: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
