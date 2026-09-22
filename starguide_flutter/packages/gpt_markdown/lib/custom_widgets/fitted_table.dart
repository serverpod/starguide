import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Sizes a column to its content and shares any spare width in proportion to
/// that content, the way a browser lays out an automatic table.
///
/// The minimum is the widest thing a column cannot break, such as its longest
/// word, so a cell wraps before the table grows past the space it is given.
class ProportionalColumnWidth extends TableColumnWidth {
  const ProportionalColumnWidth();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    var width = 0.0;
    for (final cell in cells) {
      width = max(width, cell.getMinIntrinsicWidth(double.infinity));
    }
    return width;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    var width = 0.0;
    for (final cell in cells) {
      width = max(width, cell.getMaxIntrinsicWidth(double.infinity));
    }
    return width;
  }

  /// A flex has to be positive, and an empty column still needs a share.
  @override
  double flex(Iterable<RenderBox> cells) =>
      max(1, maxIntrinsicWidth(cells, double.infinity));
}

/// Lays its child out at [width], or wider when the child cannot be made that
/// narrow.
///
/// Meant for a table inside a horizontal scroll view: the scroll view offers
/// unbounded width, so this is what makes the table fill the space it is
/// shown in, and only grow — and scroll — past it when a cell holds
/// something that cannot wrap.
class FitWidth extends SingleChildRenderObjectWidget {
  const FitWidth({super.key, required this.width, required super.child});

  /// The width to fill.
  final double width;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderFitWidth(width);

  @override
  void updateRenderObject(BuildContext context, RenderFitWidth renderObject) {
    renderObject.width = width;
  }
}

/// The render object of [FitWidth].
class RenderFitWidth extends RenderProxyBox {
  RenderFitWidth(this._width);

  double _width;

  /// The width to fill.
  double get width => _width;
  set width(double value) {
    if (value == _width) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  double _childWidth(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) {
      return constraints.constrainWidth(_width);
    }
    final minimum = child.getMinIntrinsicWidth(double.infinity);
    return constraints.constrainWidth(max(_width, minimum));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    final width = _childWidth(constraints);
    if (child == null) {
      return constraints.constrain(Size(width, 0));
    }
    final size = child.getDryLayout(
      constraints.copyWith(minWidth: width, maxWidth: width),
    );
    return constraints.constrain(size);
  }

  @override
  void performLayout() {
    final child = this.child;
    final width = _childWidth(constraints);
    if (child == null) {
      size = constraints.constrain(Size(width, 0));
      return;
    }
    child.layout(
      constraints.copyWith(minWidth: width, maxWidth: width),
      parentUsesSize: true,
    );
    size = constraints.constrain(child.size);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      max(_width, child?.getMaxIntrinsicWidth(height) ?? 0);
}
