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

class BottomNavigationSlider extends StatefulWidget {
  const BottomNavigationSlider({
    required this.shouldShow,
    required this.child,
  });
  final bool shouldShow;
  final Widget child;

  @override
  _BottomNavigationSliderState createState() => _BottomNavigationSliderState();
}

class _BottomNavigationSliderState extends State<BottomNavigationSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BottomNavigationSlider oldWidget) {
    if (oldWidget.shouldShow != widget.shouldShow) {
      _animationController.reset();
      _animationController.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.shouldShow
          ? Tween(begin: Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(
                curve: Curves.easeOutCubic,
                parent: _animationController,
              ),
            )
          : Tween(begin: Offset.zero, end: Offset(0.0, 1)).animate(
              CurvedAnimation(
                curve: Curves.easeInCubic,
                parent: _animationController,
              ),
            ),
      child: widget.child,
    );
  }
}

class ScaleAnimator extends StatefulWidget {
  const ScaleAnimator({
    required this.child,
    required this.duration,
    this.onAnimationEnd,
    this.delay,
    this.lowerBound = 0,
    this.upperBound = 1,
    this.reverse = false,
  });

  final Widget child;
  final Duration duration;
  final Duration? delay;
  final bool reverse;
  final double lowerBound;
  final double upperBound;
  final void Function()? onAnimationEnd;

  @override
  _ScaleAnimatorState createState() => _ScaleAnimatorState();
}

class _ScaleAnimatorState extends State<ScaleAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        upperBound: widget.upperBound,
        lowerBound: widget.lowerBound,
        duration: widget.duration,
        reverseDuration: widget.duration,
        value: widget.reverse ? widget.upperBound : widget.lowerBound)
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed &&
              widget.onAnimationEnd != null) {
            widget.onAnimationEnd!();
          }
        },
      );

    Future.delayed(widget.delay ?? Duration(milliseconds: 0)).then(
      (value) => widget.reverse
          ? _animationController.reverse()
          : _animationController.forward(),
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
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInCubic,
      ),
      builder: (_, __) => ScaleTransition(
        scale: _animationController,
        child: widget.child,
      ),
    );
  }
}
