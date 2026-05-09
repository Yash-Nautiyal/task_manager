import 'package:flutter/material.dart';

import '../../../core/routing/app_router.dart';
import '../../../widgets/common/appBar/home_appbar.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_minimal.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= MediaQuery.sizeOf(context).height &&
        !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset < MediaQuery.sizeOf(context).height &&
        _showBackToTop) {
      setState(() => _showBackToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HomeAppBar(
        theme: theme,
        landingPage: true,
        onPressed: () => AppRouter.pushAuth(context),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(
          parent: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
        ),
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const HomeHero(),
            HomeMinimal(theme: theme),
          ],
        ),
      ),
    );
  }
}
