import 'package:flutter/material.dart';
import 'style_lerp.dart';

/// How ordered and unordered list items are drawn.
///
/// Every field is optional. An unset field falls back to the theme, then to
/// the value the package used before this style existed — so setting one
/// field changes one thing and nothing else moves.
///
/// A style on the widget wins over the theme **per field**, not per object.
@immutable
class ListStyle {
  /// Creates a ListStyle. Null fields defer to the theme, then to the default.
  const ListStyle({
    this.bulletSize,
    this.bulletColor,
    this.bulletShape,
    this.markerTextStyle,
    this.indent,
    this.gapAfterMarker,
    this.markerWidth,
    this.nestedIndent,
  });

  /// Bullet diameter. Defaults to 0.3x the font size.
  final double? bulletSize;

  /// Bullet colour. Defaults to the text colour.
  final Color? bulletColor;

  /// Bullet shape. Defaults to a circle.
  final BoxShape? bulletShape;

  /// Style of the `1.` marker. Defaults to weight 100.
  final TextStyle? markerTextStyle;

  /// Space before the marker. Defaults to the value each list kind already
  /// used — 7 for bullets, 6 for numbers.
  final double? indent;

  /// Space between marker and text. Defaults to the value each list kind
  /// already used — 10 for bullets, 6 for numbers.
  final double? gapAfterMarker;

  /// Width of the box the marker — a bullet or a `1.` — is drawn in, with
  /// the marker aligned to its end. Text then starts at the same place in a
  /// bullet list and a numbered one, and whether the number is `1.` or
  /// `10.`, as it does in a browser. Defaults to the marker's own width.
  final double? markerWidth;

  /// Extra indent for each level of nesting, for an item written with
  /// leading spaces. Defaults to the value the package used before this was
  /// configurable — one pixel per leading space, at most four.
  final double? nestedIndent;

  /// This style, with any unset field taken from [other], field by field.
  ListStyle merge(ListStyle? other) {
    if (other == null) {
      return this;
    }
    return ListStyle(
      bulletSize: bulletSize ?? other.bulletSize,
      bulletColor: bulletColor ?? other.bulletColor,
      bulletShape: bulletShape ?? other.bulletShape,
      markerTextStyle: markerTextStyle ?? other.markerTextStyle,
      indent: indent ?? other.indent,
      gapAfterMarker: gapAfterMarker ?? other.gapAfterMarker,
      markerWidth: markerWidth ?? other.markerWidth,
      nestedIndent: nestedIndent ?? other.nestedIndent,
    );
  }

  /// This style with every remaining default filled in.
  ///
  /// Bullet size and colour depend on the surrounding text, so they stay null
  /// here and are computed per item unless set.
  ListStyle resolve(ColorScheme scheme) {
    return ListStyle(
      bulletSize: bulletSize,
      bulletColor: bulletColor,
      bulletShape: bulletShape ?? BoxShape.circle,
      markerTextStyle: markerTextStyle,
      indent: indent,
      gapAfterMarker: gapAfterMarker,
      markerWidth: markerWidth,
      nestedIndent: nestedIndent,
    );
  }

  /// A copy with the given fields replaced.
  ListStyle copyWith({
    double? bulletSize,
    Color? bulletColor,
    BoxShape? bulletShape,
    TextStyle? markerTextStyle,
    double? indent,
    double? gapAfterMarker,
    double? markerWidth,
    double? nestedIndent,
  }) {
    return ListStyle(
      bulletSize: bulletSize ?? this.bulletSize,
      bulletColor: bulletColor ?? this.bulletColor,
      bulletShape: bulletShape ?? this.bulletShape,
      markerTextStyle: markerTextStyle ?? this.markerTextStyle,
      indent: indent ?? this.indent,
      gapAfterMarker: gapAfterMarker ?? this.gapAfterMarker,
      markerWidth: markerWidth ?? this.markerWidth,
      nestedIndent: nestedIndent ?? this.nestedIndent,
    );
  }

  /// Linearly interpolates between two styles.
  static ListStyle? lerp(ListStyle? a, ListStyle? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return t < 0.5 ? null : b;
    }
    if (b == null) {
      return t < 0.5 ? a : null;
    }
    return ListStyle(
      bulletSize: lerpDouble(a.bulletSize, b.bulletSize, t),
      bulletColor: Color.lerp(a.bulletColor, b.bulletColor, t),
      bulletShape: t < 0.5 ? a.bulletShape : b.bulletShape,
      markerTextStyle: TextStyle.lerp(a.markerTextStyle, b.markerTextStyle, t),
      indent: lerpDouble(a.indent, b.indent, t),
      gapAfterMarker: lerpDouble(a.gapAfterMarker, b.gapAfterMarker, t),
      markerWidth: lerpDouble(a.markerWidth, b.markerWidth, t),
      nestedIndent: lerpDouble(a.nestedIndent, b.nestedIndent, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ListStyle &&
        other.bulletSize == bulletSize &&
        other.bulletColor == bulletColor &&
        other.bulletShape == bulletShape &&
        other.markerTextStyle == markerTextStyle &&
        other.indent == indent &&
        other.gapAfterMarker == gapAfterMarker &&
        other.markerWidth == markerWidth &&
        other.nestedIndent == nestedIndent;
  }

  @override
  int get hashCode => Object.hash(
    bulletSize,
    bulletColor,
    bulletShape,
    markerTextStyle,
    indent,
    gapAfterMarker,
    markerWidth,
    nestedIndent,
  );
}
