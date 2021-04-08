import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/views/login.dart';
import 'package:anonymous_chat/views/name_generator_screen.dart';

import 'package:flutter/cupertino.dart';

class AppNavigator extends StatelessWidget {
  final bool isAuthenticated;
  final bool isNicknamed;

  const AppNavigator({
    required this.isAuthenticated,
    required this.isNicknamed,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (c) {
            switch (settings.name) {
              default:
                return isAuthenticated
                    ? isNicknamed
                        ? Home()
                        : NameGenerator()
                    : LoginScreen();
            }
          },
        );
      },
    );
  }
}
