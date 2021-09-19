import 'package:anonymous_chat/providers/auth_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/onboarding.dart';
import 'package:anonymous_chat/views/splash_screen.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/custom_text_field.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginScreen extends StatelessWidget {
  // If onboarding info is null then the user is signing in and not registering.
  final OnboardingInfo? onboardingInfo;
  const LoginScreen({this.onboardingInfo});

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;

    return ProviderListener<bool>(
      onChange: (_, bool navigate) {
        if (navigate)
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (_) => UserInfoInitializing(),
            ),
            (route) => false,
          );
      },
      provider: navigationSignal,
      child: Scaffold(
        backgroundColor: style.backgroundColor,
        body: KeyboardHider(
          child: Consumer(builder: (context, watch, _) {
            final authNotifier = watch(phoneVerificationProvider.notifier);
            watch(phoneVerificationProvider);
            return Stack(
              children: [
                Column(
                  children: [
                    TitledAppBar(
                      leading: SizedBox.shrink(),
                    ),
                    AnimationLimiter(
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
                                SizedBox(height: 48),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 350),
                                  child: authNotifier.isCodeSent
                                      ? Container(
                                          child: TitleText(
                                            title: 'LOGIN',
                                            subtitle:
                                                'An SMS containing 6 digit code was sent to ${authNotifier.number}.',
                                          ),
                                        )
                                      : TitleText(
                                          title: 'LOGIN',
                                          subtitle:
                                              'Please enter your mobile number to receive a verification code to start using Anonima',
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 36,
                                    horizontal: 48,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 350),
                                    child: authNotifier.isCodeSent
                                        ? _CodeInput(onSumbitted: (code) {
                                            authNotifier.onCodeSubmitted(
                                                code: code);
                                          })
                                        : CustomTextField(
                                            hint: '+1 123 456 7890',
                                            onChanged: (v) =>
                                                authNotifier.number = v.trim(),
                                            dimHint: true,
                                            onSubmitted: (v) => authNotifier
                                                .onSendCodePressed(),
                                            borderColor: style.borderColor,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CtaButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          authNotifier.onSendCodePressed();
                        },
                        text: 'VERIFY',
                      )
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CodeInput extends StatelessWidget {
  final Function(String) onSumbitted;

  const _CodeInput({required this.onSumbitted});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final style = AppTheming.of(context).style;
    return PinCodeTextField(
      appContext: context,
      beforeTextPaste: (c) => false,
      length: 6,
      onCompleted: (code) {
        onSumbitted(code);
      },
      autoFocus: false,
      onChanged: (s) {},
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      keyboardType: TextInputType.number,
      cursorColor: style.accentColor,
      pinTheme: PinTheme(
        selectedColor: style.accentColor,
        inactiveColor: style.accentColor.withOpacity(0.3),
        activeColor: style.accentColor,
        fieldHeight: 56,
        borderWidth: 1,
        fieldWidth: (size.width * 0.7) / 6,
        shape: PinCodeFieldShape.underline,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
