import 'package:flutter/material.dart';

import '../models/grid_rectangle_shape.dart';
import '../utils/grid_snap.dart';
import 'grid_resize_handle.dart';

/// Renders one rectangle shape inside the editor canvas.
final class GridRectangleTile extends StatefulWidget {
  /// Creates a positioned rectangle tile for the editor canvas.
  const GridRectangleTile({
    super.key,
    required this.shape,
    required this.snapSpec,
    required this.selected,
    required this.onTap,
    required this.onDrag,
    required this.onResize,
  });

  /// Shape definition to render.
  final GridRectangleShape shape;

  /// Snap metrics used to convert grid units into pixels.
  final GridSnapSpec snapSpec;

  /// Whether the shape is currently selected in the editor.
  final bool selected;

  /// Called when the shape is tapped.
  final VoidCallback onTap;

  /// Called when the tile is dragged to a raw canvas offset.
  final ValueChanged<GridCanvasOffset>? onDrag;

  /// Called when the tile is resized to a raw pixel size.
  final ValueChanged<GridCanvasOffset>? onResize;

  @override
  State<GridRectangleTile> createState() => _GridRectangleTileState();
}

/// Stores transient pointer state for rectangle dragging and resizing.
final class _GridRectangleTileState extends State<GridRectangleTile> {
  /// Starting pixel offset used to compute drag updates.
  GridCanvasOffset? _dragStartOffset;

  /// Accumulated drag delta in logical pixels for the active gesture.
  Offset _dragDelta = Offset.zero;

  /// Starting pixel size used to compute resize updates.
  GridCanvasOffset? _resizeStartSize;

  /// Accumulated resize delta in logical pixels for the active gesture.
  Offset _resizeDelta = Offset.zero;

  /// Handles the start of a drag gesture for this tile.
  void _handleDragStart(DragStartDetails details) {
    _dragStartOffset = GridCanvasOffset(
      dx: widget.shape.position.column * widget.snapSpec.cellWidth,
      dy: widget.shape.position.row * widget.snapSpec.cellHeight,
    );
    _dragDelta = Offset.zero;
    widget.onTap();
  }

  /// Handles drag updates by translating pointer movement into canvas offsets.
  void _handleDragUpdate(DragUpdateDetails details) {
    final dragStartOffset = _dragStartOffset;
    final onDrag = widget.onDrag;
    if (dragStartOffset == null || onDrag == null) {
      return;
    }

    _dragDelta += details.delta;

    onDrag(
      GridCanvasOffset(
        dx: dragStartOffset.dx + _dragDelta.dx,
        dy: dragStartOffset.dy + _dragDelta.dy,
      ),
    );
  }

  /// Clears transient drag state when the gesture ends.
  void _handleDragEnd(DragEndDetails details) {
    _dragStartOffset = null;
    _dragDelta = Offset.zero;
  }

  /// Handles the start of a resize gesture for this tile.
  void _handleResizeStart(DragStartDetails details) {
    _resizeStartSize = GridCanvasOffset(
      dx: widget.shape.size.columns * widget.snapSpec.cellWidth,
      dy: widget.shape.size.rows * widget.snapSpec.cellHeight,
    );
    _resizeDelta = Offset.zero;
    widget.onTap();
  }

  /// Handles resize updates by translating pointer movement into pixel size.
  void _handleResizeUpdate(DragUpdateDetails details) {
    final resizeStartSize = _resizeStartSize;
    final onResize = widget.onResize;
    if (resizeStartSize == null || onResize == null) {
      return;
    }

    _resizeDelta += details.delta;

    onResize(
      GridCanvasOffset(
        dx: resizeStartSize.dx + _resizeDelta.dx,
        dy: resizeStartSize.dy + _resizeDelta.dy,
      ),
    );
  }

  /// Clears transient resize state when the gesture ends.
  void _handleResizeEnd(DragEndDetails details) {
    _resizeStartSize = null;
    _resizeDelta = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.shape.position.column * widget.snapSpec.cellWidth,
      top: widget.shape.position.row * widget.snapSpec.cellHeight,
      width: widget.shape.size.columns * widget.snapSpec.cellWidth,
      height: widget.shape.size.rows * widget.snapSpec.cellHeight,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              key: ValueKey<String>('grid-shape-${widget.shape.id}'),
              onTap: widget.onTap,
              onPanStart: widget.onDrag == null ? null : _handleDragStart,
              onPanUpdate: widget.onDrag == null ? null : _handleDragUpdate,
              onPanEnd: widget.onDrag == null ? null : _handleDragEnd,
              child: DecoratedBox(
                key: widget.selected
                    ? ValueKey<String>('grid-shape-selected-${widget.shape.id}')
                    : null,
                decoration: BoxDecoration(
                  color: widget.selected ? Colors.orange.shade300 : Colors.blueGrey.shade300,
                  border: Border.all(
                    color: widget.selected ? Colors.deepOrange : Colors.blueGrey.shade700,
                    width: widget.selected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    widget.shape.id,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
          if (widget.selected &&
              widget.shape.canResize &&
              widget.onResize != null)
            GridResizeHandle(
              handleKey: ValueKey<String>('grid-resize-handle-${widget.shape.id}'),
              onPanStart: _handleResizeStart,
              onPanUpdate: _handleResizeUpdate,
              onPanEnd: _handleResizeEnd,
            ),
        ],
      ),
    );
  }
}