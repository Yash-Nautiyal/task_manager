import 'package:flutter/material.dart';

class DbTabBar extends StatefulWidget {
  const DbTabBar({
    super.key,
    required this.theme,
    required this.tabController,
    required this.tabs,
    required this.tabCounts,
    required this.onTabSelected,
  });

  final ThemeData theme;
  final TabController tabController;
  final List<String> tabs;
  final List<int> tabCounts;
  final Function onTabSelected;

  @override
  State<DbTabBar> createState() => _DbTabBarState();
}

class _DbTabBarState extends State<DbTabBar> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
  }

  void _scrollListener() {
    _updateArrows();
  }

  void _updateArrows() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.theme.scaffoldBackgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ), // space for arrows
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: TabBar(
                onTap: (value) => widget.onTabSelected(value),
                controller: widget.tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelStyle: widget.theme.textTheme.labelLarge?.copyWith(
                  color: widget.theme.colorScheme.tertiary,
                ),
                unselectedLabelColor: widget.theme.disabledColor,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: widget.theme.colorScheme.tertiary,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 4),
                ),
                tabs: List.generate(widget.tabs.length, (index) {
                  final tab = widget.tabs[index];
                  final count =
                      index < widget.tabCounts.length
                          ? widget.tabCounts[index]
                          : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Tab(text: '$tab ($count)'),
                  );
                }),
              ),
            ),
          ),
          if (_canScrollLeft)
            Positioned(
              left: 0,
              child: IconButton(
                style: ButtonStyle(
                  maximumSize: WidgetStatePropertyAll(Size(40, 40)),
                  minimumSize: WidgetStatePropertyAll(Size(20, 20)),
                  shape: WidgetStatePropertyAll(CircleBorder()),
                  backgroundColor: WidgetStatePropertyAll(
                    widget.theme.dividerColor.withOpacity(.2),
                  ),
                ),
                icon: const Icon(Icons.arrow_left),
                onPressed: _scrollLeft,
              ),
            ),
          if (_canScrollRight)
            Positioned(
              right: 0,
              child: IconButton(
                style: ButtonStyle(
                  maximumSize: WidgetStatePropertyAll(Size(40, 40)),
                  minimumSize: WidgetStatePropertyAll(Size(20, 20)),
                  shape: WidgetStatePropertyAll(CircleBorder()),
                  backgroundColor: WidgetStatePropertyAll(
                    widget.theme.dividerColor.withOpacity(.2),
                  ),
                ),
                icon: const Icon(Icons.arrow_right),
                onPressed: _scrollRight,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
