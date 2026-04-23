import '../models/grid_geometry.dart';

/// Encodes grid geometry and constraint primitives for persistence.
Map<String, dynamic> encodeGridPoint(GridPoint point) => <String, dynamic>{
      'column': point.column,
      'row': point.row,
    };

/// Decodes a snapped grid point from persisted JSON.
GridPoint decodeGridPoint(Map<String, dynamic> json) {
  return GridPoint(
    column: json['column'] as int,
    row: json['row'] as int,
  );
}

/// Encodes a snapped grid size for persistence.
Map<String, dynamic> encodeGridSize(GridSize size) => <String, dynamic>{
      'columns': size.columns,
      'rows': size.rows,
    };

/// Decodes a snapped grid size from persisted JSON.
GridSize decodeGridSize(Map<String, dynamic> json) {
  return GridSize(
    columns: json['columns'] as int,
    rows: json['rows'] as int,
  );
}

/// Encodes rectangle size constraints for persistence.
Map<String, dynamic> encodeGridSizeConstraints(GridSizeConstraints constraints) =>
    <String, dynamic>{
      'minColumns': constraints.minColumns,
      'maxColumns': constraints.maxColumns,
      'minRows': constraints.minRows,
      'maxRows': constraints.maxRows,
    };

/// Decodes optional rectangle size constraints from persisted JSON.
GridSizeConstraints decodeGridSizeConstraints(Map<String, dynamic> json) {
  return GridSizeConstraints(
    minColumns: json['minColumns'] as int?,
    maxColumns: json['maxColumns'] as int?,
    minRows: json['minRows'] as int?,
    maxRows: json['maxRows'] as int?,
  );
}