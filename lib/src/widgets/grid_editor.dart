import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../bloc/grid_editor_bloc.dart';
import '../models/grid_geometry.dart';
import '../models/grid_shape.dart';
import '../utils/grid_snap.dart';
import 'grid_canvas.dart';

/// Hosts the editor canvas and binds widget events to the editor bloc.
final class GridEditor extends StatelessWidget {
  /// Creates a grid editor backed by the provided bloc.
  const GridEditor({
    super.key,
    required this.bloc,
    required this.snapSpec,
  });

  /// Bloc that owns the editable grid state.
  final GridEditorBloc bloc;

  /// Snap metrics used to render and interpret grid positions.
  final GridSnapSpec snapSpec;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = GridCanvasOffset(
          dx: constraints.maxWidth,
          dy: constraints.maxHeight,
        );

        return BlocBuilder<GridEditorBloc, GridEditorState>(
          bloc: bloc,
          builder: (context, state) {
            final normalizedLayout = state.layout.clampToBoard(
              snapSpec: snapSpec,
              boardSize: boardSize,
            );
            final effectiveState = state.copyWith(layout: normalizedLayout);

            if (normalizedLayout != state.layout) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (bloc.state.layout != normalizedLayout) {
                  bloc.add(GridLayoutLoaded(normalizedLayout));
                }
              });
            }

            return Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                return _handleKeyEvent(
                  event: event,
                  state: effectiveState,
                  boardSize: boardSize,
                );
              },
              child: GridCanvas(
                state: effectiveState,
                snapSpec: snapSpec,
                onShapeTap: (shapeId) {
                  bloc.add(GridShapeSelected(shapeId: shapeId));
                },
                onShapeDrag: (shapeId, offset) {
                  bloc.add(
                    GridShapeDragged(
                      shapeId: shapeId,
                      canvasOffset: offset,
                      snapSpec: snapSpec,
                    ),
                  );
                },
                onShapeResize: (shapeId, size) {
                  bloc.add(
                    GridShapeResized(
                      shapeId: shapeId,
                      size: snapSpec.snapSize(size),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Handles keyboard nudging for the currently selected shape.
  KeyEventResult _handleKeyEvent({
    required KeyEvent event,
    required GridEditorState state,
    required GridCanvasOffset boardSize,
  }) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final selectedShapeId = state.selectedShapeId;
    if (selectedShapeId == null) {
      return KeyEventResult.ignored;
    }

    final selectedShape = state.layout.shapeById(selectedShapeId);
    if (selectedShape == null || !selectedShape.canMove) {
      return KeyEventResult.ignored;
    }

    final delta = _keyDelta(event.logicalKey);
    if (delta == null) {
      return KeyEventResult.ignored;
    }

    final targetPoint = GridPoint(
      column: selectedShape.position.column + delta.column,
      row: selectedShape.position.row + delta.row,
    );
    final clampedPoint = snapSpec.clampPointToBoard(
      point: targetPoint,
      shapeSize: selectedShape.size,
      boardSize: boardSize,
    );

    bloc.add(
      GridShapeMoved(
        shapeId: selectedShapeId,
        position: clampedPoint,
      ),
    );
    return KeyEventResult.handled;
  }

  /// Returns the one-cell nudge represented by an arrow key.
  GridPoint? _keyDelta(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft) {
      return const GridPoint(column: -1, row: 0);
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      return const GridPoint(column: 1, row: 0);
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      return const GridPoint(column: 0, row: -1);
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      return const GridPoint(column: 0, row: 1);
    }

    return null;
  }
}