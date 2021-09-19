import 'package:anonymous_chat/providers/initial_settings_providers.dart';
import 'package:anonymous_chat/utilities/app_navigator.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/views/onboarding.dart';
import 'package:anonymous_chat/widgets/error_notification.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(
        builder: (context, watch, _) {
          return watch(appInitialzationProvider).when(
            data: (bool isAuthenticated) {
              return AppTheme(
                child: Stack(
                  children: [
                    AppNavigator(isAuthenticated: isAuthenticated),
                    NotificationWidget(),
                    LoadingWidget(),
                  ],
                ),
              );
            },
            loading: () => Container(
              color: Colors.white,
              child: Center(
                child: SpinKitThreeBounce(
                  size: 25,
                  color: Color(0xff008080),
                ),
              ),
            ),
            error: (e, s) {
              Future.delayed(Duration(seconds: 2))
                  .then((_) => context.refresh(appInitialzationProvider));

              return Container(
                color: Colors.white,
                child: Center(
                  child: SpinKitThreeBounce(
                    size: 25,
                    color: Color(0xff008080),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserInfoInitializing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProviderListener<bool?>(
        provider: userInfoStateProvider,
        onChange: (context, bool? isProfileComplete) {
          if (isProfileComplete != null) {
            Widget destination =
                isProfileComplete ? Home() : OnboardingScreen();

            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => destination),
                (route) => false);
          }
        },
        child: Container(
          color: Colors.white,
          child: Center(
            child: SpinKitThreeBounce(
              size: 25,
              color: Color(0xff008080),
            ),
          ),
        ),
      ),
    );
  }
}
