import '../serialization/grid_json_codec.dart';

/// Represents a snapped point on the editor grid.
final class GridPoint {
  /// Creates a point expressed in grid columns and rows.
  const GridPoint({required this.column, required this.row});

  /// The snapped grid column.
  final int column;

  /// The snapped grid row.
  final int row;

  /// Serializes this point for persistence.
  Map<String, dynamic> toJson() => encodeGridPoint(this);

  /// Recreates a snapped point from serialized data.
  factory GridPoint.fromJson(Map<String, dynamic> json) {
    return decodeGridPoint(json);
  }

  @override
  bool operator ==(Object other) {
    return other is GridPoint &&
        other.column == column &&
        other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);
}

/// Represents the width and height of a shape in grid cells.
final class GridSize {
  /// Creates a size expressed in grid columns and rows.
  const GridSize({required this.columns, required this.rows});

  /// The width of the shape in grid columns.
  final int columns;

  /// The height of the shape in grid rows.
  final int rows;

  /// Serializes this size for persistence.
  Map<String, dynamic> toJson() => encodeGridSize(this);

  /// Recreates a grid size from serialized data.
  factory GridSize.fromJson(Map<String, dynamic> json) {
    return decodeGridSize(json);
  }

  @override
  bool operator ==(Object other) {
    return other is GridSize &&
        other.columns == columns &&
        other.rows == rows;
  }

  @override
  int get hashCode => Object.hash(columns, rows);
}

/// Defines optional minimum and maximum size bounds for editable shapes.
final class GridSizeConstraints {
  /// Creates a set of optional size bounds measured in grid cells.
  const GridSizeConstraints({
    this.minColumns,
    this.maxColumns,
    this.minRows,
    this.maxRows,
  });

  /// The minimum allowed width in columns.
  final int? minColumns;

  /// The maximum allowed width in columns.
  final int? maxColumns;

  /// The minimum allowed height in rows.
  final int? minRows;

  /// The maximum allowed height in rows.
  final int? maxRows;

  /// Clamps a requested size to the configured limits.
  GridSize clamp(GridSize size) {
    final columns = switch ((minColumns, maxColumns)) {
      (final int min, final int max) => size.columns.clamp(min, max),
      (final int min, null) => size.columns < min ? min : size.columns,
      (null, final int max) => size.columns > max ? max : size.columns,
      (null, null) => size.columns,
    };
    final rows = switch ((minRows, maxRows)) {
      (final int min, final int max) => size.rows.clamp(min, max),
      (final int min, null) => size.rows < min ? min : size.rows,
      (null, final int max) => size.rows > max ? max : size.rows,
      (null, null) => size.rows,
    };

    return GridSize(columns: columns, rows: rows);
  }

  /// Serializes these constraints for persistence.
  Map<String, dynamic> toJson() => encodeGridSizeConstraints(this);

  /// Recreates size constraints from serialized data.
  factory GridSizeConstraints.fromJson(Map<String, dynamic> json) {
    return decodeGridSizeConstraints(json);
  }

  @override
  bool operator ==(Object other) {
    return other is GridSizeConstraints &&
        other.minColumns == minColumns &&
        other.maxColumns == maxColumns &&
        other.minRows == minRows &&
        other.maxRows == maxRows;
  }

  @override
  int get hashCode => Object.hash(minColumns, maxColumns, minRows, maxRows);
}