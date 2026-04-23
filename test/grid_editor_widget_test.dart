import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pv_grid_edit/pv_grid_edit.dart';

void main() {
  testWidgets('renders shapes and selects a shape when tapped', (tester) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 1, row: 1),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 40, cellHeight: 40),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('grid-shape-floating')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('grid-shape-floating')));
    await tester.pump();

    expect(bloc.state.selectedShapeId, 'floating');
    expect(find.byKey(const ValueKey<String>('grid-shape-selected-floating')), findsOneWidget);
  });

  testWidgets('drags a free-flowing shape to a snapped grid point', (tester) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 1, row: 1),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 40, cellHeight: 40),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey<String>('grid-shape-floating')),
      const Offset(80, 40),
    );
    await tester.pump();

    expect(
      bloc.state.layout.shapeById('floating')?.position,
      const GridPoint(column: 3, row: 2),
    );
    expect(bloc.state.selectedShapeId, 'floating');
  });

  testWidgets('keeps dragged shapes inside the visible board bounds', (tester) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 1, row: 1),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 40, cellHeight: 40),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey<String>('grid-shape-floating')),
      const Offset(200, 200),
    );
    await tester.pump();

    expect(
      bloc.state.layout.shapeById('floating')?.position,
      const GridPoint(column: 3, row: 3),
    );

    final boardRect = tester.getRect(find.byType(GridEditor));
    final shapeRect = tester.getRect(find.byKey(const ValueKey<String>('grid-shape-floating')));
    expect(shapeRect.right <= boardRect.right, isTrue);
    expect(shapeRect.bottom <= boardRect.bottom, isTrue);
  });

  testWidgets('renders oversized positions clamped inside the board', (tester) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.fixedSizeFreeFlowing(
            id: 'runner',
            position: const GridPoint(column: 4, row: 4),
            size: const GridSize(columns: 2, rows: 1),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 44, cellHeight: 44),
              ),
            ),
          ),
        ),
      ),
    );

    final boardRect = tester.getRect(find.byType(GridEditor));
    final shapeRect = tester.getRect(find.byKey(const ValueKey<String>('grid-shape-runner')));

    expect(
      bloc.state.layout.shapeById('runner')?.position,
      const GridPoint(column: 2, row: 3),
    );
    expect(shapeRect.right <= boardRect.right, isTrue);
    expect(shapeRect.bottom <= boardRect.bottom, isTrue);
  });

  testWidgets('nudges the selected shape with keyboard arrows and clamps to the board', (
    tester,
  ) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.freeFlowing(
            id: 'floating',
            position: const GridPoint(column: 1, row: 1),
            size: const GridSize(columns: 2, rows: 2),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 40, cellHeight: 40),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('grid-shape-floating')));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(
      bloc.state.layout.shapeById('floating')?.position,
      const GridPoint(column: 3, row: 3),
    );
  });

  testWidgets('uses a resize handle to resize a constrained shape', (tester) async {
    final bloc = GridEditorBloc(
      initialLayout: GridLayout(
        shapes: [
          GridRectangleShape.constrained(
            id: 'panel',
            position: const GridPoint(column: 1, row: 1),
            size: const GridSize(columns: 2, rows: 2),
            constraints: const GridSizeConstraints(
              minColumns: 1,
              maxColumns: 4,
              minRows: 1,
              maxRows: 4,
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: GridEditor(
                bloc: bloc,
                snapSpec: const GridSnapSpec(cellWidth: 40, cellHeight: 40),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('grid-shape-panel')));
    await tester.pump();

    await tester.drag(
      find.byKey(const ValueKey<String>('grid-resize-handle-panel')),
      const Offset(80, 40),
    );
    await tester.pump();

    expect(
      bloc.state.layout.shapeById('panel')?.size,
      const GridSize(columns: 4, rows: 3),
    );
    expect(bloc.state.selectedShapeId, 'panel');
  });
}