import 'package:flutter/material.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

/// Provides a consistent layout shell for one example page.
class ExamplePageFrame extends StatelessWidget {
  /// Creates a page frame with copy, actions, and an editor preview.
  const ExamplePageFrame({
    super.key,
    required this.title,
    required this.description,
    required this.bloc,
    required this.actions,
  });

  /// Title shown in the app bar and body.
  final String title;

  /// Short explanatory copy for the example.
  final String description;

  /// Bloc driving the editor preview.
  final GridEditorBloc bloc;

  /// Action buttons used to demonstrate the example behavior.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Flex(
                direction: constraints.maxWidth > 840 ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: constraints.maxWidth > 840 ? (constraints.maxWidth - 64) / 2 : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        Text(description, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 20),
                        Wrap(spacing: 12, runSpacing: 12, children: actions),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24, height: 24),
                  SizedBox(
                    width: constraints.maxWidth > 840 ? (constraints.maxWidth - 64) / 2 : constraints.maxWidth - 40,
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              blurRadius: 24,
                              color: Color(0x15000000),
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridEditor(
                            bloc: bloc,
                            snapSpec: const GridSnapSpec(cellWidth: 44, cellHeight: 44),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}