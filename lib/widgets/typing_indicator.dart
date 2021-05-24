// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TypingIndicatorSpacer extends StatefulWidget {
  final bool showIndicator;

  const TypingIndicatorSpacer({required this.showIndicator});
  @override
  _TypingIndicatorSpacerState createState() => _TypingIndicatorSpacerState();
}

class _TypingIndicatorSpacerState extends State<TypingIndicatorSpacer>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _indicatorSpaceAnimation;

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    );

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(
      begin: 0.0,
      end: 30.0,
    ));

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicatorSpacer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 150)
      ..reverse();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, _) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: widget.showIndicator
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bubble(
                      nip: BubbleNip.leftBottom,
                      nipRadius: 1,
                      radius: Radius.circular(8),
                      nipHeight: 8,
                      nipWidth: 6,
                      elevation: 8,
                      margin: BubbleEdges.all(0),
                      color: Colors.transparent,
                      borderColor: style.borderColor,
                      borderWidth: 0.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SpinKitThreeBounce(
                          color: style.borderColor.withOpacity(0.8),
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        );
      },
    );
  }
}
