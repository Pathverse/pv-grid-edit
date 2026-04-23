import '../utils/list_utils.dart';
import '../utils/grid_snap.dart';
import 'grid_geometry.dart';
import 'grid_rectangle_shape.dart';
import 'grid_shape.dart';
import 'grid_shape_behavior.dart';

/// Holds the full set of shapes that make up an editable grid scene.
final class GridLayout {
  /// Creates an immutable layout from a collection of shapes.
  GridLayout({required Iterable<GridShape> shapes})
      : shapes = List<GridShape>.unmodifiable(shapes);

  /// Recreates a layout from serialized data.
  factory GridLayout.fromJson(Map<String, dynamic> json) {
    final encodedShapes = (json['shapes'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<dynamic, dynamic>>();

    return GridLayout(
      shapes: encodedShapes.map((entry) {
        final shapeJson = Map<String, dynamic>.from(entry);
        switch (shapeJson['shapeType']) {
          case 'rectangle':
            return GridRectangleShape.fromJson(shapeJson);
        }

        throw FormatException('Unsupported shape type: ${shapeJson['shapeType']}');
      }),
    );
  }

  /// Ordered shapes that belong to the layout.
  final List<GridShape> shapes;

  /// Returns one shape by identifier when it exists in the layout.
  GridShape? shapeById(String id) {
    for (final shape in shapes) {
      if (shape.id == id) {
        return shape;
      }
    }

    return null;
  }

  /// Returns a new layout with one shape moved to a different snapped point.
  GridLayout moveShape(String id, GridPoint position) {
    final nextLayout = GridLayout(
      shapes: shapes.map((shape) {
        if (shape.id != id) {
          return shape;
        }

        return shape.moveTo(position);
      }),
    );

    return nextLayout._hasIllegalOverlap() ? this : nextLayout;
  }

  /// Returns a new layout with one shape resized to a different snapped size.
  GridLayout resizeShape(String id, GridSize size) {
    final nextLayout = GridLayout(
      shapes: shapes.map((shape) {
        if (shape.id != id) {
          return shape;
        }

        return shape.resizeTo(size);
      }),
    );

    return nextLayout._hasIllegalOverlap() ? this : nextLayout;
  }

  /// Returns a new layout where one free-flowing shape moves above the others.
  GridLayout bringToFront(String id) {
    final target = shapeById(id);
    if (target is! GridRectangleShape ||
        target.behavior != GridShapeBehavior.freeFlowing) {
      return this;
    }

    final highestZIndex = shapes.fold<int>(
      0,
      (currentMax, shape) => shape.zIndex > currentMax ? shape.zIndex : currentMax,
    );

    return GridLayout(
      shapes: shapes.map((shape) {
        if (shape.id != id) {
          return shape;
        }

        return target.copyWith(zIndex: highestZIndex + 1);
      }),
    );
  }

  /// Serializes this layout for persistence.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'shapes': shapes.map((shape) => shape.toJson()).toList(growable: false),
      };

  /// Returns a layout normalized so every rectangle remains inside the visible board.
  GridLayout clampToBoard({
    required GridSnapSpec snapSpec,
    required GridCanvasOffset boardSize,
  }) {
    return GridLayout(
      shapes: shapes.map((shape) {
        if (shape is! GridRectangleShape) {
          return shape;
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

        return shape.copyWith(position: clampedPosition, size: clampedSize);
      }),
    );
  }

  /// Returns whether this layout contains an overlap that should be rejected.
  bool _hasIllegalOverlap() {
    for (var leftIndex = 0; leftIndex < shapes.length; leftIndex += 1) {
      final left = shapes[leftIndex];
      if (left is! GridRectangleShape) {
        continue;
      }

      for (var rightIndex = leftIndex + 1; rightIndex < shapes.length; rightIndex += 1) {
        final right = shapes[rightIndex];
        if (right is! GridRectangleShape) {
          continue;
        }

        if (_rectanglesOverlap(left, right) && (!left.canOverlap || !right.canOverlap)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Returns whether two rectangle shapes intersect on the snapped grid.
  bool _rectanglesOverlap(GridRectangleShape left, GridRectangleShape right) {
    final leftRight = left.position.column + left.size.columns;
    final rightRight = right.position.column + right.size.columns;
    final leftBottom = left.position.row + left.size.rows;
    final rightBottom = right.position.row + right.size.rows;

    return left.position.column < rightRight &&
        leftRight > right.position.column &&
        left.position.row < rightBottom &&
        leftBottom > right.position.row;
  }

  @override
  bool operator ==(Object other) {
    return other is GridLayout && listEqualsByItem(other.shapes, shapes);
  }

  @override
  int get hashCode => Object.hashAll(shapes);
}