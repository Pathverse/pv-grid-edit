import 'package:flutter/material.dart';

import '../bloc/grid_editor_bloc.dart';
import '../models/grid_rectangle_shape.dart';
import '../models/grid_shape.dart';
import '../utils/grid_snap.dart';
import 'grid_rectangle_tile.dart';

/// Paints the current grid editor state into positioned shape widgets.
final class GridCanvas extends StatelessWidget {
  /// Creates a grid canvas for the current editor state.
  const GridCanvas({
    super.key,
    required this.state,
    required this.snapSpec,
    required this.onShapeTap,
    required this.onShapeDrag,
    required this.onShapeResize,
  });

  /// Current editor state to render.
  final GridEditorState state;

  /// Snap metrics used to convert grid units into pixels.
  final GridSnapSpec snapSpec;

  /// Called when one shape is tapped.
  final ValueChanged<String> onShapeTap;

  /// Called when one shape is dragged to a raw canvas offset.
  final void Function(String shapeId, GridCanvasOffset offset) onShapeDrag;

  /// Called when one shape is resized to a raw pixel size.
  final void Function(String shapeId, GridCanvasOffset size) onShapeResize;

  @override
  Widget build(BuildContext context) {
    final shapes = List<GridShape>.from(state.layout.shapes)
      ..sort((left, right) => left.zIndex.compareTo(right.zIndex));

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = GridCanvasOffset(
          dx: constraints.maxWidth,
          dy: constraints.maxHeight,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F1E8),
            border: Border.all(color: const Color(0xFFB8AD92)),
          ),
          child: Stack(
            children: shapes.map((shape) {
              if (shape is! GridRectangleShape) {
                return const SizedBox.shrink();
              }

              final clampedPosition = snapSpec.clampPointToBoard(
                point: shape.position,
                shapeSize: shape.size,
                boardSize: boardSize,
              );
              final clampedSize = snapSpec.clampSizeToBoard(
                size: shape.size,
                position: clampedPosition,
                boardSize: boardSize,
              );
              final visibleShape = shape.copyWith(
                position: clampedPosition,
                size: clampedSize,
              );

              return GridRectangleTile(
                shape: visibleShape,
                snapSpec: snapSpec,
                selected: state.selectedShapeId == shape.id,
                onTap: () => onShapeTap(shape.id),
                onDrag: shape.canMove
                    ? (offset) {
                        final snappedPoint = snapSpec.snap(offset);
                        final clampedPoint = snapSpec.clampPointToBoard(
                          point: snappedPoint,
                          shapeSize: shape.size,
                          boardSize: boardSize,
                        );
                        onShapeDrag(shape.id, snapSpec.offsetForPoint(clampedPoint));
                      }
                    : null,
                onResize: shape.canResize
                    ? (size) {
                        final snappedSize = snapSpec.snapSize(size);
                        final clampedSize = snapSpec.clampSizeToBoard(
                          size: snappedSize,
                          position: shape.position,
                          boardSize: boardSize,
                        );
                        onShapeResize(shape.id, snapSpec.offsetForSize(clampedSize));
                      }
                    : null,
              );
            }).toList(growable: false),
          ),
        );
      },
    );
  }
}