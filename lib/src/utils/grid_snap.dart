import '../models/grid_geometry.dart';

/// Describes a point in the editor canvas before it is snapped to the grid.
final class GridCanvasOffset {
  /// Creates a canvas offset in logical pixels.
  const GridCanvasOffset({required this.dx, required this.dy});

  /// Horizontal canvas offset in logical pixels.
  final double dx;

  /// Vertical canvas offset in logical pixels.
  final double dy;
}

/// Defines how pixel coordinates snap back to grid cell points.
final class GridSnapSpec {
  /// Creates a snap specification for the editor canvas.
  const GridSnapSpec({required this.cellWidth, required this.cellHeight});

  /// Width of one grid cell in logical pixels.
  final double cellWidth;

  /// Height of one grid cell in logical pixels.
  final double cellHeight;

  /// Snaps a canvas offset to the nearest grid point.
  GridPoint snap(GridCanvasOffset offset) {
    final column = (offset.dx / cellWidth).round();
    final row = (offset.dy / cellHeight).round();

    return GridPoint(
      column: column < 0 ? 0 : column,
      row: row < 0 ? 0 : row,
    );
  }

  /// Returns the largest snapped board dimensions currently visible in the canvas.
  GridSize boardCapacity(GridCanvasOffset boardSize) {
    final columns = (boardSize.dx / cellWidth).floor();
    final rows = (boardSize.dy / cellHeight).floor();

    return GridSize(
      columns: columns < 1 ? 1 : columns,
      rows: rows < 1 ? 1 : rows,
    );
  }

  /// Clamps a snapped grid point so the full shape remains inside the visible board.
  GridPoint clampPointToBoard({
    required GridPoint point,
    required GridSize shapeSize,
    required GridCanvasOffset boardSize,
  }) {
    final capacity = boardCapacity(boardSize);
    final maxColumn = capacity.columns - shapeSize.columns;
    final maxRow = capacity.rows - shapeSize.rows;

    return GridPoint(
      column: point.column.clamp(0, maxColumn < 0 ? 0 : maxColumn),
      row: point.row.clamp(0, maxRow < 0 ? 0 : maxRow),
    );
  }

  /// Snaps a raw pixel size back to the nearest grid size with a minimum of one cell.
  GridSize snapSize(GridCanvasOffset size) {
    final columns = (size.dx / cellWidth).round();
    final rows = (size.dy / cellHeight).round();

    return GridSize(
      columns: columns < 1 ? 1 : columns,
      rows: rows < 1 ? 1 : rows,
    );
  }

  /// Clamps a snapped grid size so it remains inside the visible board from the current origin.
  GridSize clampSizeToBoard({
    required GridSize size,
    required GridPoint position,
    required GridCanvasOffset boardSize,
  }) {
    final capacity = boardCapacity(boardSize);
    final maxColumns = capacity.columns - position.column;
    final maxRows = capacity.rows - position.row;

    return GridSize(
      columns: size.columns.clamp(1, maxColumns < 1 ? 1 : maxColumns),
      rows: size.rows.clamp(1, maxRows < 1 ? 1 : maxRows),
    );
  }

  /// Converts a snapped grid point back into a raw canvas offset.
  GridCanvasOffset offsetForPoint(GridPoint point) {
    return GridCanvasOffset(
      dx: point.column * cellWidth,
      dy: point.row * cellHeight,
    );
  }

  /// Converts a snapped grid size back into a raw canvas size.
  GridCanvasOffset offsetForSize(GridSize size) {
    return GridCanvasOffset(
      dx: size.columns * cellWidth,
      dy: size.rows * cellHeight,
    );
  }
}