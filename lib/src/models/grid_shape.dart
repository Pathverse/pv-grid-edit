import 'grid_geometry.dart';
import 'grid_shape_behavior.dart';

/// Describes the common contract for any shape that can snap to the grid.
abstract class GridShape {
  /// Creates a shape with a grid position, size, and behavior.
  const GridShape({
    required this.id,
    required this.position,
    required this.size,
    required this.behavior,
    required this.zIndex,
  });

  /// Stable identifier used to target a shape inside the layout.
  final String id;

  /// Snapped origin of the shape on the grid.
  final GridPoint position;

  /// Snapped size of the shape on the grid.
  final GridSize size;

  /// Editing rule used by the shape.
  final GridShapeBehavior behavior;

  /// Paint order used when shapes visually overlap.
  final int zIndex;

  /// Returns whether this shape can move across snapped grid points.
  bool get canMove => behavior.canMove;

  /// Returns whether this shape can resize across snapped grid cells.
  bool get canResize => behavior.canResize;

  /// Returns whether this shape may legally overlap another shape.
  bool get canOverlap => behavior.canOverlap;

  /// Returns the serialized shape kind for round-trip persistence.
  String get shapeType;

  /// Returns a new shape moved to a snapped grid point.
  GridShape moveTo(GridPoint position);

  /// Returns a new shape resized to a snapped grid size.
  GridShape resizeTo(GridSize size);

  /// Serializes this shape for persistence.
  Map<String, dynamic> toJson();
}