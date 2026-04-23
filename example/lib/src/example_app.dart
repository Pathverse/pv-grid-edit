import 'package:flutter/material.dart';

import 'pages/constrained_shapes_page.dart';
import 'pages/fixed_shapes_page.dart';
import 'pages/free_flow_layers_page.dart';
import 'pages/home_page.dart';

/// Builds the routed shell for the package example application.
class ExampleApp extends StatelessWidget {
  /// Creates the routed example application widget tree.
  const ExampleApp({super.key});

  /// The route name for the landing page.
  static const String homeRoute = '/';

  /// The route name for the fixed-shape example page.
  static const String fixedRoute = '/fixed-shapes';

  /// The route name for the constrained-shape example page.
  static const String constrainedRoute = '/constraint-playground';

  /// The route name for the free-flowing example page.
  static const String freeFlowRoute = '/free-flow-layers';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PV Grid Edit Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF5EFE3),
        useMaterial3: true,
      ),
      routes: <String, WidgetBuilder>{
        homeRoute: (_) => const HomePage(),
        fixedRoute: (_) => const FixedShapesPage(),
        constrainedRoute: (_) => const ConstrainedShapesPage(),
        freeFlowRoute: (_) => const FreeFlowLayersPage(),
      },
    );
  }
}