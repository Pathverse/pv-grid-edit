import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

void main() {
  group('GridEditorBloc', () {
    blocTest<GridEditorBloc, GridEditorState>(
      'loads a layout into state',
      build: GridEditorBloc.new,
      act: (bloc) {
        bloc.add(
          GridLayoutLoaded(
            GridLayout(
              shapes: [
                GridRectangleShape.fixed(
                  id: 'locked',
                  position: const GridPoint(column: 2, row: 3),
                  size: const GridSize(columns: 1, rows: 1),
                ),
              ],
            ),
          ),
        );
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.layout.shapeById('locked')?.position,
          'locked position',
          const GridPoint(column: 2, row: 3),
        ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'keeps fixed rectangles stationary when a move event is dispatched',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.fixed(
              id: 'fixed',
              position: const GridPoint(column: 1, row: 1),
              size: const GridSize(columns: 2, rows: 2),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(
          GridShapeMoved(
            shapeId: 'fixed',
            position: const GridPoint(column: 9, row: 9),
          ),
        );
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.layout.shapeById('fixed')?.position,
          'fixed position',
          const GridPoint(column: 1, row: 1),
        ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'moves fixed-size free-flowing rectangles while preserving size',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.fixedSizeFreeFlowing(
              id: 'floater',
              position: const GridPoint(column: 1, row: 1),
              size: const GridSize(columns: 2, rows: 2),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc
          ..add(
            const GridShapeMoved(
              shapeId: 'floater',
              position: GridPoint(column: 5, row: 4),
            ),
          )
          ..add(
            const GridShapeResized(
              shapeId: 'floater',
              size: GridSize(columns: 4, rows: 4),
            ),
          );
      },
      expect: () => [
        isA<GridEditorState>()
            .having(
              (state) => state.layout.shapeById('floater')?.position,
              'position after move and resize attempt',
              const GridPoint(column: 5, row: 4),
            )
            .having(
              (state) => state.layout.shapeById('floater')?.size,
              'size after resize attempt',
              const GridSize(columns: 2, rows: 2),
            ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'clamps constrained rectangle sizes when a resize event is dispatched',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.constrained(
              id: 'constrained',
              position: const GridPoint(column: 0, row: 0),
              size: const GridSize(columns: 3, rows: 3),
              constraints: const GridSizeConstraints(
                minColumns: 2,
                maxColumns: 4,
                minRows: 1,
                maxRows: 5,
              ),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(
          GridShapeResized(
            shapeId: 'constrained',
            size: const GridSize(columns: 10, rows: 0),
          ),
        );
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.layout.shapeById('constrained')?.size,
          'constrained size',
          const GridSize(columns: 4, rows: 1),
        ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'brings free-flowing rectangles to the front',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.constrained(
              id: 'background',
              position: const GridPoint(column: 0, row: 0),
              size: const GridSize(columns: 4, rows: 4),
              zIndex: 1,
            ),
            GridRectangleShape.freeFlowing(
              id: 'floating',
              position: const GridPoint(column: 1, row: 1),
              size: const GridSize(columns: 2, rows: 2),
              zIndex: 2,
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(const GridShapeBroughtToFront(shapeId: 'floating'));
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.layout.shapeById('floating')?.zIndex,
          'floating zIndex',
          3,
        ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'tracks the selected shape',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.freeFlowing(
              id: 'floating',
              position: const GridPoint(column: 1, row: 1),
              size: const GridSize(columns: 2, rows: 2),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(const GridShapeSelected(shapeId: 'floating'));
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.selectedShapeId,
          'selected shape',
          'floating',
        ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'snaps drag requests to the nearest grid point',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.constrained(
              id: 'dragged',
              position: const GridPoint(column: 0, row: 0),
              size: const GridSize(columns: 1, rows: 1),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(
          GridShapeDragged(
            shapeId: 'dragged',
            canvasOffset: const GridCanvasOffset(dx: 38, dy: 65),
            snapSpec: const GridSnapSpec(cellWidth: 20, cellHeight: 20),
          ),
        );
      },
      expect: () => [
        isA<GridEditorState>()
            .having(
              (state) => state.layout.shapeById('dragged')?.position,
              'snapped position',
              const GridPoint(column: 2, row: 3),
            )
            .having(
              (state) => state.selectedShapeId,
              'selected shape after drag',
              'dragged',
            ),
      ],
    );

    blocTest<GridEditorBloc, GridEditorState>(
      'restores non-overlapping shapes when a move would collide',
      build: () => GridEditorBloc(
        initialLayout: GridLayout(
          shapes: [
            GridRectangleShape.constrained(
              id: 'locked-left',
              position: const GridPoint(column: 0, row: 0),
              size: const GridSize(columns: 2, rows: 2),
            ),
            GridRectangleShape.constrained(
              id: 'locked-right',
              position: const GridPoint(column: 3, row: 0),
              size: const GridSize(columns: 2, rows: 2),
            ),
          ],
        ),
      ),
      act: (bloc) {
        bloc.add(
          const GridShapeMoved(
            shapeId: 'locked-right',
            position: GridPoint(column: 1, row: 0),
          ),
        );
      },
      expect: () => [
        isA<GridEditorState>().having(
          (state) => state.layout.shapeById('locked-right')?.position,
          'restored position',
          const GridPoint(column: 3, row: 0),
        ),
      ],
    );
  });
}