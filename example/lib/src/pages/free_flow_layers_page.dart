import 'package:flutter/material.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

import '../example_layouts.dart';
import '../widgets/example_page_frame.dart';

/// Demonstrates overlapping free-flowing shapes and z-order updates.
class FreeFlowLayersPage extends StatefulWidget {
  /// Creates the free-flowing shapes example page.
  const FreeFlowLayersPage({super.key});

  @override
  State<FreeFlowLayersPage> createState() => _FreeFlowLayersPageState();
}

/// Holds the demo bloc used by the free-flowing shapes example page.
class _FreeFlowLayersPageState extends State<FreeFlowLayersPage> {
  /// Bloc driving the free-flowing example.
  late final GridEditorBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = GridEditorBloc(initialLayout: buildFreeFlowLayout());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageFrame(
      title: 'Free Flow Layers',
      description:
          'Frozen frame + floating layers: this mixed layout blends a frozen header, overlapping free-flowing rectangles, a fixed-size movable runner, and a non-overlapping base strip. Free-flowing rectangles can overlap and change z-order while the non-overlapping shapes still restore on collision.',
      bloc: bloc,
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            bloc.add(const GridShapeBroughtToFront(shapeId: 'teal'));
          },
          child: const Text('Bring teal to front'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(const GridShapeBroughtToFront(shapeId: 'amber'));
          },
          child: const Text('Bring amber to front'),
        ),
        OutlinedButton(
          onPressed: () {
            bloc.add(
              const GridShapeDragged(
                shapeId: 'teal',
                canvasOffset: GridCanvasOffset(dx: 220, dy: 88),
                snapSpec: GridSnapSpec(cellWidth: 44, cellHeight: 44),
              ),
            );
          },
          child: const Text('Snap teal to new layer'),
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
        const Chip(label: Text('Frozen frame + floating layers')),
      ],
    );
  }
}