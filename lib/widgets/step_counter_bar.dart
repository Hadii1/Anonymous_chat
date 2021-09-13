import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class StepCounterAppBar extends StatefulWidget {
  const StepCounterAppBar({
    required this.activeIndex,
    required this.onBackPressed,
    required this.stepsNumber,
  });

  final Function() onBackPressed;
  final int activeIndex;
  final int stepsNumber;

  @override
  _StepCounterAppBarState createState() => _StepCounterAppBarState();
}

class _StepCounterAppBarState extends State<StepCounterAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _stepWidth;

  @override
  void initState() {
    _stepWidth = 155 / widget.stepsNumber;
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 155,
      duration: Duration(milliseconds: widget.stepsNumber * 200),
    );

    _animationController.animateTo(
      widget.activeIndex * _stepWidth,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StepCounterAppBar oldWidget) {
    if (oldWidget.activeIndex < widget.activeIndex) {
      _animationController.animateTo(
        widget.activeIndex * _stepWidth,
      );
    } else if (oldWidget.activeIndex > widget.activeIndex) {
      _animationController.animateBack(
        widget.activeIndex * _stepWidth,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return Stack(
      children: <Widget>[
        // Back Button
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onBackPressed,
              child: Image.asset(
                'assets/icons/back_arrow.png',
                color: Colors.white,
                width: 20,
              ),
            ),
          ),
        ),

        // Horizontal Counter
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 24,
                child: Text(
                  '${widget.activeIndex}/${widget.stepsNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: -0.2,
                    fontSize: 11.2,
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: 3.1,
                    width: 155,
                    decoration: BoxDecoration(
                      color: Color(0xff343434),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                        parent: _animationController,
                      ),
                    ),
                    builder: (context, child) => Container(
                      height: 3.1,
                      width: _animationController.value,
                      decoration: BoxDecoration(
                        color: style.accentColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
