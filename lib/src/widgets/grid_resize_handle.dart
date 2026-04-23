import 'package:flutter/material.dart';

/// Renders the bottom-right resize affordance for an editable rectangle tile.
final class GridResizeHandle extends StatelessWidget {
  /// Creates a resize handle with the provided interaction callback.
  const GridResizeHandle({
    super.key,
    required this.handleKey,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  /// Key applied to the concrete gesture target used in tests and hit testing.
  final Key handleKey;

  /// Called when the user starts resizing.
  final GestureDragStartCallback onPanStart;

  /// Called while the user drags the resize handle.
  final GestureDragUpdateCallback onPanUpdate;

  /// Called when the user stops resizing.
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        key: handleKey,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.open_in_full, size: 12),
        ),
      ),
    );
  }
}