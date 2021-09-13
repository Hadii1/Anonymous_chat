import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: KeyboardHider(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: height * 0.1,
              left: 24,
              right: 24,
            ),
            child: AnimationLimiter(
              child: Consumer(
                builder: (context, watch, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      childAnimationBuilder: (c) {
                        return SlideAnimation(
                          child: FadeInAnimation(
                            child: c,
                            duration: Duration(milliseconds: 250),
                          ),
                          duration: Duration(milliseconds: 320),
                          verticalOffset: 200,
                        );
                      },
                      children: <Widget>[
                        // Text(
                        //   'WELCOME TO ANONIMA',
                        //   textAlign: TextAlign.center,
                        //   style: style.title2Style,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //     top: 54,
                        //   ),
                        //   child: CustomTextField(
                        //     hint: 'Email',
                        //     onChanged: (email) => authNotifier.email = email,
                        //     borderColor: style.borderColor,
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //     top: 32,
                        //   ),
                        //   child: PasswordField(
                        //     onChanged: (password) =>
                        //         authNotifier.password = password,
                        //     borderColor: style.borderColor,
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //     top: 24,
                        //   ),
                        //   child: InkWell(
                        //     onTap: () => authNotifier.onForgetPasswordPressed(),
                        //     focusColor: Colors.transparent,
                        //     highlightColor: Colors.transparent,
                        //     splashColor: Colors.transparent,
                        //     child: Row(
                        //       children: [
                        //         Text(
                        //           'Forgot Password?',
                        //           style: style.smallTextStyle,
                        //         ),
                        //         Text(
                        //           ' Get help signing in',
                        //           style: style.smallTextStyle.copyWith(
                        //             color: style.accentColor,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 64, bottom: 24),
                        //   child: CtaButton(
                        //     onPressed: () async {
                        //       FocusScope.of(context).unfocus();
                        //       bool success =
                        //           await authNotifier.onLoginPressed();
                        //       if (success)
                        //         Navigator.of(context).pushAndRemoveUntil(
                        //           MaterialPageRoute(builder: (_) => Home()),
                        //           (route) => false,
                        //         );
                        //     },
                        //     text: 'LOGIN',
                        //   ),
                        // ),
                        // CtaButton(
                        //   isPrimary: false,
                        //   onPressed: () async {
                        //     FocusScope.of(context).unfocus();
                        //     bool success =
                        //         await authNotifier.onRegisterPressed();
                        //     if (success)
                        //       Navigator.of(context).pushAndRemoveUntil(
                        //         MaterialPageRoute(
                        //           builder: (_) => NameGenerator(),
                        //         ),
                        //         (route) => false,
                        //       );
                        //   },
                        //   text: 'Register',
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
