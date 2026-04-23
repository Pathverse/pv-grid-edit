import '../models/grid_shape.dart';

/// Returns whether two shape lists have identical items in the same order.
bool listEqualsByItem(List<GridShape> left, List<GridShape> right) {
  if (identical(left, right)) {
    return true;
  }

  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}