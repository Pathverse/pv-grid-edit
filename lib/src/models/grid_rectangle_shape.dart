import 'grid_geometry.dart';
import 'grid_shape.dart';
import 'grid_shape_behavior.dart';

/// Represents the rectangle implementation used by the current editor MVP.
final class GridRectangleShape extends GridShape {
  /// Creates a frozen rectangle that cannot be moved or resized.
  factory GridRectangleShape.fixed({
    required String id,
    required GridPoint position,
    required GridSize size,
    int zIndex = 0,
  }) {
    return GridRectangleShape._(
      id: id,
      position: position,
      size: size,
      behavior: GridShapeBehavior.frozen,
      zIndex: zIndex,
      constraints: null,
    );
  }

  /// Creates a rectangle that can move freely while keeping a fixed snapped size.
  factory GridRectangleShape.fixedSizeFreeFlowing({
    required String id,
    required GridPoint position,
    required GridSize size,
    int zIndex = 0,
  }) {
    return GridRectangleShape._(
      id: id,
      position: position,
      size: size,
      behavior: GridShapeBehavior.fixedSizeFreeFlowing,
      zIndex: zIndex,
      constraints: null,
    );
  }

  /// Creates a rectangle that can move and resize within optional bounds.
  factory GridRectangleShape.constrained({
    required String id,
    required GridPoint position,
    required GridSize size,
    GridSizeConstraints? constraints,
    int zIndex = 0,
  }) {
    return GridRectangleShape._(
      id: id,
      position: position,
      size: size,
      behavior: GridShapeBehavior.constrained,
      zIndex: zIndex,
      constraints: constraints,
    );
  }

  /// Creates a rectangle that can overlap and participate in z-order edits.
  factory GridRectangleShape.freeFlowing({
    required String id,
    required GridPoint position,
    required GridSize size,
    int zIndex = 0,
  }) {
    return GridRectangleShape._(
      id: id,
      position: position,
      size: size,
      behavior: GridShapeBehavior.freeFlowing,
      zIndex: zIndex,
      constraints: null,
    );
  }

  /// Recreates a rectangle shape from serialized data.
  factory GridRectangleShape.fromJson(Map<String, dynamic> json) {
    return GridRectangleShape._(
      id: json['id'] as String,
      position: GridPoint.fromJson(
        Map<String, dynamic>.from(json['position'] as Map),
      ),
      size: GridSize.fromJson(
        Map<String, dynamic>.from(json['size'] as Map),
      ),
      behavior: GridShapeBehavior.values.byName(json['behavior'] as String),
      zIndex: json['zIndex'] as int? ?? 0,
      constraints: json['constraints'] == null
          ? null
          : GridSizeConstraints.fromJson(
              Map<String, dynamic>.from(json['constraints'] as Map),
            ),
    );
  }

  /// Creates a rectangle with explicit behavior and optional bounds.
  const GridRectangleShape._({
    required super.id,
    required super.position,
    required super.size,
    required super.behavior,
    required super.zIndex,
    this.constraints,
  });

  /// Optional size bounds applied during resize operations.
  final GridSizeConstraints? constraints;

  @override
  String get shapeType => 'rectangle';

  /// Returns a copy of this rectangle with selected fields replaced.
  GridRectangleShape copyWith({
    GridPoint? position,
    GridSize? size,
    int? zIndex,
    GridSizeConstraints? constraints,
  }) {
    return GridRectangleShape._(
      id: id,
      position: position ?? this.position,
      size: size ?? this.size,
      behavior: behavior,
      zIndex: zIndex ?? this.zIndex,
      constraints: constraints ?? this.constraints,
    );
  }

  @override
  GridRectangleShape moveTo(GridPoint position) {
    if (!canMove) {
      return this;
    }

    return copyWith(position: position);
  }

  @override
  GridRectangleShape resizeTo(GridSize size) {
    if (!canResize) {
      return this;
    }

    final nextSize = constraints?.clamp(size) ?? size;
    return copyWith(size: nextSize);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'shapeType': shapeType,
        'position': position.toJson(),
        'size': size.toJson(),
        'behavior': behavior.name,
        'zIndex': zIndex,
        'constraints': constraints?.toJson(),
      };

  @override
  bool operator ==(Object other) {
    return other is GridRectangleShape &&
        other.id == id &&
        other.position == position &&
        other.size == size &&
        other.behavior == behavior &&
        other.zIndex == zIndex &&
        other.constraints == constraints;
  }

  @override
  int get hashCode => Object.hash(id, position, size, behavior, zIndex, constraints);
}