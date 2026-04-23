import 'package:flutter/material.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

import '../example_layouts.dart';
import '../widgets/example_page_frame.dart';

/// Demonstrates shapes that resize inside min and max bounds.
class ConstrainedShapesPage extends StatefulWidget {
  /// Creates the constrained-shape example page.
  const ConstrainedShapesPage({super.key});

  @override
  State<ConstrainedShapesPage> createState() => _ConstrainedShapesPageState();
}

/// Holds the demo bloc used by the constrained-shape example page.
class _ConstrainedShapesPageState extends State<ConstrainedShapesPage> {
  /// Bloc driving the constrained-shape example.
  late final GridEditorBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = GridEditorBloc(initialLayout: buildConstrainedShapesLayout());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageFrame(
      title: 'Constraint Playground',
      description:
          'This mixed layout combines a frozen frame, a constrained viewport, and a fixed-size movable cursor. Constrained shapes can move across snapped grid points, but their size is clamped to configured min and max bounds.',
      bloc: bloc,
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            bloc.add(
              const GridShapeResized(
                shapeId: 'viewport',
                size: GridSize(columns: 5, rows: 4),
              ),
            );
          },
          child: const Text('Grow within limits'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeResized(
                shapeId: 'viewport',
                size: GridSize(columns: 1, rows: 0),
              ),
            );
          },
          child: const Text('Shrink within limits'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeMoved(
                shapeId: 'cursor',
                position: GridPoint(column: 3, row: 4),
              ),
            );
          },
          child: const Text('Mixed layout'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeDragged(
                shapeId: 'viewport',
                canvasOffset: GridCanvasOffset(dx: 176, dy: 132),
                snapSpec: GridSnapSpec(cellWidth: 44, cellHeight: 44),
              ),
            );
          },
          child: const Text('Snap move viewport'),
        ),
      ],
    );
  }
}