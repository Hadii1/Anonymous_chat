import 'package:anonymous_chat/providers/name_generator.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class NameGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = InheritedAppTheme.of(context).style;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: TitledAppBar(),
      body: Consumer(builder: (context, watch, __) {
        final generatorNotifier = watch(nameGeneratorProvider);
        return SafeArea(
          child: KeyboardHider(
            child: Padding(
              padding: EdgeInsets.only(
                top: height * 0.1,
                left: 24,
                right: 24,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'USERNAME GENERATOR',
                        style: style.title2Style,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.2),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: generatorNotifier.loading
                            ? SpinKitHourGlass(
                                color: style.accentColor,
                                size: 55,
                              )
                            : SizedBox(
                                height: 55,
                                child: Text(
                                  '${generatorNotifier.color}${generatorNotifier.animal}${generatorNotifier.number}',
                                  style: style.bodyText.copyWith(
                                    color: style.accentColor,
                                    fontSize: 21,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  CustomSlide(
                    duration: Duration(seconds: 1),
                    startOffset: Offset(0, 1),
                    endOffset: Offset.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CtaButton(
                          onPressed: generatorNotifier.onRewindPressed,
                          text: 'REWIND',
                          isPrimary: false,
                        ),
                        SizedBox(height: 12),
                        CtaButton(
                          onPressed: () async {
                            bool success =
                                await generatorNotifier.onProceedPressed();

                            if (success)
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => Home(),
                                  ),
                                  (route) => false);
                          },
                          text: 'Proceed',
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
