import 'package:flutter/material.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

import '../example_layouts.dart';
import '../widgets/example_page_frame.dart';

/// Demonstrates shapes that are fixed in place on the grid.
class FixedShapesPage extends StatefulWidget {
  /// Creates the fixed-shape example page.
  const FixedShapesPage({super.key});

  @override
  State<FixedShapesPage> createState() => _FixedShapesPageState();
}

/// Holds the demo bloc used by the fixed-shape example page.
class _FixedShapesPageState extends State<FixedShapesPage> {
  /// Bloc driving the fixed-shape example.
  late final GridEditorBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = GridEditorBloc(initialLayout: buildFixedShapesLayout());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageFrame(
      title: 'Fixed Shapes',
      description:
          'This mixed layout blends frozen rectangles with one fixed-size movable runner. Frozen shapes stay locked in both position and size, while the runner can move without changing its snapped size.',
      bloc: bloc,
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            bloc.add(const GridShapeSelected(shapeId: 'panel'));
          },
          child: const Text('Select panel'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeMoved(
                shapeId: 'runner',
                position: GridPoint(column: 3, row: 4),
              ),
            );
          },
          child: const Text('Move fixed-size runner'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeResized(
                shapeId: 'status',
                size: GridSize(columns: 4, rows: 3),
              ),
            );
          },
          child: const Text('Attempt frozen resize'),
        ),
      ],
    );
  }
}