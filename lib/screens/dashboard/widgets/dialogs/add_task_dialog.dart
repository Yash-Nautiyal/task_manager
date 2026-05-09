import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/common/inputField/custom_textfield.dart';

import 'footer_buttons.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final ThemeData theme;
  final Task? task;
  final bool isEdit;
  const AddTaskDialog({
    super.key,
    required this.onTaskCreated,
    required this.theme,
    this.task,
    this.isEdit = false,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime?
  _selectedDateTime; // Replace _selectedDate and _selectedTime with this

  TaskStatus _selectedStatus = TaskStatus.todo;

  final _subtaskController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDateTime = widget.task!.dueDate;
      _selectedStatus = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate:
          _selectedDateTime != null
              ? _selectedDateTime!.subtract(const Duration(days: 365))
              : DateTime.now(),
      lastDate:
          _selectedDateTime != null
              ? _selectedDateTime!.add(const Duration(days: 365))
              : DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            _selectedDateTime != null
                ? TimeOfDay.fromDateTime(_selectedDateTime!)
                : TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.isEdit && widget.task != null) {
      //
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDateTime!,
      status: _selectedStatus,
      completedAt: null,
    );

    widget.onTaskCreated(task);
    Navigator.of(context).pop();
  }

  String _formatDateTime() {
    if (_selectedDateTime == null) return '';
    return '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at '
        '${TimeOfDay.fromDateTime(_selectedDateTime!).format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * .9,
          minWidth: screenWidth * .9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    widget.isEdit ? 'Update Task' : 'Create New Task',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.disabledColor),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title
                    CustomTextfield(
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      theme: theme,
                      onchange: (value) {
                        // Controller is already updated by TextFormField
                        // No need to set it again to avoid cursor jumping
                      },
                      hintText: 'Enter task title',
                      labelText: 'Task Title *',
                    ),
                    const SizedBox(height: 16),
                    // Description
                    CustomTextfield(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      theme: theme,
                      onchange: (value) {
                        // Controller is already updated by TextFormField
                        // No need to set it again to avoid cursor jumping
                      },
                      hintText: 'Enter task description',
                      labelText: 'Description',
                      maxLines: 3,
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Due Date & Time
                    InkWell(
                      onTap: _selectDateTime,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDateTime().isEmpty
                                    ? 'Due Date & Time *'
                                    : _formatDateTime(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      _formatDateTime().isEmpty
                                          ? theme.disabledColor
                                          : theme.colorScheme.tertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              "assets/icons/ic-calender.svg",
                              color: theme.disabledColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    // if (widget.isEdit &&
                    //     _selectedDateTime != null &&
                    //     _selectedDateTime!.isBefore(DateTime.now()))
                    //   CustomDropdown(
                    //     theme: theme,
                    //     value: _selectedStatus,
                    //     onChange:
                    //         (value) => setState(() {
                    //           _selectedStatus = value;
                    //         }),
                    //     items:
                    //         TaskStatus.values.map((status) {
                    //           return DropdownMenuItem(
                    //             value: status,
                    //             child: Text(
                    //               getStatusText(status),
                    //               style: theme.textTheme.bodyMedium?.copyWith(
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //           );
                    //         }).toList(),
                    //     label: 'Status *',
                    //   ),
                    // const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: FooterButtons(
                theme: theme,
                createTask: _createTask,
                isEdit: widget.isEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
