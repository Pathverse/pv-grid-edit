import 'package:pv_grid_edit/pv_grid_edit.dart';

/// Creates a demo layout containing only fixed rectangles.
GridLayout buildFixedShapesLayout() {
  return GridLayout(
    shapes: <GridShape>[
      GridRectangleShape.fixed(
        id: 'header',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 6, rows: 1),
      ),
      GridRectangleShape.fixed(
        id: 'panel',
        position: const GridPoint(column: 0, row: 2),
        size: const GridSize(columns: 3, rows: 2),
      ),
      GridRectangleShape.fixedSizeFreeFlowing(
        id: 'runner',
        position: const GridPoint(column: 4, row: 1),
        size: const GridSize(columns: 2, rows: 1),
      ),
      GridRectangleShape.fixed(
        id: 'status',
        position: const GridPoint(column: 4, row: 2),
        size: const GridSize(columns: 2, rows: 2),
      ),
    ],
  );
}

/// Creates a demo layout for shapes that resize within explicit limits.
GridLayout buildConstrainedShapesLayout() {
  return GridLayout(
    shapes: <GridShape>[
      GridRectangleShape.fixed(
        id: 'frame',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 6, rows: 1),
      ),
      GridRectangleShape.constrained(
        id: 'viewport',
        position: const GridPoint(column: 1, row: 1),
        size: const GridSize(columns: 3, rows: 2),
        constraints: const GridSizeConstraints(
          minColumns: 2,
          maxColumns: 5,
          minRows: 1,
          maxRows: 4,
        ),
      ),
      GridRectangleShape.constrained(
        id: 'legend',
        position: const GridPoint(column: 0, row: 4),
        size: const GridSize(columns: 2, rows: 1),
      ),
      GridRectangleShape.fixedSizeFreeFlowing(
        id: 'cursor',
        position: const GridPoint(column: 4, row: 4),
        size: const GridSize(columns: 2, rows: 1),
      ),
    ],
  );
}

/// Creates a demo layout for overlapping free-flowing rectangles.
GridLayout buildFreeFlowLayout() {
  return GridLayout(
    shapes: <GridShape>[
      GridRectangleShape.fixed(
        id: 'frame',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 6, rows: 1),
      ),
      GridRectangleShape.freeFlowing(
        id: 'teal',
        position: const GridPoint(column: 1, row: 1),
        size: const GridSize(columns: 3, rows: 3),
        zIndex: 1,
      ),
      GridRectangleShape.freeFlowing(
        id: 'amber',
        position: const GridPoint(column: 2, row: 2),
        size: const GridSize(columns: 3, rows: 2),
        zIndex: 2,
      ),
      GridRectangleShape.fixedSizeFreeFlowing(
        id: 'runner',
        position: const GridPoint(column: 0, row: 4),
        size: const GridSize(columns: 2, rows: 1),
      ),
      GridRectangleShape.constrained(
        id: 'base',
        position: const GridPoint(column: 0, row: 5),
        size: const GridSize(columns: 5, rows: 1),
      ),
    ],
  );
}