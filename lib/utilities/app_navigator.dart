import 'package:anonymous_chat/views/login_screen.dart';
import 'package:anonymous_chat/views/splash_screen.dart';

import 'package:flutter/cupertino.dart';

class AppNavigator extends StatelessWidget {
  final bool isAuthenticated;

  const AppNavigator({
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [
        HeroController(),
      ],
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (c) {
            switch (settings.name) {
              default:
                return isAuthenticated ? UserInfoInitializing() : LoginScreen();
            }
          },
        );
      },
    );
  }
}
