import 'package:flutter/material.dart';

import 'src/example_app.dart';

/// Boots the multi-page example application.
void main() {
  runApp(const MyApp());
}

/// Exposes the package example application for runtime and tests.
class MyApp extends StatelessWidget {
  /// Creates the example application root widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExampleApp();
  }
}
