/// Defines the interaction rules a shape follows inside the grid editor.
enum GridShapeBehavior {
  /// Prevents movement and resizing.
  frozen,

  /// Allows movement while keeping the current snapped size locked.
  fixedSizeFreeFlowing,

  /// Allows editing while respecting optional min and max size limits.
  constrained,

  /// Allows editing, overlap, and explicit z-order changes.
  freeFlowing,
}

/// Describes the editing capabilities attached to each shape behavior.
extension GridShapeBehaviorCapabilities on GridShapeBehavior {
  /// Returns whether shapes using this behavior can move across the grid.
  bool get canMove {
    return switch (this) {
      GridShapeBehavior.frozen => false,
      GridShapeBehavior.fixedSizeFreeFlowing ||
      GridShapeBehavior.constrained ||
      GridShapeBehavior.freeFlowing => true,
    };
  }

  /// Returns whether shapes using this behavior can resize.
  bool get canResize {
    return switch (this) {
      GridShapeBehavior.frozen || GridShapeBehavior.fixedSizeFreeFlowing => false,
      GridShapeBehavior.constrained || GridShapeBehavior.freeFlowing => true,
    };
  }

  /// Returns whether shapes using this behavior may legally overlap peers.
  bool get canOverlap {
    return switch (this) {
      GridShapeBehavior.freeFlowing => true,
      GridShapeBehavior.frozen ||
      GridShapeBehavior.fixedSizeFreeFlowing ||
      GridShapeBehavior.constrained => false,
    };
  }
}