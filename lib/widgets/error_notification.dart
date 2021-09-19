import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return MediaQuery(
      data: MediaQueryData(),
      child: Consumer(
        builder: (_, watch, __) {
          String errorMsg = watch(errorsStateProvider).item1;
          double opacity = watch(errorsStateProvider).item2 ? 1.0 : 0.0;

          return Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              top: true,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: Duration(milliseconds: 350),
                child: CustomSlide(
                  startOffset: opacity == 1 ? Offset(0, -1) : Offset.zero,
                  endOffset: opacity == 1 ? Offset.zero : Offset(0, -1),
                  duration: Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        stops: [0.7, 1],
                        colors: [Colors.black, Colors.transparent],
                      ),
                    ),
                    width: double.maxFinite,
                    child: Material(
                      elevation: 12,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 50.0, horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/exclamation.png',
                              color: style.accentColor,
                              width: 16,
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                errorMsg,
                                textAlign: TextAlign.center,
                                style: style.bodyText
                                    .copyWith(color: style.accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
