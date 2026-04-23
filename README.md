# pv_grid_edit

A Flutter package for building snapped grid editors with draggable and resizable rectangle shapes.

![Example app screenshot](https://raw.githubusercontent.com/Pathverse/pv-grid-edit/refs/heads/main/doc/image.png)

## Features

- Rectangle-based grid editing with frozen, fixed-size movable, constrained, and free-flowing behaviors.
- Collision rollback for non-overlapping shapes.
- JSON serialization for layouts and shapes.
- A simple dictionary helper for map-based load and save boundaries.

## Getting started

Add the package to your `pubspec.yaml`, then create a `GridEditorBloc` and pass it to `GridEditor`.

## Usage

```dart
final bloc = GridEditorBloc(
	initialLayout: GridLayout(
		shapes: <GridShape>[
			GridRectangleShape.constrained(
				id: 'panel',
				position: const GridPoint(column: 0, row: 0),
				size: const GridSize(columns: 3, rows: 2),
			),
		],
	),
);
```

For map-based integration, use `GridEditorMapHelper.layoutFromDictionary(...)` and `GridEditorMapHelper.dictionaryFromLayout(...)`.

