import 'package:flutter_test/flutter_test.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

void main() {
  group('GridEditorMapHelper', () {
    test('builds a layout from a dictionary keyed by shape id', () {
      final layout = GridEditorMapHelper.layoutFromDictionary(
        <String, dynamic>{
          'header': <String, dynamic>{
            'type': 'rectangle',
            'behavior': 'frozen',
            'x': 1,
            'y': 2,
            'size_x': 4,
            'size_y': 1,
          },
          'cursor': <String, dynamic>{
            'type': 'rectangle',
            'behavior': 'fixed_size_free_flowing',
            'column': 3,
            'row': 4,
            'columns': 2,
            'rows': 2,
            'z_index': 7,
          },
        },
      );

      final header = layout.shapeById('header') as GridRectangleShape?;
      final cursor = layout.shapeById('cursor') as GridRectangleShape?;

      expect(header, isNotNull);
      expect(header?.position, const GridPoint(column: 1, row: 2));
      expect(header?.size, const GridSize(columns: 4, rows: 1));
      expect(header?.behavior, GridShapeBehavior.frozen);

      expect(cursor, isNotNull);
      expect(cursor?.position, const GridPoint(column: 3, row: 4));
      expect(cursor?.size, const GridSize(columns: 2, rows: 2));
      expect(cursor?.behavior, GridShapeBehavior.fixedSizeFreeFlowing);
      expect(cursor?.zIndex, 7);
    });

    test('exports a layout back to a dictionary keyed by shape id', () {
      final layout = GridLayout(
        shapes: <GridShape>[
          GridRectangleShape.constrained(
            id: 'panel',
            position: const GridPoint(column: 2, row: 1),
            size: const GridSize(columns: 3, rows: 2),
            constraints: const GridSizeConstraints(
              minColumns: 2,
              maxColumns: 5,
              minRows: 1,
              maxRows: 3,
            ),
          ),
        ],
      );

      final dictionary = GridEditorMapHelper.dictionaryFromLayout(layout);

      expect(
        dictionary,
        <String, dynamic>{
          'panel': <String, dynamic>{
            'type': 'rectangle',
            'behavior': 'constrained',
            'x': 2,
            'y': 1,
            'size_x': 3,
            'size_y': 2,
            'z_index': 0,
            'constraints': <String, dynamic>{
              'min_size_x': 2,
              'max_size_x': 5,
              'min_size_y': 1,
              'max_size_y': 3,
            },
          },
        },
      );
    });
  });

  group('GridRectangleShape', () {
    test('frozen rectangles ignore move and resize requests', () {
      final shape = GridRectangleShape.fixed(
        id: 'fixed',
        position: const GridPoint(column: 1, row: 2),
        size: const GridSize(columns: 2, rows: 3),
      );

      final moved = shape.moveTo(const GridPoint(column: 4, row: 5));
      final resized = shape.resizeTo(const GridSize(columns: 5, rows: 6));

      expect(moved.position, shape.position);
      expect(resized.size, shape.size);
      expect(shape.behavior, GridShapeBehavior.frozen);
    });

    test('fixed-size free-flowing rectangles can move but not resize', () {
      final shape = GridRectangleShape.fixedSizeFreeFlowing(
        id: 'floating-fixed-size',
        position: const GridPoint(column: 1, row: 1),
        size: const GridSize(columns: 2, rows: 2),
      );

      final moved = shape.moveTo(const GridPoint(column: 4, row: 5));
      final resized = shape.resizeTo(const GridSize(columns: 5, rows: 6));

      expect(moved.position, const GridPoint(column: 4, row: 5));
      expect(resized.size, shape.size);
      expect(shape.behavior, GridShapeBehavior.fixedSizeFreeFlowing);
    });

    test('constrained rectangles clamp resizing to min and max bounds', () {
      final shape = GridRectangleShape.constrained(
        id: 'constrained',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 3, rows: 3),
        constraints: const GridSizeConstraints(
          minColumns: 2,
          maxColumns: 5,
          minRows: 1,
          maxRows: 4,
        ),
      );

      final shrunk = shape.resizeTo(const GridSize(columns: 1, rows: 0));
      final expanded = shape.resizeTo(const GridSize(columns: 8, rows: 9));

      expect(shrunk.size, const GridSize(columns: 2, rows: 1));
      expect(expanded.size, const GridSize(columns: 5, rows: 4));
      expect(shape.behavior, GridShapeBehavior.constrained);
    });
  });

  group('GridLayout', () {
    test('free-flowing rectangles support overlap and z-order changes', () {
      final background = GridRectangleShape.constrained(
        id: 'background',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 4, rows: 4),
      );
      final overlay = GridRectangleShape.freeFlowing(
        id: 'overlay',
        position: const GridPoint(column: 0, row: 0),
        size: const GridSize(columns: 2, rows: 2),
        zIndex: 1,
      );
      final layout = GridLayout(shapes: [background, overlay]);

      final reordered = layout.bringToFront('overlay');

      expect(reordered.shapes, hasLength(2));
      expect(reordered.shapeById('overlay')?.zIndex, 2);
      expect(reordered.shapeById('background')?.position, overlay.position);
    });

    test('serializes and deserializes rectangle layouts', () {
      final layout = GridLayout(
        shapes: [
          GridRectangleShape.fixed(
            id: 'locked',
            position: const GridPoint(column: 2, row: 2),
            size: const GridSize(columns: 1, rows: 1),
          ),
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 3, row: 4),
            size: const GridSize(columns: 2, rows: 2),
            zIndex: 7,
          ),
        ],
      );

      final roundTrip = GridLayout.fromJson(layout.toJson());

      expect(roundTrip.shapes, hasLength(2));
      expect(roundTrip.shapeById('locked')?.behavior, GridShapeBehavior.frozen);
      expect(roundTrip.shapeById('floating')?.zIndex, 7);
      expect(roundTrip.shapeById('floating')?.position,
          const GridPoint(column: 3, row: 4));
    });

    test('rejects moves that would overlap non-overlapping shapes', () {
      final layout = GridLayout(
        shapes: [
          GridRectangleShape.constrained(
            id: 'left',
            position: const GridPoint(column: 0, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
          GridRectangleShape.constrained(
            id: 'right',
            position: const GridPoint(column: 3, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      );

      final attemptedMove = layout.moveShape(
        'right',
        const GridPoint(column: 1, row: 0),
      );

      expect(
        attemptedMove.shapeById('right')?.position,
        const GridPoint(column: 3, row: 0),
      );
    });

    test('rejects overlap when either shape does not allow it', () {
      final layout = GridLayout(
        shapes: [
          GridRectangleShape.constrained(
            id: 'anchor',
            position: const GridPoint(column: 0, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 4, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      );

      final overlapped = layout.moveShape(
        'floating',
        const GridPoint(column: 1, row: 0),
      );

      expect(
        overlapped.shapeById('floating')?.position,
        const GridPoint(column: 4, row: 0),
      );
    });

    test('rejects overlap for fixed-size free-flowing shapes', () {
      final layout = GridLayout(
        shapes: [
          GridRectangleShape.constrained(
            id: 'anchor',
            position: const GridPoint(column: 0, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
          GridRectangleShape.fixedSizeFreeFlowing(
            id: 'floating-fixed-size',
            position: const GridPoint(column: 4, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      );

      final overlapped = layout.moveShape(
        'floating-fixed-size',
        const GridPoint(column: 1, row: 0),
      );

      expect(
        overlapped.shapeById('floating-fixed-size')?.position,
        const GridPoint(column: 4, row: 0),
      );
    });

    test('rejects resizes that would overlap non-overlapping shapes', () {
      final layout = GridLayout(
        shapes: [
          GridRectangleShape.constrained(
            id: 'left',
            position: const GridPoint(column: 0, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
          GridRectangleShape.constrained(
            id: 'right',
            position: const GridPoint(column: 3, row: 0),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      );

      final attemptedResize = layout.resizeShape(
        'left',
        const GridSize(columns: 4, rows: 2),
      );

      expect(
        attemptedResize.shapeById('left')?.size,
        const GridSize(columns: 2, rows: 2),
      );
    });
  });
}
