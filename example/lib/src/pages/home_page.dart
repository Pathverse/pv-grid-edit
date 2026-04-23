import 'package:flutter/material.dart';

import '../example_catalog.dart';

/// Lists the available example routes for the package demo app.
class HomePage extends StatelessWidget {
  /// Creates the example landing page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PV Grid Edit Examples')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: exampleDestinations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final destination = exampleDestinations[index];
          return Card(
            child: ListTile(
              leading: Icon(destination.icon),
              title: Text(destination.title),
              subtitle: Text(destination.subtitle),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamed(destination.routeName);
              },
            ),
          );
        },
      ),
    );
  }
}