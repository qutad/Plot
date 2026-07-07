import 'package:flutter/material.dart';
import 'package:plot/app/app_router.dart';
import 'package:plot/core/theme/plot_theme.dart';

class PlotApp extends StatelessWidget {
  const PlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plot',
      debugShowCheckedModeBanner: false,
      theme: PlotTheme.dark,
      routerConfig: appRouter,
    );
  }
}
