import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/common/inputField/custom_textfield.dart';

import '../../../models/filter_model.dart';

class DbFilters extends StatefulWidget {
  final ThemeData theme;
  final List<Task> allTasks;
  final Function(FilterModel) onFiltersChanged;
  final FilterModel? currentFilters;
  final bool? isGrid;
  final VoidCallback? onGridToggled;
  const DbFilters({
    super.key,
    required this.theme,
    required this.allTasks,
    required this.onFiltersChanged,
    this.currentFilters,
    this.isGrid = false,
    this.onGridToggled,
  });

  @override
  State<DbFilters> createState() => _DbFiltersState();
}

class _DbFiltersState extends State<DbFilters> with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _dateController;
  late AnimationController _tagController;
  late FilterModel _currentFilters;

  bool _isSearchExpanded = false;
  bool _isDateExpanded = false;

  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final multiValueListenable = ValueNotifier<List<String>>([]);

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tagController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentFilters = widget.currentFilters ?? FilterModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    _tagController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeAllFields() {
    if (_isSearchExpanded) {
      _searchController.reverse();
      _searchTextController.clear();
      _updateFilters(_currentFilters.copyWith(searchQuery: ''));
    }
    if (_isDateExpanded) {
      _dateController.reverse();
      _updateFilters(
        _currentFilters.copyWith(clearStartDate: true, clearEndDate: true),
      );
    }

    setState(() {
      _isSearchExpanded = false;
      _isDateExpanded = false;
    });
  }

  void _toggleSearch() {
    _closeAllFields();
    setState(() {
      _isSearchExpanded = true;
      _searchController.forward();
      _searchFocusNode.requestFocus();
    });
  }

  void _toggleDate() {
    _closeAllFields();
    setState(() {
      _isDateExpanded = true;
      _dateController.forward();
    });
  }

  void _updateFilters(FilterModel newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),

      initialDateRange:
          _currentFilters.startDate != null && _currentFilters.endDate != null
              ? DateTimeRange(
                start: _currentFilters.startDate!,
                end: _currentFilters.endDate!,
              )
              : null,
    );

    if (picked != null) {
      _updateFilters(
        _currentFilters.copyWith(startDate: picked.start, endDate: picked.end),
      );
    }
  }

  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('search-field'),
      constraints: BoxConstraints(maxWidth: 200),
      height: 48,
      child: CustomTextfield(
        controller: _searchTextController,
        keyboardType: TextInputType.text,
        theme: widget.theme,
        onchange: (value) {
          _updateFilters(_currentFilters.copyWith(searchQuery: value));
        },
        hintText: '',
        labelText: 'Search by Title',
        close: true,
        onClose: () => _closeAllFields(),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        key: const ValueKey('date-field'),
        constraints: const BoxConstraints(
          maxWidth: 200,
          minWidth: 150,
        ), // Added minWidth
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ).copyWith(right: 0),
        decoration: BoxDecoration(
          border: Border.all(color: widget.theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Changed from max to min
          children: [
            SvgPicture.asset(
              'assets/icons/common/solid/ic-solar-calendar-mark-bold-duotone.svg',
              color: widget.theme.disabledColor,
              width: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              // Changed from Expanded to Flexible
              child: Text(
                _currentFilters.startDate != null &&
                        _currentFilters.endDate != null
                    ? '${_currentFilters.startDate!.day}/${_currentFilters.startDate!.month} - ${_currentFilters.endDate!.day}/${_currentFilters.endDate!.month}'
                    : 'Select dates',
                style: widget.theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis, // Added overflow handling
                maxLines: 1, // Ensure single line
              ),
            ),
            IconButton(
              onPressed: _closeAllFields,
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search - Icon transforms to field
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child:
                _isSearchExpanded
                    ? Container(
                      key: const ValueKey('search-field'),
                      height: 55, // <-- Increase height to fit floating label
                      alignment: Alignment.center,
                      child: _buildSearchField(),
                    )
                    : IconButton(
                      key: const ValueKey('search-icon'),
                      onPressed: _toggleSearch,
                      icon: SvgPicture.asset(
                        'assets/icons/ic-eva_search-fill.svg',
                        color: widget.theme.disabledColor,
                      ),
                    ),
          ),

          // Date - Icon transforms to field
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                // Changed from ScaleTransition to FadeTransition
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child:
                _isDateExpanded
                    ? _buildDateField()
                    : IconButton(
                      key: const ValueKey('date-icon'),
                      onPressed: _toggleDate,
                      icon: SvgPicture.asset(
                        'assets/icons/ic-calender.svg',
                        // ignore: deprecated_member_use
                        color: widget.theme.disabledColor,
                      ),
                    ),
          ),

          if (widget.onGridToggled != null && widget.isGrid != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  // Changed from ScaleTransition to FadeTransition
                  opacity: animation,
                  child: child,
                );
              },
              child:
                  widget.isGrid!
                      ? IconButton(
                        key: const ValueKey('list-icon'),
                        onPressed: widget.onGridToggled?.call,
                        icon: SvgPicture.asset(
                          'assets/icons/common/solid/ic-solar-list.svg',
                          // ignore: deprecated_member_use
                          color: widget.theme.disabledColor,
                        ),
                      )
                      : IconButton(
                        key: const ValueKey('grid-icon'),
                        onPressed: widget.onGridToggled?.call,
                        icon: SvgPicture.asset(
                          'assets/icons/common/solid/ic-solar-widget.svg',
                          // ignore: deprecated_member_use
                          color: widget.theme.disabledColor,
                        ),
                      ),
            ),
        ],
      ),
    );
  }
}
