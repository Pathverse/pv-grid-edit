import 'package:flutter/material.dart';

import 'example_app.dart';

/// Describes one example destination shown on the home page.
class ExampleDestination {
  /// Creates a catalog item for one example route.
  const ExampleDestination({
    required this.title,
    required this.subtitle,
    required this.routeName,
    required this.icon,
  });

  /// User-facing page title.
  final String title;

  /// Short explanation of the example.
  final String subtitle;

  /// Navigator route for the example page.
  final String routeName;

  /// Icon shown in the example list.
  final IconData icon;
}

/// Lists the example pages exposed by the example application.
const List<ExampleDestination> exampleDestinations = <ExampleDestination>[
  ExampleDestination(
    title: 'Fixed Shapes',
    subtitle: 'Shows anchored rectangles that refuse move and resize requests.',
    routeName: ExampleApp.fixedRoute,
    icon: Icons.lock_outline,
  ),
  ExampleDestination(
    title: 'Constraint Playground',
    subtitle: 'Demonstrates min and max size limits with snapped grid edits.',
    routeName: ExampleApp.constrainedRoute,
    icon: Icons.straighten,
  ),
  ExampleDestination(
    title: 'Free Flow Layers',
    subtitle: 'Shows overlapping rectangles and z-order changes for free flow.',
    routeName: ExampleApp.freeFlowRoute,
    icon: Icons.layers_outlined,
  ),
];