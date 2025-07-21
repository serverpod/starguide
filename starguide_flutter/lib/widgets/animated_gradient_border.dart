import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.gradientColors,
    required this.angle,
    required this.borderRadius,
  });

  final List<Color> gradientColors;
  final double angle;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: SweepGradient(
          colors: [...gradientColors, ...gradientColors.reversed],
          stops: _generateColorStops(
              [...gradientColors, ...gradientColors.reversed]),
          transform: GradientRotation(angle),
        ),
      ),
    );
  }

  List<double> _generateColorStops(List<dynamic> colors) {
    return colors.asMap().entries.map((entry) {
      double percentageStop = entry.key / colors.length;
      return percentageStop;
    }).toList();
  }
}

class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.gradientColors,
    required this.borderRadius,
    this.animationDuration = const Duration(seconds: 2),
    this.borderWidth = 2,
    this.glowSize = 8,
    this.animationProgress,
    this.enabled = true,
  });

  final Widget child;
  final double borderWidth;
  final double glowSize;
  final List<Color> gradientColors;
  final BorderRadiusGeometry borderRadius;
  final Duration animationDuration;
  final double? animationProgress;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _angleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.addListener(() => setState(() {}));
    _angleAnimation =
        Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_controller);
    if (widget.animationProgress != null) {
      _controller.forward();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final animateTo = widget.animationProgress;
    if (animateTo != null) {
      _controller.animateTo(animateTo);
    } else {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.enabled)
          Positioned(
            top: -widget.borderWidth,
            left: -widget.borderWidth,
            right: -widget.borderWidth,
            bottom: -widget.borderWidth,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.glowSize,
                  sigmaY: widget.glowSize,
                ),
                child: GradientContainer(
                  gradientColors: widget.gradientColors,
                  borderRadius: widget.borderRadius,
                  angle: _angleAnimation.value,
                ),
              ),
            ),
          ),
        if (widget.enabled)
          Positioned(
            top: -widget.borderWidth,
            left: -widget.borderWidth,
            right: -widget.borderWidth,
            bottom: -widget.borderWidth,
            child: IgnorePointer(
              child: GradientContainer(
                gradientColors: widget.gradientColors,
                borderRadius: widget.borderRadius,
                angle: _angleAnimation.value,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}
