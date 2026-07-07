import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:plot/features/dashboard/presentation/dashboard_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);

extension PlotNavigation on BuildContext {
  void goHome() => go('/');
}
