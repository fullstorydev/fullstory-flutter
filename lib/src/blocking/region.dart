import 'dart:ui';

import 'package:fullstory_flutter/src/numbers.dart';
class BlockedRegions {
  final _regions = <Rect>{};

  void clear() => _regions.clear();


  void add(Rect region) {
    if (_regions.any((existing) => existing.containsRect(region))) {
      return;
    }
    _regions.removeWhere((existing) => region.containsRect(existing));
    _regions.add(region);
  }

  bool contains(Offset pt) => _regions.any((r) => r.contains(pt));





  List<List<int>> toHostList(double scaleFactor) => _regions
      .map(
        (r) => [
          (r.left * scaleFactor).roundSafe(),
          (r.top * scaleFactor).roundSafe(),
          (r.right * scaleFactor).roundSafe(),
          (r.bottom * scaleFactor).roundSafe(),
        ],
      )
      .toList();
}

extension _ContainsRect on Rect {
  bool containsRect(Rect other) {
    return left <= other.left &&
        top <= other.top &&
        right >= other.right &&
        bottom >= other.bottom;
  }
}
