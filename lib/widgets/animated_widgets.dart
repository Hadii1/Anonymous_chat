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

class CustomSizeTransition extends StatefulWidget {
  const CustomSizeTransition({
    required this.child,
    required this.hide,
    required this.duration,
  });
  final Duration duration;
  final bool hide;
  final Widget child;

  @override
  _CustomSizeTransitionState createState() => _CustomSizeTransitionState();
}

class _CustomSizeTransitionState extends State<CustomSizeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _animationController.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomSizeTransition oldWidget) {
    if (oldWidget.hide != widget.hide) {
      if (widget.hide) {
        _animationController.reverse();
      }
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
    return SizeTransition(
      sizeFactor: _animation,
      child: widget.child,
    );
  }
}

// class CustomSlideTransition extends StatefulWidget {
//   final bool hide;
//   final

//   const CustomSlideTransition({required this.hide});

//   @override
//   CustomSlideTransitionState createState() => CustomSlideTransitionState();
// }

// class CustomSlideTransitionState extends State<CustomSlideTransition> with SingleTickerProviderStateMixin {
  

//    late final AnimationController ctrl ;
//    late final Animation<Offset> animation;
//   @override
//   void initState() {
// ctrl = AnimationController(vsync: this,duration: )
//     super.initState();
//   }

//   @override
//   void dispose() {
// ctrl.dispose();

//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(position: position)
//   }
// }
