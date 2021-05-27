import 'package:flutter/material.dart';

// More info on: https://pub.dev/packages/flutter_staggered_animations

class Fader extends StatefulWidget {
  const Fader({
    required this.child,
    required this.duration,
    this.delay,
    this.key1,
    this.lowerBound,
  });

  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Key? key1;
  final double? lowerBound;

  @override
  _FaderState createState() => _FaderState();
}

class _FaderState extends State<Fader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      lowerBound: widget.lowerBound ?? 0,
      upperBound: 1,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      });

    Future.delayed(widget.delay ?? Duration(seconds: 0)).then(
      (value) => _animationController.forward(),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: widget.key1,
      opacity: _animationController.value,
      child: widget.child,
    );
  }
}

class CustomSlide extends StatefulWidget {
  const CustomSlide({
    required this.child,
    required this.duration,
    required this.startOffset,
    this.endOffset = Offset.zero,
    this.delay = Duration.zero,
  });
  final Duration duration;
  final Duration delay;
  final Offset startOffset;
  final Offset endOffset;
  final Widget child;

  @override
  _CustomSlideState createState() => _CustomSlideState();
}

class _CustomSlideState extends State<CustomSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    Future.delayed(widget.delay, () {
      _animationController.forward();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomSlide oldWidget) {
    if (oldWidget.startOffset != widget.startOffset ||
        oldWidget.endOffset != widget.endOffset) {
      _animationController.reset();
      _animationController.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: widget.startOffset,
        end: widget.endOffset,
      ).animate(
        CurvedAnimation(
          curve: widget.endOffset == Offset.zero
              ? Curves.easeOutExpo
              : Curves.easeInCubic,
          parent: _animationController,
        ),
      ),
      child: widget.child,
    );
  }
}

