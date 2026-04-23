import 'package:bloc/bloc.dart';

import '../models/grid_geometry.dart';
import '../models/grid_layout.dart';
import '../models/grid_shape.dart';
import '../utils/grid_snap.dart';

/// Defines the event contract for the grid editor bloc.
sealed class GridEditorEvent {
  /// Creates a new editor event.
  const GridEditorEvent();
}

/// Replaces the current editor layout with a loaded snapshot.
final class GridLayoutLoaded extends GridEditorEvent {
  /// Creates an event that loads a full layout snapshot.
  const GridLayoutLoaded(this.layout);

  /// The layout snapshot to expose as the latest editor state.
  final GridLayout layout;
}

/// Requests that one shape move to a new snapped grid point.
final class GridShapeMoved extends GridEditorEvent {
  /// Creates an event that moves one shape.
  const GridShapeMoved({required this.shapeId, required this.position});

  /// The identifier of the shape that should move.
  final String shapeId;

  /// The target snapped grid point for the shape.
  final GridPoint position;
}

/// Requests that one shape resize to a new snapped grid size.
final class GridShapeResized extends GridEditorEvent {
  /// Creates an event that resizes one shape.
  const GridShapeResized({required this.shapeId, required this.size});

  /// The identifier of the shape that should resize.
  final String shapeId;

  /// The requested snapped grid size for the shape.
  final GridSize size;
}

/// Requests that one free-flowing shape move to the top of the z stack.
final class GridShapeBroughtToFront extends GridEditorEvent {
  /// Creates an event that updates the z-order of one shape.
  const GridShapeBroughtToFront({required this.shapeId});

  /// The identifier of the shape that should move to the front.
  final String shapeId;
}

/// Requests that one shape becomes the current editor selection.
final class GridShapeSelected extends GridEditorEvent {
  /// Creates an event that selects one shape by identifier.
  const GridShapeSelected({required this.shapeId});

  /// The identifier of the shape that should become selected.
  final String shapeId;
}

/// Requests that one shape move using canvas coordinates that will be snapped.
final class GridShapeDragged extends GridEditorEvent {
  /// Creates an event that moves one shape from a raw canvas drag position.
  const GridShapeDragged({
    required this.shapeId,
    required this.canvasOffset,
    required this.snapSpec,
  });

  /// The identifier of the shape that should move.
  final String shapeId;

  /// The raw canvas position to snap back to the grid.
  final GridCanvasOffset canvasOffset;

  /// The snap configuration used to convert pixels into grid points.
  final GridSnapSpec snapSpec;
}

/// Represents the immutable editor state exposed by the bloc.
final class GridEditorState {
  /// Creates an editor state backed by one layout snapshot.
  const GridEditorState({required this.layout, this.selectedShapeId});

  /// The current layout snapshot for the editor.
  final GridLayout layout;

  /// The identifier of the currently selected shape, when one is selected.
  final String? selectedShapeId;

  /// Returns a copy of the state with selected fields replaced.
  GridEditorState copyWith({GridLayout? layout, String? selectedShapeId}) {
    return GridEditorState(
      layout: layout ?? this.layout,
      selectedShapeId: selectedShapeId ?? this.selectedShapeId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GridEditorState &&
        other.layout == layout &&
        other.selectedShapeId == selectedShapeId;
  }

  @override
  int get hashCode => Object.hash(layout, selectedShapeId);
}

/// Coordinates grid layout changes through an event-driven bloc API.
final class GridEditorBloc extends Bloc<GridEditorEvent, GridEditorState> {
  /// Creates a bloc with an optional initial layout snapshot.
  GridEditorBloc({GridLayout? initialLayout})
      : super(
          GridEditorState(
            layout: initialLayout ?? GridLayout(shapes: const <GridShape>[]),
          ),
        ) {
    on<GridLayoutLoaded>(_onLayoutLoaded);
    on<GridShapeMoved>(_onShapeMoved);
    on<GridShapeResized>(_onShapeResized);
    on<GridShapeBroughtToFront>(_onShapeBroughtToFront);
    on<GridShapeSelected>(_onShapeSelected);
    on<GridShapeDragged>(_onShapeDragged);
  }

  /// Handles replacing the editor state with a loaded layout snapshot.
  void _onLayoutLoaded(
    GridLayoutLoaded event,
    Emitter<GridEditorState> emit,
  ) {
    emit(state.copyWith(layout: event.layout));
  }

  /// Handles moving a shape inside the current layout snapshot.
  void _onShapeMoved(
    GridShapeMoved event,
    Emitter<GridEditorState> emit,
  ) {
    emit(
      state.copyWith(
        layout: state.layout.moveShape(event.shapeId, event.position),
        selectedShapeId: event.shapeId,
      ),
    );
  }

  /// Handles resizing a shape inside the current layout snapshot.
  void _onShapeResized(
    GridShapeResized event,
    Emitter<GridEditorState> emit,
  ) {
    emit(
      state.copyWith(
        layout: state.layout.resizeShape(event.shapeId, event.size),
        selectedShapeId: event.shapeId,
      ),
    );
  }

  /// Handles moving one free-flowing shape to the front of the z stack.
  void _onShapeBroughtToFront(
    GridShapeBroughtToFront event,
    Emitter<GridEditorState> emit,
  ) {
    emit(
      state.copyWith(
        layout: state.layout.bringToFront(event.shapeId),
        selectedShapeId: event.shapeId,
      ),
    );
  }

  /// Handles selecting one shape in the current editor state.
  void _onShapeSelected(
    GridShapeSelected event,
    Emitter<GridEditorState> emit,
  ) {
    emit(state.copyWith(selectedShapeId: event.shapeId));
  }

  /// Handles moving a shape by snapping a raw canvas drag position.
  void _onShapeDragged(
    GridShapeDragged event,
    Emitter<GridEditorState> emit,
  ) {
    emit(
      state.copyWith(
        layout: state.layout.moveShape(
          event.shapeId,
          event.snapSpec.snap(event.canvasOffset),
        ),
        selectedShapeId: event.shapeId,
      ),
    );
  }
}