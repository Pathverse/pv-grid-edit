import 'models/grid_geometry.dart';
import 'models/grid_layout.dart';
import 'models/grid_rectangle_shape.dart';
import 'models/grid_shape.dart';
import 'models/grid_shape_behavior.dart';

/// Converts simple dictionary payloads into typed editor layouts and back again.
final class GridEditorMapHelper {
  /// Builds a typed layout from a dictionary keyed by shape identifier.
  static GridLayout layoutFromDictionary(Map<String, dynamic> dictionary) {
    return GridLayout(
      shapes: dictionary.entries.map((entry) {
        final shapeData = Map<String, dynamic>.from(entry.value as Map);
        return _shapeFromDictionaryEntry(entry.key, shapeData);
      }),
    );
  }

  /// Exports a typed layout into a dictionary keyed by shape identifier.
  static Map<String, dynamic> dictionaryFromLayout(GridLayout layout) {
    return <String, dynamic>{
      for (final shape in layout.shapes) shape.id: _dictionaryEntryFromShape(shape),
    };
  }

  /// Builds one typed shape from a dictionary entry.
  static GridShape _shapeFromDictionaryEntry(
    String id,
    Map<String, dynamic> shapeData,
  ) {
    final type = (shapeData['type'] ?? 'rectangle').toString();
    if (type != 'rectangle') {
      throw FormatException('Unsupported helper shape type: $type');
    }

    final behavior = _parseBehavior(shapeData['behavior']?.toString());
    final position = GridPoint(
      column: _readInt(shapeData, <String>['x', 'column', 'position_x'], 0),
      row: _readInt(shapeData, <String>['y', 'row', 'position_y'], 0),
    );
    final size = GridSize(
      columns: _readInt(shapeData, <String>['size_x', 'columns', 'width'], 1),
      rows: _readInt(shapeData, <String>['size_y', 'rows', 'height'], 1),
    );
    final zIndex = _readInt(shapeData, <String>['z_index', 'zIndex'], 0);
    final constraints = _constraintsFromDictionary(shapeData['constraints']);

    return switch (behavior) {
      GridShapeBehavior.frozen => GridRectangleShape.fixed(
          id: id,
          position: position,
          size: size,
          zIndex: zIndex,
        ),
      GridShapeBehavior.fixedSizeFreeFlowing =>
        GridRectangleShape.fixedSizeFreeFlowing(
          id: id,
          position: position,
          size: size,
          zIndex: zIndex,
        ),
      GridShapeBehavior.constrained => GridRectangleShape.constrained(
          id: id,
          position: position,
          size: size,
          zIndex: zIndex,
          constraints: constraints,
        ),
      GridShapeBehavior.freeFlowing => GridRectangleShape.freeFlowing(
          id: id,
          position: position,
          size: size,
          zIndex: zIndex,
        ),
    };
  }

  /// Exports one typed shape into the helper dictionary schema.
  static Map<String, dynamic> _dictionaryEntryFromShape(GridShape shape) {
    if (shape is! GridRectangleShape) {
      throw FormatException('Unsupported helper export shape: ${shape.shapeType}');
    }

    return <String, dynamic>{
      'type': shape.shapeType,
      'behavior': _behaviorName(shape.behavior),
      'x': shape.position.column,
      'y': shape.position.row,
      'size_x': shape.size.columns,
      'size_y': shape.size.rows,
      'z_index': shape.zIndex,
      if (shape.constraints != null)
        'constraints': <String, dynamic>{
          'min_size_x': shape.constraints?.minColumns,
          'max_size_x': shape.constraints?.maxColumns,
          'min_size_y': shape.constraints?.minRows,
          'max_size_y': shape.constraints?.maxRows,
        },
    };
  }

  /// Parses optional helper constraints into typed grid constraints.
  static GridSizeConstraints? _constraintsFromDictionary(dynamic rawConstraints) {
    if (rawConstraints == null) {
      return null;
    }

    final constraints = Map<String, dynamic>.from(rawConstraints as Map);
    return GridSizeConstraints(
      minColumns: _readNullableInt(constraints, <String>['min_size_x', 'minColumns']),
      maxColumns: _readNullableInt(constraints, <String>['max_size_x', 'maxColumns']),
      minRows: _readNullableInt(constraints, <String>['min_size_y', 'minRows']),
      maxRows: _readNullableInt(constraints, <String>['max_size_y', 'maxRows']),
    );
  }

  /// Parses helper behavior names into typed runtime behavior values.
  static GridShapeBehavior _parseBehavior(String? rawBehavior) {
    return switch (rawBehavior) {
      null => GridShapeBehavior.constrained,
      'frozen' => GridShapeBehavior.frozen,
      'fixed_size_free_flowing' => GridShapeBehavior.fixedSizeFreeFlowing,
      'fixedSizeFreeFlowing' => GridShapeBehavior.fixedSizeFreeFlowing,
      'constrained' => GridShapeBehavior.constrained,
      'free_flowing' => GridShapeBehavior.freeFlowing,
      'freeFlowing' => GridShapeBehavior.freeFlowing,
      _ => throw FormatException('Unsupported helper behavior: $rawBehavior'),
    };
  }

  /// Normalizes typed behavior values back into the helper schema.
  static String _behaviorName(GridShapeBehavior behavior) {
    return switch (behavior) {
      GridShapeBehavior.frozen => 'frozen',
      GridShapeBehavior.fixedSizeFreeFlowing => 'fixed_size_free_flowing',
      GridShapeBehavior.constrained => 'constrained',
      GridShapeBehavior.freeFlowing => 'free_flowing',
    };
  }

  /// Reads one required integer-like field with fallback aliases.
  static int _readInt(
    Map<String, dynamic> data,
    List<String> keys,
    int fallback,
  ) {
    return _readNullableInt(data, keys) ?? fallback;
  }

  /// Reads one optional integer-like field with fallback aliases.
  static int? _readNullableInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.parse(value.toString());
    }

    return null;
  }
}